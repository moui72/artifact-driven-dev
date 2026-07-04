---
status: approved        # draft -> approved -> superseded
branch: design-review-robustness
created: 2026-07-03
features: []
---

# Plan: Design-review robustness hardening

## Goal

Harden three structural gaps surfaced by an external design review of this
repo — `/ardd-sync`'s untested complexity, no `.project/` concurrency guard,
and unprotected multi-step bookkeeping — while resolving whether
artifact-schema versioning needs new machinery at all.

## Scope

**In scope:**
- Extracting `/ardd-sync`'s idempotency-critical decisions into small,
  testable scripts, following the pattern already established by
  `branch-info.sh` / `sibling-tasks-complete.sh`.
- A lightweight, warn-only concurrency marker for the skills that perform
  multi-file bookkeeping (`/ardd-plan`, `/ardd-tasks`, `/ardd-implement`,
  `/ardd-converge`).
- A deterministic `lint-project.sh` check for the one class of
  bookkeeping-interruption drift that's structurally detectable: a plan at
  `approved`/`superseded` whose targeted `features:` slugs are still stuck
  at `backlogged` in `features.md`.
- A small constitution correction discovered while checking compliance for
  this plan (see Open Questions/Complexity Tracking note below).

**Out of scope:**
- Full artifact-schema migration machinery across `install.sh` runs. Per
  Principle VI (Simplicity/YAGNI), this plan does not commit to a specific
  mechanism without a concrete case forcing the design — see Open Questions.
- Real locking/mutual exclusion. The concurrency marker is advisory
  (warn-only), not enforced — per the feedback item itself ("not full
  locking, just cheap insurance") and Principle VI.

## Technical Approach

Per Principle II (Deterministic Checks Over Prose), each of the three
in-scope gaps gets pushed into a script or a lint check wherever the
invariant is a pure function of file state — not left as prose an agent
"remembers" to follow. Where a gap turns out to need judgment (a decision
reversal, a design tradeoff), it stays prose and gets surfaced as an Open
Question instead of being force-fit into a script.

### `/ardd-sync` test coverage
`/ardd-sync`'s complexity isn't in *shelling out to `gh`* (that can't be
unit-tested without real network/API state) — it's in the **decisions** it
makes from state it already has in hand: does this slug already have a
matching issue (marker search), does the label need to change given
current status vs. current label, does the tracker's state diverge from
`features.md`. Those three decisions are pure functions of inputs the
skill already parses, so they can be extracted into a script that takes
plain arguments and prints a decision — testable exactly like
`lint-project.sh`'s enum checks — without needing to mock `gh` itself.

### Concurrency marker
A single shared script, `project-lock.sh`, offering two operations:
`check <label>` (warn if `.project/.lock` exists, is newer than 5 minutes,
and was written by a *different* label) and `touch <label>` (write
`.project/.lock` with the current timestamp and label). Skills call `check`
before starting a multi-file write sequence and `touch` at each write point;
the marker is advisory only — a stale or racing lock never blocks a run,
it only surfaces a warning for the user to judge.

### Bookkeeping-consistency lint check
Rather than building rollback/transaction machinery for `/ardd-tasks`'s
approve-then-flip sequence, add one more structural check to
`lint-project.sh` (which already validates cross-references — see its
existing `plan:`/`features:` checks): a plan at `status: approved` or
`status: superseded` with a non-empty `features:` list, where any listed
slug is still `Status: backlogged` in `features.md`, is flagged. This is
the exact signature an interrupted approval sequence would leave behind,
and it's cheap to check deterministically — consistent with why
`status: generating` staleness was checked the same way instead of adding
runtime rollback.

## Phase Breakdown

### Phase 1 — Constitution correction (prerequisite, small)
- [artifacts: constitution] Update the Pre-commit Enforcement bullet in
  `constitution.md`'s Quality Standards to include
  `scripts/test-sibling-tasks-complete.sh`, which `hooks/pre-commit` already
  runs but the constitution's enumerated list doesn't yet mention — drift
  discovered during this plan's constitution-compliance check (step 6).

### Phase 2 — `/ardd-sync` testable decision scripts
[feedback: design-review-robustness — UX item 1]
- Extract slug-marker matching (does a search result's marker match this
  slug) into `scripts/sync-slug-match.sh`.
- Extract the label-swap decision (given current `Status` and current
  `ardd:*` label(s), what label change — if any — is needed) into
  `scripts/sync-label-decision.sh`.
- Extract divergence detection (given `features.md` `Status` and tracker
  issue state open/closed, is this diverged, and what's the message) into
  `scripts/sync-divergence.sh`.
- [artifacts: none] Write `scripts/test-sync-scripts.sh` covering all three
  with known-good/bad fixtures, added in the same commit as the scripts
  (Principle V).
- Update `/ardd-sync/SKILL.md` prose to shell out to these three scripts at
  the decision points it currently makes inline.
- Update `install.sh` to copy the three new scripts into
  `ardd-scripts/`, and add the new test script to `hooks/pre-commit`.

### Phase 3 — Concurrency marker
[feedback: design-review-robustness — UX item 2]
- Write `scripts/project-lock.sh` (`check`/`touch` as described above) plus
  `scripts/test-project-lock.sh`.
- Update `install.sh` to install it.
- Wire `check`/`touch` calls into `/ardd-plan` (around step 3d's artifact
  writes and step 10's approval bookkeeping), `/ardd-tasks` (around step 3's
  plan-approval flip and step 6's tasks-file write), `/ardd-implement` and
  `/ardd-converge` (around their feature-flip-on-completion step) — the
  four skills the feedback item names as racing candidates.
- Add `.project/.lock` to the gitignore guidance `install.sh` already prints
  (it's transient local state, not project history).

### Phase 4 — Bookkeeping-consistency lint check
[feedback: design-review-robustness — Reconsidered item 1]
- Add the approved/superseded-plan-vs-backlogged-feature check described
  above to `scripts/lint-project.sh`.
- Extend `tests/fixtures/bad-project` (and `good-project`) to exercise it,
  same pattern as the existing cross-reference checks.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| Concurrency marker is warn-only, not enforced | Feedback item explicitly scoped it as "cheap insurance," not real locking; building mutual exclusion over a flat-file store is a materially bigger project than the risk (solo-developer-oriented tool) currently justifies — Principle VI. |
| No new script for the bookkeeping-rollback gap (Phase 4 uses a lint check instead) | A structural after-the-fact check satisfies Principle II without inventing transactional writes across multiple files, which nothing in this project's actual usage has yet demanded. |

## Open Questions

- **Artifact-schema versioning across `install.sh` runs** (Reconsidered item
  2) is deliberately **not** turned into a task here. Two directions are
  possible and they carry different costs:
  1. Full migration machinery, parallel to `migrations/*.sh` for skill
     files, that rewrites existing target-project artifact *content* when a
     template's structure changes.
  2. A much lighter warning: `install.sh` notes (once, non-blocking) that a
     target project's artifact was written against an older template
     structure than the one just installed, and leaves reconciliation to
     `/ardd-refine`.
  This plan doesn't pick one — it needs a decision on whether (1) is ever
  actually going to happen (no template has changed structure yet, so
  there's no concrete case to design against per Principle VI) before
  committing engineering effort. Recommend deferring until a real template
  change happens, or logging it as a backlogged feature via `/ardd-feature`
  if the user wants to commit to direction (2) now.

## Production Annotation Summary

None — nothing in this plan introduces a production shortcut.
