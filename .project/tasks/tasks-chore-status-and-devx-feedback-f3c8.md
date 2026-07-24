---
plan: plan-chore-status-and-devx-feedback-2026-07-23-7fb8.md
generated: 2026-07-23
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Delegation alignment fix (F76c4)
- [x] T001 In `.claude/skills/ardd-implement/SKILL.md` step 3's "Collaborative mode" section, replace the current instruction that the worktree preamble uses "the same align-first subagent preamble ... as solo mode" with an explicit collaborative-mode alignment call: pass `branch-info.sh`'s `current` ref (already read in step 2) to `worktree-align.sh` — or `default` if `on_default` was already `true` at that point — instead of relying on `worktree-align.sh`'s no-argument default-branch behavior. State plainly that this replaces any need for a `fold-to-main.sh` step in the collaborative path (fold-to-main stays solo-mode-only).
- [x] T002 In the same collaborative-mode section, add: (a) the `aligned=false` stop-and-surface-verbatim rule (mirroring the existing solo-mode `worktree-align.sh` failure handling, same refuse-don't-resolve discipline, no new failure mode); (b) a note that the push + draft-PR offer is now visibility-only, not a delegation prerequisite — since ref-alignment doesn't depend on anything having reached `origin`; (c) a caveat that a worktree aligned to feature-branch A cannot see uncommitted work still sitting only on unrelated feature-branch B (acceptable given the existing same-file claim check and same-branch fan-out, but must be stated); (d) a note that once a delegated branch's PR (now carrying the plan/tasks commits too) merges, an earlier plan-only draft PR opened before delegation becomes redundant/closable/absorbable.

## Phase 2: STATUS.md legacy tail removal (F87b6)
- [ ] T003 [parallel] Delete the legacy `## Recent Releases` / `## Feature Backlog` section from `.project/STATUS.md` (currently the file's final ~117 lines, starting at the `## Recent Releases` heading), leaving the `_Updated:` log as the file's sole content below its header. Do not touch any other part of the file — this is a manual one-time removal, not a change to `/ardd-status`'s generation logic.
