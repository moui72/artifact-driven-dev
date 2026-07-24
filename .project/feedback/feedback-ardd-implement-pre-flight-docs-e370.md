---
status: planned
created: 2026-07-24
plan: plan-chore-docs-sweep-feedback-2026-07-24-8c58.md
---

# Feedback

## Bugs
- [x] F001 `docs/reference/skills/ardd-implement.md:70-79`'s Pre-flight bullet only says "the chosen tasks file and its bound plan must be committed" before delegation. It's stale against `skills/ardd-implement/SKILL.md:176-225`, which widened pre-flight coverage: it also resolves and covers the plan's bound feature-register files, feedback files whose `plan:` frontmatter names this plan, and `.project/artifacts/` as a whole directory. The artifacts-directory check is also handled differently from the rest — it always asks before committing (even in solo mode), never auto-commits silently. Fix: rewrite the Pre-flight bullet to name all four resolved-path kinds (plan/tasks/features/feedback, auto-committed together per mode's existing rule) plus the separate artifacts-directory check that always asks in both modes. Found via `/docs-sweep`.
