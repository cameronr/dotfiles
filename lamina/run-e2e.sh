#!/usr/bin/env bash
# Run a GPU test container with llama-swap inference paused, so no request can
# start the prod container onto the GPUs mid-test. Resumes inference on every
# exit path. A SIGKILL of this script skips the traps and leaves the pause on
# (see the lamina section of agents/AGENTS.md for the recovery command).
#
#   ./run-e2e.sh <checkout> <script-in-checkout> [args...]
set -eu

CHECKOUT="${1:?usage: run-e2e.sh <checkout> <script-in-checkout> [args...]}"
SCRIPT="${2:?usage: run-e2e.sh <checkout> <script-in-checkout> [args...]}"
shift 2
[ -d "$CHECKOUT" ] || { echo "no such checkout: $CHECKOUT" >&2; exit 2; }
[ -f "$CHECKOUT/$SCRIPT" ] || { echo "no such script: $CHECKOUT/$SCRIPT" >&2; exit 2; }

SWAP=http://localhost:8020

# fail closed: no test starts unless the pause took. pause unloads loaded
# models synchronously, so this also stops the prod container.
curl -sf -X POST "$SWAP/api/models/pause" >/dev/null

cleanup() {
  # a killed docker run leaves the container running; inference must not
  # resume while it still holds the GPUs
  docker stop -t 10 lamina-e2e 2>/dev/null || true
  curl -sf -X POST "$SWAP/api/models/resume" >/dev/null ||
    echo "RESUME FAILED: curl -X POST $SWAP/api/models/resume" >&2
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

docker run --rm \
  --name lamina-e2e \
  --gpus all \
  --shm-size 2g \
  --ulimit memlock=-1 \
  -v /home/cam/strata-data:/data \
  -v "$CHECKOUT":/work \
  lamina-e2e:latest \
  bash /work/"$SCRIPT" "$@"
