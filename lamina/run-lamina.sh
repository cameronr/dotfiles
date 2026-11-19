#!/usr/bin/env bash
# Start the fork container running THIS FORK's engine (lamina-era image layout).
#
# The lamina image builds THIS FORK from the Dockerfile in the fork clone's root (upstream
# removed its own image, db378e8ba). Its programs sit flat in /opt/lamina/build, lamina-vision
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
#
#   ./run-lamina.sh [container] [gpus]     gpus: "all" (dual) or a --gpus value (single)
set -eu

CONTAINER_NAME="${1:-lamina}"
GPUS="${2:-all}"

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
# Default: lamina:main = clean upstream (ec30341b3). It carries the sampled-draft rule
# ("Sampled requests keep their drafts by the number each position is drawn with"), which
# replaces the fork's --relaxed-drafting (now removed from the configs: upstream's rule is on
# by default for sampled requests, tuned by --spec-min-p), and the --vram-pin-gib pins.
# Rollback: IMAGE=lamina:combined (the fork build with --relaxed-drafting), and put
# --relaxed-drafting 0.3 back in the configs.
if [ -z "${IMAGE:-}" ]; then
  IMAGE=lamina:main
  docker image inspect "$IMAGE" >/dev/null 2>&1 || { echo "run-lamina: $IMAGE not built yet; using lamina:combined" >&2; IMAGE=lamina:combined; }
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
  --memory-swap=-1 \
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
