---
plan: plan-prerelease-sweep-fixes-2026-07-18-d341.md
generated: 2026-07-18
status: completed
---

# Tasks

## Phase 1: `install.sh` fixes (F001, F002)
- [x] T001 Fix F001 in `install.sh`: infer the default `CHANNEL` from
  `$SOURCE_REF`'s `-beta.` suffix shape when neither `$ARDD_CHANNEL` nor
  a previously-recorded channel (`$PREV_CHANNEL`) applies — `beta` if
  `SOURCE_REF` contains `-beta.`, `stable` otherwise (covers both a
  plain stable tag and the no-tag/dev-mode case). Preserve the existing
  precedence: explicit `$ARDD_CHANNEL` wins first, then a
  previously-recorded channel is preserved (never silently flip an
  existing beta consumer back to stable), and only the third tier's
  hardcoded `stable` default changes to this inference.
- [x] T002 Manually verify T001: run `./install.sh <fresh-target>` from
  this checkout (currently at a beta tag) with no `ARDD_CHANNEL` set and
  no prior `.project/ardd-version.md` — confirm `Channel: beta` is now
  recorded (matching `Source-Ref:`'s actual prerelease tag), and that
  `lint-project.sh`'s `channel-source-ref-consistency` check no longer
  fires on this now-consistent pair. Also verify: an explicit
  `ARDD_CHANNEL=stable ./install.sh` still forces `stable` regardless of
  `SOURCE_REF`'s shape, and a re-install against a target with a
  previously-recorded `Channel: beta` still preserves `beta` even with
  `ARDD_CHANNEL` unset.
- [x] T003 [parallel] Fix F002 in `install.sh`: split the badge block's
  gate — the supporting-file writes (workflow + seed JSON) fire whenever
  `ARDD_VERSION_BADGE=1`, independent of whether `ardd-badge-start`
  already exists in the target's README; the static-suggestion print for
  a first-time adopter stays gated on the marker's absence, unchanged.
- [x] T004 [parallel] Manually verify T003: create a fixture target with
  a README already containing the `ardd-badge-start` marker (simulating
  a prior static-badge adopter), run `ARDD_VERSION_BADGE=1 ./install.sh
  <that-target>`, and confirm both supporting files are now written
  (previously: silent no-op). Also re-confirm: a target with no README
  gets no badge output at all; `ARDD_VERSION_BADGE` unset behaves
  byte-for-byte as before.
- [x] T005 Extend `scripts/test-install-version-badge.sh` with a case
  covering T003's fix (marker-already-present + `ARDD_VERSION_BADGE=1`
  writes both files), and extend the relevant install test coverage for
  T001's fix (beta-tag source with no prior recorded channel and no
  `ARDD_CHANNEL` produces `Channel: beta`) — add a case to whichever
  existing install fixture test covers `Channel:`/`Source-Ref:`
  recording, or a new narrow test file if none currently covers this
  default-inference path.

## Phase 2: `ardd-state.sh` fixes (F003, F004)
- [x] T006 [parallel] Fix F003 in `scripts/ardd-state.sh`'s
  `cmd_feature_flip`: when the transition is specifically `tasked ->
  implemented` and the feature file has a `tasks:` frontmatter field,
  read that tasks file's `status:` and refuse the flip (clear error
  naming the tasks file and its actual status) unless it is `completed`.
  Skip the check entirely if the feature has no `tasks:` field.
- [x] T007 [parallel] Add a red-then-green regression case to
  `scripts/test-ardd-state.sh` for T006: confirm `feature-flip <slug>
  implemented` is refused (clear error naming the tasks file and its
  actual status) when the bound tasks file is not `completed`, and
  succeeds normally once it is. Also confirm a feature with no `tasks:`
  field flips freely (no regression to existing behavior).
- [x] T008 [parallel] Improve F004's error message in
  `scripts/ardd-state.sh`'s `cmd_task_check`: no change to the strict
  matching behavior itself — only a more diagnostic message when the
  strict `- \[ \] $id ` pattern fails to match but a looser search finds
  the task ID elsewhere in a different format (e.g. colon-suffixed),
  naming what was found instead of a generic not-found message.
- [x] T009 [parallel] Add a regression case to `scripts/test-ardd-state.sh`
  for T008: a `T001:` (colon-suffixed) checkbox format produces the new,
  more specific error message rather than the old generic one.

## Phase 3: `lint-project.sh` and docs fixes (F005, F006)
- [x] T010 [parallel] Fix F005 in `scripts/lint-project.sh`'s `plan:`
  existence check: detect a `/` in the `plan:` frontmatter value before
  constructing the existence-check path, and if found, report a
  distinct, clear message ("expected a bare filename, got a path:
  '$planref'") instead of running (and reporting) the doubled-path
  existence check.
- [x] T011 [parallel] Add a fixture case to the test suite covering
  `lint-project.sh`'s `plan:` existence check (`scripts/test-lint-project.sh`
  or the relevant fixture set) for T010: a tasks file whose `plan:`
  value contains a path (not a bare filename) produces the new clear
  message, not the old doubled-path message.
- [x] T012 [parallel] Fix F006: add the epic-drained-to-zero note to
  `skills/ardd-status/SKILL.md`'s by-epic breakdown section (near the
  existing "omit this... if no feature carries a non-empty epic" note)
  — state explicitly that an epic value with zero entries remaining in
  `backlogged`/`planned`/`tasked` (all moved to
  `implemented`/`retired`) simply drops out of the breakdown on its own,
  a natural consequence of the existing counting rule, not a special
  case requiring different handling.
