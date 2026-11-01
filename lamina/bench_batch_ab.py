#!/usr/bin/env python3
"""A/B the batching arm against the plain fork arm, with 2-4 conversations at once, one table.

    python3 bench-batch-ab.py --yes                  # confirm stopping prod, 2 rounds, concurrency 2 and 4
    python3 bench-batch-ab.py --yes --rounds 1 --runs 2   # quick pass (~15 min)
    python3 bench-batch-ab.py --yes --clients 4 --adapt off   # frozen-tier A/B

MAINTENANCE WINDOW. Both arms need BOTH cards to themselves (the model is bigger than any one
GPU), and llama-swap revives the prod container on every client request. So the sweep asks for
--yes, then a watchdog keeps `strata-eddoursul` stopped for its whole duration: clients hitting
the server during the sweep get restart delays or errors, and llama-swap brings prod back on the
first request after it ends. Do not run this while anyone matters is chatting.

Two arms alternating per round (order swapped next round, like bench_vs_fork.py):

  solo   ~/strata-eddoursul/run-unsloth.sh         container strata-eddoursul        (prod config)
  batch  ~/strata-eddoursul/run-unsloth-batch.sh   container strata-eddoursul-batch  (4 slots, --batch-mtp)

Each arm is benched with the fork's own client, tools/lamina_bench.py --clients N (N streaming
requests at once: total tok/s, TTFT and latency percentiles), plus its solo chat decode/TTFT as
the baseline row.  Before measuring, the batch arm is VERIFIED to have carved its slots (the
engine's own "the engine runs N" line); a failed carve aborts the arm with the engine's reason
instead of silently benching a serial server.  The learned expert profile is moved aside for the
sweep (each arm starts cold), deleted between arms, and restored at the end.

--adapt off runs the batch arm with STRATA_BATCH_ADAPT=0 (the pre-phase-9 frozen-tier shape).

Results land under ~/strata-data/bench/batch-ab/<date>/ ; the table prints medians over rounds.
Standard library only; run on the host (docker access needed).
"""
from __future__ import annotations

import argparse
import datetime
import json
import shutil
import statistics
import sys
import threading
import time
import urllib.error
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import bench_vs_fork as bvf          # noqa: E402  the arm/health/docker helpers of the fork-vs-upstream sweep

REPO = Path("/home/cam/strata-eddoursul")
BENCH = REPO / "tools" / "lamina_bench.py"
PROD = "strata-eddoursul"            # llama-swap's container; the sweep keeps it down, llama-swap revives it after
# the fork's config saves what the run learns here (container /data = ~/strata-data)
LEARNED = bvf.HOME / "strata-data" / "unsloth-ud-iq4_xs-learned.bin"
ARMS = {
    "solo":  {"script": REPO / "run-unsloth.sh",       "container": PROD,                 "port": 18031},
    "batch": {"script": REPO / "run-unsloth-batch.sh", "container": "strata-eddoursul-batch", "port": 18032},
}


def prod_running() -> bool:
    return bool(bvf.docker(["ps", "-q", "--filter", f"name=^{PROD}$"]).stdout.strip())


ARM = {"container": None}   # the container the sweep itself started; the solo arm's name IS prod's, and
                            # while it runs llama-swap cannot start prod anyway (docker name conflict)


def watchdog(stop: threading.Event) -> None:
    """llama-swap starts prod on any client request; during the sweep that is a VRAM co-tenant.
    Never stops the arm's own container: the solo arm runs under prod's name (the watchdog once
    mistook it for prod and killed its own sweep)."""
    while not stop.wait(5):
        if ARM["container"] != PROD and prod_running():
            print("  watchdog: llama-swap restarted prod - stopping it again (clients will see delays)", flush=True)
            bvf.docker(["stop", "-t", "5", PROD], check=False)


def engine_slots(port: int) -> int | None:
    """What the server says it runs at a time: /metrics carries live.parallel=N when the engine has
    slots (/status is the per-request dict and never has it; the server prints its "the engine runs
    ..." line only when that differs from the ask, so this endpoint is the truth; why_no_slots()
    shows the engine's reason when it is 0). It needs the API key; unauthenticated reads answer 401
    and would read as "no slots"."""
    req = urllib.request.Request(f"http://127.0.0.1:{port}/metrics",
                                 headers={"Authorization": f"Bearer {bvf.KEY_FILE.read_text().strip()}"})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            m = json.loads(r.read().decode("utf-8", "replace"))
    except (urllib.error.URLError, OSError, ValueError):
        return None                      # unreadable: unknown, NOT "0 slots"
    par = (m.get("live") or {}).get("parallel")
    return int(par) if isinstance(par, (int, float)) else 0


def why_no_slots(since: int = 0) -> None:
    """The engine's own reason for a failed carve - only from lines written after the arm started
    (the log keeps every earlier run, and an old 'does not fit' line once aborted a good sweep)."""
    log = bvf.HOME / "strata-data" / "install" / "eddoursul-unsloth-ud-iq4_xs-batch.log"
    if log.exists():
        with log.open("r", errors="replace") as f:
            f.seek(since)
            for l in f:
                if "not enough VRAM" in l or "does not fit" in l or "could not enable" in l:
                    print(f"    engine: {l.strip()}", flush=True)
                    return


def bench_arm(arm: str, out_root: Path, rnd: int, runs: int, clients: list[int],
              extra_env: dict[str, str] | None, client_prompt: int = 0,
              client_tokens: int = 0, client_warm: int = 0) -> dict:
    """Start the arm, verify it, bench it once per client count, stop it; return this round's metrics."""
    a, name, port = ARMS[arm], ARMS[arm]["container"], ARMS[arm]["port"]
    ARM["container"] = name              # before the GPU is touched: the watchdog must never stop this arm
    bvf.stop_containers([v["container"] for v in ARMS.values()])
    bvf.wait_gpu_idle()
    if LEARNED.exists():
        LEARNED.unlink()            # neither arm warm; the sweep restores the original at the end
    out_dir = out_root / f"r{rnd}" / arm
    out_dir.mkdir(parents=True, exist_ok=True)
    batch_log = bvf.HOME / "strata-data" / "install" / "eddoursul-unsloth-ud-iq4_xs-batch.log"
    log_off = batch_log.stat().st_size if batch_log.exists() else 0
    print(f"  starting {arm} ({name}, port {port}) ...", flush=True)
    runner = bvf.start_arm(a["script"], name, "all", port, out_dir / "run-unsloth.log", extra_env=extra_env)
    res: dict = {}
    try:
        if not bvf.wait_ready(runner, port, timeout=1200):
            print(f"  {arm} did not come up - see {out_dir / 'run-unsloth.log'}", file=sys.stderr)
            return res
        slots = None
        for _ in range(3):               # /status right after load: give the server a moment to answer
            slots = engine_slots(port)
            if slots is not None:
                break
            time.sleep(3)
        if slots is None:
            print("  ABORT: /metrics unreadable on the arm (auth? server down?) - not measuring blind.",
                  file=sys.stderr)
            return {}
        print(f"  {arm}: engine runs {slots} at a time", flush=True)
        if arm == "batch" and slots < 2:
            print("  ABORT: the batch arm has no slots to measure. A VRAM co-tenant (prod restarted "
                  "mid-load) is the usual cause.", file=sys.stderr)
            why_no_slots(log_off)
            return {}
        for c in clients:
            extra = (["--client-prompt", str(client_prompt)] if client_prompt else []) \
                    + (["--client-tokens", str(client_tokens)] if client_tokens else []) \
                    + (["--client-warm", str(client_warm)] if client_warm else [])
            d = bvf.run_bench(out_dir / f"c{c}", port, runs=runs, clients=c, ready_timeout=600, bench_script=BENCH,
                              extra=extra or None)
            if d is None:
                print(f"  {arm} c{c}: bench failed", file=sys.stderr)
                continue
            r = json.loads((d / "results.json").read_text())["results"]
            cl, chat = r.get("clients") or {}, r.get("chat") or {}
            res[f"c{c}"] = {"total_tps": (cl.get("total_tps") or {}).get("median"),
                            "ttft_p50": cl.get("ttft_p50_s"), "ttft_p95": cl.get("ttft_p95_s"),
                            "errors": cl.get("errors") or 0}
            res["chat"] = {"decode": (chat.get("decode_tps") or {}).get("median"),
                           "ttft": (chat.get("ttft_s") or {}).get("median")}
        # the batch window samples (BSTAT: rows per window is the verify-cap diagnostic) live only in
        # the running server's /metrics - snapshot them to the results dir before the arm stops
        try:
            req = urllib.request.Request(f"http://127.0.0.1:{port}/metrics",
                                         headers={"Authorization": f"Bearer {bvf.KEY_FILE.read_text().strip()}"})
            (out_dir / "metrics.json").write_bytes(urllib.request.urlopen(req, timeout=10).read())
        except (urllib.error.URLError, OSError):
            pass
    finally:
        bvf.stop_containers([name])
    return res


def med(rounds: list[dict], section: str, key: str):
    vals = [r[section][key] for r in rounds if section in r and r[section].get(key) is not None]
    return round(statistics.median(vals), 1) if vals else None


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--yes", action="store_true", help="confirm: stop the prod container for the sweep (clients will error)")
    ap.add_argument("--rounds", type=int, default=2, help="A/B rounds (medians over them; default 2)")
    ap.add_argument("--runs", type=int, default=3, help="runs per lamina_bench test (default 3)")
    ap.add_argument("--clients", default="2,4", help="comma list of concurrency levels (default 2,4)")
    ap.add_argument("--client-prompt", type=int, default=0, metavar="TOKENS",
                    help="give each concurrent request a unique prompt of about TOKENS tokens (the context "
                         "A/B; default 0: the bare instruction, a few dozen tokens)")
    ap.add_argument("--client-tokens", type=int, default=0, metavar="N",
                    help="new tokens each concurrent request generates (default 128; the real traffic "
                         "median is ~400, p90 ~1.7K)")
    ap.add_argument("--client-warm", type=int, default=0, metavar="TOKENS",
                    help="warm each client's conversation cache with a ~TOKENS-token prompt (untimed), "
                         "then measure short unique tails: the shape of cached agent sessions")
    ap.add_argument("--arms", default="solo,batch",
                    help="comma list of arms to run (default both; `--arms batch` alone is the quick "
                         "telemetry probe: one arm, one round, no A/B table comparison)")
    ap.add_argument("--adapt", default="on", choices=["on", "off"],
                    help="batch arm's STRATA_BATCH_ADAPT (off = the frozen-tier shape; default on)")
    a = ap.parse_args()
    if not a.yes:
        print("This sweep needs BOTH cards to itself: it stops the prod container and a watchdog keeps it\n"
              "stopped for the whole run (llama-swap would otherwise revive it on the next client request,\n"
              "and two engines on one GPU means OOM - which is exactly the failure this check prevents).\n"
              "Clients hitting the server meanwhile get delays/errors; llama-swap restores prod on the first\n"
              "request after the sweep. Pick a quiet window and re-run with --yes.", file=sys.stderr)
        return 2
    clients = [int(x) for x in a.clients.split(",") if x.strip()]
    arms = [x for x in ("solo", "batch") if x in {t.strip() for t in a.arms.split(",") if t.strip()}]
    if not arms:
        print("--arms must name at least one of solo,batch", file=sys.stderr)
        return 2
    out_root = bvf.HOME / "strata-data" / "bench" / "batch-ab" / datetime.date.today().isoformat()
    out_root.mkdir(parents=True, exist_ok=True)
    batch_env = None if a.adapt == "on" else {"STRATA_BATCH_ADAPT": "0"}

    backup = None
    if LEARNED.exists():
        backup = LEARNED.with_suffix(".bench-bak")
        shutil.copy2(LEARNED, backup)
    if prod_running():
        print(f"  stopping {PROD} for the sweep (clients will error until it ends)")
        bvf.stop_containers([PROD])
    wd_stop = threading.Event()
    threading.Thread(target=watchdog, args=(wd_stop,), daemon=True).start()
    done: dict[str, list[dict]] = {}
    try:
        for rnd in range(a.rounds):
            for arm in [x for x in (["solo", "batch"] if rnd % 2 == 0 else ["batch", "solo"]) if x in arms]:
                print(f"round {rnd} [{arm}]", flush=True)
                t0 = time.time()
                done.setdefault(arm, []).append(
                    bench_arm(arm, out_root, rnd, a.runs, clients, batch_env if arm == "batch" else None,
                              a.client_prompt, a.client_tokens, a.client_warm))
                print(f"  {arm} done in {time.time() - t0:.0f} s", flush=True)
    finally:
        wd_stop.set()
        bvf.stop_containers([v["container"] for v in ARMS.values()])
        if backup and backup.exists():
            if LEARNED.exists():
                LEARNED.unlink()         # the container rewrote it as root: copy2's truncate would fail
            shutil.copy2(backup, LEARNED)     # prod's learned ranking back where it belongs
            backup.unlink()
            print("  (the learned expert profile was restored; prod re-learns from there)")

    w = 16
    print()
    print(f"batch A/B on this rig (medians of {a.rounds} round{'s' if a.rounds > 1 else ''}; "
          f"solo = prod config, batch = 4 slots + --batch-mtp, tiers "
          f"{'FROZEN' if a.adapt == 'off' else 'rhythmic'})")
    print(f"{'':24s}{'solo':>{w}s}{'batch':>{w}s}{'gain':>9s}")
    for label, section, key, lower_better in [
            ("chat decode tok/s", "chat", "decode", False), ("chat TTFT s", "chat", "ttft", True)]:
        s, b = med(done.get("solo", []), section, key), med(done.get("batch", []), section, key)
        gain = f"{(b / s - 1) * 100:+.0f}%" if s and b else ""
        gain = f"{(s / b - 1) * 100:+.0f}%" if lower_better and s and b else gain
        print(f"{label:24s}{str(s):>{w}s}{str(b):>{w}s}{gain:>9s}")
    for c in clients:
        s, b = med(done.get("solo", []), f"c{c}", "total_tps"), med(done.get("batch", []), f"c{c}", "total_tps")
        gain = f"{(b / s - 1) * 100:+.0f}%" if s and b else ""
        print(f"{f'{c}x total tok/s':24s}{str(s):>{w}s}{str(b):>{w}s}{gain:>9s}")
        ts, tb = med(done.get("solo", []), f"c{c}", "ttft_p50"), med(done.get("batch", []), f"c{c}", "ttft_p50")
        ps, pb = med(done.get("solo", []), f"c{c}", "ttft_p95"), med(done.get("batch", []), f"c{c}", "ttft_p95")
        print(f"{f'{c}x TTFT p50/p95 s':24s}{f'{ts} / {ps}':>{w}s}{f'{tb} / {pb}':>{w}s}")
    errs = {arm: sum(r.get(f"c{c}", {}).get("errors", 0) for r in rs) for arm, rs in done.items()}
    print(f"\nerrors: {errs}   results: {out_root}")
    print("prod comes back on the next client request (llama-swap).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
