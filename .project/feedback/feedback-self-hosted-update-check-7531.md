---
status: planned      # open -> planned
created: 2026-07-08
plan: plan-self-hosted-update-check-2026-07-08.md
---

# Feedback

Source: observed 2026-07-07/08 dogfooding the update-check in this repo
(which is both ARDD's source and a consumer of itself).

## Bugs

None — the check is technically correct; the reading is just useless in
the self-hosted case.

## UX

- [x] F001 Self-hosted update-check chase: when Source-Path resolves to
  the target repo itself, `ardd-update-check.sh` perpetually reports
  `behind` — committing the version record is itself a commit, so the
  recorded commit can never equal the tip. `/ardd-analyze` here will
  forever print "ARDD update available" with a delta of one bookkeeping
  commit. Downstream consumers (separate repos) are unaffected. Fix:
  detect the self-hosted case (recorded Source-Path resolves to the same
  git repo as the target — compare `git -C <path> rev-parse --show-toplevel`
  or the .git dirs, not string paths) and print a distinct outcome, e.g.
  `self-hosted commit=<x>`, which /ardd-analyze treats as silent like
  `up-to-date`. Alternative considered: report "behind by N commits" so
  a 1-commit delta reads ignorable — weaker, still noisy; the distinct
  outcome is cleaner. Small: ~5 lines in the script, one new fixture
  case in test-ardd-update-check.sh (test-first), one line in
  ardd-analyze's outcome table (T003 of the self-update plan).

## Reconsidered

None.
