# Defects

_Last verified: 2026-07-06_

## constitution.md

- **Claim:** Shell scripts target POSIX sh and may be installed into arbitrary target projects
  **Actual:** `migrations/0001-diagram-stale.sh` and
  `migrations/0002-diagram-status.sh` use BSD-only `sed -i ''`, which
  fails under GNU sed — so on a Linux target project whose state predates
  those migrations, `install.sh`'s migration step breaks. Missed by the
  2026-07-05 verify run. Related gap: unlike 0003, neither migration has
  a fixture test (the testing-paradigm standard postdates them), which is
  why ubuntu CI never caught it.
  **Location:** migrations/0001-diagram-stale.sh:17, migrations/0002-diagram-status.sh:49,51
  **Severity:** broken-contract (Linux targets with pre-0002 state only; no-op for already-migrated projects)

- **Claim:** Behavioral smoke tests are required for state-mutating skill paths
  **Actual:** exactly one smoke scenario exists
  (`.github/workflows/smoke.yml`: `/ardd-feature` → `/ardd-plan`); the
  `/ardd-tasks`, `/ardd-implement`, `/ardd-converge`, `/ardd-feedback`,
  and `/ardd-sync` state-mutating paths have none. The standard as worded
  overclaims current coverage — either add scenarios as the smoke harness
  matures (it can't execute until the API key is provisioned) or soften
  the wording to "at least one scenario, expanding with the harness."
  **Location:** .github/workflows/smoke.yml:1
  **Severity:** drift

All other spot-checks passed: pre-commit runs the two lints plus every
`scripts/test-*.sh` by glob (v1.1.0 rule upheld); state mutations across
all ten state-touching skills are script-performed via `ardd-state.sh`
(Principle II as amended); the per-feature register standing decision
matches reality (migration 0003 applied, `lint-project.sh` enforces the
schema, no hand-maintained index exists); governance
footer/frontmatter/SIR agree (now also lint-enforced); the new scripts
are POSIX-clean (`[[:space:]]` classes, not bashisms); no vendored
dependencies.
