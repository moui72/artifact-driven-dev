---
slug: status-view-mode
status: implemented
logged: 2026-07-18
plan: plan-status-view-mode-2026-07-18-ce1f.md
tasks: tasks-status-view-mode-6377.md
---

A /ardd-status --view mode that reports a summary of current status, a snapshot of incomplete/in-flight work, and a recommended next step, without regenerating or writing STATUS.md.
Why: sometimes you just want a quick read-only glance (like /ardd-plan --list or /ardd-implement --list) rather than the full discover-everything-and-write-STATUS.md pass, especially when nothing has changed since the last write.
