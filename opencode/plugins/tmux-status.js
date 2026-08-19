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
let status = "-"; // one of: w i e -  ("q" is derived, never stored here)
let waitingInput = false; // true while a question or permission is pending
let lastTitle = ""; // last OSC title pushed, to skip redundant writes
// SessionIDs of subagents that descend from the focused session and have been
// seen asking for input. The plugin API can't enumerate sessions, so we learn
// subagent IDs from events and track them here. Cleared on session switch.
const subagentSessions = new Set();

export default {
  id: "tmux-status",
  tui: async (api) => {
    // Best-effort: a failure here must never take down the TUI.
    try {
      // Take ownership of the terminal title: disable the TUI core's own
      // reactive title-setting so it doesn't fight us.
      api.kv.set("terminal_title_enabled", false);

      status = "-";
      waitingInput = false;
      lastTitle = "";
      subagentSessions.clear();

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

      // The effective status char: a pending question or permission overrides
      // everything to "q" (the TUI is blocked waiting for the user's input).
      function effectiveStatus() {
        return waitingInput ? "q" : status;
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

      // A question/permission can only be pending while the turn is working.
      // Used to gate the waiting-input poll. Also stays active while a tracked
      // subagent is still working, so its pending input keeps being polled.
      function turnActive() {
        if (status === "w") return true;
        for (const sid of subagentSessions) {
          let st;
          try {
            st = api.state.session.status(sid);
          } catch {
            continue; // a throw mustn't break the loop
          }
          const t = typeof st === "string" ? st : st?.type;
          if (t === "busy") return true;
        }
        return false;
      }

      // Change the base status and re-emit, skipping the OSC write if the
      // effective title is unchanged.
      function applyStatus(next) {
        if (status === next) return;
        status = next;
        // A pending question/permission can't survive the turn ending; clear a
        // stale flag so the title doesn't stick on "q" after the session goes
        // idle.
        if (!turnActive() && waitingInput) waitingInput = false;
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

      // True if `sessionID` is a descendant of `ancestorID`, walking the
      // parentID chain (a subagent's parentID points at its parent). Capped so
      // a malformed/cyclic chain can't loop forever.
      function isDescendantOf(sessionID, ancestorID) {
        let cur = sessionID;
        for (let i = 0; i < 10; i++) {
          if (cur == null) return false;
          if (cur === ancestorID) return true;
          cur = api.state.session.get(cur)?.parentID;
        }
        return false;
      }

      // Like matchesFocused, but also accepts events from subagents that
      // descend from the focused session. Used by the permission/question
      // handlers only (a subagent's busy/idle/error must NOT touch the focused
      // pane's status char). Tracks accepted subagent IDs so the poll can keep
      // the turn active and look them up.
      function matchesFocusedOrSubagent(event) {
        const sid = eventSessionID(event);
        if (sid == null) return true;
        const cur = currentSession();
        if (cur.id == null) return false;
        if (sid === cur.id) return true;
        if (isDescendantOf(sid, cur.id)) {
          subagentSessions.add(sid);
          return true;
        }
        return false;
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

      // Waiting on user input (permission). Fast path: flag the waiting state
      // immediately so the title flips to "q" without waiting for the poll.
      // The poll below is the authoritative source (this event alone can be
      // clobbered by a later "busy" status).
      api.event.on(
        "permission.v2.asked",
        safe((event) => {
          if (!matchesFocusedOrSubagent(event)) return;
          if (!waitingInput) {
            waitingInput = true;
            emit();
          }
        }),
      );

      // Waiting on user input (question). Defensive fast path: on the current
      // opencode version this event does NOT reach the plugin event bus, so the
      // poll below is the primary question signal.
      api.event.on(
        "question.v2.asked",
        safe((event) => {
          if (!matchesFocusedOrSubagent(event)) return;
          if (!waitingInput) {
            waitingInput = true;
            emit();
          }
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
      // Drop tracked subagents first: they belonged to the old focused session.
      api.event.on(
        "tui.session.select",
        safe(() => {
          subagentSessions.clear();
          emit();
        }),
      );

      // Authoritatively poll for pending input (question OR permission), but
      // only while the turn is active (input can't be pending once the session
      // goes idle). This is the primary signal: the permission route does not
      // push a distinct keymap mode (unlike the question route's "question"
      // mode), and the permission event alone can be clobbered by a later
      // "busy" status. The state store is the same source the footer uses.
      setInterval(() => {
        if (!turnActive()) return;
        try {
          const { id } = currentSession();
          if (id == null) return;
          const questions = api.state.session.question(id) ?? [];
          const permissions = api.state.session.permission(id) ?? [];
          let next = questions.length > 0 || permissions.length > 0;
          // The focused session isn't pending, but a tracked subagent might be.
          if (!next) {
            for (const sid of subagentSessions) {
              const qs = api.state.session.question(sid) ?? [];
              const ps = api.state.session.permission(sid) ?? [];
              if (qs.length > 0 || ps.length > 0) {
                next = true;
                break;
              }
            }
          }
          if (next === waitingInput) return;
          waitingInput = next;
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
