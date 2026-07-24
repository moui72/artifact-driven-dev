---
slug: plan-time-complexity-stamps
status: backlogged
logged: 2026-07-24
---

At tasks-file generation time, /ardd-plan stamps a complexity: simple|moderate|complex field into each tasks file's frontmatter, reviewed and correctable at the plan approval checkpoint.
Why: plan time is when full context exists to predict how much judgment implementation will need; the stamp is the on-disk routing signal for model selection at implement dispatch (see implement-dispatch-model-routing). Enum lands in lint-project.sh in the same commit.
