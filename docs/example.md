# What the files actually look like

A worked example — abridged excerpts from a fictional project (**shelfie**,
a small self-hosted book-tracking web app) at a realistic mid-life moment:
artifacts stable, one feature shipping, one bug captured, one plan in
flight. Every file below lives under `.project/` in the target project.
(Schemas and enums: [reference/project-files.md](reference/project-files.md).)

## An artifact — `artifacts/datamodel.md`

```markdown
---
status: stable
last_updated: 2026-07-08
diagram_type: erDiagram
diagram_status: current
render_hint: |
  One block per entity; derive relationships from FK refs; omit index detail.
---

# Data Model

## Overview

Canonical schema for shelfie. SQLite is the single source of truth;
the web UI reads only through the query layer (see infrastructure.md).

## Entities

### Book

| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| isbn | TEXT UNIQUE NULLABLE | absent for pre-ISBN and self-published books |
| title | TEXT NOT NULL | |
| added_at | TEXT (ISO 8601 date) | normalization rule below |
| shelf_id | INTEGER FK → Shelf.id | every book sits on exactly one shelf |

### Shelf

| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| name | TEXT UNIQUE NOT NULL | user-defined; "Unshelved" is created at first run |

## Normalization Rules

- All dates are ISO 8601 (`YYYY-MM-DD`), stored as TEXT — no epoch integers.
- ISBNs are stored hyphen-free; display formatting is a UI concern.
- [OPEN: do lending records belong here or in a separate loans artifact?]

## Production Annotations

- Search is `LIKE '%term%'` for now — no FTS index. Acceptable below
  ~5k books; revisit if the query layer shows >50ms search times.
```

The `[OPEN: ...]` item is a genuine undecided question — `/ardd-status`
reports it, and it's why a stricter author might have left this artifact
`status: draft`. The Production Annotations section is where known
shortcuts live, by convention, so `/ardd-plan` and `/ardd-audit` can find
them.

## A feature-register entry — `features/reading-goals.md`

```markdown
---
slug: reading-goals
status: tasked
logged: 2026-07-02
plan: plan-reading-goals-2026-07-09-4e2a.md
tasks: tasks-reading-goals-91c3.md
gh_issue: 42
---

Let a user set a yearly reading goal and see progress toward it.
Why: the most-requested feature from the beta group; drives return visits.
```

One file per idea. It was one line when `/ardd-backlog` logged it; the
`plan:`/`tasks:` pointers and status flips accumulated as `/ardd-plan`
picked it up, and `gh_issue:` appeared when `/ardd-tracker` pushed it.
`status: tasked` will become `implemented` when the tasks file completes —
a flip that rides the work branch and lands when it merges.

## A feedback file — `feedback/feedback-demo-notes-7f1b.md`

```markdown
---
status: open
created: 2026-07-11
plan: null
---

# Feedback

## Bugs
- [x] F001 Deleting a shelf orphans its books instead of moving them to
  "Unshelved" [artifacts: datamodel]

## UX
- [ ] F002 The add-book form buries the ISBN lookup below the fold

## Reconsidered
- [x] F003 "Every book sits on exactly one shelf" — we want multi-shelf
  (tags, effectively) [artifacts: datamodel]
```

Captured in one `/ardd-feedback` pass after a demo. F003 is tagged with
the artifact that records the decision it reverses — at planning time that
triggers an explicit confirm-the-reversal prompt. The `[x]` marks mean a
plan run has already incorporated F001 and F003; F002 stays `[ ]` for a
later batch.

## A plan (excerpt) — `plans/plan-reading-goals-2026-07-09-4e2a.md`

```markdown
---
status: approved
branch: reading-goals
created: 2026-07-09
features: [reading-goals]
surfaced-defects: [a3f81c2e]
---

# Plan: Reading goals

## Goal
Ship yearly reading goals with a progress view.

## Phase Breakdown

### Phase 1: Data
- Add ReadingGoal entity (year, target_count) per datamodel.md
- Fix defect a3f81c2e: Book.added_at stored as epoch in the import path,
  violating the ISO 8601 rule [defect: a3f81c2e]

### Phase 2: UI
- Goal-setting form on the profile view (F-goal from feature design)
- Progress bar on the shelf overview

## Open Questions
- Should past years' goals be editable? Deferred — logged as [OPEN] in ui.md.
```

## A tasks file (excerpt) — `tasks/tasks-reading-goals-91c3.md`

```markdown
---
plan: plan-reading-goals-2026-07-09-4e2a.md
generated: 2026-07-09
status: in-progress
---

# Tasks

## Phase 1: Data
- [x] T001 [artifacts: datamodel] Add ReadingGoal table + migration
- [x] T002 [artifacts: datamodel, infrastructure] Fix epoch dates in the
  import path (defect a3f81c2e); add a regression test per the
  constitution's test-after standard
- [ ] T003 [artifacts: datamodel] [parallel] Backfill added_at for rows
  imported before the fix

## Phase 2: UI
- [ ] T004 [artifacts: ui, datamodel] Goal-setting form on profile view
```

`/ardd-implement` works this top to bottom, loading only each task's
declared artifacts, committing per task. If the run dies here, the next
`/ardd-implement` sees `in-progress` with no live worktree claiming it and
offers to reconcile against the codebase before continuing.

---

These excerpts are illustrative, not templates — `/ardd-init` seeds real
artifacts from the shipped templates, and your set will match your
project's concerns. The guides show the commands that produce and consume
each of these: [guides/core-loop.md](guides/core-loop.md) is the
day-to-day cycle.
