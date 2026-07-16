---
plan: plan-install-manifest-gap-fix-2026-07-15-20fb.md
generated: 2026-07-15
status: ready   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: fix the reported gap [feedback: F001]

- [ ] T001 (test-first) Add a `feature-list.sh` case to
  `scripts/test-install-worktreeinclude.sh`'s "Case 1b" block (after
  the existing `worktree-reap.sh` check, ~line 183): assert
  `$target/.claude/skills/ardd-scripts/feature-list.sh` is executable,
  same `[ -x ... ]` pattern as the other four checks in that block. Run
  it and confirm it fails against the current `install.sh` (the file is
  genuinely absent post-install).

- [ ] T002 Add the missing line to `install.sh`:
  `cp "$SCRIPT_DIR/scripts/feature-list.sh" "$ARDD_SCRIPTS_DIR/feature-list.sh"`
  next to the other `ardd-scripts` copies (`install.sh:169-184`), and
  add `"$ARDD_SCRIPTS_DIR/feature-list.sh"` to the immediately-following
  `chmod +x` argument list. Confirm T001 now passes and
  `./scripts/test-install-worktreeinclude.sh` is green end to end.

## Phase 2: prevent recurrence [feedback: F002]

- [ ] T003 (test-first) Write `scripts/test-install-manifest-complete.sh`:
  fixture-based (a throwaway temp dir with a couple of fabricated
  `.claude/skills/*/SKILL.md` files referencing `ardd-scripts/*.sh`
  paths, plus a minimal fabricated `install.sh` with a deliberately
  incomplete `cp` manifest) proving the check reports the missing
  script and passes when the manifest is complete. Also include a
  real-repo assertion: run the check against this actual repo's
  `skills/*/SKILL.md` and `install.sh` and confirm it currently reports
  nothing missing (T002 already closed the one known gap). Confirm the
  fixture-based failure case fails as expected against the
  not-yet-written script.

- [ ] T004 Write `scripts/test-install-manifest-complete.sh` itself
  (despite the "test-" prefix per this repo's existing naming
  convention for glob-discovered pre-commit/CI scripts — note in a
  comment at the top of the file that it is itself a check script, not
  a test of another script, mirroring how `scripts/lint-project.sh` and
  `scripts/lint-docs.sh` are structured): grep every
  `skills/*/SKILL.md` for `ardd-scripts/<name>\.sh` references, grep
  `install.sh`'s `chmod +x` argument list for `<name>\.sh` names, union
  both as the "expected" set, then grep `install.sh`'s `cp` lines for
  `scripts/<name>\.sh ` source paths as the "actual" set; report any
  name in expected-but-not-actual. Confirm T003's assertions now pass.

- [ ] T005 [parallel] Add a CI job for
  `test-install-manifest-complete.sh` to `.github/workflows/lint.yml`,
  following the existing per-script job pattern (this repo's CI
  enumerates jobs explicitly, unlike the pre-commit hook's glob).
