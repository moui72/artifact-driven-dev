---
plan: plan-docs-drift-fixes-2026-07-18-2fbb.md
generated: 2026-07-18
status: ready
---

# Tasks

## Phase 1: `ardd-status` reference page
- [ ] T001 [parallel] Add `/ardd-status --view` to
  `docs/reference/skills/ardd-status.md`'s Usage section (currently only
  shows bare `/ardd-status`) — describe it as the read-only side-door
  mode (per `skills/ardd-status/SKILL.md`'s own `--view` usage line and
  its step sequence), matching the tone/format already used for
  `/ardd-plan --list`'s and `/ardd-implement --list`'s documentation on
  their own reference pages.
- [ ] T002 [parallel] Add a mention of the register's `epic:` field and
  the by-epic Feature Backlog breakdown to
  `docs/reference/skills/ardd-status.md` (per
  `skills/ardd-status/SKILL.md`'s epic-grouping steps) — fits under
  "What it checks" or "Writes", whichever the page's existing structure
  makes the more natural fit; read the page first to decide.

## Phase 2: Routing for `/ardd-plan --slate`
- [ ] T003 [parallel] Add a row to `USAGE.md`'s "How do I…?" routing
  table for a backlog-organizing/defragging intent (e.g. "Figure out
  what to plan next, or how to group my backlog" → `/ardd-plan --slate`),
  matching the table's existing terse two-column-plus-guide-link style.
- [ ] T004 [parallel] Add a corresponding mention of `/ardd-plan
  --slate` to `docs/guides/core-loop.md`'s narrative, at whatever point
  in the existing flow ("Plan a batch" or similar) makes sense for
  introducing the defrag/grouping advisory mode.
