---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: built-with-ardd-badge
created: 2026-07-06
features: [built-with-ardd-badge]
surfaced-defects: []
---

# Plan: badge feature, downstream-upgrade fixes, docs three-tier reframe

## Goal

Ship the opt-in "built with ARDD" badge, fix the two gaps the first
downstream upgrade exposed (dangling register tags; the artifacts-none
convention), and land the docs review — three-tier core-loop reframe,
continuing.md guide, staleness sweep.

## Scope

**In:** the `built-with-ardd-badge` feature (no artifact changes needed —
pure install.sh behavior); all items of
`feedback-migration-dangling-tags-b959.md` (fix chosen 2026-07-06:
migration rewrites tags), `feedback-artifacts-none-tag-9fc6.md`
(recommended (a)+(b): soften wording + lint special-case), and
`feedback-docs-review-core-loop-5ef3.md` (F009 three-tier reversal
user-confirmed 2026-07-06).

**Out:** smoke-harness promotion (blocked on the API key; tracked in
DEFECTS.md as already-surfaced 970d935b); any tracker/sync work.

## Technical Approach

Four independent phases — the badge (install.sh + templates), the
migration fix (new 0004, since 0003 is already recorded as applied in
downstream `.ardd-applied` files and migrations run once), the
artifacts-none convention (skill prose + lint), and the docs batch
(generator + prose). Scripts/lint changes are test-first per Principle V;
doc tasks are the stated exception. The docs phase's generator-ordering
fix (F005) must land before the reframe regeneration (F009) so the
three-tier tables come out in workflow order.

## Phase Breakdown

### Phase 1 — built-with-ardd-badge (feature)

- T-A Design the badge snippet: static shields.io markdown
  (`[![built with ARDD](https://img.shields.io/badge/built%20with-ARDD-blue)](https://github.com/moui72/artifact-driven-dev)`),
  wrapped in HTML marker comments (`<!-- ardd-badge-start/end -->`) so
  presence is detectable and reinjection idempotent.
- T-B install.sh offers injection, strictly opt-in: only when the
  target README exists and lacks the marker; prints the snippet and asks
  (in non-interactive runs: never injects, prints the suggestion
  instead — mirror the gitignore-suggestion posture; install.sh never
  edits target content unasked). Decline-memory mechanism decided
  in-task (candidates: `.ardd-applied`-style marker line vs. offer-only-
  when-absent each run) — prefer the simplest that avoids nagging.
  Fixture test extension (install test asserts: no README edit without
  consent, idempotent reinjection, marker detection) + CI, same commit.

### Phase 2 — migration 0004: dangling register tags [feedback b959 F001]

- T-C `migrations/0004-retag-features-refs.sh`: rewrite bracket-tags
  naming the removed `features` artifact in `.project/tasks/*.md` and
  `.project/feedback/*.md` — drop `features` from multi-artifact tags,
  remove the whole tag when it named only `features`. Idempotent;
  recorded in `.ardd-applied`. Fixture test first (pre-migration project
  carrying both tag shapes, red), CI job. Downstream repos get fixed on
  their next install.sh run.

### Phase 3 — artifacts-none convention [feedback 9fc6 F001]

- T-D Soften ardd-tasks step 3: "declare the artifacts the task needs,
  omitting the tag entirely when none apply — never write a placeholder
  name." Doc-only skill edit.
- T-E lint-project.sh special-cases a literal `none`/`n/a` inside a
  bracket-tag with a pointed message ("omit the tag instead of naming a
  placeholder") replacing the generic missing-file error. Bad fixture
  first (red), findings count bumped, CI already covers.

### Phase 4 — docs review batch [feedback 5ef3]

- T-F (F005) gen-skill-docs.sh emits tables in explicit workflow order
  (ordered lists per tier in the generator, or an `order:` frontmatter
  field — decide in-task; ordered-list-in-generator is simpler and the
  order is editorial anyway). Fixture test asserts order (red first).
  Must precede T-G's regeneration.
- T-G (F009, user-confirmed reversal) Three-tier reframe: re-tier
  frontmatter (`setup`: bootstrap, codify, featurize; `core`: feature,
  feedback, refine, plan, tasks, implement; `extension`: the rest),
  teach the generator + its test the third tier, regenerate README
  tables + templates/WORKFLOW.md, and align USAGE's numbered steps to
  the delivery loop (research moves to Extensions, matching README).
- T-H (F008) Write guides/continuing.md — "Working an established
  project": log ideas immediately (`/ardd-feature`), capture
  observations (`/ardd-feedback`), targeted plans by slug,
  feedback-scoped plans, when to `/ardd-converge`, a
  `/ardd-verify`//`/ardd-critique` cadence. Fold in and remove both
  existing guides' "Adding features after..." tail sections (each gets
  a pointer); add a `/ardd-feedback` step/pointer to USAGE's workflow.
- T-I (F001) Rewrite USAGE step 1 to match ardd-bootstrap's actual
  behavior (constitution created by bootstrap, suggestion catalog,
  workflow_mode, judgment-driven artifact set).
- T-J (F002, F003, F004) Staleness sweep: greenfield.md research/
  approval claims; the 7 "ArDD" occurrences; per-feature-register and
  "four artifacts" leftovers across guides/existing-project.md, README,
  USAGE, CLAUDE.md (including CLAUDE.md's lint-enum description).
- T-K (F006, F007) README structure: move Future directions + Credits
  to the bottom; move "Recovering from a rewritten main" to
  docs/decisions/ with a one-line pointer.

## Complexity Tracking

| Deviation | Justification (Principle VI) |
|---|---|
| (none) | Badge is a static snippet + one install.sh prompt; migration 0004 follows the established migration pattern |

## Open Questions

- [OPEN: T-B decline-memory mechanism — decided at implementation;
  prefer simplest non-nagging option]
- [OPEN: T-F ordering mechanism — ordered list in generator vs. order:
  frontmatter; decide in-task]

## Production Annotation Summary

- None anticipated. (The smoke-harness continue-on-error annotation
  predates and outlives this plan.)
