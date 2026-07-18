---
status: open      # open -> planned
created: 2026-07-18
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## UX
- [ ] F001 `tests/prerelease/` scenarios S1–S7 (written ~2026-07-15) have
  no scenario exercising `Agent`-tool worktree **fan-out** delegation
  (`worktree-reap-and-fanout`, implemented 2026-07-12) — S6 only tests
  the script layer against a manually-created worktree, never the real
  `isolation: "worktree"` multi-select fan-out path with per-report-back
  `merge_policy` merges, the `core.bare` check, and reap. This is the
  highest-blast-radius surface with zero live coverage. Recommend a new
  **S8 (full tier)**: solo greenfield, two `ready` tasks files,
  background both via `/ardd-implement` multi-select, verify both
  merges land code+state atomically, reap runs, `inflight-worktrees.sh`
  empties. Fold in the `fold-to-main.sh` eager-background-while-on-a-branch
  path (`background-by-default-flow`, 2026-07-12) as S8's setup step
  (start the second run from a feature branch) rather than a separate
  scenario.
- [ ] F002 No scenario exercises *switching* release channels — S3
  checks that version/channel get recorded correctly but never runs
  `/ardd-update --beta` then `--stable` on the same consumer to confirm
  `Channel:`/`Source-Ref:` in `ardd-version.md` stay consistent both
  ways, that `ardd-update-check.sh` computes `behind` within the
  recorded channel, and that `lint-project.sh`'s prerelease-ref-under-stable
  check (from `channel-source-ref-consistency`, 2026-07-18) fires only
  when it should. Both `update-channel-switch-flags` (2026-07-15) and
  `channel-source-ref-consistency` (2026-07-18) postdate S3's authoring.
  Recommend extending **S3 (full tier)** with this channel-switch flow.
- [ ] F003 No scenario touches `epic:` register labels at all
  (`epics-grouping-in-feature-regi` + `backlog-assign-epics-automated`,
  2026-07-15/18) — S7's peripheral sweep predates them. Recommend
  extending **S7 (smoke tier — cheap)**: seed a couple of `epic:` fields
  in the consumer's register and check `/ardd-status`/`/ardd-backlog`
  handle grouping and the automated-assignment sweep sanely.

Found via an agent survey of the repo's CI/prerelease surface area for
coverage gaps (2026-07-18). Priority order given: CI wiring fix (see
`feedback-ci-migration-tests-unwired-37ee.md`) → F001 (S8) → F002 (S3
extension) → F003 (S7 extension).
