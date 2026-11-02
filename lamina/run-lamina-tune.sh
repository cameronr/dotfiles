#!/usr/bin/env bash
# bench_vs_fork arm-B wrapper for config sweeps: the prod launcher with a variant config
# named by TUNE (a file in configs/). Everything else (LAMINA_DRAFT_PROXY, IMAGE, PORT)
# is inherited from the sweep's environment, so each variant is one env line away from prod.
set -eu
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CONF="${TUNE:?TUNE=<file in configs/>}" exec bash "$HERE/run-lamina.sh" "$@"
