---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: backlog-assign-epics-automated
created: 2026-07-18
features: [backlog-assign-epics-automated]
surfaced-defects: []
---

# Plan: backlog-assign-epics-automated

## Goal

Add `/ardd-backlog --assign-epics`, a re-runnable, confirmation-gated
sweep that proposes `epic:` groupings across the backlogged feature
register and applies only the ones the user approves.

## Scope

**In scope:**
- A new `--assign-epics` mode on `/ardd-backlog`, structurally mirroring
  its existing `--from-artifacts` bulk mode (walk → propose → one
  batched confirmation → apply → report).
- Walks every `backlogged` (and, per the feature's own "should be
  re-runnable" requirement, any feature whose `epic` is absent —
  regardless of status, so a `planned`/`tasked` item that was skipped
  earlier can still be picked up later) feature register entry, reading
  its description and `Why:` line.
- Proposes thematic groupings by agent judgment, grounded in the
  register text — never invents a grouping the descriptions don't
  support. Items with no clear fit are proposed ungrouped/standalone,
  not forced into a bucket (mirroring the atelier dry run's explicit
  handling of the one speculative item that didn't cluster).
- One batched `AskUserQuestion` (multiSelect) presenting every proposed
  group, with per-group accept/decline — never N sequential prompts,
  matching `--from-artifacts`'s existing convention.
- A new `epic` key on `ardd-state.sh feature-field` (currently
  `plan|tasks|gh_issue` only) — the register-write path this feature's
  own spec sketch flagged as missing.
- Apply accepted groupings via the new `feature-field <slug> epic
  <value>` call, one per feature.
- Report the applied/declined counts, then the existing `/ardd-status`
  handoff (already in `/ardd-backlog`'s step 6) picks up the by-epic
  breakdown refresh — no change needed there.

**Out of scope:**
- Grouping open feedback files or `DEFECTS.md` entries by epic — the
  feature's own description mentions these as inputs a future pass
  *could* consider, but the register is the only place `epic:` actually
  lives (feedback/DEFECTS have no such field, and adding one is a
  separate, unscoped design question). This plan sticks to what the
  existing `epic` field actually governs: the feature register.
- Any UI beyond the existing `feature-list.sh --epic`/`/ardd-status`
  by-epic breakdown — this feature only automates *proposing and
  writing* the field, not new ways to view it.
- Reassigning or removing an existing `epic` value — this pass only
  ever proposes for features that currently lack one; changing an
  already-assigned epic is a reconsideration, `/ardd-feedback`'s
  territory, not this sweep's.

## Technical Approach

`--assign-epics` is added to `skills/ardd-backlog/SKILL.md` as a new
top-level mode, entered the same way `--from-artifacts` already is
(skip the single-idea steps, run a separate numbered procedure). It
reuses `scripts/feature-list.sh --all` (already installed, already
supports the `epic` column) to enumerate every feature and its current
`epic` value, filters in-process to entries with `epic` empty — no new
enumeration script needed, this filtering is a column check over
already-deterministic output, the same category of grep-over-script-
output already used elsewhere in this skill set (e.g.
`/ardd-implement --list`'s status-column filter).

The grouping proposal itself is agent judgment against free-text
register descriptions — not mechanizable, matching how `--from-artifacts`
already treats "is this a real capability" as agent classification, not
a script.

The one new mechanizable piece is the write path: `ardd-state.sh
feature-field` gains `epic` as a third valid key alongside
`plan|tasks|gh_issue`, with a regression test mirroring the existing
`plan`/`tasks`/`gh_issue` test blocks in `scripts/test-ardd-state.sh`.

## Phase Breakdown

### Phase 1: `epic` write path (test-first, independent of Phase 2)
- T001 (test-first) Add a regression case to `scripts/test-ardd-state.sh`
  covering `feature-field <slug> epic <value>` — set, replace, and (per
  the existing pattern for the other three keys) confirm an unknown key
  is still refused. Confirm the new `epic` case fails against current
  `ardd-state.sh` first (red — `epic` isn't a recognized key yet).
- T002 Add `epic` to `ardd-state.sh feature-field`'s valid-key case
  statement (`plan|tasks|gh_issue` → `plan|tasks|gh_issue|epic`). T001's
  case goes green.

### Phase 2: `--assign-epics` sweep mode (depends on Phase 1 for the write path it calls)
- T003 Add the `--assign-epics` usage line and mode-dispatch to
  `skills/ardd-backlog/SKILL.md`'s Usage section (mirroring
  `--from-artifacts`'s existing dispatch), and write the new mode's
  numbered procedure: enumerate every feature via `feature-list.sh
  --all`, filter to those with an empty `epic` column, propose thematic
  groupings by judgment (grounded in each entry's description/`Why:`
  line — never invented), leave any non-clustering item standalone
  rather than forcing a group.
- T004 [parallel] Write the batched-confirmation step: one
  `AskUserQuestion` (multiSelect) listing every proposed group with
  per-group accept/decline, mirroring `--from-artifacts`'s existing
  batched-prompt convention exactly (same tool, same one-call-not-N
  discipline).
- T005 Write the apply step: for each accepted group's features, call
  `ardd-state.sh feature-field <slug> epic <value>` (from Phase 1); for
  declined groups, apply nothing. Report applied/declined counts. No new
  `/ardd-status` handoff logic needed — `/ardd-backlog`'s existing step 6
  already runs `/ardd-status`, which already has the by-epic breakdown
  wired from the earlier `epics-grouping-in-feature-regi` feature.
- T006 Update `docs/reference/skills/ardd-backlog.md`'s hand-written body
  to document `--assign-epics`, mirroring how `--from-artifacts` is
  already documented there.

## Open Questions

- Whether re-running `--assign-epics` against a backlog where some
  features already have an `epic` and some don't should also *suggest*
  adding a not-yet-assigned feature to an *existing* epic value (found
  via a prior run), versus only ever proposing brand-new group names —
  leaning toward also considering existing epic values as candidate
  buckets, since that's the more useful "grows an existing list
  incrementally" behavior the feature's own "should be re-runnable" pain
  point implies, but left to implementation judgment since the register
  text is what would need to signal the fit either way.
