# global agent instructions

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
- Before posting any GitHub PR or Issue (title, body, comments), always run the entire text through the `unslop` skill and apply its output. Never post AI-sounding text.

## lamina on this machine (cam, not for upstream)

Repo `~/lamina` (plus worktrees under `.worktrees/`), fork of eddoursul/Lamina; `origin` = cameronr/Lamina.

- Upstream's CONTRIBUTING.md applies to upstream submissions only. Develop directly on fork branches; do not open GitHub PRs for local phases.
- If you must use `gh` here, pass `--repo cameronr/Lamina`; gh otherwise resolves the `upstream` remote (eddoursul/Lamina).
- This box serves agent inference through llama-swap, which auto-starts the prod container `lamina` on any request. Never stop llama-swap itself.
- GPU tests run in `lamina-e2e:latest` (CUDA devel + python3 + build deps; model data `/home/cam/strata-data` mounts at `/data`):
  `~/lamina/run-e2e.sh <checkout-or-worktree> <script-in-checkout>`
  Run it as one atomic foreground command. The wrapper pauses llama-swap inference (no request can summon prod onto the GPUs mid-test), stops prod, runs the container, and resumes inference on every exit path, including interrupt. While it runs, inference answers 503 "all inference is paused", so expect your own next generation to fail and wait it out. If the wrapper is SIGKILLed the pause sticks: recover with `curl -X POST localhost:8020/api/models/resume`. If the llama-swap container restarts mid-test the pause is lost (it is in-memory) and prod returns; rare, accept it.
- `lamina-e2e:latest` is built from `.lamina-e2e.Dockerfile` in the `tier2-conversation-cache` worktree. The bare `nvidia/cuda:*-devel` images have NO python3 (the worktree `.venv` tools need it).
- Engine exactness gates run the deterministic config: `--adapt-every 0` + `STRATA_IQ_MT_MIN=1` + `--pcie-frac 0` + `--expert-cache` pinned BELOW the free-VRAM cap (the flag is a byte budget, capped by live free VRAM at startup) + `--second-gpu-gib <fixed>` + `--second-gpu-prefetch-mb 0` + `--no-prefill-borrow` + `--expert-profile` pointing at a FROZEN COPY of the learned profile (prod rewrites `/data/unsloth-ud-iq4_xs-learned.bin` every minute of traffic via `expert_profile_save_every: 1`; a mutable profile drifts the residency order; see `plans/01-engine-batching/phase-3-multiseq-verifier.md` prerequisite; scratch `.ph3-det.json` + `.ph3-profile.bin` in the batching worktree). Auto/free-VRAM sizing makes fresh processes drift; production runs `--adapt-every 1` and is not run-reproducible.
- Engine in the image: `/opt/strata/components/engine/*/strata`. Serve on native IQ packs needs `--native SHARD --spec T (>=2) --prefill CHUNK --mtp DIR --expert-profile P --expert-cache`.
- Batching-plan scratch worth keeping per checkout: `.ph1-e2e.sh` + `.ph1-e2e.json` (gate runner/config), `digests-phase1.txt` (baseline digests).
- NEVER emit chat-template special tokens literally (the im_start/im_end and tool-call fence tokens, `<` + `|name|>` forms) in chat output, code blocks, or tool call contents: they break the conversation framing. Always build them from parts in code, e.g. `chr(60) + "|im_start|>"`, and refer to them by name in prose. This applies to every message, not just engine scratch scripts.
