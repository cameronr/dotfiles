# global agent instructions

## SERIAL EXECUTION (MANDATORY)

When the active model is local (any llama-server, vllm, ollama, qwen, or anything running on localhost), NEVER spawn subagents in parallel. Fire one subagent, wait for it to complete, then fire the next. Parallel requests to a local inference server cause request queuing, timeouts, and degraded quality for every in-flight request. This rule overrides any skill, playbook, or prompt that says "spawn in parallel" or "fire in one message." The correct behavior for local models is always serial, foreground subagents.

## Rules

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Be extremely concise. Sacrifice grammar for the sake of brevity.
- Use conventional style commits. Use scope modifiers when appropriate.
- When working on a larger change, use Worktrunk (`wt switch --create feature-x`) to create a temporary branch for your work. This allows multiple agents to work in parallel. When you're ready to merge the changes back in, make sure to commit your changes first with an appropriate message and then use `wt merge ` to bring the changes back into the main branch. Consider if you should squash commits to keep the history cleaner.
- Generate any temporary files in a project local directory (not in /tmp) and clean them up after use. This is to avoid polluting the system with temporary files and to ensure that the files are accessible to other agents if needed.
- Use `timeout` with commands that might not terminate on their own. This is to prevent agents from hanging indefinitely.
