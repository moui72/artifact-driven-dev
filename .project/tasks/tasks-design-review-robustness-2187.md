---
plan: plan-design-review-robustness-2026-07-03.md
generated: 2026-07-03
status: completed
---

# Tasks

## Phase 1: Close earlier drift (prerequisite)

- [x] T001 [artifacts: constitution] [parallel] Update `constitution.md`'s
  Quality Standards → Pre-commit Enforcement bullet to add
  `scripts/test-sibling-tasks-complete.sh` to the enumerated list of scripts
  `hooks/pre-commit` runs — that script was added in an earlier session and
  `hooks/pre-commit` already runs it, but the constitution's list still only
  names the original four. Bump `last_updated`.
- [x] T002 [parallel] Add a `sibling-tasks-complete` job to
  `.github/workflows/lint.yml` running `./scripts/test-sibling-tasks-
  complete.sh`, mirroring the existing job pattern (e.g. the `lint-project`
  job: checkout + one run step) — this test script was added without CI
  wiring in the same earlier session as T001's drift.

## Phase 2: `/ardd-sync` testable decision scripts

- [x] T003 [parallel] Write `scripts/test-sync-slug-match.sh`: fixture-based
  regression test for a not-yet-written `scripts/sync-slug-match.sh
  <slug> <search-result-body>...` that decides whether a `gh issue list
  --search` result's body contains this slug's `ardd-sync-slug-<slug>`
  marker (see `skills/ardd-sync/SKILL.md`'s Push step 2 for the exact
  marker format). Cover: no results → no match; one result with the exact
  marker → match, prints the issue number; one result with a marker for a
  *different* slug → no match. Mirror the throwaway-fixture style of
  `scripts/test-branch-info.sh`. Confirm this test fails right now — the
  script doesn't exist yet (Principle V: red before green).
- [x] T004 [parallel] Implement `scripts/sync-slug-match.sh` to make T003's
  tests pass. Confirm they pass (green).
- [x] T005 [parallel] Write `scripts/test-sync-label-decision.sh`: fixture-
  based regression test for a not-yet-written `scripts/sync-label-
  decision.sh <status> <current-labels>` that decides what `ardd:*` label
  change (if any) is needed given a `features.md` `Status` value and the
  issue's current labels (see `skills/ardd-sync/SKILL.md`'s Push step 3).
  Cover: label already matches status → no change; label is behind status
  → prints old/new label pair; `Status: implemented` with issue still open
  → prints "close". Confirm this test fails right now — the script doesn't
  exist yet.
- [x] T006 [parallel] Implement `scripts/sync-label-decision.sh` to make
  T005's tests pass. Confirm they pass.
- [x] T007 [parallel] Write `scripts/test-sync-divergence.sh`: fixture-based
  regression test for a not-yet-written `scripts/sync-divergence.sh
  <status> <issue-state>` that decides whether tracker state has diverged
  from `features.md` (see `skills/ardd-sync/SKILL.md`'s Pull step 2: closed-
  but-not-`implemented`, or reopened-but-`implemented`). Cover: matching
  states → not diverged; each of the two divergent combinations → diverged
  with the right message text. Confirm this test fails right now — the
  script doesn't exist yet.
- [x] T008 [parallel] Implement `scripts/sync-divergence.sh` to make T007's
  tests pass. Confirm they pass.
- [x] T009 Update `skills/ardd-sync/SKILL.md` prose so Push step 2 calls
  `sync-slug-match.sh`, Push step 3 calls `sync-label-decision.sh`, and Pull
  step 2 calls `sync-divergence.sh` at the exact points where those
  decisions are currently made inline — the surrounding `gh` calls
  themselves stay in prose (only the pure decisions move into scripts).
  Depends on T004, T006, T008 existing.
- [x] T010 Update `install.sh`'s "Deterministic check/utility scripts"
  section to copy `scripts/sync-slug-match.sh`, `scripts/sync-label-
  decision.sh`, and `scripts/sync-divergence.sh` into `$ARDD_SCRIPTS_DIR`
  and `chmod +x` them, mirroring how `lint-project.sh`/`branch-info.sh`/
  `sibling-tasks-complete.sh` are installed. Depends on T004, T006, T008.
- [x] T011 Add `scripts/test-sync-slug-match.sh`, `scripts/test-sync-label-
  decision.sh`, and `scripts/test-sync-divergence.sh` to `hooks/pre-commit`'s
  `checks` list, and add three matching jobs to
  `.github/workflows/lint.yml` (one per script, mirroring the existing
  per-script job pattern). Depends on T003, T005, T007.

## Phase 3: Concurrency marker

- [x] T012 Write `scripts/test-project-lock.sh`: fixture-based regression
  test (throwaway temp dir, mirroring `scripts/test-sibling-tasks-
  complete.sh`'s style) for a not-yet-written `scripts/project-lock.sh`
  with two subcommands: `touch <label>` (writes `.project/.lock` containing
  the current timestamp and `<label>`) and `check <label>` (prints a warning
  line if `.project/.lock` exists, is newer than 5 minutes old, and its
  recorded label differs from `<label>`; otherwise silent). Cover: no lock
  file → silent; fresh lock from the same label → silent; fresh lock from a
  different label → warns; a lock older than 5 minutes from a different
  label → silent (stale, not a real race). Confirm this test fails right
  now — the script doesn't exist yet.
- [x] T013 Implement `scripts/project-lock.sh` (`touch`/`check`
  subcommands) to make T012's tests pass. Confirm they pass.
- [x] T014 Update `install.sh` to copy `scripts/project-lock.sh` into
  `$ARDD_SCRIPTS_DIR` and `chmod +x` it (mirroring the other installed
  scripts); add `scripts/test-project-lock.sh` to `hooks/pre-commit`'s
  `checks` list and a matching job to `.github/workflows/lint.yml`; and
  extend `install.sh`'s gitignore-guidance section with a one-line note
  that a target project should also gitignore `.project/.lock` (transient
  local state, not project history — same reasoning already given there for
  `.claude/skills/ardd-*/`). Depends on T013.
- [x] T015 [parallel] Update `skills/ardd-plan/SKILL.md`: call
  `.claude/skills/ardd-scripts/project-lock.sh check ardd-plan` before step
  3d's artifact writes and before step 9's plan write, and `... touch
  ardd-plan` immediately after each; note in prose that a warning from
  `check` is advisory — surface it to the user but don't block on it.
  Depends on T013.
- [x] T016 [parallel] Update `skills/ardd-tasks/SKILL.md`: call `project-
  lock.sh check ardd-tasks` before step 3's plan-approval flip and before
  step 6's tasks-file write, and `... touch ardd-tasks` immediately after
  each. Depends on T013.
- [x] T017 [parallel] Update `skills/ardd-implement/SKILL.md`: call
  `project-lock.sh check ardd-implement` / `... touch ardd-implement`
  around step 7's feature-flip-on-completion write. Depends on T013.
- [x] T018 [parallel] Update `skills/ardd-converge/SKILL.md`: call
  `project-lock.sh check ardd-converge` / `... touch ardd-converge` around
  step 6's feature-flip-on-completion write. Depends on T013.

## Phase 4: Bookkeeping-consistency lint check

- [x] T019 Extend `tests/fixtures/bad-project`: add a `features:
  [some-slug]` entry to its plan frontmatter where the plan's own `status`
  is `approved` (reuse `plan-foo-2026-01-01.md`, already `status: draft` in
  that fixture per T-earlier work — change it to `approved` for this case,
  or add a second plan file if changing it would conflict with an existing
  assertion) and add a matching `features.md` entry for that slug still at
  `Status: backlogged`. Run `scripts/lint-project.sh` against
  `bad-project` and confirm it does *not* yet flag this specific
  combination — demonstrating the gap before T020 closes it (red state).
- [x] T020 Add a new check to `scripts/lint-project.sh`'s plan-validation
  loop: for a plan at `status: approved` or `status: superseded` with a
  non-empty `features:` list, for each listed slug look up its `Status` in
  `features.md` and report a violation if it's still `backlogged` (the
  fingerprint an approval sequence interrupted between the plan-status flip
  and the feature-status flip would leave — see `/ardd-tasks` step 3).
  Confirm T019's fixture now fails lint for this new reason, and
  `tests/fixtures/good-project` still passes.
- [x] T021 Run the full script suite — `scripts/lint-docs.sh`,
  `scripts/test-lint-project.sh`, `scripts/test-branch-info.sh`,
  `scripts/test-sibling-tasks-complete.sh`, `scripts/test-sync-slug-
  match.sh`, `scripts/test-sync-label-decision.sh`, `scripts/test-sync-
  divergence.sh`, `scripts/test-project-lock.sh`,
  `scripts/test-hook-lint-on-write.sh`, `scripts/test-hooks-pre-commit.sh`
  — and confirm none regressed across all four phases. This is a
  verification/integration task, not new code, so it has no new test of
  its own (Principle V's stated exception).
