---
plan: plan-pre-commit-lint-hook-2026-07-03.md
generated: 2026-07-03
status: in-progress
---

# Tasks

## Phase 1: Hook script and its test

- [x] T001 Add `scripts/test-hooks-pre-commit.sh`: a regression test for
  `hooks/pre-commit`'s aggregation/short-circuit logic. Build a temp dir with
  a `scripts/` subdirectory containing four stub scripts named identically to
  the real ones (`lint-docs.sh`, `test-lint-project.sh`,
  `test-branch-info.sh`, `test-hook-lint-on-write.sh`) plus a copy of
  `hooks/pre-commit`, then run it with that temp dir as cwd — mirroring the
  throwaway-fixture pattern already used by `scripts/test-branch-info.sh` and
  `scripts/test-hook-lint-on-write.sh`. Assert: (a) exits 0 when all four
  stubs exit 0, (b) exits non-zero and names the failing script when one
  stub exits non-zero, stopping before running any scripts after it in the
  sequence. Confirm this test fails right now — `hooks/pre-commit` doesn't
  exist yet (Principle V: test-first, red before green).
- [ ] T002 Add `hooks/pre-commit`: POSIX sh script, run from repo root
  (`cwd`, matching how git invokes hooks). Runs `./scripts/lint-docs.sh`,
  `./scripts/test-lint-project.sh`, `./scripts/test-branch-info.sh`,
  `./scripts/test-hook-lint-on-write.sh` in that order. On the first
  non-zero exit, print which script failed and abort (non-zero exit);
  otherwise exit 0 with no output (matches the other scripts' quiet-on-
  success convention). Confirm T001's test now passes (green).
- [ ] T003 Wire `scripts/test-hooks-pre-commit.sh` into
  `.github/workflows/lint.yml` as its own job, mirroring the existing job
  pattern (checkout + run script).

## Phase 2: Document the opt-in step

- [ ] T004 [parallel] Add the one-time `git config core.hooksPath hooks`
  step to `CLAUDE.md`'s Commands section, matching the existing command-list
  format, with a one-line note that this is a per-clone opt-in (git won't
  auto-enable a tracked hooks directory).
- [ ] T005 [parallel] Add a short contributor-facing note to `README.md`
  documenting the same opt-in step for working on this source repo itself —
  distinct from `install.sh`'s target-project instructions elsewhere in the
  same file (Principle IV: keep the two install targets separate).
