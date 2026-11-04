#!/bin/bash
# Re-grant Local Network permission to the tmux server without restarting it.
# The kernel consults the grant at connect time against the running server, so
# invalidating the decision + triggering a fresh prompt is enough; panes, the
# server, and all windows keep running.
set -euo pipefail

BUNDLE_ID="com.cam.tmux.app"

tccutil reset All "$BUNDLE_ID"
cat <<'EOF'
Grant reset. Now, in any tmux pane, run a LAN command to raise the prompt:

  curl -m 15 http://10.0.0.1/      (or: ssh mediabox)

and click Allow on the "Tmux" dialog.

If it STILL denies (errno 65 / "No route to host" from python/telnet/wget
while curl works), the nehelper uuidcache is poisoned with a stale identity.
As root:

  sudo killall nehelper
  sudo rm -f /Library/Preferences/com.apple.networkextension.uuidcache.plist
  tccutil reset All com.cam.tmux.app

then raise the prompt again as above.
EOF
