---
slug: implicit-plan-approval
status: implemented
logged: 2026-07-03
plan: plan-implicit-plan-approval-2026-07-03.md
tasks: tasks-implicit-plan-approval-455c.md
---

Selecting a `status: draft` plan in `/ardd-tasks` implicitly flips it to
`approved` instead of `/ardd-tasks` filtering drafts out and requiring a
separate explicit approval step back in `/ardd-plan`.
Why: raised mid-session while approving `plan-pre-commit-lint-hook` — the
two-step approve-then-select flow felt like unnecessary ceremony when
picking a plan to generate tasks from already implies the intent to move
forward with it.
