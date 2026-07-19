---
slug: work-queue-parallel-safety
status: implemented
logged: 2026-07-19
plan: plan-work-queue-parallel-safety-2026-07-19-4c10.md
tasks: tasks-work-queue-parallel-safety-eadb.md
---

A single-pane work-queue view: an installed parallel-matrix.sh reports feature- and artifact-overlap verdicts among ready tasks files and in-flight worktrees (no path heuristics), surfaced as a Work Queue section in /ardd-status and as annotations on /ardd-implement's fan-out multi-select picker.
Why: nothing today answers the pairwise 'can I launch A and B together?' question before fan-out; vetted in .project/plans/research-work-queue-parallel-safety-vie-2026-07-19-25f7.md
