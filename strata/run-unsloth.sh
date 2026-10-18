#!/usr/bin/env bash
# Start the Strata container. The config JSON is the only source of truth:
# CONFIG points the entrypoint straight at it, so no CONTEXT/VISION/FAMILY/
# MODEL env vars can drift from it. (The entrypoint reads those only when it
# has to run setup on a fresh volume; pass them by hand for that one run.)
set -eu

CONTAINER_NAME="${1:-strata}"
GPUS="${2:-all}"

# one card gets the single config, "all" (the 4090+3090 pair) the dual
CONFIG="strata-unsloth-ud-iq4_xs-single.json"
if [ "$GPUS" = "all" ]; then
  CONFIG="strata-unsloth-ud-iq4_xs-dual.json"
fi

docker rm --force "$CONTAINER_NAME" 2>/dev/null

set -x

docker run --rm \
  --name "$CONTAINER_NAME" \
  --gpus "$GPUS" \
  --stop-timeout 30 \
  -p "${PORT:-18020}:8080" \
  --ulimit memlock=-1 \
  -v /home/cam/strata-data:/data \
  -v /home/cam/strata-data/strata-unsloth-ud-iq4_xs.log:/opt/strata/strata-unsloth-ud-iq4_xs.log \
  -v "/home/cam/strata-data/config/$CONFIG:/data/config/strata-unsloth-ud-iq4_xs.json" \
  -e "CONFIG=/data/config/strata-unsloth-ud-iq4_xs.json" \
  -e "STRATA_ALLOWED_HOSTS=mediabox.theringfamily.org,mediabox" \
  -e "STRATA_STAGE_TRIM=1" \
  strata
