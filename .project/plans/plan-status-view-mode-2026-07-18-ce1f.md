---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: status-view-mode
created: 2026-07-18
features: [status-view-mode]
surfaced-defects: []
---

# Plan: status-view-mode

## Goal

Add a read-only `/ardd-status --view` mode; wire the three currently-unwired
migration regression tests into CI; and extend the local-only prerelease
sweep with a new fan-out scenario (S8) plus additions to S3 and S7 —
closing the gaps two feedback batches surfaced today.

## Scope

**In scope:**
- `status-view-mode` (feature): a `/ardd-status --view` read-only side
  door — reports a summary, incomplete/in-flight snapshot, and
  recommended next step without regenerating or writing `STATUS.md`,
  mirroring the existing `--list` side-door pattern already used by
  `/ardd-plan` and `/ardd-implement`.
- `feedback-ci-migration-tests-unwired-37ee.md` (F001): add CI jobs for
  `test-migration-critique-to-audit.sh`, `test-migration-sync-to-tracker.sh`,
  and `test-migration-workflow-table.sh` to `.github/workflows/lint.yml`,
  mirroring the existing `migration-retag`/`migration-diagram-type` job
  shape.
- `feedback-prerelease-sweep-scenario-gaps-95f6.md` (F001–F003):
  - F001 — new `tests/prerelease/scenarios/S8.md` (full tier): live
    `Agent`-tool worktree fan-out delegation, folding in the
    `fold-to-main.sh` eager-background-while-on-a-branch path as its
    setup step.
  - F002 — extend `S3.md` (full tier) with a channel-switch flow
    (`/ardd-update --beta` then `--stable` on the same consumer).
  - F003 — extend `S7.md` (smoke tier) with `epic:` register-label
    coverage.
  - Update `skills/prerelease-sweep/SKILL.md` and
    `docs/reference/skills/prerelease-sweep.md` (if it names scenario
    tiers/counts) to reflect the new/extended scenario set.

**Out of scope:**
- Any change to how `/ardd-status`'s normal (non-`--view`) write path
  works — `--view` is strictly additive, a new read-only mode alongside
  the existing full write behavior, same shape as `/ardd-plan --list` and
  `/ardd-implement --list`.
- Actually *running* S8 or the extended S3/S7 scenarios — that's a
  separate `/prerelease-sweep` invocation once these scenario files
  exist; this plan only writes the scenario specs and CI wiring.
- The parallel `research-docs-freshness-skill` investigation
  (`.project/plans/research-docs-freshness-skill-2026-07-18.md`) — a
  separate research thread, not folded in here.

## Technical Approach

**`status-view-mode`**: `/ardd-status`'s existing steps already compute
everything `--view` needs to report (artifact status, in-flight
worktrees, feedback/backlog counts, recommended next step) — `--view`
reuses that same discovery (steps 1–5 of the current skill, unchanged)
but stops before step 6's `STATUS.md` write, printing the assembled
report directly instead. This mirrors `/ardd-plan --list` and
`/ardd-implement --list`'s existing "read-only side door, runs before
the normal flow, no writes" shape exactly — the same convention, applied
to `/ardd-status`.

**CI wiring (F001)**: a pure `.github/workflows/lint.yml` edit — three
new jobs, each identical in shape to the existing `migration-retag`/
`migration-diagram-type` jobs, just naming the three currently-unwired
scripts.

**Prerelease sweep additions (F001–F003)**: new/extended scenario
Markdown files under `tests/prerelease/scenarios/`, following each
existing scenario's established shape (Axes / Purpose / Setup / Steps —
per `S3.md`'s and `S6.md`'s current structure). No change to the
dispatch mechanism in `skills/prerelease-sweep/SKILL.md` itself beyond
registering the new S8 scenario and noting the S3/S7 extensions, if the
skill file enumerates scenario names/counts anywhere.

## Phase Breakdown

### Phase 1: `/ardd-status --view` mode
Depends on: —
- T001: Add a `--view` usage line and mode description to
  `skills/ardd-status/SKILL.md`'s top usage block, alongside the existing
  Usage section — same doc location as `/ardd-plan --list`/
  `/ardd-implement --list`'s own usage lines, parallel structure. State
  plainly it runs steps 1–5 (discovery) unchanged, then prints the
  assembled report and stops — no `STATUS.md` write, no step 7's
  orphaned-flip confirmation (visibility only, matching `--list`'s "no
  writes of any kind" framing).
- T002: [artifacts: constitution] Write the `--view` step: run the
  existing discovery steps (1–5) as-is, then print the Report format
  from step 5 directly to the terminal instead of writing it to
  `STATUS.md` in step 6. Skip step 7 (orphaned-flip confirmation) and
  step 8 (next-step prompt via `AskUserQuestion`) entirely in this mode —
  `--view` is inspection only, never a state-changing prompt.
- T003: Manually exercise `/ardd-status --view` against this repo's own
  `.project/` state and confirm it reports the same substantive content
  a full `/ardd-status` run would, without touching `STATUS.md` (`git
  status --short .project/STATUS.md` shows no change after running it).

### Phase 2: CI wiring fix (F001)
Depends on: —
[parallel] with Phase 1 (different files, no shared dependency)
- T004: [feedback: F001] Add three CI jobs to
  `.github/workflows/lint.yml` — `migration-critique-to-audit`,
  `migration-sync-to-tracker`, `migration-workflow-table` — each running
  its corresponding `scripts/test-migration-*.sh`, matching the existing
  `migration-retag`/`migration-diagram-type` job shape exactly (same
  `runs-on`, same `actions/checkout@v4` step, one `run:` line).
- T005: Verify locally that all three scripts referenced in T004 actually
  pass (`./scripts/test-migration-critique-to-audit.sh`,
  `./scripts/test-migration-sync-to-tracker.sh`,
  `./scripts/test-migration-workflow-table.sh`) — confirming there's no
  latent failure hiding behind the missing CI wiring before it goes live
  in the workflow.

### Phase 3: Prerelease sweep scenario additions (F001–F003)
Depends on: —
[parallel] with Phases 1–2 (different files)
- T006: [feedback: F001] Write `tests/prerelease/scenarios/S8.md` (full
  tier) — Agent-tool worktree fan-out delegation scenario: solo
  greenfield consumer, two `ready` tasks files, background both via
  `/ardd-implement`'s multi-select fan-out, verify both merges land
  code+state atomically (per `merge_policy`), `worktree-reap.sh` runs
  post-merge, and `inflight-worktrees.sh` reports empty afterward. Fold
  in the `fold-to-main.sh` eager-background-while-on-a-branch path as
  S8's setup step (start the second of the two runs from a feature
  branch rather than the default branch, so backgrounding it exercises
  the fold path too) — per the plan's Out of scope note, no separate
  scenario for this. Follow `S6.md`'s existing structure (Axes / Purpose
  / Setup / Steps) as the template.
- T007: [feedback: F002] Extend `tests/prerelease/scenarios/S3.md` (full
  tier) with a channel-switch flow: after S3's existing upgrade-path
  steps, run `/ardd-update --beta` then `/ardd-update --stable` on the
  same consumer, asserting `Channel:`/`Source-Ref:` in
  `.project/ardd-version.md` stay mutually consistent after each switch,
  `ardd-update-check.sh` computes `behind` within the currently-recorded
  channel, and `lint-project.sh`'s prerelease-ref-under-stable check
  (from `channel-source-ref-consistency`) fires only when it should
  (i.e. not immediately after the `--beta` switch, but correctly if a
  stale beta ref were left under a stable channel).
- T008: [feedback: F003] Extend `tests/prerelease/scenarios/S7.md`
  (smoke tier) with `epic:` register-label coverage: seed a couple of
  `epic:` fields into the consumer's feature register and confirm
  `/ardd-status` groups its Feature Backlog counts "by epic" correctly
  and `/ardd-backlog --assign-epics` behaves sanely against
  already-labeled entries (proposes nothing for already-`epic`'d slugs,
  or handles them per its own documented behavior).
- T009: [artifacts: none] Update `skills/prerelease-sweep/SKILL.md` and,
  if it exists and enumerates scenario names/tiers,
  `docs/reference/skills/prerelease-sweep.md` to register S8 and note the
  S3/S7 extensions — only if either currently hardcodes a scenario
  list/count that would otherwise go stale; if scenario discovery is
  already dynamic (globs `tests/prerelease/scenarios/*.md`), skip this
  task's doc edit and note why in the completion record.

## Complexity Tracking

No deviations requiring justification — `--view` follows the established
`--list` side-door pattern precisely; the CI fix is a straight three-job
addition matching an existing pattern; the sweep scenarios follow each
existing scenario file's own established shape.

## Open Questions

- [OPEN: Does `skills/prerelease-sweep/SKILL.md` hardcode a scenario
  list, or does it dynamically discover `tests/prerelease/scenarios/*.md`
  at dispatch time? T009 is written to handle either case, but this
  wasn't confirmed before drafting this plan — resolve at execution
  time.]
- [OPEN: Should S8's two-tasks-file fan-out scenario provision its own
  throwaway consumer repo state (two synthetic `ready` tasks files
  seeded directly), or does it need a more realistic feature/plan
  history behind them? `S6.md`'s existing shape should answer this by
  precedent — resolve at execution time by reading it.]
