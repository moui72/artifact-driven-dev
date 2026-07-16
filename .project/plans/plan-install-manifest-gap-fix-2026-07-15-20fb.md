---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: install-manifest-gap-fix
created: 2026-07-15
features: []
surfaced-defects: []
---

# Plan: install-manifest-gap-fix

## Goal

Fix `install.sh`'s missing `cp` line for `scripts/feature-list.sh` so it
actually reaches installed projects, and add a packaging-manifest
regression test that catches this class of gap mechanically in future.

## Scope

In scope:
- `install.sh`: add the missing `cp` (and matching `chmod +x`) line for
  `scripts/feature-list.sh`, alongside the other `ardd-scripts` copies
  (F001).
- A regression-test case proving the fix, extending the existing
  `scripts/test-install-worktreeinclude.sh`'s "Case 1b" block (the same
  file that already checks `ardd-state.sh`/`ardd-update-check.sh`/
  `source-resolve.sh`/`worktree-reap.sh` are installed and executable) —
  test-first per constitution Principle V.
- A packaging-manifest regression test: enumerate every `scripts/*.sh`
  referenced by a skill (`.claude/skills/*/SKILL.md`, grepped for
  `ardd-scripts/<name>.sh`) or by CI (`.github/workflows/lint.yml`), and
  assert each has a corresponding `cp` line in `install.sh` (F002).

Out of scope:
- No change to `feature-list.sh`'s own behavior — this is purely a
  packaging gap, the script itself works correctly (already covered by
  `scripts/test-feature-list.sh`).
- No broader audit of every existing `cp` line for other undiscovered
  gaps — F002's new manifest test is what performs that audit going
  forward; this plan doesn't hand-verify the other ~19 lines.

## Technical Approach

F001 is a one-line fix: add
`cp "$SCRIPT_DIR/scripts/feature-list.sh" "$ARDD_SCRIPTS_DIR/feature-list.sh"`
next to the other `ardd-scripts` copies (`install.sh:169-184`), and add
`"$ARDD_SCRIPTS_DIR/feature-list.sh"` to the `chmod +x` list immediately
following. Proven by extending the existing installed-and-executable
check pattern in `scripts/test-install-worktreeinclude.sh`'s Case 1b
block (same file, same pattern: `[ -x "$target/.claude/skills/ardd-scripts/feature-list.sh" ]`).

F002 is the actual fix for the *class* of gap, not just this instance:
a new script, `scripts/test-install-manifest-complete.sh`, that
mechanically diffs "scripts referenced by something that expects them
installed" against "scripts install.sh actually copies." Two reference
sources: (a) every `.claude/skills/*/SKILL.md` containing a literal
`.claude/skills/ardd-scripts/<name>.sh` path (grep, extract `<name>.sh`),
and (b) `install.sh`'s own `chmod +x` argument list, which is a second
place a script could be forgotten independently of the `cp` list. Assert
every name from both sources has a matching `cp` line in `install.sh`.
This directly prevents a repeat of F001: a future skill referencing a
new script without extending `install.sh`'s manifest in the same commit
now fails this test.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| New dedicated test script (`test-install-manifest-complete.sh`) rather than folding the check into `test-install-worktreeinclude.sh` | That file tests `.worktreeinclude` + version-file + a handful of specific executables; a general manifest-completeness scan is a distinct concern (grepping all skill files, not fixture-specific), and keeping it separate matches this repo's existing one-script-per-concern test layout (Principle VI — avoid conflating distinct checks in one file just because both touch `install.sh`). |

## Phase Breakdown

### Phase 1: fix the reported gap [feedback: F001]

- T001 (test-first) Add a `feature-list.sh` case to
  `scripts/test-install-worktreeinclude.sh`'s "Case 1b" block (after
  the existing `worktree-reap.sh` check, ~line 183): assert
  `$target/.claude/skills/ardd-scripts/feature-list.sh` is executable,
  same `[ -x ... ]` pattern as the other four checks in that block. Run
  it and confirm it fails against the current `install.sh` (the file is
  genuinely absent post-install).
- T002 Add the missing line to `install.sh`:
  `cp "$SCRIPT_DIR/scripts/feature-list.sh" "$ARDD_SCRIPTS_DIR/feature-list.sh"`
  next to the other `ardd-scripts` copies (`install.sh:169-184`), and
  add `"$ARDD_SCRIPTS_DIR/feature-list.sh"` to the immediately-following
  `chmod +x` argument list. Confirm T001 now passes and
  `./scripts/test-install-worktreeinclude.sh` is green end to end.

### Phase 2: prevent recurrence [feedback: F002]

- T003 (test-first) Write `scripts/test-install-manifest-complete.sh`:
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
- T004 Write `scripts/test-install-manifest-complete.sh` itself
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
- T005 [parallel] Add a CI job for `test-install-manifest-complete.sh`
  to `.github/workflows/lint.yml`, following the existing per-script
  job pattern (this repo's CI enumerates jobs explicitly, unlike the
  pre-commit hook's glob).

## Open Questions

- Should the manifest-completeness check also cover `templates/*.md`
  and other non-`scripts/` files `install.sh` copies (e.g.
  `constitution-suggestions.md`, artifact templates)? Left out of scope
  — F001/F002 are specifically about `scripts/*.sh`, and those other
  copies aren't referenced by a `<name>.sh`-shaped path the same way,
  so the grep pattern doesn't generalize cleanly without more design.
  Revisit if a similar gap is ever found there.
