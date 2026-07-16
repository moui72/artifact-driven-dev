---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: list-mode-for-plan-and-impleme
created: 2026-07-15
features: [list-mode-for-plan-and-impleme]
surfaced-defects: []
---

# Plan: list-mode-for-plan-and-impleme

## Goal

Give `/ardd-plan` and `/ardd-implement` a `--list` mode that prints
eligible slugs/tasks files with basic info and exits, without entering
either skill's interactive pick flow.

## Scope

In scope:
- A new deterministic script, `scripts/feature-list.sh`, mirroring the
  existing `scripts/tasks-list.sh` — enumerates `.project/features/*.md`
  by glob (constitution standing decision: register-wide views come from
  enumeration, never a second hand-maintained index) and prints one line
  per feature: `<slug>\t<status>\t<logged>\t<description>`, filtered to
  `backlogged` by default, `--status <s1,s2,...>` to widen the filter,
  `--all` for every status.
- `skills/ardd-plan/SKILL.md`: a `--list` usage form that shells out to
  `feature-list.sh` (default filter) and prints the result, then stops —
  no artifact discovery, no feedback load, no interactive pick.
- `skills/ardd-implement/SKILL.md`: a `--list` usage form that shells out
  to the existing `tasks-list.sh`, filters its output to `ready` and
  `in-progress` rows only (a plain grep/awk over already-produced
  tab-separated columns — not a new mutation or invariant check, so this
  filtering stays skill-prose per Principle II's own scope, the same way
  other skills already grep script output inline), and prints the
  result, then stops.
- `scripts/test-feature-list.sh` (fixture-based regression test,
  mirroring `scripts/test-tasks-list.sh`'s structure) and a new CI job in
  `.github/workflows/lint.yml` (this repo's CI enumerates jobs
  explicitly rather than globbing, unlike the pre-commit hook — a new
  script needs an explicit job added, not just the test file).
- Reference docs: `docs/reference/skills/ardd-plan.md`,
  `docs/reference/skills/ardd-implement.md`.

Out of scope:
- No change to the existing interactive pick flow in either skill —
  `--list` is a pure side-door, bare-form behavior is untouched.
- No change to `tasks-list.sh` itself — its existing `[--all]` flag and
  four-column output already cover what `/ardd-implement --list` needs;
  only the `ready`/`in-progress` filtering is new, and that's a grep step
  in skill prose, not a script change.
- No constitution changes — no new principle, data-model concept, or
  production shortcut, and this repo has no `datamodel.md`/
  `infrastructure.md`/`ui.md` to touch.

## Technical Approach

`tasks-list.sh` already exists and already does most of what
`/ardd-implement --list` needs (status, checkbox progress, plan binding,
`--all` to include `abandoned`). The only gap for `--implement --list` is
narrowing its default output (which includes `ready`, `in-progress`, and
`completed`) down to just `ready`/`in-progress` — the feature's stated
scope ("ready/in-progress tasks files"). That's a column-3 filter over
already-deterministic tab-separated output, not a new invariant, so it's
implemented as a one-line filter in the skill's `--list` step rather than
a new script flag — consistent with how other skills already consume
script output directly (e.g. `/ardd-status` greeping
`feature-*.md` frontmatter).

`/ardd-plan --list` has no existing equivalent — nothing in this repo
currently enumerates the feature register with a one-line description
per entry. Per the constitution's standing decision that register-wide
views come from enumeration (glob) and per Principle II (a pure function
of file state gets a real deterministic script), this needs a new
script: `feature-list.sh`. Its shape directly mirrors `tasks-list.sh`
(same tab-separated-line-per-file structure, same `--all`-style opt-in
widening, same frontmatter-parsing `awk` pattern) so it reads as the
same kind of tool, not a bespoke one-off. Default filter is `backlogged`
(matching the feature request's framing: "what's actionable at a
glance" for planning), with `--status <comma-list>` for anything wider
and `--all` as shorthand for every status.

Both `--list` invocations are read-only and skip every side-effecting
step of their host skill (artifact discovery, feedback/defect loading,
delegation gates, etc.) — they exist purely to answer "what's
actionable right now" from a script or a quick terminal check, per the
feature's stated motivation.

## Phase Breakdown

### Phase 1: `feature-list.sh` [feature: list-mode-for-plan-and-impleme]

- T001 (test-first) Write `scripts/test-feature-list.sh` — a
  fixture-based regression test (throwaway temp dir, mirroring
  `scripts/test-tasks-list.sh`'s structure) covering: default filter
  returns only `backlogged` entries; `--status planned,tasked` widens
  the filter to exactly those statuses; `--all` returns every status;
  output column order and tab-separation; a feature body with a `Why:`
  line still yields only the first (one-sentence description) line in
  the description column; empty register directory (`.project/features/`
  absent or empty) exits 0 with no output. Run it against the not-yet-written
  script and confirm it fails.
- T002 Write `scripts/feature-list.sh` implementing the behavior T001
  tests: glob `.project/features/*.md`, parse frontmatter (`slug`,
  `status`, `logged`) the same `awk`-between-`---`-markers pattern
  `tasks-list.sh` uses, take the body's first non-blank line as
  `description`, filter by status (default `backlogged`; `--status
  <list>`; `--all`), and print `<slug>\t<status>\t<logged>\t<description>`
  per matching file. Confirm T001 now passes.
- T003 [parallel] Add a CI job for `test-feature-list.sh` to
  `.github/workflows/lint.yml`, following the existing per-script job
  pattern (this repo's CI enumerates jobs explicitly, unlike the
  pre-commit hook's glob).

### Phase 2: skill `--list` modes [feature: list-mode-for-plan-and-impleme]

- T004 [artifacts: none] Add a `--list` usage form to
  `skills/ardd-plan/SKILL.md`: run
  `.claude/skills/ardd-scripts/feature-list.sh` (installed copy; source
  repo path as fallback per the standard present-or-fallback rule used
  elsewhere in this skill), print its output, and stop — before step 1's
  branch check and before any other step. Document that this bypasses
  the interactive pick flow entirely and performs no writes. No test
  task — prose-only skill-file change (Principle V's documentation-only
  exception).
- T005 [artifacts: none] [parallel] Add a `--list` usage form to
  `skills/ardd-implement/SKILL.md`: run
  `.claude/skills/ardd-scripts/tasks-list.sh` (same present-or-fallback
  rule), filter its tab-separated output to rows whose status column is
  `ready` or `in-progress`, print the result, and stop — before step 1's
  `inflight-worktrees.sh` call and pick-list presentation. No test task
  — prose-only change.
- T006 [artifacts: none] [parallel] Update
  `docs/reference/skills/ardd-plan.md` and
  `docs/reference/skills/ardd-implement.md` to document the new `--list`
  usage forms, matching T004/T005.

## Open Questions

- Should `feature-list.sh`'s description column truncate a very long
  first body line, the way `tasks-list.sh` doesn't need to (task/plan
  filenames are short by construction)? Left to T002's implementation —
  match `tasks-list.sh`'s no-truncation precedent unless a fixture case
  in T001 shows it's actually needed.
- `/ardd-implement --list`'s ready/in-progress filter doesn't currently
  cross-reference `inflight-worktrees.sh` to flag a file another
  worktree already claims (the way the normal pick-list step does) —
  intentionally out of scope per the feature's own framing ("basic info
  ... without entering the interactive pick flow"), but worth revisiting
  if `--list` output turns out to get used for anything beyond a quick
  glance.
