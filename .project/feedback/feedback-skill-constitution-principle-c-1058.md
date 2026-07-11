---
status: planned      # open -> planned
created: 2026-07-10
plan: plan-principle-agnostic-skills-2026-07-10.md
---

# Feedback

## Reconsidered
- [x] F001 Skills hardcode references to *target-project* constitution
  principles that a given target may not have. `/ardd-plan` step 6 ("Flag
  any planned patterns that require a Complexity Tracking entry per the
  simplicity principle"), step 8's **Complexity Tracking** deliverable
  ("table of justified deviations from the simplicity principle"), and
  `/ardd-critique`'s hardcoded **Simplicity** section all assume the target
  constitution defines a simplicity principle with Complexity Tracking.
  Many target constitutions won't. The skills should be **naive to which
  principles a constitution contains**: still do what the constitution
  demands *if that principle is present*, but not spell out named
  principles that may be absent. Figure out how to separate these concerns
  — e.g. the skill reads the target's actual constitution and enforces
  whatever principles it finds, rather than embedding a fixed principle
  vocabulary in skill prose. [artifacts: constitution]

  **Scope guard for the fix:** do *not* touch the "constitution Principle
  II" references in `/ardd-render` (step 6), `/ardd-tasks` (step 60), and
  `/ardd-plan` (steps 4 & 9). Those name *ARDD's own* constitution
  (determinism/mechanization) as maintainer commentary explaining why the
  skill shells out to a deterministic script — they are not assumptions
  about a target project's constitution and must stay. The fix is only for
  references that presuppose a *target's* principle set.
