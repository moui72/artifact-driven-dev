---
plan: plan-rejected-feature-status-2026-07-19-9590.md
generated: 2026-07-19
status: in-progress
---

# Tasks

## Phase 1: Schema and state mutation
- [x] T001 [artifacts: constitution] Add `rejected` and `subsumed` to
  `scripts/lint-project.sh`'s `FEATURE_STATUS_ENUM` (currently
  `"backlogged planned tasked implemented retired"`), with inline
  comments mirroring the existing `retired` comment's style — one for
  each new value, explicit about what distinguishes it from both
  `retired` and the other new value.
- [x] T002 Add the five new legal transitions to
  `scripts/ardd-state.sh`'s `cmd_feature_flip` (`backlogged ->
  rejected`, `planned -> rejected`, `backlogged -> subsumed`, `planned
  -> subsumed`, `tasked -> subsumed`), update the `case "$to"`
  validation list to include both new values, and update the
  subcommand's usage-text line (currently
  `backlogged->planned->tasked->implemented->retired`) to show both new
  branches clearly, including a one-line note on why `subsumed` alone
  reaches from `tasked` (absorption noticed late) while `rejected` does
  not (pre-work decision only).
- [x] T003 Add regression cases to `scripts/test-ardd-state.sh`: legal
  `backlogged -> rejected`, `planned -> rejected`, `backlogged ->
  subsumed`, `planned -> subsumed`, and `tasked -> subsumed` transitions
  all succeed; both `rejected` and `subsumed` refuse every outbound
  transition (terminal, same pattern as the existing `retired` terminal
  test); an illegal transition into either from `implemented` is
  refused with the existing clear error message; an illegal `tasked ->
  rejected` (not one of the five new edges) is also refused, confirming
  the asymmetry holds.
- [x] T004 [parallel] Add fixture cases to `scripts/test-lint-project.sh`
  confirming feature files with `status: rejected` and `status:
  subsumed` both pass the enum check cleanly.

## Phase 2: Skill prose and docs
- [x] T005 [parallel] Update `docs/reference/project-files.md`'s feature
  register status-arc line (currently `backlogged` → `planned` →
  `tasked` → `implemented` (or → `retired`)) to also show the
  `backlogged`/`planned` → `rejected` branch and the
  `backlogged`/`planned`/`tasked` → `subsumed` branch.
- [x] T006 [parallel] Update `skills/ardd-status/SKILL.md`'s Feature
  Backlog report template: add `rejected` and `subsumed` to the count
  line alongside `implemented`/`retired` (omitted when zero each, same
  convention already used for `retired` in practice), and confirm/state
  explicitly that the by-epic breakdown's exclusion of non-actionable
  statuses covers both new terminal states too (grouped alongside
  `implemented`/`retired` in the "omit from grouping" list).
- [x] T007 [parallel] Update `skills/ardd-plan/SKILL.md`'s step 3a
  guidance (currently: "If its status isn't `backlogged` (e.g. already
  `planned`/`tasked`/`implemented`), tell the user it's already past
  the backlog stage and stop") to also name `rejected` and `subsumed`
  as statuses this skill refuses to design forward from — a rejected
  idea needs a fresh backlog entry if reconsidered, and a subsumed
  entry's scope should be planned under whichever feature actually
  absorbed it, never revived under its own slug.

## Phase 3: Manual verification
- [ ] T008 Manually exercise the full arc against two throwaway
  fixture features: (a) create one at `backlogged`, flip it to
  `rejected` via `ardd-state.sh feature-flip <slug> rejected`, confirm
  `lint-project.sh` accepts it, confirm `/ardd-plan <that-slug>` now
  refuses per T007's updated guidance, and confirm attempting any
  further flip out of `rejected` is refused; (b) create a second at
  `tasked`, flip it to `subsumed`, confirming the late-stage transition
  specifically (the one `rejected` doesn't get), and confirm the same
  terminal-refusal behavior. Also verify a `planned -> rejected` flip
  succeeds for completeness. Clean up both fixtures afterward.
