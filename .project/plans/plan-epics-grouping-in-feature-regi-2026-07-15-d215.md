---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: epics-grouping-in-feature-regi
created: 2026-07-15
features: [epics-grouping-in-feature-regi]
surfaced-defects: []
---

# Plan: epics-grouping-in-feature-regi

## Goal

Add an optional `epic:` frontmatter field to the feature register for
declared, durable grouping of related features into release-cadence-sized
bundles, and surface that grouping in `feature-list.sh`, `/ardd-status`,
and `/ardd-tracker`.

## Scope

In scope (the feature's own "minimal version," deliberately bounded):
- `constitution.md`: `epic` added to the feature register's documented
  optional fields (**already applied** ahead of this plan — MINOR bump
  1.10.0 → 1.11.0, SIR written).
- `scripts/lint-project.sh`: validate `epic` when present (non-empty,
  free text — no enum, mirroring the existing `diagram_type`/
  `render_target`-style emptiness check, not the `gh_issue`
  numeric-format check since `epic` is an arbitrary slug).
- `scripts/feature-list.sh`: add `epic` as a fifth output column and a
  `--epic <slug>` filter (in addition to the existing `--status`/`--all`
  filters), so `/ardd-plan --list` can show and filter by epic.
- `/ardd-status`: an optional "by epic" breakdown line under Feature
  Backlog, shown only when at least one feature carries an `epic` value
  — mirrors the existing "omit if none" pattern used throughout this
  skill's report sections.
- `/ardd-tracker` push: when a feature has `epic` set, ensure a matching
  GitHub milestone exists (`gh api repos/{owner}/{repo}/milestones` /
  `gh issue edit --milestone`) and assign the pushed issue to it —
  register owns `epic` and pushes it one-directionally, exactly like the
  existing register→tracker field-ownership rule for name/slug/
  description; pull never reads milestone back into the register.

Out of scope (explicitly, per the feature's own framing):
- No `epic` files with their own lifecycle/status — a second register to
  keep consistent — until flat-slug grouping proves insufficient.
- No `/ardd-plan` interactive "plan this epic" picker UI — passing
  multiple feature slugs that share an epic to `/ardd-plan <slug>
  <slug> ...` already plans them as one unit today; `feature-list.sh
  --epic <slug>` (this plan) is what a maintainer greps to find that
  slug list. No new selection mechanism.
- No cross-project or cross-repo epic concept — `epic` is a per-project
  free-text slug, not a synced/validated taxonomy.
- No change to the computed/ephemeral "defrag" plan-time footprint
  analysis (`plan-time-defrag-slate-analysi`, separate backlog item) —
  distinct declared-vs-computed concepts, not to be conflated.

## Technical Approach

`epic` follows the same shape as the register's other optional fields
(`plan`, `tasks`, `gh_issue`): free text, validated for shape but never
enum-checked, read by enumeration (glob) per the constitution's
register-wide-views standing decision — no second index file, no new
storage mechanism. `feature-list.sh` already exists (this repo's own
`list-mode-for-plan-and-impleme` feature, shipped earlier today) and
already parses frontmatter the same `awk`-between-`---`-markers way
`tasks-list.sh` does — adding a fifth column and a filter flag is a
direct extension of that existing pattern, not a new script.

`/ardd-status`'s Feature Backlog section already counts by `status`; the
epic breakdown is an additional grouping over the same already-loaded
data (glob `.project/features/*.md`, group by `epic` where present) —
no new script, since this is read-only visibility identical in kind to
the existing status-count line.

`/ardd-tracker`'s milestone assignment is the one genuinely new piece of
`gh` glue. Per the standing mechanization decision (`CLAUDE.md`'s audited
non-goals: "`ardd-tracker`'s remaining `gh` glue... error handling needs
judgment"), this stays skill-prose calling `gh` directly, not a new
`scripts/sync-*.sh` script — consistent with how push/pull already work
today. Milestone creation is idempotent (ignore "already exists," the
same pattern the Prerequisites step already uses for labels).

## Complexity Tracking

| Deviation | Justification |
|---|---|
| `epic` has no enum / no epic-file lifecycle | Feature explicitly scopes this out until flat-slug grouping proves insufficient (YAGNI — Principle VI); a second register-like construct is real complexity this plan deliberately doesn't introduce without evidence. |
| `/ardd-tracker` milestone glue stays skill-prose, not a script | Matches the existing, audited decision that `ardd-tracker`'s `gh` glue is judgment-heavy and not mechanizable the way pure file-state checks are (CLAUDE.md mechanization non-goals). |

## Phase Breakdown

### Phase 1: schema validation [feature: epics-grouping-in-feature-regi]

- T001 (test-first) Add an `epic` case to `tests/fixtures/bad-project/.project/features/`
  (a new or amended fixture file with `epic:` present but empty) and a
  corresponding assertion in `scripts/test-lint-project.sh` expecting
  `lint-project.sh` to report it. Confirm the assertion fails against
  the current `lint-project.sh` (no `epic` handling exists yet).
- T002 Add `epic` emptiness validation to `scripts/lint-project.sh`'s
  feature-register loop — mirroring the existing `rfield` free-text
  emptiness pattern used for `diagram_type`/`render_target`/etc., not
  the `gh_issue` numeric check (an `epic` slug is arbitrary text, not a
  number). Add a non-empty `epic:` value to
  `tests/fixtures/good-project/.project/features/widget-export.md` (or
  another good-project feature file) to prove the positive case stays
  clean. Confirm T001's assertion now passes and
  `./scripts/test-lint-project.sh` is green end to end.

### Phase 2: `feature-list.sh` epic column + filter [feature: epics-grouping-in-feature-regi]

- T003 (test-first) Extend `scripts/test-feature-list.sh` with
  assertions for: the fifth output column carries `epic` (empty string
  when unset, matching the tab-separated shape the other optional
  fields already use); `--epic <slug>` filters to only features with
  that exact `epic` value, composable with `--status`/`--all` (e.g.
  `--all --epic foo` widens status but still filters by epic). Confirm
  these fail against the current two-flag `feature-list.sh`.
- T004 Extend `scripts/feature-list.sh`: parse `epic` from frontmatter
  the same way `slug`/`status`/`logged` are parsed, append it as a
  fifth tab-separated column, and add the `--epic <slug>` filter.
  Confirm T003 now passes.

### Phase 3: `/ardd-status` epic breakdown [feature: epics-grouping-in-feature-regi]

- T005 Add an optional "by epic" line/section to
  `skills/ardd-status/SKILL.md`'s step 1 (feature register enumeration)
  and step 6/report template's Feature Backlog section: when any
  feature carries a non-empty `epic`, group backlogged/planned/tasked
  counts by epic value and list them (omit the section entirely when no
  feature has `epic` set — same "omit if none" convention already used
  throughout this skill). No test task — prose-only skill-file change
  (constitution Principle V's documentation-only exception).

### Phase 4: `/ardd-tracker` milestone mapping [feature: epics-grouping-in-feature-regi]

- T006 Add a milestone-assignment sub-step to `skills/ardd-tracker/SKILL.md`'s
  push phase: when a feature being pushed has `epic` set, ensure a
  GitHub milestone named for that epic slug exists (create via `gh api
  repos/{owner}/{repo}/milestones -f title=<epic>`, ignoring
  "already exists" errors — the same idempotent pattern the
  Prerequisites step already uses for labels) and assign the issue to
  it (`gh issue edit <n> --milestone <epic>`). Document that this is
  one-directional (register → tracker, matching the existing
  name/slug/description ownership rule) — pull never reads a milestone
  back into `epic`. No test task — prose-only change to `gh`-calling
  skill prose, consistent with `/ardd-tracker`'s existing untested `gh`
  glue (constitution Principle V's documentation-only exception, and
  the standing mechanization non-goal noted in Technical Approach).

## Open Questions

- Should an issue's milestone be *cleared* if a feature's `epic` field
  is later removed? Left unresolved — the minimal version only handles
  the push-forward case; a removal-sync would need `/ardd-tracker` to
  distinguish "epic never set" from "epic removed," which the register
  alone can't do without a diff against prior state. Revisit if this
  turns out to matter in practice.
- `feature-list.sh --epic <slug>` does exact-match filtering only — no
  typo-tolerance or epic-name validation against existing values. Left
  as-is (YAGNI) unless real usage shows epic slugs drift or typo.
