#!/usr/bin/env bash
# Start the fork container running THIS FORK's engine (lamina-era image layout).
#
# The lamina image builds THIS FORK from the Dockerfile on the fork's fork/docker branch
# (upstream removed its own image, db378e8ba, and the fork's recipe was never merged to main).
# Copy that branch's Dockerfile and .dockerignore into a clean checkout before `docker build`;
# the ignore matters, a worktree's build-*/ trees are gigabytes. Its programs sit flat in
# /opt/lamina/build, lamina-vision
# beside lamina-server like the server has expected since the vision "exe" config key was
# removed (the configs keep their exe keys: the rollback images still read them, the new
# server ignores them). We override the entrypoint and run build/lamina-server with our own
# config; the engine starts from the server's own folder (build/lamina). --pack is gone
# upstream (the native GGUFs are the weight source). Rollback: run-unsloth-eddoursul-strata.sh + *-strata.json.
#
# The model files, MTP draft layer and learned expert profile are already under /data
# (~/strata-data); nothing is downloaded.
#
# Lives here in dotfiles; ~/lamina/run-lamina.sh symlinks here.
# Configs come from the configs/ dir next to this script (the fork clone's configs/ symlinks
# the same files), so it works run from either place.
# CONF=<file in configs/> overrides the tuned config.
# IMAGE=<tag> overrides the image (default: the image named after the container, :latest).
# MEM_MIN_GIB=<n> overrides the free-memory floor (default 70); DRY_RUN=1 resolves everything and exits.
#
#   ./run-lamina.sh [container] [gpus]     gpus: "all" (dual) or a --gpus value (single)
set -eu

CONTAINER_NAME="${1:-lamina}"
GPUS="${2:-all}"

# Free-memory guard. Loading pins about 56 GiB (the model plus the cudaHostRegister'd expert
# arena); launching on top of an already tight host memcg-thrashes or OOM-reboots the machine
# (this box rebooted on 2026-11-12 from two arenas at once). Require MEM_MIN_GIB free before
# the engine starts: default 70, MEM_MIN_GIB=0 disables it.
#
# A container already running under this same name is about to be replaced by us, so its pages
# are counted as free: that keeps a restart from being blocked by the very server it restarts.
MEM_MIN_GIB="${MEM_MIN_GIB:-70}"
if [ "${MEM_MIN_GIB}" -gt 0 ]; then
  avail_kb=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
  old_pid=$(docker inspect -f '{{.State.Pid}}' "$CONTAINER_NAME" 2>/dev/null || true)
  if [ -n "${old_pid:-}" ] && [ "${old_pid:-0}" != "0" ]; then
    old_cg=$(awk -F'::' '$1=="0"{print $2}' /proc/"$old_pid"/cgroup 2>/dev/null || true)
    if [ -n "${old_cg:-}" ] && [ -f "/sys/fs/cgroup${old_cg}/memory.current" ]; then
      avail_kb=$(( avail_kb + $(awk '{print int($1/1024)}' "/sys/fs/cgroup${old_cg}/memory.current") ))
    fi
  fi
  min_kb=$(( MEM_MIN_GIB * 1024 * 1024 ))
  if [ "$avail_kb" -lt "$min_kb" ]; then
    echo "run-lamina: $(( avail_kb / 1048576 )) GiB available, below the ${MEM_MIN_GIB} GiB floor; not launching." >&2
    echo "run-lamina: free some memory, lower MEM_MIN_GIB, or set MEM_MIN_GIB=0 to skip this check." >&2
    exit 1
  fi
fi

# the script's own dir with symlinks resolved (a worktree's run-lamina.sh symlink must land
# on the dotfiles configs/, not on the worktree it was called from)
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# one card gets the single config, "all" (the 4090+3090 pair) the dual
# Eval (2026-11-05): defaults switched to unsloth Dynamic 3.1 UD-IQ4_XS (the -v31 configs: 4-shard
# V3.1 files, thinking-mode sampling temp 1.0). Rollback: CONF=ud-iq4_xs-dual.json (the V3 files
# stay under /data/models/unsloth-UD-IQ4_XS).
if [ "$GPUS" = "all" ]; then
  CONF="${CONF:-ud-iq4_xs-v31-dual.json}"
else
  CONF="${CONF:-ud-iq4_xs-v31-single.json}"
fi
# Default: lamina:main, a build of fork main. Since upstream's ef99402c8..3aed0f4f7 that build
# encodes pictures inside lamina-server itself, on the engine's kernels, borrowing the engine's
# expert-cache slots for each picture ("vision": {"gpu": true, "lend": true}) and holding nothing on
# a card between pictures; there is no lamina-vision binary in it at all. The fork's own answer to
# the same problem (plans/13-in-engine-vision: the encode inside the ENGINE process, so no second
# CUDA context anywhere) stays built: IMAGE=lamina:in-engine-vision, and it needs a config that sets
# "vision": {"in_engine": true}, because with this one it starts its sidecar and names "lend" as a
# key it does not read. Both are A/B-able; :main is the default because it is upstream's path.
# Rollback to the pre-lend build of main: IMAGE=lamina:main-20261120 (main-<date> tags are kept).
if [ -z "${IMAGE:-}" ]; then
  IMAGE=lamina:main
  docker image inspect "$IMAGE" >/dev/null 2>&1 || { echo "run-lamina: $IMAGE not built; build it or pass IMAGE=<tag>" >&2; exit 1; }
fi

if [ "${DRY_RUN:-0}" = 1 ]; then
  echo "run-lamina: checks passed. image=$IMAGE conf=$CONF gpus=$GPUS available=$(( $(awk '/^MemAvailable:/{print int($2/1048576)}' /proc/meminfo) )) GiB (no launch)"
  exit 0
fi

# the server always serves with an API key; keep a stable one
# (clients send: Authorization: Bearer $(cat /home/cam/strata-data/api-key))
KEY_FILE=/home/cam/strata-data/api-key
if [ ! -s "$KEY_FILE" ]; then
  umask 077
  openssl rand -hex 24 >"$KEY_FILE"
  echo "made a new API key: $KEY_FILE"
fi

docker rm --force "$CONTAINER_NAME" 2>/dev/null || true

# LAMINA_DRAFT_PROXY: the 2-bit draft head copy. 0 = the exact head over every row (the safe
# default, as on the strata-era image). Override for an A/B: LAMINA_DRAFT_PROXY=1 ./run-lamina.sh ...
set -x

docker run --rm \
  --name "$CONTAINER_NAME" \
  --gpus "$GPUS" \
  --stop-timeout 120 \
  --memory=88g \
  --memory-swap=88g \
  -p "${PORT:-18020}:8080" \
  --ulimit memlock=-1 \
  --shm-size 2g \
  -v /home/cam/strata-data:/data \
  -v "$HERE/configs/$CONF:/cfg/lamina.json:ro" \
  -e "LAMINA_API_KEY=$(cat "$KEY_FILE")" \
  -e "LAMINA_ALLOWED_HOSTS=mediabox.theringfamily.org,mediabox" \
  -e "LAMINA_DRAFT_PROXY=${LAMINA_DRAFT_PROXY:-0}" \
  --entrypoint /opt/lamina/build/lamina-server \
  "$IMAGE" \
  --config /cfg/lamina.json --host 0.0.0.0 --port 8080
