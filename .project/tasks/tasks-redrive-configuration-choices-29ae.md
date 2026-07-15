---
plan: plan-redrive-configuration-choices-2026-07-14-1e00.md
generated: 2026-07-14
status: in-progress
---

# Tasks

## Phase 1: `/ardd-update --reconfigure`

- [x] T001 In `skills/ardd-update/SKILL.md`: update the
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

## Phase 2: Documentation

Depends on Phase 1 (describes its behavior).

- [ ] T002 [parallel] Update
  `docs/reference/skills/ardd-update.md`: add `--reconfigure` to the
  `## Usage` code block and its prose, and rewrite item 5 in "What a run
  does" to describe both the default backfill-only behavior and the
  `--reconfigure` re-ask-everything behavior (mirroring T001's SKILL.md
  wording, not just restating "once"). [feature:
  redrive-configuration-choices]
- [ ] T003 [parallel] Update
  `docs/reference/configuration.md`: the intro paragraph currently states
  "`/ardd-update` backfills ... once for installs whose constitution
  lacks the field entirely — `workflow_mode` is never asked again and
  simply defaults to `solo` when absent." Replace with wording covering
  both the default backfill (unchanged) and the `--reconfigure` path
  (all four fields, including `workflow_mode`, can be re-asked on
  demand). [feature: redrive-configuration-choices]
- [ ] T004 [parallel] Update `CLAUDE.md`'s two
  "workflow field" passages (the `workflow_mode` paragraph, currently
  "...asked once by `/ardd-init`, detection-suggested)"; and the
  `next_step_prompt` paragraph, currently "...asked once by `/ardd-init`,
  and once by `/ardd-update` for installs whose constitution lacks the
  field)") to note that `/ardd-update --reconfigure` can re-ask either
  field afterward — one parenthetical clause each, not a rewrite of the
  surrounding architecture prose. [feature:
  redrive-configuration-choices]
