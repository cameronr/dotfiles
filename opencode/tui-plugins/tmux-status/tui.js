// OpenCode TUI plugin (V2 API): reports live agent status via the terminal (OSC) title.
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
// Discovered by the TUI from ~/.config/opencode/plugins/tmux-status/ (symlinked
// here by dotfiles/install). Do NOT register it in cli.json "plugins": the TUI
// silently skips cli.json entries that point at existing local files. The
// sibling index.js is a no-op server plugin so the server's own discovery of
// this directory doesn't fail (it can't resolve "@opencode-ai/plugin/tui").
//
// Requires:
//   - cli.json "terminal": { "title": false } so the TUI core's own reactive
//     title effect doesn't fight this plugin (V1 disabled this via kv; V2 has
//     no plugin-facing equivalent, so it must be set in cli.json).
//   - tmux with `set -g focus-events on` so terminal focus events reach the
//     TUI (used to clear the "done" check when you focus the pane again).
//
// Manual refresh/clear: ctrl+shift+r (default) clears the focused session's
// "done" / error check, the same as refocusing the pane. Also available via
// the command palette and /tmux-refresh. The bind is configurable through a
// `refresh_key` option, but only if this plugin is listed in cli.json
// "plugins" with options (it is not: it is directory-discovered, so the
// default bind applies).
//
// V2 API notes (ported from the V1 tui(api) plugin):
//   - api.event.on(type, fn)        -> context.data.on(type, fn); payload in event.data
//   - api.state.session.*           -> context.data.session.*
//   - api.state.session.question()  -> context.data.session.form.list() (questions are forms)
//   - api.state.session.status()    -> "idle" | "running"
//   - api.route.current             -> context.ui.router.current()
//   - api.renderer.setTerminalTitle -> context.renderer.setTerminalTitle()
//   - api.renderer.on("focus")      -> context.renderer.on("focus")
//   - "question.v2.asked" event     -> "form.created" (data.form.sessionID)
//   - "session.error" event         -> "session.execution.failed"
//   - "tui.session.select" event    -> "session.viewed" + route check in the poll
//
// Status model: the displayed char is derived per focused session from the
// data store, never stored globally. "w" comes from data.session.status()
// (running); "q" from non-empty form/permission lists for the session or a
// validated subagent; "i"/"e" from SessionInfo.time.idle + outcome, shown
// until the user has seen the result. "Seen" is tracked two ways: the
// server's time.viewed watermark, trusted only for completions the plugin
// did NOT observe live, and the local `dismissed` watermark (set on route
// arrival and terminal focus). Live completions ignore time.viewed because
// the TUI auto-sends session.viewed when a turn ends while its route is on
// the session - a route-based notion of "viewed" that does not reflect
// whether the user's eyes were on the terminal (e.g. they switched tmux
// tabs). The check therefore persists until arrival or terminal focus.

import { Plugin } from "@opencode-ai/plugin/tui";
import { createComponent } from "@opentui/solid";

// Preserved V1 API implementation (V1 tui(api) surface). Referenced so the
// V2 port stays diffable against it while the remaining gaps are fixed.
import v1 from "./v1.js";
export { v1 };

// Module-level state, kept so it survives across events for the TUI's life.
let lastTitle = ""; // last OSC title pushed, to skip redundant writes
// Local "user has seen this" watermark per session (epoch ms). Supplements the
// server's time.viewed, which updates asynchronously after a terminal focus or
// route change.
const dismissed = new Map();
// SessionIDs with known pending input, validated as descendants of the focused
// session at event time. Cleared on route change.
const pendingWatch = new Set();
// SessionIDs whose turn-end we observed live (execution.succeeded/failed/
// interrupted). For those the server's time.viewed is untrustworthy: the TUI
// auto-sends session.viewed the moment a turn ends while its route is on the
// session, which is a route-based notion of "viewed" that does not reflect
// whether the user's eyes were on the terminal (e.g. they switched tmux
// tabs). Only the local `dismissed` watermark (arrival / terminal focus)
// reliably means "user saw it".
const liveEnd = new Set();

export default Plugin.define({
  id: "tmux-status",
  setup(context) {
    // Best-effort: a failure here must never take down the TUI.
    try {
      // Last route sessionID seen, for arrival detection (session.viewed and
      // the poll). Referenced by the handlers below.
      let lastRouteID = null;

      lastTitle = "";
      dismissed.clear();
      pendingWatch.clear();
      liveEnd.clear();
      lastRouteID = null;

      const data = context.data;
      const renderer = context.renderer;

      // The session currently in focus (from the route), or the home
      // placeholder.
      function currentSession() {
        const route = context.ui.router.current();
        if (route && route.type === "session") {
          const s = data.session.get(route.sessionID);
          return { id: route.sessionID, title: s?.title };
        }
        return { id: null, title: "OpenCode" };
      }

      // The effective status char, derived per focused session from the data
      // store: pending input beats working; working beats a done/error result;
      // a result only shows while unviewed (server watermark or local
      // `dismissed`).
      function effectiveStatus() {
        const { id } = currentSession();
        if (id == null) return "-";
        if (pendingInput(id)) return "q";
        try {
          if (data.session.status(id) === "running") return "w";
        } catch {}
        try {
          const info = data.session.get(id);
          const idle = info?.time?.idle;
          if (idle == null || info?.outcome == null) return "-";
          const viewed = liveEnd.has(id)
            ? (dismissed.get(id) ?? 0)
            : Math.max(info.time.viewed ?? 0, dismissed.get(id) ?? 0);
          if (viewed >= idle) return "-";
          return info.outcome === "failed" ? "e" : "i";
        } catch {
          return "-";
        }
      }

      // True if the focused session or one of its subagents (family members or
      // event-learned pending IDs validated against it) has a pending question
      // or permission.
      function pendingInput(id) {
        const ids = [id];
        try {
          for (const sid of data.session.family(id) ?? []) {
            if (sid !== id && isDescendantOf(sid, id)) ids.push(sid);
          }
        } catch {}
        for (const sid of pendingWatch) {
          if (!ids.includes(sid)) ids.push(sid);
        }
        for (const sid of ids) {
          try {
            if ((data.session.form.list(sid) ?? []).length > 0) return true;
            if ((data.session.permission.list(sid) ?? []).length > 0) return true;
          } catch {}
        }
        return false;
      }

      // Push the encoded status + session title to the terminal, skipping the
      // OSC write if the resulting title is unchanged.
      function emit() {
        const { title } = currentSession();
        const session = (title ?? "OpenCode").slice(0, 40);
        const next = `OC | ${effectiveStatus()} ${session}`;
        if (next === lastTitle) return;
        lastTitle = next;
        renderer.setTerminalTitle(next);
      }

      // Mark the focused session as seen (local `dismissed` watermark) and
      // re-emit, clearing its "done" / error check. No-op unless the focused
      // session is currently showing the check (i or e). Shared by terminal
      // focus and the manual refresh keybind.
      function dismissFocused() {
        const { id } = currentSession();
        if (id == null) return;
        const status = effectiveStatus();
        if (status !== "i" && status !== "e") return;
        dismissed.set(id, Date.now());
        emit();
      }

      // Events carry the sessionID in data.sessionID, or in data.form.sessionID
      // for form.created.
      function eventSessionID(event) {
        return event?.data?.sessionID ?? event?.data?.form?.sessionID;
      }

      // True if `sessionID` is a descendant of `ancestorID`, walking the
      // parentID chain (a subagent's parentID points at its parent). Capped so
      // a malformed/cyclic chain can't loop forever.
      function isDescendantOf(sessionID, ancestorID) {
        let cur = sessionID;
        for (let i = 0; i < 10; i++) {
          if (cur == null) return false;
          if (cur === ancestorID) return true;
          cur = data.session.get(cur)?.parentID;
        }
        return false;
      }

      // Like a focused-only match, but also accepts events from subagents that
      // descend from the focused session. Used by the permission/question
      // handlers only (a subagent's busy/idle/error must NOT touch the focused
      // pane's status char).
      function matchesFocusedOrSubagent(event) {
        const sid = eventSessionID(event);
        if (sid == null) return true;
        const cur = currentSession();
        if (cur.id == null) return false;
        if (sid === cur.id) return true;
        return isDescendantOf(sid, cur.id);
      }

      // Wrap a handler so a thrown error can't break the event bus.
      const safe = (fn) => (event) => {
        try {
          fn(event);
        } catch {
          // Best-effort status display; ignore handler errors.
        }
      };

      const stops = [];

      // Turn lifecycle events. State is per-session and only the focused
      // session is displayed, so these simply trigger a recompute; the poll
      // below is the safety net.
      stops.push(
        data.on(
          "session.execution.started",
          safe(() => {
            emit();
          }),
        ),
      );

      stops.push(
        data.on(
          "session.execution.succeeded",
          safe((event) => {
            const sid = eventSessionID(event);
            if (sid != null) liveEnd.add(sid);
            emit();
          }),
        ),
      );

      // A user/shutdown/superseded interruption still ends the turn cleanly.
      stops.push(
        data.on(
          "session.execution.interrupted",
          safe((event) => {
            const sid = eventSessionID(event);
            if (sid != null) liveEnd.add(sid);
            emit();
          }),
        ),
      );

      // Error.
      stops.push(
        data.on(
          "session.execution.failed",
          safe((event) => {
            const sid = eventSessionID(event);
            if (sid != null) liveEnd.add(sid);
            emit();
          }),
        ),
      );

      // Defensive fallback: some builds may still emit "session.status"
      // (status is an object: { type: "busy" | "idle" | "retry" }). v2
      // primarily uses the session.execution.* events above.
      stops.push(
        data.on(
          "session.status",
          safe(() => {
            emit();
          }),
        ),
      );

      // Waiting on user input (permission). Fast path: remember the session so
      // pendingInput() keeps checking it, and recompute immediately so the
      // title flips to "q" without waiting for the poll.
      stops.push(
        data.on(
          "permission.asked",
          safe((event) => {
            if (!matchesFocusedOrSubagent(event)) return;
            const sid = eventSessionID(event);
            if (sid != null) pendingWatch.add(sid);
            emit();
          }),
        ),
      );

      // Waiting on user input (question). Questions are forms in V2; this is
      // the primary question signal alongside the poll.
      stops.push(
        data.on(
          "form.created",
          safe((event) => {
            if (!matchesFocusedOrSubagent(event)) return;
            const sid = eventSessionID(event);
            if (sid != null) pendingWatch.add(sid);
            emit();
          }),
        ),
      );

      // Fast-path clears: drop the watched ID as soon as the user answers,
      // cancels, or replies, and recompute without waiting for the poll.
      stops.push(
        data.on(
          "form.replied",
          safe((event) => {
            const sid = eventSessionID(event);
            if (sid != null) pendingWatch.delete(sid);
            emit();
          }),
        ),
      );

      stops.push(
        data.on(
          "form.cancelled",
          safe((event) => {
            const sid = eventSessionID(event);
            if (sid != null) pendingWatch.delete(sid);
            emit();
          }),
        ),
      );

      stops.push(
        data.on(
          "permission.replied",
          safe((event) => {
            const sid = eventSessionID(event);
            if (sid != null) pendingWatch.delete(sid);
            emit();
          }),
        ),
      );

      // Arrived at a session: mark it seen locally (the server's time.viewed
      // updates asynchronously), drop watched IDs from the old route, and
      // recompute.
      stops.push(
        data.on(
          "session.viewed",
          safe((event) => {
            const sid = eventSessionID(event);
            const { id } = currentSession();
            if (sid != null && sid === id && id !== lastRouteID) {
              lastRouteID = id;
              pendingWatch.clear();
              dismissed.set(id, Date.now());
            }
            emit();
          }),
        ),
      );

      // Safety-net poll: emit() is cheap local reads and dedupes via
      // lastTitle. Also catches focused-session changes that session.viewed
      // missed.
      const timer = setInterval(() => {
        try {
          const { id } = currentSession();
          if (id !== lastRouteID) {
            lastRouteID = id;
            pendingWatch.clear();
            if (id != null) dismissed.set(id, Date.now());
          }
          emit();
        } catch {
          // Best-effort; ignore.
        }
      }, 1000);

      // Clear the "done" / error check when the terminal is focused again.
      // This replaces the old tmux pane-focus-in hook.
      const onFocus = () => {
        try {
          dismissFocused();
        } catch {
          // Ignore.
        }
      };
      renderer.on("focus", onFocus);

      // Manual refresh/clear: same dismissal as a terminal focus. The keymap
      // layer is owned by this component (per the plugin SDK contract), so it
      // must be claimed through a UI slot component that is released on
      // cleanup below.
      function KeymapSetup() {
        context.keymap.layer(() => ({
          mode: "base",
          priority: 10,
          commands: [
            {
              id: "tmux.status.refresh",
              title: "Refresh tmux status",
              group: "Plugin",
              palette: true,
              slash: { name: "tmux-refresh" },
              bind: context.options?.refresh_key ?? "ctrl+shift+r",
              run: () => {
                try {
                  dismissFocused();
                } catch {
                  // Ignore.
                }
              },
            },
          ],
        }));
        return null;
      }
      const releaseStatusSlot = context.ui.slot({
        append: "prompt.footer.status",
        render: () => createComponent(KeymapSetup, {}),
      });

      // Initial title.
      emit();

      return () => {
        clearInterval(timer);
        for (const stop of stops) {
          try {
            stop();
          } catch {
            // Ignore.
          }
        }
        try {
          releaseStatusSlot();
        } catch {
          // Ignore.
        }
        try {
          renderer.off("focus", onFocus);
        } catch {
          // Ignore.
        }
      };
    } catch {
      // Best-effort; never take down the TUI.
    }
  },
});
