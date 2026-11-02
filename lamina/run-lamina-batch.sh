#!/usr/bin/env bash
# Start the batching test arm: the fork's prod container, but running the WORKTREE's engine
# and server (the server.py mount carries the batch telemetry fixes, e.g. BDONE draft counts).
# (the phase 1-9 batch code lives on branch batch-phase1-harness and in no image yet).
#
# Same image as run-lamina.sh (lamina), new container name (-batch), the worktree
# mounted at /work, and configs/eddoursul-ud-iq4_xs-dual-batch.json driving serve/server.py:
# "parallel": 4 (the server adds --batch 4), --batch-mtp drafts, 32K context and a pinned
# expert cache so four full-context slot sessions fit (see the config's _comment).
#
# The container is named lamina-batch so `docker ps`, logs and the A/B script can
# tell the arms apart.  GPU: only one arm can hold the cards - this script stops the prod
# container first.  llama-swap brings prod back on the next agent chat, so run your tests
# without chatting in parallel (same rule as the gate runs).
#
#   ./run-lamina-batch.sh [container] [gpus]     gpus: "all" (dual) or a --gpus value
#   PORT=18021 CONF=<file in configs/> WORKTREE=<checkout> STRATA_BATCH_ADAPT=0 (freeze tiers) ...
set -eu

CONTAINER_NAME="${1:-lamina-batch}"
GPUS="${2:-all}"
IMAGE="${IMAGE:-lamina}"
WORKTREE="${WORKTREE:-/home/cam/lamina/.worktrees/batch-phase1-harness}"

HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"   # the dotfiles dir, even via the repo symlink
CONF="${CONF:-eddoursul-ud-iq4_xs-dual-batch.json}"

# Guard the values that decide whether this arm can run at all (reserve 896 silently degrades the
# engine to "starting with 1 slot" and starves even the verify graph's instantiate):
#   --vram-reserve-mib >= 3072  the room the cache sizing leaves is where the slots are carved from
#   --max-context      <= 262144 the engine's limit; slots cost 0.23 GiB at ANY context (elastic K/V),
#                               but the shared pool (~420K cells at reserve 3072) is what caps how
#                               many long contexts fit at once - see the config's _comment.
python3 - "$HERE/configs/$CONF" <<'PY' || exit 1
import json, sys
c = json.load(open(sys.argv[1])); a = c["args"]
def val(f, d=None):
    return a[a.index(f) + 1] if f in a else d
ctx, res = int(val("--max-context", 0)), int(val("--vram-reserve-mib", 0))
if res < 3072:
    sys.exit(f"{sys.argv[1]}: --vram-reserve-mib {res} leaves no room to carve slots (needs >= 3072)")
if ctx > 262144:
    sys.exit(f"{sys.argv[1]}: --max-context {ctx} exceeds the engine's 262144")
if ctx > 65536:
    print(f"{sys.argv[1]}: context {ctx} - the shared K/V pool (~420K cells) fits ~4 conversations to "
          "~100K each or 1-2 full ones; an over-full engine exits ('the K/V cannot grow')")
if int(c.get("parallel") or 0) < 2:
    sys.exit(f"{sys.argv[1]}: \"parallel\" must be >= 2 for a batching arm")
PY

[ -x "$WORKTREE/.p4-cbuild/strata" ] || { echo "no engine build at $WORKTREE/.p4-cbuild/strata (build it:
  docker run --rm -v $WORKTREE:/work nvidia/cuda:13.0.0-devel-ubuntu24.04 bash -c
    'apt-get update -qq; apt-get install -y -qq cmake ninja-build build-essential git; cd /work/.p4-cbuild && ninja strata')"; exit 1; }

# the prod container holds the GPUs; llama-swap restarts it on the next request (see header)
if [ -n "$(docker ps -q --filter name=lamina$)" ] && [ "$CONTAINER_NAME" != "lamina" ]; then
  echo "stopping the prod container (llama-swap will bring it back on the next agent chat - avoid chatting during the test)"
  docker stop lamina >/dev/null
fi

KEY_FILE=/home/cam/strata-data/api-key
[ -s "$KEY_FILE" ] || { umask 077; openssl rand -hex 24 >"$KEY_FILE"; echo "made a new API key: $KEY_FILE"; }

docker rm --force "$CONTAINER_NAME" 2>/dev/null || true
set -x

# @VISION_EXE@ and @ENGINE_LIB@ are filled in inside the container (the component dir carries the
# CUDA libs the mounted binary needs on LD_LIBRARY_PATH; the server prepends the config's lib_dirs)
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
  -v "$HERE/configs/$CONF:/data/eddoursul.json:ro" \
  -v "$WORKTREE:/work:ro" \
  -v "$WORKTREE/serve/server.py:/opt/strata/terminal/serve/server.py:ro" \
  -e "STRATA_API_KEY=$(cat "$KEY_FILE")" \
  -e "STRATA_ALLOWED_HOSTS=mediabox.theringfamily.org,mediabox" \
  -e "STRATA_DRAFT_PROXY=${STRATA_DRAFT_PROXY:-0}" \
  ${STRATA_BATCH_ADAPT:+-e "STRATA_BATCH_ADAPT=$STRATA_BATCH_ADAPT"} \
  ${STRATA_BATCH_WINDOW:+-e "STRATA_BATCH_WINDOW=$STRATA_BATCH_WINDOW"} \
  "$IMAGE" \
  sh -c 'vexe=$(ls /opt/strata/components/engine/*/strata-vision 2>/dev/null | head -1)
         elib=$(ls -d /opt/strata/components/engine/*/ 2>/dev/null | head -1)
         sed -e "s|@VISION_EXE@|$vexe|" -e "s|@ENGINE_LIB@|$elib|" /data/eddoursul.json > /tmp/eddoursul.json
         cd /opt/strata/terminal
         exec /opt/strata/terminal/python/bin/python3 serve/server.py \
           --engine strata --config /tmp/eddoursul.json --port 8080'
