---
status: planned
created: 2026-07-14
plan: plan-203c-2026-07-14-bf43.md
---

# Feedback

## Bugs
- [x] F001 `/ardd-plan` never explicitly `git add`+commits the plan file (step 9) or the tasks file (step 13) it writes, nor the flips those files undergo afterward (plan-flip, feature-flip). In solo mode, where `/ardd-plan` often runs directly on the default branch, this leaves a window where a `status: ready` tasks file is real and approved on disk but not in the branch's commit history. `/ardd-implement`'s delegation gate (step 3) has no pre-flight check for this — it assumes anything `ready` on disk is also committed. When it delegates to a worktree subagent in that window, `worktree-align.sh` reports `aligned=true` (it only fast-forwards committed history), but the plan/tasks files are silently absent from the new worktree; the subagent correctly stops per its "tasks file must exist" instruction, but only after a full agent launch round-trip, and the coordinator has to notice, commit by hand, and re-delegate. Reproduces reliably whenever a plan is drafted in one session and `/ardd-implement` invoked from a separate one without an explicit commit in between (this is the second observed occurrence — a project memory entry already documents the first). Suggested fix (either, not necessarily both): (a) in `/ardd-plan`, commit the plan/tasks files immediately after writing/flipping them when running on the default branch in solo mode; (b) in `/ardd-implement`'s delegation gate, check `git status --short` on the chosen tasks file and its bound plan before delegating, and commit or block with a message if either is uncommitted. [artifacts: constitution]
