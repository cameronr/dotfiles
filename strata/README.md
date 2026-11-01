# strata - niko Strata (pre-rename) configs, kept in case the old stack is needed

- `run-unsloth.sh`: starts the niko Strata 0.2.0-beta image with the tuned configs in `configs/`
  (symlinked as ~/strata/run-unsloth.sh).
- `run-unsloth-eddoursul-strata.sh` + `configs/*-strata.json`: the eddoursul fork on the old Strata
  base (image `strata-eddoursul:watch-dd0390f`) - the rollback from the Lamina migration.
- `configs/upstream-*.json`: upstream Strata comparison configs.

The Lamina-era stack (prod launcher, tuned configs, bench rig, upstream watch) lives in
`../lamina/`.
