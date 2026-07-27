---
plan: plan-feat-collab-status-refresh-2026-07-27-7811.md
generated: 2026-07-27
status: ready   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
complexity: moderate
---

# Tasks

## Phase 1: /ardd-implement coordinator + inline wiring
- [ ] T001 Update `skills/ardd-implement/SKILL.md` step 3's collaborative-mode coordinator sequence: after the report-back side-effect checks and the fast-forward of the feature branch onto the subagent-reported branch, the coordinator MUST run `/ardd-status` on the feature branch in the primary checkout (refresh + `status-prune.sh` when `status_history_keep` is set) and commit it BEFORE the push/PR offer — the push never happens without it. Re-scope the "delegated subagent must never run `/ardd-status`" note to solo mode only, stating why (solo's abandoned-worktree trapped-write risk is real; in collaborative mode the coordinator's feature-branch refresh in the primary checkout is the required norm, and the subagent still never runs it — the coordinator owns the refresh). Mid-run visibility pushes (the first-commit draft-PR offer) are exempt: the invariant binds pushes carrying terminal state. Add the invariant sentence verbatim: "in collaborative mode, no ArDD skill pushes a feature branch whose STATUS.md predates the state the push carries."
- [ ] T002 Update `skills/ardd-implement/SKILL.md` step 8's inline path: state that in collaborative mode the terminal `/ardd-status` on the feature branch is what satisfies the invariant, and any push/PR offer must come after that refresh, never before. Depends on T001 (same invariant wording).

## Phase 2: /ardd-plan collaborative ending
- [ ] T003 Update `skills/ardd-plan/SKILL.md`: in collaborative mode, before the run's terminal push/draft-PR offer — and before any later terminal-state push in the same run (the post-approval/tasking push) — run the terminal `/ardd-status` on the feature branch (refresh + prune) and commit it, so a plan-only PR's STATUS.md matches the plan/tasks state it carries. Keep step 15's existing analyze handoff as the mechanism; the edit pins its ordering relative to the push. Include the invariant sentence verbatim (same wording as T001). Depends on T001.

## Phase 3: /ardd-status scoping
- [ ] T004 Update `skills/ardd-status/SKILL.md`'s "Run only from the primary checkout, never inside a delegated worktree" passage: add the collaborative-mode clarification — running on a feature branch in the primary checkout is the required norm there (the refresh rides the branch and lands with the PR), and the prohibition's target remains delegated worktrees (all modes) plus solo-mode's trapped-write case. State the invariant sentence verbatim (same wording as T001). Depends on T001.

## Phase 4: docs + verification
- [ ] T005 Sync the mode-scoped rule into CLAUDE.md (the single-writer ownership note's `/ardd-status` line and the "Two operating modes" collaborative bullet) and into the hand-written bodies of `docs/reference/skills/ardd-implement.md`, `docs/reference/skills/ardd-plan.md`, and `docs/reference/skills/ardd-status.md` — same invariant, same solo/collaborative split, no contradicting leftover prose. Depends on T002, T003, T004.
- [ ] T006 Run `scripts/lint-docs.sh` and `scripts/lint-project.sh .`; confirm both pass with no new findings. Depends on T005.
