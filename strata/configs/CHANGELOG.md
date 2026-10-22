# Strata engine run configs - changelog

Configs for the two engines benchmarked against each other on mediabox
(RTX 4090 + RTX 3090, Qwen3.8-Flash-Next UD-IQ4_XS pack):

- `eddoursul-ud-iq4_xs-{single,dual}.json` - the eddoursul/Strata fork
  (`~/strata-eddoursul`, image `strata-eddoursul`). Uses `--main-gpu`/
  `--second-gpu`/`--head-split`, no `--layer-split`/`--batch-groups`/
  `--conversation-cache-*`. Run with `~/strata-eddoursul/run-unsloth.sh`.
- `upstream-ud-iq4_xs-{single,dual}.json` - upstream Niko1221/Strata
  (`~/strata`, image `strata-0.2.1.4`). Run with `../run-unsloth.sh`
  (lives here, symlinked as `~/strata/run-unsloth.sh`).

Both are bind-mounted to `/data/eddoursul.json` / `/data/strata-run.json`
by the run scripts; `@VISION_EXE@` is substituted at container start.
`single` = one GPU, `dual` = `--gpus all` (both cards).

This repo holds the real files; the repo clones hold symlinks:

    ~/strata-eddoursul/configs/eddoursul-ud-iq4_xs-*.json -> here
    ~/strata/configs/upstream-ud-iq4_xs-*.json            -> here

## 2026-10-21

- `run-unsloth.sh` here is now the 0.2.1.4 upstream runner (was
  `~/strata/run-unsloth-2.sh`); the 0.1-era runner that used to live here
  is dropped (image `strata`, `STRATA_STAGE_TRIM`, `/opt/strata/engine`
  paths - all superseded). `~/strata/run-unsloth.sh` keeps its symlink,
  so `bench_vs_fork.py` arm A now starts the 0.2 image.
- Moved all four configs here from the (untracked) `configs/` dirs in
  `~/strata` and `~/strata-eddoursul`; symlinked back. Upstream files
  renamed `unsloth-ud-iq4_xs-*` -> `upstream-ud-iq4_xs-*` to distinguish
  the two engines at a glance; `run-unsloth-2.sh` updated.
- Paths updated to the flat 0.2 data layout: `~/strata-data` mounted at
  `/data` is itself the Strata data folder now (was `/data/Strata-data/...`
  from the nested default; `models/`, `packs/`, `mtp/`,
  `*-learned.bin` live at the `/data` root).
- Removed the 0.1-era `strata-unsloth-ud-iq4_xs-*.json` (superseded;
  visible in git history). The 0.1 runner `../run-unsloth.sh` reads its
  jsons from `~/strata-data/config/`, unaffected.

## 2026-10-20 (before the move)

- Fork configs created: fork-engine flags (`--main-gpu 0 --second-gpu 1`,
  `--expert-profile-save`), tuned `--pcie-frac 0`, `--spec-min-p 0.5`,
  `--spec-lookup 16`, `--kv-grow`, `--hc-q8`.
- Upstream configs re-pinned to the 0.2.1.4 image layout
  (`component:strata-engine`, `/opt/strata/terminal` cwd,
  `@VISION_EXE@` placeholder, `--trim-stage-weights` replacing the old
  `STRATA_STAGE_TRIM=1` env var).
