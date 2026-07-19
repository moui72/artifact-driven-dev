---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: rejected-feature-status
created: 2026-07-19
features: [rejected-feature-status]
surfaced-defects: []
---

# Plan: rejected-feature-status

## Goal

Add two sibling terminal states to the feature register's status
enum — `rejected` (a `backlogged`/`planned` idea decided against and
never built) and `subsumed` (an entry whose scope ended up shipping
under a *different* feature/plan entry) — wired through the
schema-of-record, the state mutation script, and every skill/doc
surface that documents the status lifecycle.

## Scope

**In scope:**
- `scripts/lint-project.sh`'s `FEATURE_STATUS_ENUM` (the schema-of-record
  per this repo's own convention) — add both `rejected` and `subsumed`.
- `scripts/ardd-state.sh`'s `cmd_feature_flip` — add the legal
  transitions `backlogged -> rejected`, `planned -> rejected`,
  `backlogged -> subsumed`, `planned -> subsumed`, and `tasked ->
  subsumed` (absorption can be noticed late — after tasking, before
  implementation — unlike rejection, which by definition only applies
  before work starts). Both `rejected` and `subsumed` are terminal (no
  arc out, mirroring `retired`). Update the subcommand's usage text.
- `.project/artifacts/constitution.md`'s "Feature register format"
  standing decision — already updated in this session (version bump
  1.11.1 → 1.12.0, Sync Impact Report added, covering both statuses) as
  this plan's step-3 artifact design work.
- `docs/reference/project-files.md`'s status-arc line for the feature
  register.
- `skills/ardd-status/SKILL.md`'s Feature Backlog report — add both
  `rejected` and `subsumed` (like `retired`) to the count line, omitted
  when zero, and confirm the by-epic breakdown's existing exclusion of
  non-actionable statuses (`implemented`/`retired`) also covers both new
  terminal states.
- `skills/ardd-plan/SKILL.md`'s step 3a (feature-status gate: "if its
  status isn't backlogged... tell the user it's already past the
  backlog stage") — extend the guidance to name both `rejected` and
  `subsumed` explicitly as statuses this skill won't design forward
  from.
- Regression tests: `scripts/test-ardd-state.sh` (new legal/illegal
  transition cases for both new statuses), `scripts/test-lint-project.sh`
  (enum acceptance for both).

**Out of scope:**
- Retroactively reclassifying any existing register entry — this plan
  only adds the capability; using it on real entries is a separate,
  later decision.
- Any change to `feature-list.sh`'s default filter (`backlogged`) or its
  `--status` argument handling — it already accepts arbitrary status
  values generically; no code change needed there for new enum members.
- Any further terminal-state ideas beyond these two — this plan's scope
  was set by a design review that considered a `wontdo`-style collapse
  and explicitly rejected it (the two cases answer a different
  load-bearing question — "does this capability exist in the shipped
  system?" — and collapsing them would push that fact into free-text
  notes).

## Technical Approach

`rejected` and `subsumed` are added as siblings to `retired` — three
distinct terminal states, never a hierarchy or a combined status. The
distinguishing question for a future reader is "does this capability
exist in the shipped system?": `retired` = yes, then no (shipped, then
removed); `rejected` = no, never; `subsumed` = yes, credited to a
different entry. This granularity mirrors the repo's own existing norm
that ship-state distinctions are status-grade (`retired` is its own
status, not a note on `implemented`).

`subsumed` is deliberately not named `superseded`, despite this repo
already having a `superseded` status — for **plans** (a newer plan
replacing an older *unapproved* one for the *same* feature: a
same-document, one-for-one replacement). The feature-level case here is
a different shape: an entry's *scope* gets absorbed into a *different*,
already-ahead feature's work — not a document replacement. Reusing the
word would make lint messages and docs ambiguous across the two enums
for two genuinely different semantics.

The legal-transition table in `cmd_feature_flip` gains five new edges:
`backlogged -> rejected`, `planned -> rejected`, `backlogged ->
subsumed`, `planned -> subsumed`, `tasked -> subsumed`. `rejected` never
appears as a `from` state (terminal); `subsumed` never appears as a
`from` state either. `subsumed`'s extra `tasked ->` edge (which
`rejected` doesn't get) reflects that absorption is realistically
noticed at any point before the entry's own implementation lands, while
rejection is a pre-work decision by definition — the plan's own step 5
tasks include a prose note reinforcing this asymmetry so a future editor
doesn't "fix" it into looking symmetric with `rejected`.

## Phase Breakdown

### Phase 1: Schema and state mutation
Depends on: —
- T001: [artifacts: constitution] Add `rejected` and `subsumed` to
  `scripts/lint-project.sh`'s `FEATURE_STATUS_ENUM` (currently
  `"backlogged planned tasked implemented retired"`), with inline
  comments mirroring the existing `retired` comment's style — one for
  each new value, explicit about what distinguishes it from both
  `retired` and the other new value.
- T002: Add the five new legal transitions to `scripts/ardd-state.sh`'s
  `cmd_feature_flip` (`backlogged -> rejected`, `planned -> rejected`,
  `backlogged -> subsumed`, `planned -> subsumed`, `tasked ->
  subsumed`), update the `case "$to"` validation list to include both,
  and update the subcommand's usage-text line (currently
  `backlogged->planned->tasked->implemented->retired`) to show both new
  branches clearly, including a one-line note on why `subsumed` alone
  reaches from `tasked` (absorption noticed late) while `rejected` does
  not (pre-work decision only).
- T003: Add regression cases to `scripts/test-ardd-state.sh`: legal
  `backlogged -> rejected`, `planned -> rejected`, `backlogged ->
  subsumed`, `planned -> subsumed`, and `tasked -> subsumed` transitions
  all succeed; both `rejected` and `subsumed` refuse every outbound
  transition (terminal, same pattern as the existing `retired` terminal
  test); an illegal transition into either from `implemented` is
  refused with the existing clear error message; an illegal `tasked ->
  rejected` (not one of the five new edges) is also refused, confirming
  the asymmetry holds.
- T004 [parallel] Add fixture cases to `scripts/test-lint-project.sh`
  confirming feature files with `status: rejected` and `status:
  subsumed` both pass the enum check cleanly.

### Phase 2: Skill prose and docs
Depends on: Phase 1
- T005 [parallel] Update `docs/reference/project-files.md`'s feature
  register status-arc line (currently `backlogged` → `planned` →
  `tasked` → `implemented` (or → `retired`)) to also show the
  `backlogged`/`planned` → `rejected` branch and the
  `backlogged`/`planned`/`tasked` → `subsumed` branch.
- T006 [parallel] Update `skills/ardd-status/SKILL.md`'s Feature Backlog
  report template: add `rejected` and `subsumed` to the count line
  alongside `implemented`/`retired` (omitted when zero each, same
  convention already used for `retired` in practice), and confirm/state
  explicitly that the by-epic breakdown's exclusion of non-actionable
  statuses covers both new terminal states too (grouped alongside
  `implemented`/`retired` in the "omit from grouping" list).
- T007 [parallel] Update `skills/ardd-plan/SKILL.md`'s step 3a guidance
  (currently: "If its status isn't `backlogged` (e.g. already
  `planned`/`tasked`/`implemented`), tell the user it's already past the
  backlog stage and stop") to also name `rejected` and `subsumed` as
  statuses this skill refuses to design forward from — a rejected idea
  needs a fresh backlog entry if reconsidered, and a subsumed entry's
  scope should be planned under whichever feature actually absorbed it,
  never revived under its own slug.

### Phase 3: Manual verification
Depends on: Phase 2
- T008 Manually exercise the full arc against two throwaway fixture
  features: (a) create one at `backlogged`, flip it to `rejected` via
  `ardd-state.sh feature-flip <slug> rejected`, confirm
  `lint-project.sh` accepts it, confirm `/ardd-plan <that-slug>` now
  refuses per T007's updated guidance, and confirm attempting any
  further flip out of `rejected` is refused; (b) create a second at
  `tasked`, flip it to `subsumed`, confirming the late-stage transition
  specifically (the one `rejected` doesn't get), and confirm the same
  terminal-refusal behavior. Also verify a `planned -> rejected` flip
  succeeds for completeness. Clean up both fixtures afterward.

## Complexity Tracking

No deviations requiring justification — both new statuses closely
mirror the existing `retired` terminal-state pattern throughout (schema,
state script, skill prose, docs), applied to two additional, clearly-
distinguished terminal outcomes; the asymmetric `tasked -> subsumed`
edge is the one deliberate wrinkle, and it's justified inline in the
Technical Approach and called out explicitly in T002/T003 so it reads
as intentional, not an oversight.

## Open Questions

None — the design review that expanded this plan from `rejected` alone
to `rejected` + `subsumed` already resolved the naming question
(`subsumed`, not `superseded`) and the collapse question (kept
separate, not merged into a `wontdo`-style single status).
