---
status: open      # open -> planned
created: 2026-07-20
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

From `/scenario-sweep S9` regression run `2026-07-20-7b1a` (b8b6
F001–F003 all verified fixed; report
`dev-notes/scenario-runs/2026-07-20-7b1a/S9-report.md`). Two other
findings taste-deferred and one declined as by-design — triage table on
disk in that run directory.

## Bugs
- [ ] F001 `templates/ardd-badge-workflow.yml` hardcodes
  `on.push.branches: [main]`, so on a repo whose default branch is
  `master` (or anything else) the badge-sync workflow never fires —
  even though install.sh's badge section already detects the target's
  real default branch and fills it into the endpoint URL in the printed
  snippet. Fix: fill the target's real default branch into the written
  workflow's `branches:` filter at install time via the same
  coordinate-fill mechanism the snippet already uses (install.sh writes
  the workflow file, so the substitution point exists); keep `[main]`
  as the template's placeholder form. Regression validation: extend
  `scripts/test-install-version-badge.sh` with a master-default fixture
  asserting the written workflow's `branches:` carries the real branch,
  then a final `/scenario-sweep S9` rerun — which is also the user's
  hard gate for dispatching stable.
