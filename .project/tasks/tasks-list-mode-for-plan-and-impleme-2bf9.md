---
plan: plan-list-mode-for-plan-and-impleme-2026-07-15-a2c2.md
generated: 2026-07-15
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: `feature-list.sh` [feature: list-mode-for-plan-and-impleme]

- [x] T001 (test-first) Write `scripts/test-feature-list.sh` — a
  fixture-based regression test (throwaway temp dir, mirroring
  `scripts/test-tasks-list.sh`'s structure) covering: default filter
  returns only `backlogged` entries; `--status planned,tasked` widens
  the filter to exactly those statuses; `--all` returns every status;
  output column order and tab-separation; a feature body with a `Why:`
  line still yields only the first (one-sentence description) line in
  the description column; empty register directory
  (`.project/features/` absent or empty) exits 0 with no output. Run it
  against the not-yet-written script and confirm it fails.

- [x] T002 Write `scripts/feature-list.sh` implementing the behavior
  T001 tests: glob `.project/features/*.md`, parse frontmatter (`slug`,
  `status`, `logged`) using the same `awk`-between-`---`-markers pattern
  `tasks-list.sh` uses, take the body's first non-blank line as
  `description`, filter by status (default `backlogged`; `--status
  <list>`; `--all`), and print
  `<slug>\t<status>\t<logged>\t<description>` per matching file. Confirm
  T001 now passes.

- [x] T003 [parallel] Add a CI job for `test-feature-list.sh` to
  `.github/workflows/lint.yml`, following the existing per-script job
  pattern (this repo's CI enumerates jobs explicitly, unlike the
  pre-commit hook's glob).

## Phase 2: skill `--list` modes [feature: list-mode-for-plan-and-impleme]

- [x] T004 Add a `--list` usage form to `skills/ardd-plan/SKILL.md`: run
  `.claude/skills/ardd-scripts/feature-list.sh` (installed copy; source
  repo path as fallback per the standard present-or-fallback rule used
  elsewhere in this skill), print its output, and stop — before step
  1's branch check and before any other step. Document that this
  bypasses the interactive pick flow entirely and performs no writes.
  No test task — prose-only skill-file change (Principle V's
  documentation-only exception).

- [x] T005 [parallel] Add a `--list` usage form to
  `skills/ardd-implement/SKILL.md`: run
  `.claude/skills/ardd-scripts/tasks-list.sh` (same present-or-fallback
  rule), filter its tab-separated output to rows whose status column is
  `ready` or `in-progress`, print the result, and stop — before step
  1's `inflight-worktrees.sh` call and pick-list presentation. No test
  task — prose-only change.

- [x] T006 [parallel] Update `docs/reference/skills/ardd-plan.md` and
  `docs/reference/skills/ardd-implement.md` to document the new
  `--list` usage forms, matching T004/T005.
