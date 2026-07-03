---
status: approved
branch: implicit-plan-approval
created: 2026-07-03
features: [implicit-plan-approval]
---

# Plan: Implicit plan approval via /ardd-tasks

## Goal

Remove the redundant two-step ceremony where a plan must be explicitly
approved in `/ardd-plan` before `/ardd-tasks` will even show it: selecting a
`status: draft` plan in `/ardd-tasks` becomes the approval action itself.

## Scope

**In scope:** `skills/ardd-plan/SKILL.md`, `skills/ardd-tasks/SKILL.md`,
and the doc references to the old approval mechanism in `USAGE.md` and
`README.md`.

**Not in scope:** no artifact changes. This is a skill-behavior change, not
a new principle, exception, or production shortcut — checked against the
constitution's artifact-affected table in `/ardd-plan` step 3b, nothing
applies.

## Technical Approach

Tracing the current "on approval" block in `/ardd-plan` step 10 turned up a
real dependency the naive version of this feature would silently break:
feedback-item resolution (marking `[x]`/`[-]` in a `feedback-*.md` file and
flipping it to `status: planned`) currently happens *only* at approval time,
using live session context from the interactive negotiation in step 5 — but
a plan's own document only records which feedback items were *accepted*
(as tasks referencing them), never which were *declined*. If approval moves
to a later, separate `/ardd-tasks` invocation, there's no longer any record
to recover a declined item's `[-]` marking from.

Fix: decouple feedback-item resolution from plan approval entirely. It
happens right after step 5's negotiation, unconditionally — the interactive
decision (accept/decline each item) is already made at that point in the
conversation, regardless of whether the plan itself is later approved
immediately or picked up in a future `/ardd-tasks` session. This is a
correctness fix this feature requires, not scope creep: without it, a
declined-and-deferred plan would corrupt feedback bookkeeping.

What's left gated behind "approval" after that split is purely mechanical
and derivable from the plan file alone, with no session context needed:
flip `status: draft` → `approved`, and flip each `features:` slug from
`backlogged` to `planned` (adding `· Plan: <filename>` to its metadata
line). Both already read straight from the plan's own frontmatter, so
`/ardd-tasks` can perform them identically to how `/ardd-plan` used to,
just triggered by plan *selection* instead of plan *drafting*.

Supersession (an existing approved or draft plan being replaced) also moves
earlier: it's decided and applied immediately when the new plan is
drafted (still an interactive confirmation — "does this supersede
`plan-X.md`?" — just no longer waiting for the new plan's own approval to
apply it). Leaving a plan an old draft supersedes as `status: superseded`
even if the new draft is later abandoned unactioned is accepted as fine:
`/ardd-analyze`/`STATUS.md` surface open draft counts either way, so a
draft that never gets picked up doesn't go unnoticed.

`/ardd-tasks` step 2 changes from filtering out `status: draft` plans to
listing both draft and approved ones (status shown per plan, same as it
already shows for existing tasks files). Selecting a draft one runs the
finalization described above immediately before task generation; selecting
an already-approved one skips straight to generation, unchanged.

No deterministic check or script applies here (Principle II) — this is
interactive-flow/judgment prose, not a checkable invariant. No automated
test exists for skill *behavior* by design (per `CLAUDE.md`); verification
is manual — dry-running the new step sequence against a real draft plan
before merging, same as every other `SKILL.md` change in this repo.

## Phase Breakdown

### Phase 1 — Move feedback resolution out of the approval gate
- Edit `skills/ardd-plan/SKILL.md` step 5: feedback-item marking (`[x]`/
  `[-]`) and feedback-file status flip (`open` → `planned`, setting `plan:`)
  happen immediately after the interactive negotiation described there,
  not deferred to step 10.
- Edit `skills/ardd-plan/SKILL.md` step 10: remove feedback-file handling
  from the "once approved" block (now redundant with the above).

This phase is independently correct and demonstrable: feedback resolution
no longer depends on plan approval timing, verifiable by dry-running a plan
with a mix of accepted and declined feedback items and confirming both are
finalized regardless of whether the plan is approved in the same run.

### Phase 2 — Move plan/feature approval to /ardd-tasks
- Edit `skills/ardd-plan/SKILL.md` step 7: supersession, once confirmed by
  the user, is applied immediately (flip the old plan's `status` to
  `superseded` right away) rather than deferred to step 10.
- Edit `skills/ardd-plan/SKILL.md` step 10: remove the "ask for approval"
  prompt and the plan-status-flip / features-flip side effects. Replace
  with: present the summary as before, note the plan is saved as `draft`,
  and that running `/ardd-tasks` and selecting it is what approves it and
  generates tasks.
- Edit `skills/ardd-tasks/SKILL.md` step 2: list plans regardless of
  `status` (draft or approved), showing status per plan in the presented
  list — mirroring how existing tasks files already show status/progress
  there.
- Edit `skills/ardd-tasks/SKILL.md`: immediately after a plan is selected,
  if its `status` is `draft`, perform the finalization — flip to
  `approved`; for each slug in the plan's `features:` list, flip that
  entry in `features.md` from `backlogged` to `planned` and add
  `· Plan: <filename>` — before proceeding to task generation. If already
  `approved`, skip straight to generation.

This phase is independently demonstrable: drafting a plan with `/ardd-plan`
now ends at `status: draft` with no approval prompt; running `/ardd-tasks`
against it flips it to `approved` and its features to `planned` as part of
generating tasks, in one step.

### Phase 3 — Fix stale doc references
- `USAGE.md`: "The plan isn't written to disk until you approve it" is
  already inaccurate today (the plan is written as `draft` at `/ardd-plan`
  step 9, before any approval step) — correct it to describe the new flow:
  drafted plans are saved immediately; `/ardd-tasks` approves on selection.
- `USAGE.md`: "After approving the plan: `/tasks`" step heading and
  surrounding prose — update to describe selecting the draft in
  `/ardd-tasks` as the approval action.
- `README.md`: `/ardd-tasks` row in the Skills table ("After plan
  approval") — update to reflect that `/ardd-tasks` performs the approval
  now, not just follows it.

## Complexity Tracking

None.

## Open Questions

None — the one real design gap found while planning (feedback-item
resolution losing its record if deferred) is resolved in Phase 1, not left
open.

## Production Annotation Summary

None. ADD's constitution did not adopt the Production Annotations
principle for its own development (declined at bootstrap).
