---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: prerelease-sweep-fixes
created: 2026-07-18
features: []
surfaced-defects: []
---

# Plan: prerelease-sweep-fixes

## Goal

Fix the 6 findings accepted from the 2026-07-18 full prerelease sweep
(`feedback-prerelease-sweep-2026-07-18-50ea-ad22.md`), clearing the way
for a 1.0 stable cut — highest priority: `install.sh`'s `Channel:`
default fighting its own `Source-Ref:` in the normal between-releases
state.

## Scope

**In scope:** all 6 feedback items (F001–F006), each a small, well-scoped
fix with a confirmed root cause:
- F001: `install.sh`'s `Channel` default doesn't account for the source
  checkout's actual tag shape.
- F002: `ARDD_VERSION_BADGE=1` silently no-ops when a static badge marker
  already exists in the target README.
- F003: `ardd-state.sh feature-flip <slug> implemented` has no
  cross-check against the bound tasks file's actual completion status.
- F004: `ardd-state.sh task-check`'s error message doesn't explain a
  malformed/colon-suffixed checkbox mismatch.
- F005: `lint-project.sh`'s `plan:` frontmatter error garbles the message
  when given a path instead of a bare filename.
- F006: `skills/ardd-status/SKILL.md` doesn't document the
  epic-drained-to-zero case for the by-epic breakdown.

**Out of scope:**
- Re-running the sweep itself — that's the regression-rerun step after
  this plan's fixes merge (`/prerelease-sweep S2 S3 S4 S6 S7`, the
  scenarios that produced these findings), not part of this plan.
- Any of the taste-deferred or duplicate items from the triage
  (`dev-notes/prerelease-runs/2026-07-18-50ea/TRIAGE.md`) — only the 6
  accepted findings are in scope.
- Dispatching the stable-release workflow itself — a separate, later
  decision once this plan's fixes are verified.

## Technical Approach

**F001** — `install.sh`'s existing channel-precedence comment (around
line 373) already states the intended order: explicit `$ARDD_CHANNEL` >
previously-recorded channel (never silently flip an existing beta
consumer back to stable) > a sensible default. The bug is in the third
tier: the default is a hardcoded `stable`, ignoring `$SOURCE_REF`'s own
shape even though `SOURCE_REF` is computed just above it in the same
block. Fix: when neither `$ARDD_CHANNEL` nor a previously-recorded
channel apply (first install, no explicit request), infer the default
from whether `$SOURCE_REF` matches the `-beta.` suffix convention this
repo already uses elsewhere (`next-version.sh`, `source-resolve.sh`) —
`beta` if `SOURCE_REF` contains `-beta.`, `stable` otherwise (covers both
a plain stable tag and the no-tag/dev-mode case, where `stable` remains
the correct default per the existing "absent = stable" consumer parse
rule).

**F002** — the badge block's entire body (both the static-only path and
the `ARDD_VERSION_BADGE=1` path) is currently gated on one condition:
`README.md` exists AND lacks the `ardd-badge-start` marker. Fix: split
the gate. The *print-the-static-suggestion-for-the-first-time* behavior
stays gated on marker absence (unchanged). The *write-the-supporting-files
-when-opted-in* behavior (workflow + seed JSON) should fire whenever
`ARDD_VERSION_BADGE=1`, regardless of whether the static marker is
already present — a project that already adopted the static badge is
exactly the kind of consumer who'd want the dynamic upgrade, and
shouldn't need to silently discover (or worse, never discover) that they
have to strip the marker first. The idempotent "don't overwrite existing
files" behavior for the two supporting files stays unchanged.

**F003** — `cmd_feature_flip` (`scripts/ardd-state.sh`) already reads the
feature file (`feature_file "$slug"`) and its frontmatter. Add: when the
transition is specifically `tasked -> implemented` and the feature file
has a `tasks:` frontmatter field, read that tasks file's `status:` and
refuse the flip (clear error naming the tasks file and its actual
status) unless it is `completed`. If the feature has no `tasks:` field
(a flip performed some other way — reconcile mode, manual bookkeeping),
skip the check; this mirrors `completion-flip-check.sh`'s existing
narrow scope rather than inventing a new universal invariant.

**F004** — `cmd_task_check`'s error path, when the strict `- \[ \] $id `
pattern doesn't match, currently just says "no unchecked task '$id' in
$file" with no diagnostic help. Improve the message only (no matching
behavior change — the strict format is correct per `/ardd-plan`'s own
output convention): if a looser grep for `$id` finds *something* in the
file that isn't a clean unchecked-task line, name what was found (e.g.
"found '$id' but not in the expected '- [ ] $id ' format — check for a
trailing colon or other formatting issue") instead of a generic
not-found message.

**F005** — `lint-project.sh`'s `plan:` existence check
(`$PROJECT_DIR/plans/$planref`) silently produces a doubled/garbled path
when `$planref` contains a `/` (a path was given instead of a bare
filename), because it always prepends `$PROJECT_DIR/plans/` without
checking for that case first. Fix: detect a `/` in `$planref` before
constructing the existence-check path and, if found, report a distinct,
clear message ("expected a bare filename, got a path: '$planref'")
instead of running (and reporting) the doubled-path existence check.

**F006** — a documentation-only addition to
`skills/ardd-status/SKILL.md`'s by-epic breakdown section (around the
existing "omit this... if no feature carries a non-empty epic" note):
state explicitly that an epic value that previously had entries but now
has zero remaining in `backlogged`/`planned`/`tasked` (all moved to
`implemented`/`retired`) simply drops out of the breakdown on its own —
a natural consequence of the existing counting rule, not a special case
requiring different handling, but worth stating so a future reader
doesn't wonder whether a "0/0/0" line should appear instead.

## Phase Breakdown

### Phase 1: `install.sh` fixes (F001, F002)
Depends on: —
- T001: Fix F001 in `install.sh` — infer the default `CHANNEL` from
  `$SOURCE_REF`'s `-beta.` suffix shape when neither `$ARDD_CHANNEL` nor
  a previously-recorded channel apply, per the Technical Approach above.
  Preserve the existing precedence comment's intent (explicit request >
  preserve existing recorded channel > sensible default) — only the
  third tier's hardcoded `stable` changes.
- T002: Manually verify T001: run `./install.sh <fresh-target>` from
  this checkout (currently at a beta tag) with no `ARDD_CHANNEL` set and
  no prior `.project/ardd-version.md` — confirm `Channel: beta` is now
  recorded (matching `Source-Ref:`'s actual prerelease tag), and that
  `lint-project.sh`'s `channel-source-ref-consistency` check no longer
  fires on this now-consistent pair. Also verify: an explicit
  `ARDD_CHANNEL=stable ./install.sh` still forces `stable` regardless of
  `SOURCE_REF`'s shape (explicit request wins), and a re-install against
  a target with a previously-recorded `Channel: beta` still preserves
  `beta` even if `ARDD_CHANNEL` is unset (existing "never silently flip"
  rule, unaffected by this fix).
- T003 [parallel] Fix F002 in `install.sh` — split the badge block's
  gate per the Technical Approach above: the supporting-file writes
  (workflow + seed JSON) fire whenever `ARDD_VERSION_BADGE=1`,
  independent of whether `ardd-badge-start` already exists in the
  target's README; the static-suggestion print for a first-time adopter
  stays gated on the marker's absence, unchanged.
- T004 [parallel] Manually verify T003: create a fixture target with a
  README already containing the `ardd-badge-start` marker (simulating a
  prior static-badge adopter), run `ARDD_VERSION_BADGE=1 ./install.sh
  <that-target>`, and confirm both supporting files are now written
  (previously: silent no-op). Also re-confirm the existing behaviors are
  unaffected: a target with no README gets no badge output at all;
  `ARDD_VERSION_BADGE` unset behaves byte-for-byte as before.
- T005 Extend `scripts/test-install-version-badge.sh` with a case
  covering T003's fix (marker-already-present + `ARDD_VERSION_BADGE=1`
  writes both files) and extend the channel-recording test coverage
  (wherever `install.sh`'s Channel-default behavior is currently tested,
  or add a case if none exists) for T001's fix (beta-tag source with no
  prior recorded channel and no `ARDD_CHANNEL` produces `Channel: beta`).

### Phase 2: `ardd-state.sh` fixes (F003, F004)
Depends on: —
[parallel] with Phase 1 (different files)
- T006 [parallel] Fix F003 in `scripts/ardd-state.sh`'s
  `cmd_feature_flip` — add the `tasked -> implemented` completion
  cross-check per the Technical Approach above (read the feature's
  `tasks:` field if present, refuse the flip with a clear error unless
  that tasks file's `status:` is `completed`; skip the check entirely if
  no `tasks:` field is recorded).
- T007 [parallel] Add a red-then-green regression case to
  `scripts/test-ardd-state.sh` for T006: confirm `feature-flip <slug>
  implemented` is refused (with a clear error naming the tasks file and
  its actual status) when the bound tasks file is not `completed`, and
  succeeds normally once it is. Also confirm a feature with no `tasks:`
  field flips freely (no regression to existing behavior).
- T008 [parallel] Improve F004's error message in
  `scripts/ardd-state.sh`'s `cmd_task_check` per the Technical Approach
  above — no change to the matching behavior itself, only a more
  diagnostic message when the strict pattern fails to match but a looser
  search finds the task ID elsewhere in a different format.
- T009 [parallel] Add a regression case to `scripts/test-ardd-state.sh`
  for T008: a `T001:` (colon-suffixed) checkbox format produces the new,
  more specific error message rather than the old generic one.

### Phase 3: `lint-project.sh` and docs fixes (F005, F006)
Depends on: —
[parallel] with Phases 1–2 (different files)
- T010 [parallel] Fix F005 in `scripts/lint-project.sh`'s `plan:`
  existence check — detect a `/` in the `plan:` frontmatter value before
  constructing the existence-check path, per the Technical Approach
  above, and report the distinct clearer message instead of the doubled
  path.
- T011 [parallel] Add a fixture case to whichever `test-lint-project.sh`
  (or equivalent) fixture set covers the `plan:` existence check for
  T010: a tasks file whose `plan:` value contains a path (not a bare
  filename) produces the new clear message, not the old doubled-path
  message.
- T012 [parallel] Fix F006 — add the epic-drained-to-zero note to
  `skills/ardd-status/SKILL.md`'s by-epic breakdown section per the
  Technical Approach above (a documentation-only addition, no behavior
  change — the counting rule already handles this correctly; only the
  prose was silent on it).

## Complexity Tracking

No deviations requiring justification — each fix targets one confirmed
root cause with a narrow, existing-pattern-following change (channel
inference mirrors this repo's existing `-beta.` suffix convention;
feature-flip's cross-check mirrors `completion-flip-check.sh`'s existing
narrow scope; the two error-message fixes add no new behavior, only
clearer diagnostics).

## Open Questions

None — all 6 findings arrived with confirmed root causes from the
sweep's own reports, and each fix is a direct, narrowly-scoped change.
