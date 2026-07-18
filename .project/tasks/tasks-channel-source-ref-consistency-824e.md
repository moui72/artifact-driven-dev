---
plan: plan-channel-source-ref-consistency-2026-07-18-461b.md
generated: 2026-07-18
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: the lint-project.sh check (test-first)
- [ ] T001 (test-first) Add fixtures and regression cases to
  `scripts/test-lint-project.sh`:
  1. Create `tests/fixtures/good-project/.project/ardd-version.md` with
     a consistent pairing: `Channel: stable` and either no `Source-Ref:`
     line at all, or a plain `Source-Ref: v1.2.3` (no prerelease
     suffix) — this must NOT be flagged.
  2. Create `tests/fixtures/bad-project/.project/ardd-version.md` with
     the atelier-shaped mismatch: `Channel: stable` paired with
     `Source-Ref: v1.2.3-beta.2` (a prerelease tag) — this MUST be
     flagged. Bump `scripts/test-lint-project.sh`'s
     `EXPECTED_BAD_FINDINGS` from `37` to `38` to account for the new
     finding.
  3. Add a standalone temp-dir case (mirroring the existing targeted
     single-field message-quality cases already in this file, e.g. the
     "invalid delegation value reported with allowed values" case)
     asserting the exact violation message names the file path, both
     field values (`Channel: stable`, the mismatched `Source-Ref:`
     value), and states the nature of the mismatch (a prerelease tag
     under a stable channel).
  Confirm all new/modified cases fail against current `lint-project.sh`
  first (red — no such check exists yet; `good-project`'s existing pass
  case and `bad-project`'s existing count are both still valid
  baselines to diff against). Apply the test framework's
  expected-failure marker on this red commit per the constitution's
  full-suite pre-commit hook convention (this repo has no language-level
  xfail marker for its POSIX-sh test scripts — use `--no-verify` with
  the emergency documented in the commit body, per existing precedent
  in this repo's own history).
  [feedback: n/a] [feature: channel-source-ref-consistency]
- [ ] T002 Add the `Channel:`/`Source-Ref:` consistency check to
  `scripts/lint-project.sh`: for each project's `.project/ardd-version.md`
  (if the file exists), extract the `Channel:` and `Source-Ref:` line
  values via `sed`/`grep` (matching the read style already used in
  `install.sh` and `scripts/ardd-update-check.sh` for this exact file —
  do not introduce a new parsing convention). If `Channel:` is exactly
  `stable` and `Source-Ref:` is present and matches a prerelease tag
  shape (reuse the `-beta.` suffix recognition pattern already codified
  in `scripts/source-resolve.sh`/`scripts/next-version.sh`, e.g. a
  `case` match on `*-beta.*` or a more general `-[a-zA-Z]` prerelease
  suffix after the `vX.Y.Z` core — check both scripts and follow
  whichever pattern is more general/reusable, per Principle VIII: check
  existing idioms before inventing a new regex), report a finding
  naming the file, the `Channel:` value, the `Source-Ref:` value, and
  that a prerelease tag under a `stable` channel is a self-contradictory
  pairing. T001's cases go green — remove its expected-failure marker.
  [feedback: n/a] [feature: channel-source-ref-consistency]
