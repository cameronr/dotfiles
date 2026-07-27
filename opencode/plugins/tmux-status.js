// OpenCode plugin: writes live agent status into a tmux pane *option*
// (not the pane title itself), so it doesn't fight with OpenCode's own
// title-setting escape sequences.
//
// Install:
//   Project-local: .opencode/plugin/tmux-title.js
//   Global:        ~/.config/opencode/plugin/tmux-title.js
//
// Requires: opencode running inside a tmux pane (uses $TMUX_PANE, which
// tmux sets automatically). No config needed on the opencode side.
//
// Pair this with tmux-title.conf, which reads @agent_status back out in
// pane-border-format and appends an icon after OpenCode's own title.
//
// Debugging: set OPENCODE_TMUX_DEBUG=1 in your shell before launching
// opencode, then `tail -f /tmp/opencode-tmux-debug.log` in another pane.
// It logs every event.type as it fires, plus a JSON dump of its payload,
// so you can see exactly which event corresponds to "working" on your
// version of OpenCode and adjust the switch below if needed.

import { execSync } from "child_process";
import { appendFileSync } from "fs";

const DEBUG = process.env.OPENCODE_TMUX_DEBUG === "1";
const DEBUG_LOG = "/tmp/opencode-tmux-debug.log";

function debugLog(event) {
  if (!DEBUG) return;
  try {
    appendFileSync(
      DEBUG_LOG,
      `${new Date().toISOString()} ${event.type} ${JSON.stringify(event)}\n`,
    );
  } catch {}
}

function setStatus(status) {
  const pane = process.env.TMUX_PANE;
  if (!pane) return; // not running inside tmux, nothing to do
  try {
    execSync(`tmux set-option -p -t ${pane} @agent_status ${status}`);
  } catch {
    // tmux not on PATH, or the pane went away — fail silently
  }
}

export const TmuxTitlePlugin = async ({ directory }) => {
  setStatus("idle"); // sensible default before the first event fires

  return {
    event: async ({ event }) => {
      debugLog(event);

      switch (event.type) {
        // Agent actively doing something
        case "session.created":
        case "tool.execute.before":
        case "message.part.updated":
          setStatus("working");
          break;

        // session.status carries an explicit busy/idle flag on most
        // OpenCode versions — trust it over the heuristics above when present
        case "session.status": {
          const s = event.properties?.status ?? event.data?.status;
          if (s) setStatus(s === "idle" ? "idle" : "working");
          break;
        }

        case "permission.asked":
          setStatus("waiting");
          break;

        case "session.idle":
          setStatus("idle");
          break;

        case "session.error":
          setStatus("error");
          break;
      }
    },
  };
};
