#!/bin/bash
# Wrap the Homebrew tmux binary in a minimal .app bundle so macOS can attach a
# persistent Local Network permission to it. tmux is ad-hoc signed with no bundle
# id, so once its launching terminal quits, the server has no grantable identity
# and macOS blocks LAN access (TN3179). A bundle id + NSLocalNetworkUsageDescription
# gives it one.
#
# The bundle MUST be signed with a real code-signing identity, not `codesign -s -`
# (ad-hoc). The TCC UI honors ad-hoc grants and nehelper logs "allowed", but the
# kernel's packet-level enforcement distrusts ad-hoc signatures ("No team ID found")
# and silently blocks third-party binaries (python, wget, bare ssh) while
# Apple-signed ones (curl, nc, perl) bypass the policy entirely. Symptom: errno 65
# "No route to host" from python inside tmux panes, curl fine in the same pane.
# One-time setup: create a self-signed codeSigning cert ("Tmux Local Signing"),
# import it into the login keychain, set Trust → Code Signing → Always Trust.
# The grant binds to the cdhash, so re-run this script after `brew upgrade tmux`
# and re-grant once.
#
# If the kernel ever caches a bad verdict for the bundle id (nehelper logs
# "allowed by preference" + "UUID cache hit" while python still gets errno 65),
# bump BUNDLE_ID: the kernel's local-network verdict cache is keyed by bundle id
# and survives codesign changes and tccutil reset.
#
# LAST RESORT, the one that cost hours: /Library/Preferences/com.apple.networkextension.uuidcache.plist
# (root-owned, "CUEN" binary format) maps signing identifiers to the UUIDs TCC
# keys policy on. A poisoned entry (e.g. from a deleted bundle id) makes the
# kernel consult a stale UUID whose preference is deny, while TCC.db, nehelper
# logs, and System Settings all show allowed. Reboot does NOT clear it. Fix as
# root: killall nehelper && rm -f that file, then tccutil reset All <bundle id>
# and re-approve the fresh prompt.
#
# Two more facts learned the hard way, both handled by the LaunchAgent:
#   - TCC attributes a terminal-launched process to the terminal (its responsible
#     process), so the server must be started by launchd to own its identity.
#   - The bare brew binary does get its own prompt under launchd, but CLI
#     executables may not appear in the Local Network settings list and their
#     grants re-prompt. The bundle is what makes the grant named, listed, and
#     durable.
set -euo pipefail

BUNDLE_ID="com.cam.tmux.app"
# NOTE: do not rename/move this bundle casually. Bundle path, id, and signing
# identity all feed the kernel's local-network identity resolution; churn here
# is what poisoned the uuidcache (see LAST RESORT above). If identity ever
# resolves stale, delete the uuidcache as root rather than moving the bundle.
APP_DIR="${HOME}/apps/tmux-app/Tmux.app"
BIN_DIR="${HOME}/bin"

SRC="$(brew --prefix tmux)/bin/tmux"
[[ -x "$SRC" ]] || { echo "tmux not found at $SRC" >&2; exit 1; }

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$BIN_DIR"
cp "$SRC" "$APP_DIR/Contents/MacOS/tmux"

BUNDLE_VER="$("$SRC" -V | awk '{print $2}')"
printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0"><dict>\n  <key>CFBundleIdentifier</key><string>%s</string>\n  <key>CFBundleName</key><string>Tmux</string>\n  <key>CFBundleExecutable</key><string>tmux</string>\n  <key>CFBundlePackageType</key><string>APPL</string>\n  <key>CFBundleVersion</key><string>%s</string>\n  <key>NSLocalNetworkUsageDescription</key>\n  <string>tmux sessions run shells and tools that reach hosts on the local network.</string>\n</dict></plist>\n' "$BUNDLE_ID" "$BUNDLE_VER" > "$APP_DIR/Contents/Info.plist"

SIGN_IDENTITY="Tmux Local Signing"
security find-identity -v -p codesigning | grep -q "$SIGN_IDENTITY" || {
  echo "signing identity '$SIGN_IDENTITY' not found; see header comment for one-time setup" >&2; exit 1; }
# No --options runtime: hardened runtime refuses to load brew's ad-hoc signed
# dylibs (utf8proc etc) under a different Team ID. A plain real signature is
# what the kernel needs; opencode itself runs without hardened runtime.
codesign -s "$SIGN_IDENTITY" -f "$APP_DIR"
ln -sf "$APP_DIR/Contents/MacOS/tmux" "$BIN_DIR/tmux"

# The LaunchAgent starts the server from launchd. PATH must be set there:
# launchd's default lacks /opt/homebrew, and TPM shells out to tmux, which
# would silently skip every plugin.
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.cam.tmux.plist"
mkdir -p "$(dirname "$LAUNCH_AGENT")"
KEEPER_CMD="T=$APP_DIR/Contents/MacOS/tmux; trap '' HUP; \"\$T\" new-session -d -c $HOME -s 0 2>/dev/null; exec \"\$T\" wait-for keep"
sed "s|__TMUX_KEEPER_CMD__|$KEEPER_CMD|" "$(dirname "$0")/com.cam.tmux.plist" > "$LAUNCH_AGENT"
launchctl bootout "gui/$(id -u)/com.cam.tmux" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT"

echo "built: $APP_DIR"
echo "link:  $BIN_DIR/tmux -> $APP_DIR/Contents/MacOS/tmux"
echo "agent: $LAUNCH_AGENT (bootstrapped)"
echo "cdhash: $(codesign -dvvv "$APP_DIR" 2>&1 | grep -m1 '^CDHash=' | cut -d= -f2)"
echo "version: $("$BIN_DIR/tmux" -V)"
echo
echo "Cutover (when not holding a live session):"
echo "  tmux kill-server"
echo "  sleep 6"
echo "  tmux attach -t 0"
echo "The agent is KeepAlive: killing the server makes launchd relaunch it"
echo "within ~5s. Do not use kickstart while a server is still running."
echo "Approve the Tmux popup once if it appears. After a brew upgrade tmux:"
echo "re-run this script and grant Tmux once again (the cdhash changes)."