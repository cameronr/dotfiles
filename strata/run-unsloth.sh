#!/usr/bin/env bash
# Start the Strata container (0.2.0-beta image) with the tuned configs in
# configs/, run by serve/server.py directly instead of the image's entrypoint.
# The entrypoint runs `strata launch`, which re-tunes and rewrites the run
# config from env vars and presets; these configs pin the engine flags this
# setup was tuned on, exactly like the strata-eddoursul fork's run-unsloth.sh
# does on its 0.2-beta base. The old 0.1 jsons in /home/cam/strata-data/config/
# are the tuning reference; the paths follow the beta layout (the engine
# package, /opt/strata/terminal, /data itself) and the old STRATA_STAGE_TRIM=1
# is now the --trim-stage-weights flag. The GGUFs, pack and MTP draft layer
# are already prepared under /data; nothing is downloaded.
#
# Lives here in dotfiles; ~/strata/run-unsloth.sh symlinks here. Configs come
# from the configs/ dir next to this script (~/strata/configs/ symlinks the
# same files), so it works run from either place.
#
#   ./run-unsloth.sh [container] [gpus]   gpus: "all" (dual) or a --gpus value (single)
set -eu

CONTAINER_NAME="${1:-strata}"
GPUS="${2:-all}"
IMAGE="${IMAGE:-strata-0.2.1.4}"   # the 0.2.0-beta build; `strata` is the 0.1.x image, not this one

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# one card gets the single config, "all" (the 4090+3090 pair) the dual
CONF="upstream-ud-iq4_xs-single.json"
[ "$GPUS" = "all" ] && CONF="upstream-ud-iq4_xs-dual.json"

# the server always serves with an API key; keep a stable one
# (clients send: Authorization: Bearer $(cat /home/cam/strata-data/api-key))
KEY_FILE=/home/cam/strata-data/api-key
if [ ! -s "$KEY_FILE" ]; then
  umask 077
  openssl rand -hex 24 > "$KEY_FILE"
  echo "made a new API key: $KEY_FILE"
fi

docker rm --force "$CONTAINER_NAME" 2>/dev/null || true

set -x

docker run --rm \
  --name "$CONTAINER_NAME" \
  --gpus "$GPUS" \
  --stop-timeout 120 \
  -p "${PORT:-18020}:8080" \
  --ulimit memlock=-1 \
  --shm-size 2g \
  -v /home/cam/strata-data:/data \
  -v "$HERE/configs/$CONF:/data/strata-run.json:ro" \
  -e "STRATA_API_KEY=$(cat "$KEY_FILE")" \
  -e "STRATA_ALLOWED_HOSTS=mediabox.theringfamily.org,mediabox" \
  "$IMAGE" \
  sh -c 'vexe=$(ls /opt/strata/components/engine/*/strata-vision 2>/dev/null | head -1)
         sed "s|@VISION_EXE@|$vexe|" /data/strata-run.json > /tmp/strata-run.json
         cd /opt/strata/terminal
         exec /opt/strata/terminal/python/bin/python3 serve/server.py \
           --engine strata --config /tmp/strata-run.json --port 8080'
