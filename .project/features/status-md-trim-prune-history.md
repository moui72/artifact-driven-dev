---
slug: status-md-trim-prune-history
status: implemented
logged: 2026-07-24
plan: plan-status-md-trim-prune-history-2026-07-24-1038.md
tasks: tasks-status-md-trim-prune-history-485d.md
---

STATUS.md grows unbounded in long-running projects because /ardd-status prepends every _Updated block and preserves all prior ones verbatim. Add a method to trim/prune older STATUS.md update history to keep it slimmer — while preserving the single-writer boundary and durable re-entry chronology the design depends on.
