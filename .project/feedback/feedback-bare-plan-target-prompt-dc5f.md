---
status: open      # open -> planned
created: 2026-07-19
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## UX

- [ ] F001 A bare `/ardd-plan` (no slug, no feedback/defect scope) should
  prompt the user with the plannable items it found — backlogged feature
  slugs, open feedback files, unsurfaced defects — and let them pick what
  to target, rather than effectively complaining that there are no
  feedback items to plan from and stopping.
- [ ] F002 When a bare `/ardd-plan` finds truly nothing plannable (empty
  backlog, no open feedback, no unsurfaced defects), it should end with a
  prose explanation and concrete next-step suggestions — e.g.
  `/ardd-backlog <idea>` or `/ardd-feedback <observation>` to create
  something plannable, or `/ardd-implement` if a `ready` tasks file
  already exists — instead of a bare complaint.
