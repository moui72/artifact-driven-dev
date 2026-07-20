---
plan: plan-badge-guards-2026-07-20-8b60.md
generated: 2026-07-20
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Red tests

- [x] T001 Extend `scripts/test-install-version-badge.sh` with three
  red-first cases pinning the S9 findings (feedback `b8b6` F001–F003):
  (a) env-unset install over a README carrying
  `ardd-badge-version-start` markers must NOT print the static-badge
  suggestion, and must print a one-line acknowledgment naming the found
  form; (b) `ARDD_VERSION_BADGE=1` install over a README carrying
  `ardd-badge-pair-start` markers must NOT print the full paste-this
  snippet block — instead a short "already badged via pair markers" note
  pointing at `templates/badge.md` (supporting files still
  written/refreshed as usual); (c) `ARDD_VERSION_BADGE=1` install into a
  README-less repo: the pointer must acknowledge the flag is already set
  ("create a README and re-run" phrasing, not "re-run with
  ARDD_VERSION_BADGE=1"). Run the script and confirm all three new cases
  FAIL against current install.sh (red-first checkpoint — commit with
  the repo's established red-first shell-test convention, documented in
  the commit body).

## Phase 2: Fix

- [ ] T002 In install.sh's badge section, add marker-family detection (a
  small helper or case block identifying which of `ardd-badge-start`,
  `ardd-badge-version-start`, `ardd-badge-pair-start` the README
  carries — beware substring overlap: `ardd-badge-start` naively greps
  as a substring of nothing, but `ardd-badge-version-start` and
  `ardd-badge-pair-start` both contain `ardd-badge-`, so match the full
  marker tokens with word-exact patterns) and branch both guards on it:
  the env-unset static-suggestion path (~line 588) suppresses the
  suggestion when ANY family is present and prints the acknowledgment
  naming the form; the `ARDD_VERSION_BADGE=1` snippet path (~line 555)
  keeps current behavior for `version` markers and replaces the paste
  block with the "already badged via <form> markers, see
  templates/badge.md to switch shapes" note for `pair`/`static`. Update
  the no-README pointer to branch on `ARDD_VERSION_BADGE` being set. All
  three T001 cases plus the full existing suite green; `lint-docs.sh`
  green. (Post-merge regression gate, coordinator-level, not a task:
  rerun `/scenario-sweep S9`.)
