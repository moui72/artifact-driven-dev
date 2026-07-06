---
slug: pre-commit-lint-hook
status: implemented
logged: 2026-07-03
plan: plan-pre-commit-lint-hook-2026-07-03.md
tasks: tasks-pre-commit-lint-hook-afed.md
---

A local git pre-commit hook runs `scripts/lint-docs.sh`,
`scripts/test-lint-project.sh`, `scripts/test-branch-info.sh`, and
`scripts/test-hook-lint-on-write.sh`, blocking the commit if any fail.
Why: the constitution's Pre-commit Enforcement standard is currently stated
but not implemented — only CI (after push) and the write-time `PostToolUse`
hook (`.project/` writes only) exist today.
