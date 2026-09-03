// Server-side shim for the tmux-status TUI plugin.
//
// The TUI discovers this directory and loads ./tui.js (the real plugin).
// The server ALSO auto-discovers ~/.config/opencode/plugins/ and only loads
// a subdirectory when it contains an index.js, so this no-op keeps the
// server from failing on the directory. Keep it import-free: it must load
// cleanly in the server process, which cannot resolve TUI-only modules.
export default {
  id: "tmux-status",
  setup() {},
};
