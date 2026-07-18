---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: docs-drift-fixes
created: 2026-07-18
features: []
surfaced-defects: []
---

# Plan: docs-drift-fixes

## Goal

Fix the three human-facing documentation gaps `docs-sweep`'s first live
dogfood run found: `/ardd-status --view` and the register's `epic:`
field/by-epic breakdown are undocumented on `docs/reference/skills/ardd-status.md`,
and `/ardd-plan --slate` is unrouted in `USAGE.md` and `docs/guides/core-loop.md`.

## Scope

**In scope:**
- `feedback-ardd-status-reference-page-mis-7fa5.md` (F001, F002): add
  `--view` usage to `docs/reference/skills/ardd-status.md`'s Usage
  section, and document the `epic:` field / by-epic Feature Backlog
  breakdown somewhere on that page (What it checks or Writes, whichever
  fits the existing structure).
- `feedback-ardd-plan-slate-mode-unrouted-c563.md` (F001): add a
  `USAGE.md` "How do I…?" row routing a backlog-organizing intent to
  `/ardd-plan --slate`, and a corresponding mention in
  `docs/guides/core-loop.md`'s narrative.

**Out of scope:**
- Any other docs-site page or capability not named by these three
  feedback items — this plan fixes exactly what `docs-sweep` found on
  its first run, not a fresh full sweep.
- Re-running `/docs-sweep` itself as part of this plan — that's a
  separate, later invocation (its own cadence, per its own SKILL.md),
  not a task this plan owns.

## Technical Approach

Pure documentation edits, hand-written prose additions to already-existing
files — no code, no artifacts, no schema changes. Each task maps directly
to one feedback item's cited gap, using the exact locations the feedback
already pinpointed (file:line citations from `docs-sweep`'s dogfood run).

## Phase Breakdown

### Phase 1: `ardd-status` reference page (feedback-ardd-status-reference-page-mis-7fa5.md)
Depends on: —
- T001 [parallel] Add `/ardd-status --view` to
  `docs/reference/skills/ardd-status.md`'s Usage section (currently only
  shows bare `/ardd-status`) — describe it as the read-only side-door
  mode (per `skills/ardd-status/SKILL.md`'s own `--view` usage line and
  its step sequence), matching the tone/format already used for
  `/ardd-plan --list`'s and `/ardd-implement --list`'s documentation on
  their own reference pages. [feedback: F001]
- T002 [parallel] Add a mention of the register's `epic:` field and the
  by-epic Feature Backlog breakdown to
  `docs/reference/skills/ardd-status.md` (per
  `skills/ardd-status/SKILL.md`'s epic-grouping steps) — fits under
  "What it checks" or "Writes", whichever the page's existing structure
  makes the more natural fit; read the page first to decide. [feedback:
  F002]

### Phase 2: Routing for `/ardd-plan --slate` (feedback-ardd-plan-slate-mode-unrouted-c563.md)
Depends on: —
[parallel] with Phase 1 (different files)
- T003 [parallel] Add a row to `USAGE.md`'s "How do I…?" routing table
  for a backlog-organizing/defragging intent (e.g. "Figure out what to
  plan next, or how to group my backlog" → `/ardd-plan --slate`),
  matching the table's existing terse two-column-plus-guide-link style.
- T004 [parallel] Add a corresponding mention of `/ardd-plan --slate` to
  `docs/guides/core-loop.md`'s narrative, at whatever point in the
  existing flow ("Plan a batch" or similar) makes sense for introducing
  the defrag/grouping advisory mode.

## Complexity Tracking

No deviations requiring justification — pure prose additions to existing
docs pages, no new mechanism.

## Open Questions

None — the feedback items already cite exact file:line locations, and
the fix at each is a direct documentation addition.
