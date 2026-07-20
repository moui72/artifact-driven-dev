---
status: planned
created: 2026-07-20
plan: plan-dot-project-reviewer-guide-2026-07-20-ee87.md
---

# Feedback

## UX
- [x] F001 next_step_prompt's AskUserQuestion offer degrades untested under Claude Code's dontAsk permission mode, which denies the AskUserQuestion tool outright (per the permission-modes docs) rather than showing it. The denial should read as "no — stop here" (the existing Esc-counts-as-no rule roughly covers the intent, but nothing states it), and the two prompting skills (/ardd-status step 8, /ardd-plan's terminal prompt) should say explicitly that a denied/unavailable AskUserQuestion call means decline — never retry the prompt and never treat the denial as an error that aborts the report already written.
