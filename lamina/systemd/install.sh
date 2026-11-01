#!/bin/sh
# One-time setup for the nightly upstream watch. Needs sudo (system units; the service runs as root
# for docker access and drops git back to you).
#   sudo ./install.sh
# Results in ~/strata-results.md, logs with:  journalctl -u strata-bench-watch.service
# Run by hand any time:  systemctl start strata-bench-watch.service
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"

sudo cp "$HERE/strata-bench-watch.service" "$HERE/strata-bench-watch.timer" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now strata-bench-watch.timer
systemctl list-timers strata-bench-watch.timer
