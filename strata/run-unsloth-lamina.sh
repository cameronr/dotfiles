#!/usr/bin/env bash
# Start the lamina-era fork container (image strata-eddoursul:lamina-<sha>) with our pack.
#
# The lamina image (renamed tree, C++ server) boots nothing of the old layout: the entrypoint
# is env-driven (MODEL=..., LAMINA_* keys) and only knows upstream's models, so we bypass it and
# run build/lamina-server with our own config, exactly like run-unsloth.sh did for the strata-era
# image's python server. The server starts its engine from its own folder (build/lamina), so the
# config needs no exe key; --pack is gone upstream (the native GGUFs are the weight source).
#
# Same interface as run-unsloth.sh: [container] [gpus], PORT env (host port), IMAGE and CONF
# overrides; bench_vs_fork.py drives arms through this.
#
#   ./run-unsloth-lamina.sh strata-eddoursul-lamina all
set -eu

CONTAINER_NAME="${1:-strata-eddoursul-lamina}"
GPUS="${2:-all}"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${CONF:-eddoursul-ud-iq4_xs-dual-lamina.json}"
IMAGE="${IMAGE:-strata-eddoursul:lamina-5fa68aa06}"

KEY_FILE=/home/cam/strata-data/api-key
if [ ! -s "$KEY_FILE" ]; then
  umask 077
  openssl rand -hex 24 >"$KEY_FILE"
  echo "made a new API key: $KEY_FILE"
fi

docker rm --force "$CONTAINER_NAME" 2>/dev/null || true
set -x

docker run --rm \
  --name "$CONTAINER_NAME" \
  --gpus "$GPUS" \
  --stop-timeout 120 \
  --memory=88g \
  --memory-swap=88g \
  -p "${PORT:-18034}:8080" \
  --ulimit memlock=-1 \
  --shm-size 2g \
  -v /home/cam/strata-data:/data \
  -v "$HERE/configs/$CONF:/cfg/lamina.json:ro" \
  -e "LAMINA_API_KEY=$(cat "$KEY_FILE")" \
  -e "LAMINA_ALLOWED_HOSTS=mediabox.theringfamily.org,mediabox" \
  --entrypoint /opt/lamina/build/lamina-server \
  "$IMAGE" \
  --config /cfg/lamina.json --host 0.0.0.0 --port 8080
