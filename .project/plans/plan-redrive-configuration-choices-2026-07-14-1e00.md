---
status: approved
branch: redrive-configuration-choices
created: 2026-07-14
features: [redrive-configuration-choices]
surfaced-defects: []
---

# Plan: redrive-configuration-choices

## Goal

Let a user re-answer the four workflow-configuration questions
(`workflow_mode`, `next_step_prompt`, `delegation`, `merge_policy`) at any
time after initial setup, instead of only once via `/ardd-init` or as a
one-time backfill via `/ardd-update`.

## Scope

**In scope:** a new `--reconfigure` mode on `/ardd-update` that re-asks all
four fields regardless of whether they're already set, shows current
values, and stamps only the ones the user chooses to change. Documentation
updates everywhere the "asked once" framing is currently stated as an
absolute (`CLAUDE.md`, `docs/reference/skills/ardd-update.md`,
`docs/reference/configuration.md`).

**Out of scope:** artifact changes (none needed — `constitution.md`'s
Governance section already treats these four fields as per-project
operational settings exempt from Sync Impact Report/versioning, and that
exemption already covers a value being changed, not just set); a
standalone `/ardd-configure` skill or an `/ardd-init --reconfigure` flag
(considered, not chosen — extending `/ardd-update` reuses its existing
per-install entry point and its existing step-5 backfill logic, which this
plan generalizes rather than duplicates); adding new workflow fields beyond
the four that already exist.

## Technical Approach

`/ardd-update` step 5 currently *backfills* `next_step_prompt`,
`delegation`, and (solo mode) `merge_policy` only when the field is absent
from `constitution.md` frontmatter entirely — `workflow_mode` is never
touched there at all (it's asked once, only by `/ardd-init`). This plan
generalizes that step: when `/ardd-update --reconfigure` is passed, every
field the ask would otherwise skip (because it's already present) is asked
anyway, showing its current value, and `workflow_mode` joins the set of
askable fields for the first time outside `/ardd-init`. Without the flag,
behavior is unchanged — bare `/ardd-update` still only backfills absent
fields, never touches ones already set. All writes continue to go through
`ardd-state.sh stamp`, the existing script-performed mutation path
(constitution Principle II) — no new script is needed since stamping an
already-present field works identically to stamping an absent one.

## Phase Breakdown

### Phase 1: `/ardd-update --reconfigure`

- [ ] T001 [artifacts: none] In `skills/ardd-update/SKILL.md`: update the
  Usage section to document `/ardd-update --reconfigure` alongside the
  bare form. Rewrite step 5 ("Ask the next-step-prompt question, once, if
  never asked" + the `delegation`/`merge_policy` backfill paragraph) so
  that: (a) without `--reconfigure`, behavior is unchanged — ask only
  fields absent entirely; (b) with `--reconfigure`, ask all four fields
  (`workflow_mode`, `next_step_prompt`, `delegation`, and — solo mode
  only — `merge_policy`) regardless of presence, presenting each
  field's current value (or "not yet set") before asking whether to
  keep it or choose a new value; stamp only fields the user actually
  changes via `ardd-state.sh stamp`. `workflow_mode` becomes reachable
  here for the first time outside `/ardd-init` — reuse the exact
  question wording `/ardd-init` uses for all four fields (grep
  `skills/ardd-init/SKILL.md` steps covering `workflow_mode`,
  `next_step_prompt`, and `delegation`/`merge_policy` for the wording to
  mirror). Never ask `merge_policy` in collaborative mode, matching
  existing behavior. Renumber the trailing report step's references if
  needed. [feature: redrive-configuration-choices]

### Phase 2: Documentation

Depends on Phase 1 (describes its behavior).

- [ ] T002 [artifacts: none] [parallel] Update
  `docs/reference/skills/ardd-update.md`: add `--reconfigure` to the
  `## Usage` code block and its prose, and rewrite item 5 in "What a run
  does" to describe both the default backfill-only behavior and the
  `--reconfigure` re-ask-everything behavior (mirroring T001's SKILL.md
  wording, not just restating "once"). [feature:
  redrive-configuration-choices]
- [ ] T003 [artifacts: none] [parallel] Update
  `docs/reference/configuration.md`: the intro paragraph currently states
  "`/ardd-update` backfills ... once for installs whose constitution
  lacks the field entirely — `workflow_mode` is never asked again and
  simply defaults to `solo` when absent." Replace with wording covering
  both the default backfill (unchanged) and the `--reconfigure` path
  (all four fields, including `workflow_mode`, can be re-asked on
  demand). [feature: redrive-configuration-choices]
- [ ] T004 [artifacts: none] [parallel] Update `CLAUDE.md`'s two
  "workflow field" passages (the `workflow_mode` paragraph, currently
  "...asked once by `/ardd-init`, detection-suggested)"; and the
  `next_step_prompt` paragraph, currently "...asked once by `/ardd-init`,
  and once by `/ardd-update` for installs whose constitution lacks the
  field)") to note that `/ardd-update --reconfigure` can re-ask either
  field afterward — one parenthetical clause each, not a rewrite of the
  surrounding architecture prose. [feature:
  redrive-configuration-choices]

No test tasks: every task in this plan is a documentation/prose change to
`SKILL.md` files and hand-written doc bodies, the explicit exception
Constitution Principle V carves out ("a pure research/decision task, or a
documentation-only change").

## Open Questions

None — the four fields, their enums, and their existing stamp mechanism
are all already established; this plan only adds a re-ask entry point.

## Summary of decisions made this run

- No artifact changes: `constitution.md`'s existing Governance exception
  for workflow fields already covers changing (not just setting) them.
- Chosen design: extend `/ardd-update` with a `--reconfigure` flag, over a
  standalone `/ardd-configure` skill or an `/ardd-init --reconfigure`
  flag.
