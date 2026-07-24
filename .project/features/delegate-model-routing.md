---
slug: delegate-model-routing
status: backlogged
logged: 2026-07-24
---

Configurable model routing for /ardd-implement's delegated worktree runs: a delegate_model constitution frontmatter field, either a single tier alias or a complexity map keyed by the tasks file's complexity: stamp, resolved to a model: override on the Agent dispatch.
Why: subagents start with fresh context, so the delegation boundary is the one place model routing costs no prompt cache (per-skill session routing was investigated and rejected — per-model caches make it net-negative for frequent skills). Prefer tier aliases over model names to survive model churn; default asymmetric — routing complex files up matters more than routing simple ones down. Depends on plan-time-complexity-stamps for the map form.
