---
status: open      # open -> planned
created: 2026-07-16
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Reconsidered
- [ ] F001 `skills/ardd-implement/SKILL.md`'s delegation pre-flight check
  (step 3, "Pre-flight: verify the chosen tasks file and its bound plan
  are committed before launching") currently reads: on an uncommitted
  plan/tasks file, "offer to commit them now, or block delegation." User
  report: "this happens often" — a delegation attempt failed because
  the plan/tasks files existed only as uncommitted changes on `main`;
  recovery required noticing the failure, committing by hand, and
  re-launching. Reconsidered: in solo mode, on the current (usually
  default) branch, with no other reason to hold the commit back, the
  agent should just commit the uncommitted plan/tasks file(s)
  automatically as part of the pre-flight step — not stop to ask —
  since asking only adds a round-trip for what's almost always the
  obvious right move (these are exactly the files the immediately-prior
  `/ardd-plan` run just wrote). Collaborative mode's existing
  "never push without confirming" rule is a different, separately-owned
  decision and is not in scope here — this is specifically about
  committing locally before delegating, not about pushing.
