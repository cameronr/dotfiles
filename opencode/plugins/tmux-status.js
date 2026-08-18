// OpenCode TUI plugin: reports live agent status via the terminal (OSC) title.
//
// Why the title and not a tmux pane option? When opencode runs inside the sbx
// microVM, tmux is unreachable from inside the VM, so `tmux set-option -p`
// (the old approach) fails. The OSC terminal title, however, crosses the VM
// boundary, so the tmux theme can read the status back out of `pane_title`.
//
// Title encoding: "OC | <char> <session>" where <char> is a single char:
//   w = working
//   q = waiting (permission/question asked)
//   i = idle/done (the "green check" state)
//   e = error
//   - = none / cleared (no icon)
//
// The tmux theme (tmux-tokyo-night-theme-cam.sh) parses <char> and <session>
// out of the pane title and renders an icon accordingly.
//
// Install:
//   Project-local: .opencode/plugin/tmux-status.js
//   Global:        ~/.config/opencode/plugin/tmux-status.js
//
// Requires: tmux with `set -g focus-events on` so terminal focus events reach
// the TUI (used to clear the "done" check when you focus the pane again).

// Module-level state, kept so it survives across events for the TUI's life.
let status = "-"; // one of: w q i e -
let questionMode = false; // true while the TUI is showing a pending question
let lastTitle = ""; // last OSC title pushed, to skip redundant writes

export default {
  id: "tmux-status",
  tui: async (api) => {
    // Best-effort: a failure here must never take down the TUI.
    try {
      // Take ownership of the terminal title: disable the TUI core's own
      // reactive title-setting so it doesn't fight us.
      api.kv.set("terminal_title_enabled", false);

      status = "-";
      questionMode = false;
      lastTitle = "";

      // The session currently in focus (from the route), or the home
      // placeholder.
      function currentSession() {
        const route = api.route.current;
        if (route && route.name === "session") {
          const id = route.params?.sessionID;
          const s = api.state.session.get(id);
          return { id: id ?? null, title: s?.title };
        }
        return { id: null, title: "OpenCode" };
      }

      // The effective status char: a pending question overrides everything to
      // "q" (the TUI is blocked waiting for the user's answer).
      function effectiveStatus() {
        return questionMode ? "q" : status;
      }

      // Push the encoded status + session title to the terminal, skipping the
      // OSC write if the resulting title is unchanged.
      function emit() {
        const { title } = currentSession();
        const session = (title ?? "OpenCode").slice(0, 40);
        const next = `OC | ${effectiveStatus()} ${session}`;
        if (next === lastTitle) return;
        lastTitle = next;
        api.renderer.setTerminalTitle(next);
      }

      // A question can only be pending while the turn is active (working, or
      // waiting on a permission). Used to gate the question-mode poll.
      function turnActive() {
        return status === "w" || status === "q";
      }

      // Change the base status and re-emit, skipping the OSC write if the
      // effective title is unchanged.
      function applyStatus(next) {
        if (status === next) return;
        status = next;
        // A question can't survive the turn ending; clear a stale flag so the
        // title doesn't stick on "q" after the session goes idle.
        if (!turnActive() && questionMode) questionMode = false;
        emit();
      }

      // Events carry the sessionID in properties.sessionID or
      // properties.info.id.
      function eventSessionID(event) {
        return event?.properties?.sessionID ?? event?.properties?.info?.id;
      }

      // Only let an event affect the title if it belongs to the focused
      // session, so subagent/background sessions don't clobber the focused
      // pane's title. Events with no sessionID are always applied.
      function matchesFocused(event) {
        const sid = eventSessionID(event);
        if (sid == null) return true;
        const cur = currentSession();
        return cur.id != null && sid === cur.id;
      }

      // Wrap a handler so a thrown error can't break the event bus.
      const safe = (fn) => (event) => {
        try {
          fn(event);
        } catch {
          // Best-effort status display; ignore handler errors.
        }
      };

      // Primary working/done/error signal. status is an object
      // ({ type: "busy" | "idle" | "retry", ... }) on this opencode version,
      // but be defensive about a plain string too.
      api.event.on(
        "session.status",
        safe((event) => {
          if (!matchesFocused(event)) return;
          const st = event?.properties?.status ?? event?.data?.status;
          const t = typeof st === "string" ? st : st?.type;
          if (t === "busy") {
            applyStatus("w");
          } else if (t === "idle") {
            applyStatus("i");
          } else if (t === "retry") {
            applyStatus("e");
          }
        }),
      );

      // Waiting on user input (permission). This event does fire on the
      // current opencode version.
      api.event.on(
        "permission.v2.asked",
        safe((event) => {
          if (!matchesFocused(event)) return;
          applyStatus("q");
        }),
      );

      // Waiting on user input (question). Kept as a defensive fallback: on the
      // current opencode version this event does NOT reach the plugin event
      // bus, so the mode poll below is the primary question signal.
      api.event.on(
        "question.v2.asked",
        safe((event) => {
          if (!matchesFocused(event)) return;
          applyStatus("q");
        }),
      );

      // Error.
      api.event.on(
        "session.error",
        safe((event) => {
          if (!matchesFocused(event)) return;
          applyStatus("e");
        }),
      );

      // The focused session changed; re-emit for the newly focused session.
      api.event.on(
        "tui.session.select",
        safe(() => {
          emit();
        }),
      );

      // Poll the TUI mode to detect pending questions, but only while the turn
      // is active (a question can't be pending once the session goes idle).
      // There is no event for a question being asked on the current opencode
      // version, but the TUI enters a "question" mode while one is up, and
      // `api.mode.current()` exposes it.
      setInterval(() => {
        if (!turnActive()) return;
        try {
          let mode = "base";
          try {
            mode = api.mode.current();
          } catch {
            return;
          }
          const next = mode === "question";
          if (next === questionMode) return;
          questionMode = next;
          emit();
        } catch {
          // Best-effort; ignore.
        }
      }, 1000);

      // Clear the green "done" check when the terminal is focused again.
      // This replaces the old tmux pane-focus-in hook.
      api.renderer.on("focus", () => {
        try {
          if (status === "i") {
            status = "-";
            emit();
          }
        } catch {
          // Ignore.
        }
      });

      // Initial title.
      emit();
    } catch {
      // Best-effort; never take down the TUI.
    }
  },
};
