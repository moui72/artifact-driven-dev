---
slug: list-mode-for-plan-and-impleme
status: tasked
logged: 2026-07-14
plan: plan-list-mode-for-plan-and-impleme-2026-07-15-a2c2.md
tasks: tasks-list-mode-for-plan-and-impleme-2bf9.md
---

`/ardd-implement`, `/ardd-plan`, and their tasks-file surface gain a --list mode that prints all eligible slugs (backlogged features for /ardd-plan; ready/in-progress tasks files for /ardd-implement) with basic info (status, created date, brief description) without entering the interactive pick flow.
Why: makes it possible to see what's actionable at a glance (e.g. from a script or a quick check) instead of invoking the full skill and reading its interactive prompt.
