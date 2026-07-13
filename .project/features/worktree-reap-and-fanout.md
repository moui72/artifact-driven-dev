---
slug: worktree-reap-and-fanout
status: implemented
logged: 2026-07-11
plan: plan-worktree-reap-and-fanout-2026-07-12-c560.md
tasks: tasks-worktree-reap-and-fanout-10f7.md
---

A worktree-reap script removes delegated worktrees whose branch has merged into the default branch (clean tree only, refuse-never-resolve), wired into the post-merge step, and the delegation gate can fan out one worktree per independent ready tasks file instead of cautioning against a second in-flight run.
Why: nothing removes a merged worktree today, so inflight-worktrees.sh accumulates stale entries and the worktrees-equal-in-flight-truth signal degrades — which matters more once parallel background runs are routine; fan-out depends on the merge-driver feature to make out-of-order landings conflict-free.
