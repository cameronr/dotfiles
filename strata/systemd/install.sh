#!/bin/sh
# One-time setup for the nightly upstream watch. Needs sudo (docker group + system units).
#   ./install.sh
# After this the timer is live; see the results in ~/strata-results.md and the logs with
#   journalctl -u strata-bench-watch.service
# To trigger a run by hand:  systemctl start strata-bench-watch.service
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"

sudo usermod -aG docker cam
sudo cp "$HERE/strata-bench-watch.service" "$HERE/strata-bench-watch.timer" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now strata-bench-watch.timer
systemctl list-timers strata-bench-watch.timer

echo
echo "note: shells already running do not see the new docker group yet; a systemd-run service does."
echo "for a manual run from today's shell: newgrp docker first (or reboot)."
