#!/usr/bin/env python3
"""A/B two Lamina arms (usually two images of the same fork, e.g. current prod vs a new build), one at a time on the GPU.

    python3 bench_vs_fork.py --repo-a ~/lamina --name-a lamina-old --image-a lamina:main \
                             --repo-b ~/lamina --name-b lamina-new --image-b lamina:watch-<sha>
    python3 bench_vs_fork.py --profile dual,single-3090   # sweep both machine setups, one table each
    python3 bench_vs_fork.py --rounds 1 --runs 3          # quick pass
    python3 bench_vs_fork.py --yes --restart              # no prompt, bring prod back at the end

Each arm is started by its own repo's launch script (the fork's engine takes different flags, configs and
env than upstream's, so there is no shared docker invocation): run-lamina.sh takes [container] [gpus] and
honours PORT, CONF and IMAGE, so an image-vs-image sweep points both arms at ~/lamina with different
--image-X (the old strata arm still works through its run-unsloth.sh).  An API key in ~/strata-data/api-key
(which the fork's script creates and requires) is passed to bench clients that need one.

The bench runner comes from the arm's own image: a new-layout image runs
`docker exec <arm> /opt/lamina/build/lamina-server --bench-url http://127.0.0.1:8080` inside its container
(its LAMINA_API_KEY is already in the exec's env), an older image runs its own tools/lamina_bench.py with
its .venv there instead.  Both write a results.json under ~/strata-data/bench-staging (= /data/bench-staging
in the container), which the sweep moves to the arm's results folder; the table and the printed
`lamina-server --bench-compare` command read that one schema.

Profiles pick the cards (the run-lamina.sh pairing: "all" gets each repo's dual config, anything else the
single one): dual = both cards, single-3090 / single-4090 = that card alone.  Each profile runs the full A/B
on its own before moving to the next, and prints its own table.

For each round it alternates the arms (order swapped next round, like tools/ab_engine.py): start the arm,
wait for /health, run the image's own bench against it, stop it, wait for the GPU to go idle.  The fork's
learned expert profile (expert_profile_save) is deleted before every arm so no arm starts warm.  Any running
lamina container (including the one serving this agent) is stopped for the sweep; --restart brings prod back
with the --restart-script at the end.

Prints a per-metric table (medians over rounds, decode tok/s, TTFT, 4K/16K prefill, agent cache hit, a
geometric-mean score) and the exact `lamina-server --bench-compare` command for the per-test detail.
Results stay under ~/strata-data/bench/ab-fork/<date>/<profile>/<arm>/round<N>/ . An explicit --image-A is
exported as IMAGE to that arm's launch script (the arm runs exactly the checked image); --image-B works the
same way, but the fork's script names its image by container name, so tagging the build is enough there.
Lives in dotfiles/lamina (~/lamina/bench_vs_fork.py symlinks here). Docker access is needed: run with sudo
if your user cannot talk to docker.  Standard library only; run this on the host, not inside a container.
"""
from __future__ import annotations

import argparse
import datetime
import json
import shlex
import shutil
import math
import os
import pwd
import statistics
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


def real_home() -> Path:
    """The invoking user's home, not root's, so the paths below keep working under sudo."""
    if u := os.environ.get("SUDO_USER"):
        return Path(pwd.getpwnam(u).pw_dir)
    return Path.home()


ROOT = Path(__file__).resolve().parent
HOME = real_home()
KEY_FILE = HOME / "strata-data" / "api-key"
# the fork's config sets expert_profile_save, so its arm gets warmer every run from this file; the sweep
# deletes it before every arm so neither arm starts from learned expert routing (upstream never writes it)
LEARNED_PROFILE = HOME / "strata-data" / "unsloth-ud-iq4_xs-v31-learned.bin"   # the v31 configs' expert_profile_save (= /data/... in the container)
LEARNED_BAK = LEARNED_PROFILE.with_suffix(".sweep-bak")
# both bench runners write their report under this /data folder of the arm's container; the sweep moves
# the report out of it into the arm's results folder (it must sit under the host's ~/strata-data to be
# the same folder seen from inside)
STAGING = HOME / "strata-data" / "bench-staging"
CTR_PORT = 8080   # the server's port inside every arm's container (run-lamina.sh maps its host port here)
# profile -> docker --gpus value passed to each arm's run-unsloth.sh ("all" picks each repo's dual config)
PROFILES = {"dual": "all", "single-3090": "device=1", "single-4090": "device=0"}
BENCH_PORT = 18033
PROD_CONTAINER = "lamina"  # llama-swap's prod container; stopped for the sweep even when it is not an arm
STOP_TIMEOUT = 90          # the fork's own script asks docker for 120; give it room to shut down cleanly
METRICS = [                # (key, label, higher-is-better)
    ("decode", "chat decode tok/s", True),
    ("chat_ttft", "chat TTFT s", False),
    ("pre_4K", "4K prefill tok/s", True),
    ("ttft_4K", "4K TTFT s", False),
    ("pre_16K", "16K prefill tok/s", True),
    ("ttft_16K", "16K TTFT s", False),
    ("agent_hit", "agent cache hit %", True),
    ("score", "score (geo-mean)", True),
]


def docker(args: list[str], check: bool = True) -> subprocess.CompletedProcess:
    cmd = ["docker"] + args
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
    except FileNotFoundError:
        sys.exit("docker not found")
    except subprocess.SubprocessError as e:
        sys.exit(f"docker {' '.join(args)}: {e}")
    if check and p.returncode != 0:
        err = (p.stderr or "").strip()
        if "permission denied" in err.lower():
            sys.exit("no docker access - run this script with sudo")
        sys.exit(f"docker {' '.join(args)} failed ({p.returncode}): {err}")
    return p


def http_json(url: str, timeout: float = 5):
    try:
        with urllib.request.urlopen(url, timeout=timeout) as r:
            return json.loads(r.read().decode("utf-8", "replace"))
    except (urllib.error.URLError, OSError, ValueError):
        return None


def stop_containers(names: list[str]) -> None:
    for n in names:
        if docker(["ps", "-aq", "--filter", f"name=^{n}$"]).stdout.strip():
            print(f"  stopping {n}")
            docker(["stop", "-t", str(STOP_TIMEOUT), n], check=False)
    # --rm containers linger briefly after stop; force-remove whatever is left so the name is free
    for n in names:
        for _ in range(60):
            if not docker(["ps", "-aq", "--filter", f"name=^{n}$"]).stdout.strip():
                break
            docker(["rm", "-f", n], check=False)
            time.sleep(2)


def wait_gpu_idle(timeout: float = 120, gpu: str | None = None) -> None:
    """Wait until no CUDA compute processes remain. With `gpu` (an nvidia-smi index), only that
    card is checked - other cards may host unrelated work (a game on the 4090 must not block a
    3090-only sweep; note games DO show up in --query-compute-apps)."""
    sel = ["--id", gpu] if gpu else []
    t0 = time.time()
    while time.time() - t0 < timeout:
        try:
            p = subprocess.run(["nvidia-smi", *sel, "--query-compute-apps=pid", "--format=csv,noheader"],
                               capture_output=True, text=True, timeout=20)
            if not p.stdout.strip():
                return
        except (FileNotFoundError, subprocess.SubprocessError):
            return          # no nvidia-smi here; hope for the best
        time.sleep(3)


def start_arm(script: Path, name: str, gpus: str, port: int, log_path: Path,
              detach: bool = False, extra_env: dict[str, str] | None = None) -> subprocess.Popen:
    """Run the arm's own run-unsloth*.sh in the background (its docker run is foreground); it does its
    own docker rm --force, so a leftover container of that name is taken out first.  detach=True keeps
    the container up after this process exits (used for --restart, where nothing polls the runner)."""
    env = dict(os.environ, PORT=str(port), **(extra_env or {}))
    log = log_path.open("w", encoding="utf-8")
    return subprocess.Popen(["bash", str(script), name, gpus], cwd=str(script.parent), env=env,
                            stdout=log, stderr=subprocess.STDOUT, start_new_session=detach)


def wait_ready(runner: subprocess.Popen, port: int, timeout: float) -> bool:
    """Poll /health until loaded.  The container appears only a moment after docker run starts, so
       liveness comes from the runner process (its docker run is foreground: it ends when the container
       ends); polling docker ps here races the container into existing."""
    t0, last = time.time(), 0
    while time.time() - t0 < timeout:
        h = http_json(f"http://127.0.0.1:{port}/health")
        if isinstance(h, dict) and h.get("loaded"):
            return True
        if runner.poll() is not None:
            print(f"  the container ended during load (exit {runner.returncode}) - see run-unsloth.log",
                  file=sys.stderr)
            return False
        if time.time() - last > 30:
            print(f"  loading ... {int(time.time() - t0)} s")
            last = time.time()
        time.sleep(3)
    return False


def bench_style(image: str) -> str | None:
    """How the arm's image can be benched from inside: "new" when its lamina-server speaks --bench-url,
    "old" when it carries tools/lamina_bench.py and the .venv to run it, else None. The probe run needs no
    GPU; the flat build/ layout of a new image has no tools/, so old wins when both could match."""
    p = docker(["run", "--rm", "--entrypoint", "sh", image, "-c",
                "if [ -x /opt/lamina/.venv/bin/python ] && [ -f /opt/lamina/tools/lamina_bench.py ]; then echo old; "
                "elif grep -aq -- --bench-url /opt/lamina/build/lamina-server; then echo new; else echo none; fi"],
               check=False)
    return {"old": "old", "new": "new"}.get(p.stdout.strip())


def run_bench(style: str, container: str, out_dir: Path, stage_rel: str, runs: int, clients: int | None,
              ready_timeout: float, extra: list[str] | None) -> Path | None:
    """Run the arm's own bench inside its container against http://127.0.0.1:8080 and move the report
    folder into out_dir; the newest results.json there wins, as before. The report is staged under the
    container's /data (the host's ~/strata-data), so it leaves the container with no docker cp; a new-style
    report's dir is written by root, and cam can still move it (the parent is cam's)."""
    stage = STAGING / stage_rel
    stage.mkdir(parents=True, exist_ok=True)
    if style == "new":   # the key is already in the container's env (LAMINA_API_KEY), where the exec inherits it
        cmd = ["docker", "exec", container, "/opt/lamina/build/lamina-server",
               "--bench-url", f"http://127.0.0.1:{CTR_PORT}", "--bench-runs", str(runs),
               "--bench-out", f"/data/{stage.relative_to(STAGING.parent)}"]
        if clients:
            cmd += ["--bench-clients", str(clients)]
    else:
        cmd = ["docker", "exec", "-w", "/opt/lamina", container, ".venv/bin/python", "tools/lamina_bench.py",
               "--url", f"http://127.0.0.1:{CTR_PORT}", "--runs", str(runs),
               "--out", f"/data/{stage.relative_to(STAGING.parent)}", "--ready-timeout", str(ready_timeout)]
        if KEY_FILE.exists() and KEY_FILE.read_text().strip():       # the fork's server always has a key
            cmd += ["--api-key", KEY_FILE.read_text().strip()]
        if clients:
            cmd += ["--clients", str(clients)]
    if extra:
        cmd += list(extra)
    if subprocess.run(cmd, cwd=str(ROOT)).returncode != 0:
        return None
    dirs = sorted((d for d in stage.iterdir() if (d / "results.json").exists()),
                  key=lambda d: d.stat().st_mtime)
    if not dirs:
        return None
    dest = out_dir / dirs[-1].name
    shutil.move(str(dirs[-1]), str(dest))
    return dest


def med(vals: list[float]) -> float | None:
    return round(statistics.median(vals), 1) if vals else None


def summarize(results_json: Path) -> dict:
    """Per-run stats from one results.json, in the shape of bench-split.py's table."""
    d = json.loads((results_json / "results.json").read_text(encoding="utf-8"))
    r = d.get("results") or {}
    out: dict[str, float | None] = {}
    chat = r.get("chat") or {}
    out["decode"] = (chat.get("decode_tps") or {}).get("median")
    out["chat_ttft"] = (chat.get("ttft_s") or {}).get("median")
    prompts = r.get("prompts") or {}
    for tag in prompts:
        p = prompts.get(tag) or {}
        reqs = [q for q in p.get("requests", []) if q.get("ok")]
        out[f"pre_{tag}"] = med([q["prompt_tps"] for q in reqs if q.get("prompt_tps")])
        out[f"ttft_{tag}"] = med([q["ttft_s"] for q in reqs if q.get("ttft_s")])
    agent = r.get("agent") or {}
    hit = agent.get("hit_pct")
    if isinstance(hit, dict):
        hit = hit.get("median")
    out["agent_hit"] = hit
    scores = [out[k] for k in ("decode", "pre_4K", "pre_16K") if out.get(k)]
    out["score"] = round(math.prod(scores) ** (1 / len(scores)), 1) if len(scores) == 3 else None
    return out


def sweep(profile: str, gpus: str, arms: dict[str, dict], rounds: int, runs: int,
          clients: int | None, port: int, ready_timeout: float, out_root: Path,
          bench_extra: list[str] | None = None,
          learned_profile: Path | None = None) -> dict[str, Path]:
    """Run the alternating A/B rounds for one profile; print its table; return the latest results folder per arm."""
    lp = learned_profile or LEARNED_PROFILE
    lpbak = lp.with_suffix(".sweep-bak")
    print(f"\n### profile {profile}: --gpus {gpus}")
    samples: dict[str, dict[str, list[float]]] = {k: {} for k in arms}
    latest: dict[str, Path] = {}
    order = list(arms)
    for rnd in range(1, rounds + 1):
        if rnd % 2 == 0:
            order = order[::-1]           # alternate arms so drift hits both equally
        for k in order:
            arm = arms[k]
            print(f"\n=== {profile} round {rnd} arm {k} ({arm['name']}) ===")
            stop_containers([PROD_CONTAINER] + [a["name"] for a in arms.values()])
            wait_gpu_idle()
            if lp.exists():                         # cold expert routing for every arm, every round
                if not lpbak.exists():       # the sweep's first arm: keep the original to restore at the end
                    shutil.copy2(lp, lpbak)
                lp.unlink()
                print("  cleared the learned expert profile (original kept for restore at the end)")
            arm_dir = out_root / profile / k / f"round{rnd}"
            arm_dir.mkdir(parents=True, exist_ok=True)
            try:                                   # whatever happens, this arm's container must not
                env = dict(IMAGE=arm["image"]) if arm["image_set"] else {}
                if arm.get("conf"):
                    env["CONF"] = arm["conf"]
                runner = start_arm(arm["script"], arm["name"], gpus, port, arm_dir / "run-unsloth.log",
                                   extra_env=env)
                res = None                         # outlive the load and the bench, or it squats the port
                if wait_ready(runner, port, ready_timeout):
                    res = run_bench(arm["bench"], arm["name"], arm_dir,
                                    f"{out_root.name}/{profile}-{k}-round{rnd}", runs, clients,
                                    ready_timeout, bench_extra)
                    if not res:
                        print(f"  arm {k} bench failed; skipping this round", file=sys.stderr)
                else:
                    print(f"  arm {k} did not come up; skipping this round", file=sys.stderr)
            finally:
                stop_containers([arm["name"]])
            if res:
                latest[k] = res
                for key, val in summarize(res).items():
                    if val is not None:
                        samples[k].setdefault(key, []).append(val)

    if len(latest) == 2:
        cols = (20, 22, 24, 10)

        def trow(a: str, b: str, c: str, d: str) -> str:
            wa, wb, wc, wd = cols
            return f"{a:<{wa}}{b:<{wb}}{c:<{wc}}{d:>{wd}}"

        pad = " " * (len(profile) + 2)
        print("\n" + f"{profile}  " + trow("metric", "A " + arms["A"]["name"],
                                           "B " + arms["B"]["name"], "B vs A"))
        print("-" * (len(profile) + 2 + sum(cols)))
        for key, label, more in METRICS:
            va, vb = med(samples["A"].get(key, [])), med(samples["B"].get(key, []))
            if va is None or vb is None:
                print(pad + trow(label, "-", "-", "-"))
                continue
            delta = (vb - va) / va * 100
            good = (delta > 0) == more
            print(pad + trow(label, str(va), str(vb), f"{delta:+.1f}%") + ("" if good else "  <"))
        def in_ctr(p: Path) -> str:   # reports live under ~/strata-data, which run-lamina.sh mounts at /data
            return "/data" + str(p)[len(str(HOME / "strata-data")):]
        print(f"per-test detail: docker run --rm -v {HOME / 'strata-data'}:/data --entrypoint "
              f"/opt/lamina/build/lamina-server {arms['B']['image']} --bench-compare {in_ctr(latest['B'])} "
              f"{in_ctr(latest['A'])}")
    return latest


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0], formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo-a", type=Path, default=HOME / "strata",
                    help="baseline checkout, started by its run-unsloth.sh (default ~/strata)")
    ap.add_argument("--repo-b", type=Path, default=HOME / "lamina",
                    help="candidate checkout, started by its run-lamina.sh (default ~/lamina)")
    ap.add_argument("--script-a", default="run-unsloth.sh",
                    help="arm A's launch script in its repo (default run-unsloth.sh; e.g. run-unsloth-2.sh)")
    ap.add_argument("--script-b", default="run-lamina.sh",
                    help="arm B's launch script in its repo (default run-lamina.sh; e.g. run-unsloth.sh)")
    ap.add_argument("--name-a", help="arm A's container name (default the repo folder name)")
    ap.add_argument("--name-b", help="arm B's container name (default the repo folder name)")
    ap.add_argument("--image-a", help="arm A's image for the exists-check (default --name-a; set when the "
                                      "launch script runs a fixed image that is not the container's name)")
    ap.add_argument("--image-b", help="arm B's image for the exists-check (default --name-b)")
    ap.add_argument("--conf-a", help="arm A's CONF (a config name in the repo's configs/, exported to its "
                                     "launch script; default the script's own default)")
    ap.add_argument("--conf-b", help="arm B's CONF, same rules")
    ap.add_argument("--learned-profile", type=Path,
                    help="the engine's expert_profile_save file, deleted before every arm so each starts "
                         "with cold expert routing (default: the v31 configs' save file)")
    ap.add_argument("--bench-extra", default="",
                    help="extra args appended to the image's bench command, one shell-split string "
                         "(new-style takes --bench-long --bench-think --bench-...; old-style --long --think ...)")
    ap.add_argument("--profile", default="dual", metavar="NAMES",
                    help=f"comma-separated card setups to sweep (default dual): {', '.join(PROFILES)}")
    ap.add_argument("--rounds", type=int, default=2, help="rounds; arms alternate order per round (default 2)")
    ap.add_argument("--runs", type=int, default=3, help="runs per test inside each bench (default 3)")
    ap.add_argument("--clients", type=int, default=0, metavar="N", help="also bench N concurrent clients (server needs --batch)")
    ap.add_argument("--port", type=int, default=BENCH_PORT, help="host port both arms are exposed on (default 18033)")
    ap.add_argument("--ready-timeout", type=float, default=1800, help="seconds to wait for the model to load")
    ap.add_argument("--out", type=Path, help="results root (default bench/ab-fork/<date>)")
    ap.add_argument("--restart", action="store_true", help="restart the prod server at the end")
    ap.add_argument("--restart-script", type=Path, default=HOME / "lamina" / "run-lamina.sh",
                    help="script for --restart (default ~/lamina/run-lamina.sh, the current prod server)")
    ap.add_argument("--restart-port", type=int, default=18020, help="port for the --restart server (default 18020)")
    ap.add_argument("--yes", action="store_true", help="do not ask before stopping running containers")
    a = ap.parse_args()

    profiles = [p.strip() for p in a.profile.split(",") if p.strip()]
    for p in profiles:
        if p not in PROFILES:
            sys.exit(f"unknown profile '{p}'; pick from {', '.join(PROFILES)}")

    arms = {}
    for k, (repo, script) in (("A", (a.repo_a, a.script_a)), ("B", (a.repo_b, a.script_b))):
        repo = repo.expanduser().resolve()
        script = repo / script
        if not script.is_file():
            sys.exit(f"arm {k}: {script} not found")
        name = (a.name_a if k == "A" else a.name_b) or repo.name
        image = (a.image_a if k == "A" else a.image_b) or name
        if not docker(["image", "ls", "-q", image]).stdout.strip():
            sys.exit(f"arm {k}: image '{image}' not found - build it first (or pass --image-{k.lower()})")
        # an explicit --image-X is also exported as IMAGE to the arm's launch script, so the arm runs
        # exactly the image that was checked (the fork's script names its image by container instead)
        arms[k] = {"repo": repo, "script": script, "name": name, "image": image,
                   "image_set": bool(a.image_a if k == "A" else a.image_b),
                   "conf": a.conf_a if k == "A" else a.conf_b,
                   "bench": bench_style(image)}

    running = docker(["ps", "--format", "{{.Names}}"]).stdout.split()
    touch = sorted({n for n in (PROD_CONTAINER, arms["A"]["name"], arms["B"]["name"]) if n in running})
    print(f"arms: A={arms['A']['name']} ({arms['A']['script'].name}, bench {arms['A']['bench']})  "
          f"B={arms['B']['name']} ({arms['B']['script'].name}, bench {arms['B']['bench']})")
    print(f"profiles={', '.join(profiles)}  rounds={a.rounds} runs={a.runs}  port={a.port}")
    if touch and not a.yes:
        print(f"This will stop: {', '.join(touch)} (the agent container included) and use the GPU alone.")
        input("Enter to continue, Ctrl-C to abort. ")

    stamp = datetime.datetime.now().strftime("%Y-%m-%d-%H%M")     # per sweep, so reruns never mix folders
    out_root = a.out or HOME / "strata-data" / "bench" / "ab-fork" / stamp
    out_root.mkdir(parents=True, exist_ok=True)
    for k in arms:
        if not arms[k]["bench"]:
            sys.exit(f"arm {k}: image '{arms[k]['image']}' offers no bench "
                     "(no lamina-server --bench-url and no tools/lamina_bench.py)")
    lp = a.learned_profile.expanduser().resolve() if a.learned_profile else LEARNED_PROFILE
    lpbak = lp.with_suffix(".sweep-bak")
    ok = False
    try:
        for p in profiles:
            latest = sweep(p, PROFILES[p], arms, a.rounds, a.runs, a.clients or None, a.port,
                           a.ready_timeout, out_root,
                           shlex.split(a.bench_extra) if a.bench_extra else None, learned_profile=lp)
            ok = ok or len(latest) == 2
    finally:
        stop_containers([PROD_CONTAINER, arms["A"]["name"], arms["B"]["name"]])
        if lpbak.exists():   # prod's learned routing back before its next start
            if lp.exists():
                lp.unlink()                          # the last arm rewrote it (root: truncate would fail)
            shutil.copy2(lpbak, lp)
            lpbak.unlink()
            print("  the learned expert profile was restored")
        if a.restart:
            print(f"\nrestarting the prod {PROD_CONTAINER} server via {a.restart_script}")
            start_arm(a.restart_script, PROD_CONTAINER, "all", a.restart_port,
                      out_root / "restart.log", detach=True)
            print(f"  leaving it loading in the background (port {a.restart_port}); see {out_root / 'restart.log'}")

    if not ok:
        sys.exit("\nno profile produced results for both arms; see the output above")
    print(f"\nresults: {out_root}")


if __name__ == "__main__":
    main()
