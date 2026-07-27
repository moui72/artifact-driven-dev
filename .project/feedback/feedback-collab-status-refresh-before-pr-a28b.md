---
status: open      # open -> planned
created: 2026-07-27
plan: null
---

# Feedback

Supersedes the `ci-status-refresh-on-main-coll` register entry (flipped
`rejected` alongside this file, per
`research-ci-status-refresh-on-main-coll-2026-07-27-0c1d.md`'s verdict:
the CI-job shape reverses two recorded decisions and its PR-noise
motivation mostly evaporated after `merge=ours` + `status_history_keep`).
This item is the surviving kernel, reshaped per the user's direction.

## Reconsidered
- [ ] F001 In collaborative mode, the feature branch must always get a
  STATUS.md refresh as the LAST step before a PR is pushed/opened — true
  for a plan-only PR (`/ardd-plan`'s collaborative path) and for an
  implementation PR (`/ardd-implement`, inline AND delegated), regardless
  of whether a plan-only PR merged beforehand. Today this holds only for
  inline implement runs (step 8's terminal `/ardd-status`); a delegated
  run ships a PR whose STATUS.md still shows planning-time state (observed
  live: PR #29 carried `ready, 0/9` next to a `completed 9/9` tasks file),
  and `/ardd-plan`'s collaborative path pushes plan/tasks without any
  refresh. Two prose decisions get reversed to make it hold:
  (1) the blanket "a delegated subagent must never run `/ardd-status`"
  rule (`skills/ardd-implement/SKILL.md` step 3 note + step 8, echoed in
  `skills/ardd-status/SKILL.md`'s "run only from the primary checkout"
  and CLAUDE.md) — its trapped-write rationale only holds for solo mode's
  abandoned-worktree case; in collaborative mode the worktree branch
  fast-forwards into the feature branch by construction, so a terminal
  refresh written in the worktree rides the branch exactly like
  checkboxes and register flips already do. Relax to: forbidden in solo
  delegated runs (coordinator refreshes after merge, unchanged);
  REQUIRED as the delegated run's terminal act in collaborative mode
  (refresh + `status-prune.sh` when `status_history_keep` is set, then
  commit, before reporting back). Alternatively the coordinator performs
  the refresh after fast-forwarding the feature branch and before
  pushing — either owner is acceptable so long as exactly one does it
  and the push never happens without it.
  (2) `/ardd-plan`'s collaborative ending: before the push/draft-PR
  offer (and again whenever the branch is re-pushed at approval/tasking),
  run the terminal `/ardd-status` on the feature branch so the plan-only
  PR carries a report matching its own plan/tasks state.
  Net invariant to state in prose: "in collaborative mode, no ArDD skill
  pushes a feature branch whose STATUS.md predates the state the push
  carries."
