---
plan: plan-implicit-plan-approval-2026-07-03.md
generated: 2026-07-03
status: in-progress
---

# Tasks

## Phase 1: Move feedback resolution out of the approval gate

- [x] T001 Edit `skills/ardd-plan/SKILL.md`. In step 5 (feedback loading),
  immediately after the interactive negotiation for each `## Reconsidered`
  item (confirm/decline an artifact override), perform the bookkeeping that
  currently lives in step 10's "once approved" block: mark each loaded
  feedback item `[x]` if incorporated or `[-]` if declined; once every item
  in a feedback file is `[x]`/`[-]`, flip that file's `status` to `planned`
  and set its `plan:` field to this plan's filename. This now happens
  unconditionally at draft time, not gated behind plan approval — declined
  items have no record anywhere else once the plan is written (only
  accepted items become tasks), so this can't be deferred without losing
  information. In step 10, delete the feedback-file handling from the
  "once approved" block (now redundant). Verify by dry-running: draft a
  plan against a feedback file with both an accepted and a declined item,
  confirm both get marked correctly without approving the plan.

## Phase 2: Move plan/feature approval to /ardd-tasks

- [ ] T002 Edit `skills/ardd-plan/SKILL.md`. In step 7 (supersession check),
  once the user confirms a new plan supersedes an existing one, flip that
  existing plan's `status` to `superseded` immediately — don't wait for the
  new plan's own approval. In step 10: remove the "Ask for approval before
  the plan is considered final... Do not generate tasks until the user
  approves" prompt and everything in the current "Once approved:" block
  except what T001 didn't already remove (i.e. remove the plan
  `status: draft` → `approved` flip and the `features:` backlogged →
  planned flip — both move to `/ardd-tasks`, see T003). Replace with: after
  presenting the summary, tell the user the plan is saved as `draft` at its
  file path, and that running `/ardd-tasks` and selecting it is what
  approves it and generates tasks.
- [ ] T003 [parallel] Edit `skills/ardd-tasks/SKILL.md`. In step 2 (pick a
  plan): stop filtering out `status: draft` plans — list plans regardless
  of status, showing each plan's status in the presented list (alongside
  the existing tasks-file status/progress note). Add a new step immediately
  after plan selection, before task generation: if the selected plan's
  `status` is `draft`, flip it to `approved`, then read the plan's
  `features:` frontmatter list and for each slug flip its entry in
  `.project/artifacts/features.md` from `Status: backlogged` to
  `Status: planned`, adding `· Plan: <plan filename>` to its metadata line
  — the same mechanics `/ardd-plan` step 10 used to perform, just triggered
  by selection instead of drafting. If the selected plan is already
  `approved`, skip this and proceed straight to generation as before.
  Verify by dry-running: pick a freshly-drafted (unapproved) plan and
  confirm it flips to `approved` with its features flipped to `planned`
  before tasks are written.

## Phase 3: Fix stale doc references

- [ ] T004 [parallel] Edit `USAGE.md`. Step 5 ("Generate a plan") currently
  says "The plan isn't written to disk until you approve it" — this is
  already inaccurate today (the plan is written as `draft` before any
  approval step) and more clearly wrong after T001–T003. Replace with an
  accurate description: the plan is saved as `draft` immediately;
  `/ardd-tasks` approves it when you select it. Update step 6 ("Generate
  tasks") — currently titled around "After approving the plan" — to
  describe selecting the draft in `/ardd-tasks` as the approval action
  itself, not a separate prior step.
- [ ] T005 [parallel] Edit `README.md`'s Skills table: the `/ardd-tasks` row
  currently reads "After plan approval" — update to reflect that
  `/ardd-tasks` performs the approval when a draft plan is selected, not
  just something that runs after approval happened elsewhere.
