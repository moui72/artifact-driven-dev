---
status: open
created: 2026-07-24
plan: null
---

# Feedback

## Bugs
- [ ] F001 `docs/reference/skills/ardd-defects.md:32-38` says a fixed defect "silently drops out" on the next run, with no caveat. `skills/ardd-defects/SKILL.md:80-89` added a reconciliation sub-step that spot-checks a claim present in the prior `DEFECTS.md` but missing from a fresh survey, before letting it drop. Fix: add a clause noting the pre-drop reconciliation spot-check. Found via `/docs-sweep`.
