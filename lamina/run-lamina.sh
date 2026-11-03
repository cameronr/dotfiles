#!/usr/bin/env bash
# Start the fork container running THIS FORK's engine (lamina-era image layout).
#
# The lamina image (eddoursul/Lamina, renamed tree) boots nothing of the strata-era layout:
# its entrypoint is env-driven (MODEL=..., LAMINA_* keys) and only knows upstream's models,
# so we bypass it and run build/lamina-server with our own config, exactly like the old
# run-unsloth-strata.sh did for the python server. The server starts its engine from its own
# folder (build/lamina), so the config needs no exe key; --pack is gone upstream (the native
# GGUFs are the weight source). Rollback: run-unsloth-eddoursul-strata.sh + *-strata.json.
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

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# one card gets the single config, "all" (the 4090+3090 pair) the dual
if [ "$GPUS" = "all" ]; then
  CONF="${CONF:-ud-iq4_xs-dual.json}"
else
  CONF="${CONF:-ud-iq4_xs-single.json}"
fi
# Eval (2026-11-03): lamina:relaxed = the perf-decode branch (relaxed drafting P=0.3) on upstream
# tip, which now carries the merged conversation cache (PR #41). The nightly :latest rebuild
# carries neither (its engine rejects --relaxed-drafting). Rollback: :latest (drop both; also
# remove --relaxed-drafting from the configs).
IMAGE="${IMAGE:-lamina:relaxed}"

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
