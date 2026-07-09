---
status: planned      # open -> planned
created: 2026-07-09
plan: plan-next-step-prompt-2026-07-09.md
---

# Feedback

## Bugs

## UX
- [x] F001 `/ardd-plan` cannot be *targeted* at `DEFECTS.md`: step 5's defect surfacing is one-shot by design — declining a defect records its id in the plan's `surfaced-defects:` frontmatter and it is never re-offered — and there is no defect-scoping argument mirroring the feedback-file arguments. So a defect declined once (e.g. "not now") has no structured path back into a later plan; the workarounds are prose instructions to plan or laundering the defect through a redundant feedback file. Suggested shape: a defect-scoping argument to `/ardd-plan` that re-offers named (or all currently listed) `DEFECTS.md` entries even if their ids already appear in some plan's `surfaced-defects:` list, producing `[defect: <id>]` fix tasks as step 5 does today. (Follow-on to the gap fixed via feedback-plan-defects-check-4cdb.md, which created the one-shot surfacing.)

## Reconsidered
