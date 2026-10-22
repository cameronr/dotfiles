#!/usr/bin/env bash
# Start the Strata container running THIS FORK's engine.
#
# The fork's engine (src/, built into the image) is not upstream's: it has no
# --layer-split, --batch/--batch-groups, --kv-resident, --resident-budget-gib or
# --conversation-cache-*, and uses --main-gpu/--second-gpu/--head-split for the
# two cards (see examples/README.md). So `strata launch` (upstream's flow) writes
# flags this engine refuses; we run serve/server.py directly with the fork's own
# config, exactly like examples/run-ud-q4_k_xl.bat and the old CONFIG= json did.
#
# The model files, pack and MTP draft layer are already prepared under
# /data (the Strata data folder; from the earlier setup run); nothing is
# downloaded.
#
# Lives here in dotfiles; ~/strata-eddoursul/run-unsloth.sh symlinks here.
# Configs come from the configs/ dir next to this script (the fork clone's
# configs/ symlinks the same files), so it works run from either place.
# CONF=<file in configs/> overrides the tuned config (used by
# bench_single_tune.py for flag variants).
#
#   ./run-unsloth.sh [container] [gpus]     gpus: "all" (dual) or a --gpus value (single)
set -eu

CONTAINER_NAME="${1:-strata}"
GPUS="${2:-all}"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# one card gets the single config, "all" (the 4090+3090 pair) the dual
# CONF=<file in configs/> overrides (used by bench_single_tune.py for flag variants)
if [ "$GPUS" = "all" ]; then
  CONF="${CONF:-eddoursul-ud-iq4_xs-dual.json}"
else
  CONF="${CONF:-eddoursul-ud-iq4_xs-single.json}"
fi

# the server always serves with an API key; keep a stable one
# (clients send: Authorization: Bearer $(cat /home/cam/strata-data/api-key))
KEY_FILE=/home/cam/strata-data/api-key
if [ ! -s "$KEY_FILE" ]; then
  umask 077
  openssl rand -hex 24 >"$KEY_FILE"
  echo "made a new API key: $KEY_FILE"
fi

docker rm --force "$CONTAINER_NAME" 2>/dev/null

# STRATA_DRAFT_PROXY: the 2-bit draft head copy. 0 = the exact head over every row (safe; what ran before the copy
# could handle big draft vocabs). 1 = the 2-bit copy (~2.5x faster draft-head argmax). The copy used to throw
# "too many rows" on this model's 106k CJK draft vocab; the grid-stride rescore fix (branch draft-proxy-unbounded)
# makes 1 work at any size. Default 0 until that fix is merged and the image rebuilt, then flip the default to 1.
# Override for an A/B:  STRATA_DRAFT_PROXY=1 ./run-unsloth.sh strata-eddoursul all
set -x

docker run --rm \
  --name "$CONTAINER_NAME" \
  --gpus "$GPUS" \
  --stop-timeout 120 \
  -p "${PORT:-18020}:8080" \
  --ulimit memlock=-1 \
  --shm-size 2g \
  -v /home/cam/strata-data:/data \
  -v "$HERE/configs/$CONF:/data/eddoursul.json:ro" \
  -e "STRATA_API_KEY=$(cat "$KEY_FILE")" \
  -e "STRATA_ALLOWED_HOSTS=mediabox.theringfamily.org,mediabox" \
  -e "STRATA_DRAFT_PROXY=${STRATA_DRAFT_PROXY:-0}" \
  "$CONTAINER_NAME" \
  sh -c 'vexe=$(ls /opt/strata/components/engine/*/strata-vision 2>/dev/null | head -1)
         sed "s|@VISION_EXE@|$vexe|" /data/eddoursul.json > /tmp/eddoursul.json
         cd /opt/strata/terminal
         exec /opt/strata/terminal/python/bin/python3 serve/server.py \
           --engine strata --config /tmp/eddoursul.json --port 8080'
