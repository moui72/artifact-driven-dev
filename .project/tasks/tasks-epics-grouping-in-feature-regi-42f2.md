---
plan: plan-epics-grouping-in-feature-regi-2026-07-15-d215.md
generated: 2026-07-15
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: schema validation [feature: epics-grouping-in-feature-regi]

- [x] T001 (test-first) Add an `epic` case to
  `tests/fixtures/bad-project/.project/features/` (a new or amended
  fixture file with `epic:` present but empty) and a corresponding
  assertion in `scripts/test-lint-project.sh` expecting
  `lint-project.sh` to report it. Confirm the assertion fails against
  the current `lint-project.sh` (no `epic` handling exists yet).

- [x] T002 Add `epic` emptiness validation to `scripts/lint-project.sh`'s
  feature-register loop — mirroring the existing `rfield` free-text
  emptiness pattern used for `diagram_type`/`render_target`/etc., not
  the `gh_issue` numeric check (an `epic` slug is arbitrary text, not a
  number). Add a non-empty `epic:` value to
  `tests/fixtures/good-project/.project/features/widget-export.md` (or
  another good-project feature file) to prove the positive case stays
  clean. Confirm T001's assertion now passes and
  `./scripts/test-lint-project.sh` is green end to end.

## Phase 2: `feature-list.sh` epic column + filter [feature: epics-grouping-in-feature-regi]

- [ ] T003 (test-first) Extend `scripts/test-feature-list.sh` with
  assertions for: the fifth output column carries `epic` (empty string
  when unset, matching the tab-separated shape the other optional
  fields already use); `--epic <slug>` filters to only features with
  that exact `epic` value, composable with `--status`/`--all` (e.g.
  `--all --epic foo` widens status but still filters by epic). Confirm
  these fail against the current two-flag `feature-list.sh`.

- [ ] T004 Extend `scripts/feature-list.sh`: parse `epic` from
  frontmatter the same way `slug`/`status`/`logged` are parsed, append
  it as a fifth tab-separated column, and add the `--epic <slug>`
  filter. Confirm T003 now passes.

## Phase 3: `/ardd-status` epic breakdown [feature: epics-grouping-in-feature-regi]

- [ ] T005 Add an optional "by epic" line/section to
  `skills/ardd-status/SKILL.md`'s step 1 (feature register enumeration)
  and step 6/report template's Feature Backlog section: when any
  feature carries a non-empty `epic`, group backlogged/planned/tasked
  counts by epic value and list them (omit the section entirely when
  no feature has `epic` set — same "omit if none" convention already
  used throughout this skill). No test task — prose-only skill-file
  change (constitution Principle V's documentation-only exception).

## Phase 4: `/ardd-tracker` milestone mapping [feature: epics-grouping-in-feature-regi]

- [ ] T006 Add a milestone-assignment sub-step to
  `skills/ardd-tracker/SKILL.md`'s push phase: when a feature being
  pushed has `epic` set, ensure a GitHub milestone named for that epic
  slug exists (create via `gh api repos/{owner}/{repo}/milestones -f
  title=<epic>`, ignoring "already exists" errors — the same
  idempotent pattern the Prerequisites step already uses for labels)
  and assign the issue to it (`gh issue edit <n> --milestone <epic>`).
  Document that this is one-directional (register → tracker, matching
  the existing name/slug/description ownership rule) — pull never
  reads a milestone back into `epic`. No test task — prose-only
  change to `gh`-calling skill prose, consistent with
  `/ardd-tracker`'s existing untested `gh` glue (constitution
  Principle V's documentation-only exception, and the standing
  mechanization non-goal noted in the plan's Technical Approach).
