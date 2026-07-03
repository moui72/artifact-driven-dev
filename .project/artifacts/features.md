---
last_updated: 2026-07-03
---

# Features

## Pre-commit lint enforcement

_Slug: `pre-commit-lint-hook` · Status: implemented · Logged 2026-07-03 · Plan: plan-pre-commit-lint-hook-2026-07-03.md · Tasks: tasks-pre-commit-lint-hook-afed.md_
A local git pre-commit hook runs `scripts/lint-docs.sh`,
`scripts/test-lint-project.sh`, `scripts/test-branch-info.sh`, and
`scripts/test-hook-lint-on-write.sh`, blocking the commit if any fail.
Why: the constitution's Pre-commit Enforcement standard is currently stated
but not implemented — only CI (after push) and the write-time `PostToolUse`
hook (`.project/` writes only) exist today.

## Implicit plan approval via /ardd-tasks

_Slug: `implicit-plan-approval` · Status: planned · Logged 2026-07-03 · Plan: plan-implicit-plan-approval-2026-07-03.md_
Selecting a `status: draft` plan in `/ardd-tasks` implicitly flips it to
`approved` instead of `/ardd-tasks` filtering drafts out and requiring a
separate explicit approval step back in `/ardd-plan`.
Why: raised mid-session while approving `plan-pre-commit-lint-hook` — the
two-step approve-then-select flow felt like unnecessary ceremony when
picking a plan to generate tasks from already implies the intent to move
forward with it.
