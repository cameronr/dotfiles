---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
metadata:
  opencode/autoinvoke: false
slash: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

## When to invoke

- The user said "reflect" or "/reflect".
- A complex task (5+ tool calls) just landed cleanly and the recipe is worth keeping.
- The agent hit dead ends, found the working path, and the path generalizes.
- The user corrected the agent's approach mid-task.
- A non-trivial workflow emerged that isn't captured anywhere.

Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent finds its own session before fanning out. Sessions live in SQLite at `~/.local/share/opencode/opencode.db` (WAL mode, so query with `sqlite3` in read-only mode or copy the file first if the DB is live). Do not read other projects' sessions. That crosses workspace boundaries and reads private chats from unrelated projects.

```bash
# <workspace-path> is spliced into the SQL: double any single quotes in it
# (e.g. /a/'b' becomes /a/''b''), same escaping the audit scripts use.
sqlite3 "file:$HOME/.local/share/opencode/opencode.db?mode=ro" \
  "SELECT id, title, datetime(time_created/1000, 'unixepoch')
   FROM (SELECT id, title, time_created, time_updated FROM session
         WHERE directory = '<workspace-path>'
         UNION ALL
         SELECT id, title, time_created, time_updated FROM session_v2
         WHERE directory = '<workspace-path>')
   ORDER BY time_updated DESC LIMIT 10"
```

Two session generations: V1 (`session` + `message` + `part`; order messages and parts by `time_created`) and V2 (`session_v2` + `session_message`; order by `seq`). V1 text content lives in `part.data.text`; V2 embeds the whole message, content parts included, in `session_message.data`. Timestamps are ms epoch integers.

For each candidate, check that its first user message contains the conversation's opening user prompt. Take the matching session id. If no session resolves, write a tight digest of the session and pass that instead.

### 2. Spawn three reviewers in parallel

One message, three `task` calls, one per reviewer. Distinct types are preferable (configure via `~/.config/opencode/pstack-roles.md`), but the defaults may share a type. Reviewers need MCP access for context lookups (tickets, chat threads, observability traces referenced in the transcript), so use types with full tool access. The prompt forbids file writes; the parent applies edits.

| Lens | `subagent_type` | Prompt template |
|---|---|---|
| Judgment | your configured reflect-judgment type (default `general`) | `references/judgment-reviewer.md` |
| Tooling | your configured reflect-tooling type (default `code-reviewer`) | `references/tooling-reviewer.md` |
| Divergent | your configured reflect-judgment type (default `general`) | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the session id or digest where marked. Reviewers return findings in the `task` response body.

### 3. Synthesize

One `task` call, `subagent_type: general` (or your configured reflect-judgment type). The synthesizer's quality check includes spot-verifying citations, which can require MCP access, so keep full tool access. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. The synthesizer already applies this criterion; this is a final pass before edits land. See the **encode-lessons-in-structure** principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org; do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Those are tracker submissions, not skill edits. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the `skill-creator` skill (from the `skill-creator` plugin) and run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `skill-creator` and run its description-optimization loop.
- `new skill via skill-creator: <kebab-name>`: hand creation to `skill-creator`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
