---
plan: plan-status-view-mode-2026-07-18-ce1f.md
generated: 2026-07-18
status: in-progress
---

# Tasks

## Phase 1: `/ardd-status --view` mode
- [x] T001 Add a `--view` usage line and mode description to
  `skills/ardd-status/SKILL.md`'s top usage block, alongside the existing
  Usage section — same doc location as `/ardd-plan --list`/
  `/ardd-implement --list`'s own usage lines, parallel structure. State
  plainly it runs steps 1–5 (discovery) unchanged, then prints the
  assembled report and stops — no `STATUS.md` write, no step 7's
  orphaned-flip confirmation (visibility only, matching `--list`'s "no
  writes of any kind" framing).
- [x] T002 Write the `--view` step in `skills/ardd-status/SKILL.md`: run
  the existing discovery steps (1–5) as-is, then print the Report format
  from step 5 directly to the terminal instead of writing it to
  `STATUS.md` in step 6. Skip step 7 (orphaned-flip confirmation) and
  step 8 (next-step prompt via `AskUserQuestion`) entirely in this mode —
  `--view` is inspection only, never a state-changing prompt.
- [x] T003 Manually exercise `/ardd-status --view` against this repo's
  own `.project/` state (as specified by T001–T002) and confirm it
  reports the same substantive content a full `/ardd-status` run would,
  without touching `STATUS.md` (`git status --short .project/STATUS.md`
  shows no change after running it). Record the outcome as this task's
  completion note.

## Phase 2: CI wiring fix (feedback F001, feedback-ci-migration-tests-unwired-37ee.md)
- [x] T004 [parallel] Add three CI jobs to `.github/workflows/lint.yml` —
  `migration-critique-to-audit`, `migration-sync-to-tracker`,
  `migration-workflow-table` — each running its corresponding
  `scripts/test-migration-*.sh`, matching the existing
  `migration-retag`/`migration-diagram-type` job shape exactly (same
  `runs-on`, same `actions/checkout@v4` step, one `run:` line).
- [x] T005 [parallel] Verify locally that all three scripts referenced in
  T004 actually pass (`./scripts/test-migration-critique-to-audit.sh`,
  `./scripts/test-migration-sync-to-tracker.sh`,
  `./scripts/test-migration-workflow-table.sh`) — confirming there's no
  latent failure hiding behind the missing CI wiring before it goes live
  in the workflow.

## Phase 3: Prerelease sweep scenario additions (feedback F001–F003, feedback-prerelease-sweep-scenario-gaps-95f6.md)
- [ ] T006 [parallel] Write `tests/prerelease/scenarios/S8.md` (full
  tier) — Agent-tool worktree fan-out delegation scenario: solo
  greenfield consumer, two `ready` tasks files, background both via
  `/ardd-implement`'s multi-select fan-out, verify both merges land
  code+state atomically (per `merge_policy`), `worktree-reap.sh` runs
  post-merge, and `inflight-worktrees.sh` reports empty afterward. Fold
  in the `fold-to-main.sh` eager-background-while-on-a-branch path as
  S8's setup step (start the second of the two runs from a feature
  branch rather than the default branch, so backgrounding it exercises
  the fold path too) — no separate scenario for this. Follow `S6.md`'s
  existing structure (Axes / Purpose / Setup / Steps) as the template.
- [ ] T007 [parallel] Extend `tests/prerelease/scenarios/S3.md` (full
  tier) with a channel-switch flow: after S3's existing upgrade-path
  steps, run `/ardd-update --beta` then `/ardd-update --stable` on the
  same consumer, asserting `Channel:`/`Source-Ref:` in
  `.project/ardd-version.md` stay mutually consistent after each switch,
  `ardd-update-check.sh` computes `behind` within the currently-recorded
  channel, and `lint-project.sh`'s prerelease-ref-under-stable check
  (from `channel-source-ref-consistency`) fires only when it should
  (i.e. not immediately after the `--beta` switch, but correctly if a
  stale beta ref were left under a stable channel).
- [ ] T008 [parallel] Extend `tests/prerelease/scenarios/S7.md` (smoke
  tier) with `epic:` register-label coverage: seed a couple of `epic:`
  fields into the consumer's feature register and confirm `/ardd-status`
  groups its Feature Backlog counts "by epic" correctly and
  `/ardd-backlog --assign-epics` behaves sanely against already-labeled
  entries (proposes nothing for already-`epic`'d slugs, or handles them
  per its own documented behavior).
- [ ] T009 First check whether `skills/prerelease-sweep/SKILL.md` (and,
  if it exists, `docs/reference/skills/prerelease-sweep.md`) hardcodes a
  scenario name/tier list, or dynamically discovers
  `tests/prerelease/scenarios/*.md` at dispatch time. If hardcoded,
  update it to register S8 and note the S3/S7 extensions. If already
  dynamic, make no edit and record why in this task's completion note.
