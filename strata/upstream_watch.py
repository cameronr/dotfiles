#!/usr/bin/env python3
"""Nightly upstream watch: pull upstream, rebuild the fork, A/B them, log a time series, render a report.

    python3 upstream_watch.py                    # gated nightly run (a systemd timer fires this at 01:00)
    python3 upstream_watch.py --force            # ignore the no-change gate and the GPU-busy guard
    python3 upstream_watch.py --rounds 1 --runs 3 --profile dual

It pulls ~/strata (upstream main) and its published image ghcr.io/niko1221/strata:<version>-<flavor>, rebuilds
the fork's image (~/strata-eddoursul is never pulled or modified), runs bench_vs_fork.py as arm A=upstream vs
arm B=fork, appends a row to ~/strata-data/bench/series.jsonl, rewrites ~/strata-results.md from the whole
series, and prunes old watch-* fork images. state.json records the last good (upstream_sha, version, fork_sha);
when tonight matches it the run is a no-op unless --force. The wrapper has no scheduling of its own.

Standard library only; run on the host (docker + nvidia-smi access needed).
"""
from __future__ import annotations

import argparse
import datetime
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import NoReturn

sys.path.insert(0, str(Path(__file__).resolve().parent))
import bench_vs_fork as bvf

HOME = Path.home()
STRATA = HOME / "strata"                    # upstream checkout, tracks Niko1221/Strata main
FORK = HOME / "strata-eddoursul"            # fork checkout; never pulled or modified
SCRIPTS = Path(__file__).resolve().parent
DATA = HOME / "strata-data" / "bench"
SERIES = DATA / "series.jsonl"
STATE = DATA / "state.json"
MD = HOME / "strata-results.md"
TAG_RE = re.compile(r"^v([0-9]+(?:\.[0-9]+)+)$")

ARGS: argparse.Namespace                     # parsed CLI, set by main(); stages read it


def iso() -> str:
    return datetime.datetime.now().isoformat(timespec="minutes")


def fail(stage: str, detail: str) -> NoReturn:
    """Record a failure row, print it, exit 1. state.json is only ever written on full success."""
    DATA.mkdir(parents=True, exist_ok=True)
    with SERIES.open("a", encoding="utf-8") as f:
        f.write(json.dumps({"date": iso(), "kind": "fail", "stage": stage, "detail": detail}) + "\n")
    print(f"FAIL {stage}: {detail}", file=sys.stderr)
    sys.exit(1)


def git(repo: Path, *args: str) -> str:
    p = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True)
    return p.stdout.strip() if p.returncode == 0 else ""


def run(cmd: list[str], timeout: float) -> int:
    """Run with inherited stdio; any docker/timeout error collapses to a nonzero code the stage fails on."""
    try:
        return subprocess.run(cmd, timeout=timeout).returncode
    except (FileNotFoundError, subprocess.SubprocessError):
        return 1


def guard_gpu() -> None:
    if ARGS.force:
        return
    try:
        p = subprocess.run(["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"],
                           capture_output=True, text=True, timeout=20)
    except (FileNotFoundError, subprocess.SubprocessError):
        return                                   # no nvidia-smi to read; nothing to contend with
    for line in p.stdout.splitlines():
        line = line.strip()
        if line.isdigit() and int(line) >= ARGS.gpu_busy_pct:
            print("GPU busy; skipping this night")
            sys.exit(0)                          # skip, not a failure


def pull_upstream() -> tuple[str, str]:
    if run(["git", "-C", str(STRATA), "pull", "--ff-only"], 300) != 0:
        fail("pull_upstream", "git pull --ff-only failed")
    sha = git(STRATA, "rev-parse", "HEAD")
    if not sha:
        fail("pull_upstream", "no HEAD")
    version = next((m.group(1) for line in git(STRATA, "tag", "--sort=-creatordate").splitlines()
                    if (m := TAG_RE.match(line.strip()))), "")
    if not version:
        fail("pull_upstream", "no vN.N tag")
    return sha, version


def fork_info() -> tuple[str, bool]:
    sha = git(FORK, "rev-parse", "HEAD")
    if not sha:
        fail("fork_info", "no HEAD")
    return sha, bool(git(FORK, "status", "--porcelain"))


def gate(upstream_sha: str, version: str, fork_sha: str) -> None:
    if ARGS.force:
        return
    cur = {"upstream_sha": upstream_sha, "version": version, "fork_sha": fork_sha}
    if STATE.exists():
        try:
            prev = json.loads(STATE.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            prev = None
        if prev == cur:
            print("no upstream or fork change; nothing to do")
            sys.exit(0)


def pull_image(version: str, flavor: str) -> str:
    image = f"ghcr.io/niko1221/strata:{version}-{flavor}"
    if run(["docker", "pull", image], 3600) != 0:
        fail("pull_image", image)
    return image


def build_fork(fork_sha: str, arch: str) -> str:
    tag = f"strata-eddoursul:watch-{fork_sha[:7]}"
    if run(["docker", "build", "-t", tag, "--build-arg", f"CUDA_ARCHITECTURES={arch}", str(FORK)], 3 * 3600) != 0:
        fail("build_fork", tag)
    # the fork's launch script runs the image named after its container (strata-eddoursul), so :latest
    # is what the arm actually runs; the watch-<sha> tag is what prune() keeps history by.
    if run(["docker", "tag", tag, "strata-eddoursul:latest"], 60) != 0:
        fail("build_fork", "strata-eddoursul:latest")
    return tag


def sweep(profile: str, rounds: int, runs: int, image_a: str) -> Path:
    out_root = DATA / "ab-fork" / datetime.datetime.now().strftime("%Y-%m-%d-%H%M")
    cmd = [sys.executable, str(SCRIPTS / "bench_vs_fork.py"), "--profile", profile,
           "--rounds", str(rounds), "--runs", str(runs), "--yes",
           "--image-a", image_a, "--image-b", "strata-eddoursul", "--out", str(out_root)]
    if bvf.docker(["ps", "-q", "--filter", "name=^strata$"]).stdout.strip():
        cmd.append("--restart")
    # env is inherited unmodified on purpose: never export IMAGE here, or bench_vs_fork's --restart
    # would inherit it and restart the production server on the wrong image.
    if subprocess.run(cmd, cwd=str(SCRIPTS)).returncode != 0:
        fail("sweep", str(out_root))
    return out_root


def collect(out_root: Path, profile: str) -> tuple[dict, dict, float]:
    arms: dict[str, dict] = {}
    for k in ("A", "B"):
        samples: dict[str, list[float]] = {}
        for d in sorted(Path(p).parent for p in out_root.glob(f"{profile}/{k}/round*/*/results.json")):
            for key, val in bvf.summarize(d).items():
                if val is not None:
                    samples.setdefault(key, []).append(val)
        arms[k] = {key: bvf.med(samples.get(key, [])) for key, _, _ in bvf.METRICS}
    a, b = arms["A"], arms["B"]
    if not a.get("score") or not b.get("score"):
        fail("collect", f"missing score: A={a.get('score')} B={b.get('score')}")
    return a, b, b["score"] / a["score"]


def record(profile: str, fork_sha: str, fork_dirty: bool, upstream_sha: str, version: str,
           image_a: str, out_root: Path, a: dict, b: dict, ratio: float) -> None:
    DATA.mkdir(parents=True, exist_ok=True)
    row = {"date": iso(), "kind": "run", "profile": profile, "fork_sha": fork_sha,
           "fork_dirty": fork_dirty, "upstream_sha": upstream_sha, "version": version,
           "image_a": image_a, "out": str(out_root), "A": a, "B": b, "ratio": round(ratio, 4)}
    with SERIES.open("a", encoding="utf-8") as f:
        f.write(json.dumps(row) + "\n")
    STATE.write_text(json.dumps({"upstream_sha": upstream_sha, "version": version, "fork_sha": fork_sha}),
                     encoding="utf-8")


def load_rows() -> list[dict]:
    if not SERIES.exists():
        return []
    rows = []
    for line in SERIES.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            rows.append(json.loads(line))
        except json.JSONDecodeError:
            pass
    return rows


def fmt(v: float | None) -> str:
    return "-" if v is None else str(v)


def render_md(rows: list[dict]) -> str:
    """Full report text, a pure function of the series rows (never appends to MD)."""
    runs = [r for r in rows if r.get("kind") == "run"]
    if not runs:
        return "# Strata upstream watch\n\nNo run yet.\n"
    out = ["# Strata upstream watch", ""]
    last = runs[-1]
    fork = str(last.get("fork_sha", "?"))[:7]
    if last.get("fork_dirty"):
        fork += "-dirty"
    ratio = last.get("ratio")
    out.append(f"Last run {last.get('date', '?')}: fork {fork}  "
               f"upstream {str(last.get('upstream_sha', '?'))[:7]} ({last.get('version', '?')})")
    out.append(f"Verdict: {'' if ratio is None else f'{(ratio - 1) * 100:+.1f}%'} fork vs upstream")
    if len(runs) >= 2 and all(r.get("ratio") is not None and r["ratio"] < 1.03 for r in runs[-2:]):
        out.append("upstream catching up: two straight runs within 3%")
    out.append("")
    if rows[-1].get("kind") == "fail":
        f = rows[-1]
        out.append(f"last sweep failed ({f.get('date', '?')}, stage {f.get('stage', '?')}); "
                   f"table shows the previous good run")
        out.append("")
    out += [f"## Latest A/B ({last.get('profile', '?')})", "",
            "| metric | upstream | fork | delta% |", "| --- | ---: | ---: | ---: |"]
    a, b = last.get("A", {}), last.get("B", {})
    for key, label, _ in bvf.METRICS:
        va, vb = a.get(key), b.get(key)
        delta = f"{(vb - va) / va * 100:+.1f}" if va and vb is not None else "-"
        out.append(f"| {label} | {fmt(va)} | {fmt(vb)} | {delta} |")
    out += ["", "## History", "",
            "| date | upstream | upstream score | fork score | ratio |", "| --- | --- | ---: | ---: | ---: |"]
    for r in runs[-20:]:
        rt = r.get("ratio")
        out.append(f"| {r.get('date', '?')} | {r.get('version', '?')} | {fmt(r.get('A', {}).get('score'))} | "
                   f"{fmt(r.get('B', {}).get('score'))} | {'-' if rt is None else rt} |")
    out += ["", "Per-test detail folders live under ~/strata-data/bench/ab-fork/.", ""]
    return "\n".join(out)


def render() -> None:
    MD.write_text(render_md(load_rows()), encoding="utf-8")


def prune() -> None:
    # keep the 2 newest images per repo; the fork's :latest and any latest-* alias are never candidates,
    # so what dies is the old watch-<sha> fork builds and superseded upstream version pulls.
    for repo in ("ghcr.io/niko1221/strata", "strata-eddoursul"):
        p = subprocess.run(["docker", "image", "ls", repo, "--format", "{{json .}}"],
                           capture_output=True, text=True)
        if p.returncode != 0:
            continue
        tagged = []
        for line in p.stdout.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except json.JSONDecodeError:
                continue
            tag = str(d.get("Tag", ""))
            if tag != "latest" and not tag.startswith("latest-"):
                tagged.append((str(d.get("CreatedAt", "")), str(d.get("ID", ""))))
        tagged.sort(reverse=True)
        for _, img in tagged[2:]:
            if img:
                bvf.docker(["rmi", img], check=False)


def main() -> None:
    global ARGS
    ap = argparse.ArgumentParser(description="Nightly upstream watch: pull, rebuild, A/B, log, report.",
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--force", action="store_true", help="ignore the no-change gate and the GPU guard")
    ap.add_argument("--profile", default="dual", help="bench profile passed through (default dual)")
    ap.add_argument("--rounds", type=int, default=2, help="bench rounds (default 2)")
    ap.add_argument("--runs", type=int, default=3, help="bench runs per test (default 3)")
    ap.add_argument("--flavor", default="cuda13", help="upstream image flavor tag (default cuda13)")
    ap.add_argument("--arch", default="86;89", help="docker build-arg CUDA_ARCHITECTURES (default 86;89)")
    ap.add_argument("--gpu-busy-pct", type=int, default=20, help="skip if any GPU util >= this (default 20)")
    ARGS = ap.parse_args()

    guard_gpu()
    upstream_sha, version = pull_upstream()
    fork_sha, fork_dirty = fork_info()
    gate(upstream_sha, version, fork_sha)
    image_a = pull_image(version, ARGS.flavor)
    build_fork(fork_sha, ARGS.arch)
    out_root = sweep(ARGS.profile, ARGS.rounds, ARGS.runs, image_a)
    a, b, ratio = collect(out_root, ARGS.profile)
    record(ARGS.profile, fork_sha, fork_dirty, upstream_sha, version, image_a, out_root, a, b, ratio)
    render()
    prune()
    print(f"done: fork {(ratio - 1) * 100:+.1f}% vs upstream (score {b['score']} vs {a['score']})")


if __name__ == "__main__":
    main()
