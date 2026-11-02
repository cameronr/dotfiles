#!/usr/bin/env python3
"""Nightly upstream watch: pull upstream, rebuild the fork, A/B them, log a time series, render a report.

    sudo python3 upstream_watch.py               # gated nightly run (a systemd timer fires it at 01:00)
    sudo python3 upstream_watch.py --force       # ignore the no-change gate and the GPU-busy guard
    sudo python3 upstream_watch.py --rounds 1 --force

It pulls ~/strata (upstream main) and its published image ghcr.io/niko1221/strata:<version>-<flavor>; when
that release has no published image (they are hand-published and often lag) it builds upstream from source
instead. It rebuilds the fork's image (~/lamina is never pulled or modified), runs bench_vs_fork.py
as arm A=upstream vs arm B=fork, appends a row to ~/strata-data/bench/series.jsonl, rewrites
~/strata-results.md from the whole series, and prunes old watch-* images. state.json records the last good
(upstream_sha, version, fork_sha); when tonight matches it the run is a no-op unless --force. The wrapper
has no scheduling of its own.

Standard library only; run on the host with sudo (docker access needed). Output files are chowned back to the
invoking user, and git runs as that user, so root leaves nothing it owns behind except container state.
"""
from __future__ import annotations

import argparse
import datetime
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import NoReturn

sys.path.insert(0, str(Path(__file__).resolve().parent))
import bench_vs_fork as bvf

HOME = bvf.real_home()                       # under sudo this is still the human's home, not /root
STRATA = HOME / "strata"                    # upstream checkout, tracks Niko1221/Strata main
FORK = HOME / "lamina"                      # fork checkout; never pulled or modified
SCRIPTS = Path(__file__).resolve().parent
DATA = HOME / "strata-data" / "bench"
SERIES = DATA / "series.jsonl"
STATE = DATA / "state.json"
MD = HOME / "strata-results.md"
TAG_RE = re.compile(r"^v([0-9]+(?:\.[0-9]+)+)$")
GHCR_REPO = "niko1221/strata"
MANIFEST_ACCEPT = ",".join(("application/vnd.oci.image.index.v1+json",
                            "application/vnd.docker.distribution.manifest.list.v2+json",
                            "application/vnd.docker.distribution.manifest.v1+json"))

ARGS: argparse.Namespace                     # parsed CLI, set by main(); stages read it


def sudo_user() -> str | None:
    """The human behind a root run (sudo sets SUDO_USER; the timer sets WATCH_USER), or None if plain."""
    if os.geteuid() != 0:
        return None
    return os.environ.get("WATCH_USER") or os.environ.get("SUDO_USER") or None


def own(*paths: Path) -> None:
    """Give root-written outputs back to the human so plain runs can still read and append them."""
    if not (u := sudo_user()):
        return
    for p in paths:
        if p.exists():
            subprocess.run(["chown", "-R", f"{u}:", str(p)], capture_output=True)


def git_cmd(repo: Path, *args: str) -> list[str]:
    """git as the repo's owner: root trips git's dubious-ownership guard, and root-run pulls would leave
       root-owned objects (and lose the user's stored credentials) in the checkout."""
    cmd = ["git", "-c", f"safe.directory={repo}", "-C", str(repo), *args]
    return ["sudo", "-u", u, "-H", *cmd] if (u := sudo_user()) else cmd


def iso() -> str:
    return datetime.datetime.now().isoformat(timespec="minutes")


def fail(stage: str, detail: str) -> NoReturn:
    """Record a failure row, print it, exit 1. state.json is only ever written on full success."""
    DATA.mkdir(parents=True, exist_ok=True)
    with SERIES.open("a", encoding="utf-8") as f:
        f.write(json.dumps({"date": iso(), "kind": "fail", "stage": stage, "detail": detail}) + "\n")
    own(DATA)
    print(f"FAIL {stage}: {detail}", file=sys.stderr)
    sys.exit(1)


def git(repo: Path, *args: str) -> str:
    p = subprocess.run(git_cmd(repo, *args), capture_output=True, text=True)
    return p.stdout.strip() if p.returncode == 0 else ""


def run(cmd: list[str], timeout: float, stdin_text: str | None = None) -> int:
    """Run with inherited stdio; any docker/timeout error collapses to a nonzero code the stage fails on."""
    try:
        return subprocess.run(cmd, input=stdin_text.encode() if stdin_text else None,
                              timeout=timeout).returncode
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
    if run(git_cmd(STRATA, "pull", "--ff-only"), 300) != 0:
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


def ghcr_has_tag(tag: str) -> bool:
    """Registry HEAD, no docker needed. Published images are hand-run per release (see upstream's
       docker-images.yml), so a fresh release can simply have none; then we build from source."""
    try:
        with urllib.request.urlopen(f"https://ghcr.io/token?scope=repository:{GHCR_REPO}:pull",
                                    timeout=30) as r:
            token = json.loads(r.read())["token"]
        req = urllib.request.Request(f"https://ghcr.io/v2/{GHCR_REPO}/manifests/{tag}",
                                     headers={"Authorization": f"Bearer {token}",
                                              "Accept": MANIFEST_ACCEPT}, method="HEAD")
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status == 200
    except (urllib.error.URLError, OSError, ValueError, KeyError):
        return False


TERMINAL_STAGE_RE = re.compile(r"^(FROM .* AS terminal)$", re.MULTILINE)


def patched_dockerfile(repo: Path) -> str | None:
    """Repo Dockerfile, ready for `docker build -f -` (the fix never touches either checkout).
       Two layouts: the strata-era Dockerfile needs STRATA_COMMIT wired into its `AS terminal`
       stage (package_terminal.py refuses to stamp a commit-less archive when the context has no
       .git); the lamina-era one stamps nothing (setup.py embeds what it needs), so its text is
       returned as it is."""
    text = (repo / "Dockerfile").read_text(encoding="utf-8") if (repo / "Dockerfile").is_file() else None
    if text is None:
        return None
    patched, n = TERMINAL_STAGE_RE.subn(r"\1\nARG STRATA_COMMIT\nENV STRATA_COMMIT=$STRATA_COMMIT",
                                        text, count=1)
    return patched if n else text


def resolve_image(version: str, flavor: str, upstream_sha: str) -> str:
    tag = f"{version}-{flavor}"
    if ghcr_has_tag(tag):
        image = f"ghcr.io/{GHCR_REPO}:{tag}"
        if run(["docker", "pull", image], 3600) != 0:
            fail("resolve_image", image)
        return image
    image = f"strata-upstream:watch-{upstream_sha[:7]}"
    print(f"no published image {tag}; building upstream from source at {upstream_sha[:7]}")
    df = patched_dockerfile(STRATA)
    if df is None:
        fail("resolve_image", "no Dockerfile in the upstream checkout")
    if run(["docker", "build", "-f", "-", "-t", image, "--build-arg", f"STRATA_COMMIT={upstream_sha}",
            "--build-arg", f"CUDA_ARCHITECTURES={ARGS.arch}", str(STRATA)], 3 * 3600, stdin_text=df) != 0:
        fail("resolve_image", f"{image} (source build)")
    return image


def build_fork(fork_sha: str, arch: str) -> str:
    tag = f"lamina:watch-{fork_sha[:7]}"
    df = patched_dockerfile(FORK)
    if df is None:
        fail("build_fork", "no Dockerfile in the fork checkout")
    # STRATA_COMMIT only exists in the strata-era Dockerfile (the lamina one stamps nothing; an
    # unknown --build-arg is only a warning, but a quiet build log keeps real warnings visible).
    args = ["--build-arg", f"CUDA_ARCHITECTURES={arch}"]
    if "ARG STRATA_COMMIT" in df:
        args.insert(0, f"--build-arg=STRATA_COMMIT={fork_sha}")
    if run(["docker", "build", "-f", "-", "-t", tag, *args, str(FORK)], 3 * 3600, stdin_text=df) != 0:
        fail("build_fork", tag)
    # the fork's launch script runs the image named after its container (lamina), so :latest
    # is what the arm actually runs; the watch-<sha> tag is what prune() keeps history by.
    # (Prod migrated to the lamina-era image 2026-10-31: run-lamina.sh starts lamina-server
    # directly, so a rebuilt image is bootable and :latest moves unconditionally again.)
    if run(["docker", "tag", tag, "lamina:latest"], 60) != 0:
        fail("build_fork", "lamina:latest")
    return tag


def sweep(profile: str, rounds: int, runs: int, image_a: str) -> Path:
    out_root = DATA / "ab-fork" / datetime.datetime.now().strftime("%Y-%m-%d-%H%M")
    cmd = [sys.executable, str(SCRIPTS / "bench_vs_fork.py"), "--profile", profile,
           "--rounds", str(rounds), "--runs", str(runs), "--yes",
           "--image-a", image_a, "--image-b", "lamina", "--out", str(out_root)]
    if bvf.docker(["ps", "-q", "--filter", "name=^lamina$"]).stdout.strip():
        cmd.append("--restart")
    if bool(bvf.docker(["ps", "-q", "--filter", "name=^llama-swap$"]).stdout.strip()):
        # llama-swap must stay up (it serves agent inference and auto-starts prod); unload only frees VRAM
        print("unloading llama-swap models for the sweep")
        subprocess.run(["llama-swap-cli", "unload"], check=False)
    # env is inherited unmodified on purpose: never export IMAGE here, or bench_vs_fork's --restart
    # would inherit it and restart the production server on the wrong image.
    rc = subprocess.run(cmd, cwd=str(SCRIPTS)).returncode
    if rc != 0:
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
    for repo in ("ghcr.io/niko1221/strata", "strata-upstream", "lamina"):
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
    image_a = resolve_image(version, ARGS.flavor, upstream_sha)
    build_fork(fork_sha, ARGS.arch)
    out_root = sweep(ARGS.profile, ARGS.rounds, ARGS.runs, image_a)
    a, b, ratio = collect(out_root, ARGS.profile)
    record(ARGS.profile, fork_sha, fork_dirty, upstream_sha, version, image_a, out_root, a, b, ratio)
    render()
    own(DATA, MD)
    prune()
    print(f"done: fork {(ratio - 1) * 100:+.1f}% vs upstream (score {b['score']} vs {a['score']})")


if __name__ == "__main__":
    main()
