---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: plan-time-defrag-slate-analysi
created: 2026-07-17
features: [plan-time-defrag-slate-analysi]
surfaced-defects: []
---

# Plan: plan-time-defrag-slate-analysi (codified `/ardd-plan --slate` mode)

## Goal

Give `/ardd-plan` a `--slate` mode that computes an advisory, ephemeral
"defrag" grouping over the open feature backlog — bundles (sequential,
plan-together) and parallel sets (safe to fan out) — grounded in real
codebase footprint and dependency evidence, then hands off to the
existing multi-slug `/ardd-plan <slug> [<slug> ...]` invocation for
whichever grouping the user picks.

## Scope

**In scope:**
- `skills/ardd-plan/SKILL.md`: a new `--slate` usage form, entered before
  step 1's normal flow (mirroring how `--from` and feedback/defect scopes
  are already distinguished by argument shape). Runs an entirely separate
  procedure (detailed in Technical Approach) that ends in a
  recommendation — never a plan write, never a register write. It is a
  pure read-and-report mode, like `--list`, not a plan-generating one.
- The N=0/N=1 degenerate branch (research prototype 1, sync-tab-scroll):
  report "nothing to defrag" and point at `/ardd-plan <the-one-item>`
  rather than fabricate a slate.
- The N≥2 cross-item procedure (research prototype 2, atelier): for each
  `backlogged` item, grade a footprint confidence (`high`/`medium`/`low`)
  grounded in actual greps of the codebase (never assumed from the
  register's prose alone); compute two separate relations between every
  pair of items — file-set overlap and ordering dependency — and use both
  to classify each item into exactly one of: a **bundle** (sequential,
  shares files or is ordered — recommend planning with a single
  multi-slug `/ardd-plan` call, in the stated order), a **parallel set**
  (pairwise file-disjoint, no ordering dependency, confidence high enough
  to trust — recommend separate `/ardd-plan <slug>` calls, one per item,
  safe to fan out to worktrees), or **solo-deferred** (low/speculative
  confidence, or gated on a non-code decision — never placed in a
  parallel set; recommend planning alone, on its own timeline).
- Presenting the computed grouping to the user (plain text, or — if
  `next_step_prompt: true` — an `AskUserQuestion` offering to run the
  top-recommended `/ardd-plan` invocation now, same mechanism `/ardd-plan`
  and `/ardd-status` already use for their own next-step prompts).
- Documenting the explicit non-goal: past roughly a dozen items, this
  MVP does not attempt an exhaustive N² pairwise comparison or a
  pre-filter data structure (research finding 5/6 from the atelier
  pass) — see Open Questions.
- Reference doc: `docs/reference/skills/ardd-plan.md` (the `--slate` form).

**Out of scope:**
- No new deterministic script. Footprint estimation requires reading each
  feature's prose description and judging which real files it would
  touch — this is not a pure function of file state (Principle II only
  requires scripting what's *actually mechanizable*; grading a feature
  description against a codebase is agent judgment, the same category as
  `/ardd-status`'s existing cross-artifact prose checks). The one
  genuinely mechanical sub-step — enumerating `backlogged` items — is
  already served by the existing `scripts/feature-list.sh --status
  backlogged` from the `list-mode-for-plan-and-impleme` feature; this
  plan adds no new script.
- No register field, no persisted output. The slate is recomputed fresh
  on every `--slate` invocation and never written anywhere — the feature
  description's own framing ("computed/mechanical/ephemeral, distinct
  from the declared/semantic/durable `epic` field") rules out storing it.
- No change to `/ardd-plan`'s existing multi-slug behavior (step 3
  already loops over however many feature slugs are passed) — slate mode
  is purely a recommendation layer that ends by naming which slugs to
  pass to that existing, unmodified mechanism.
- No cross-item N² pre-filter or graph data structure (see Open
  Questions) — both research passes together only ever exercised N=1 and
  N=12; a scalable pre-filter is explicitly deferred, not designed here.
- No constitution changes — no new principle, data-model concept, or
  production shortcut, and this repo has no `datamodel.md`/
  `infrastructure.md`/`ui.md` to touch (same conclusion as the
  `list-mode-for-plan-and-impleme` plan reached for a structurally
  similar feature).

## Technical Approach

`/ardd-plan --slate` is a new top-level mode, checked for at the very
start of the skill (same place `--from`, a `feedback-*.md` argument, and
a `defect:`/`defects` argument are already distinguished by shape) —
entering it skips steps 1–15 entirely, the same way `--from` skips
straight to step 11. Its own steps:

1. **Enumerate the backlog.** Run `scripts/feature-list.sh --status
   backlogged` (existing script, unmodified) — this is the register-
   direct-read discipline both research passes validated as
   unconditional (never trust `STATUS.md`'s assembled counts, even when,
   as in the atelier run, they happen to already be correct).

2. **N=0/N=1 branch.** Zero items: report "nothing to defrag" and stop.
   One item: report "nothing to defrag — single open item" and recommend
   `/ardd-plan <that slug>` directly; stop. (Prototype 1's headline
   finding: a slate is a relation *between* items, and with N≤1 the
   relation set is empty by construction — don't manufacture one.)

3. **Per-item footprint grading (N≥2).** For each backlogged item, read
   its register entry (description + `Why:` line) and ground a footprint
   estimate in real greps/reads of the codebase — never free-associated
   from the prose alone. Grade confidence `high` (concrete existing seam
   found), `medium` (seam exists but scope has a real unknown, e.g. a
   non-code gate), or `low` (greenfield / no seam exists / the item's own
   artifact language flags it as speculative or deferred). This mirrors
   both research passes' method exactly — e.g. atelier's
   `wasm-hunspell-backend` (high: a 37-line, already-abstracted
   interface) versus `llm-assistance` (low: infrastructure.md itself
   calls it a later phase with an open question).

4. **Pairwise relations (N≥2), two axes, computed separately.** For
   every pair of items, determine (a) **file-set overlap** — do their
   footprints share any file, and (b) **dependency** — does one need to
   land before the other regardless of file overlap (an interface one
   item would consume that the other edits, a shared code path one
   transforms and the other reads). Both research passes independently
   converged on this as the load-bearing lesson: overlap without
   dependency is a safe parallel pair even when topically related
   (atelier's `project-scoped-personal-dictionary` sharing the
   "spellcheck" label but not `speller.ts`); dependency without full file
   overlap still forces sequencing (atelier's `smart-typography-
   substitution` → `{docx-export, epub-pdf-export}`, ordered through a
   shared render/export *path* rather than a shared file set).

5. **Classify and present.** Using confidence (step 3) and the two
   relations (step 4):
   - **Bundle**: items connected by a dependency edge, or sharing files
     with no safe reordering — sequenced, recommended as one multi-slug
     `/ardd-plan <slug1> <slug2> ...` call in dependency order.
   - **Parallel set**: items that are pairwise file-disjoint, have no
     dependency edge between them, and are *not* `low` confidence —
     recommended as separate `/ardd-plan <slug>` calls, safe to fan out
     to worktrees. A `low`-confidence item is never placed here even if
     no overlap was found (research lesson 2: a wrong "disjoint" call is
     the expensive failure — it green-lights a fan-out that then merge-
     conflicts).
   - **Solo-deferred**: `low`/speculative confidence, or explicitly
     gated on a non-code decision per the artifact — recommended as its
     own single-slug `/ardd-plan <slug>` on its own timeline, no bundling
     or fan-out suggested.

   Present the full grouping (which items in each bucket, and why —
   the specific shared file or dependency for bundles) as the report,
   then the recommended next command(s). If `next_step_prompt: true`,
   offer the single top-priority recommendation via `AskUserQuestion`
   (same mechanism already used for `/ardd-plan`'s and `/ardd-status`'s
   own next-step prompts) — never more than one such prompt per turn end,
   consistent with the existing rule.

This plan's own two backlog items (this feature and
`codex-second-harness-support`) are themselves an N=2 case once this
feature ships and is `implemented`/removed from the backlog it's
analyzing — not exercised as part of implementation, since the tasks
here build the mode, not run it.

## Phase Breakdown

### Phase 1: `--slate` mode skeleton, N=0/N=1 branch
- Add `--slate` to `skills/ardd-plan/SKILL.md`'s argument-shape dispatch
  (alongside `--from`, feedback-scope, defect-scope), routing straight
  past steps 1–15 into the new procedure.
- Implement steps 1–2 of the Technical Approach: enumerate via
  `feature-list.sh --status backlogged`, and the N=0/N=1 degenerate
  branch (report + stop / recommend the single slug + stop).
- Demonstrable increment: `/ardd-plan --slate` against a 0- or 1-item
  backlog correctly reports "nothing to defrag" without fabricating a
  slate — directly testable against this repo's *own* current backlog
  state at each of those N values (or a scratch fixture project).

### Phase 2: N≥2 footprint grading and pairwise relations (depends on Phase 1)
- Implement steps 3–4: per-item confidence grading (worked examples in
  skill prose, per Open Questions) and the two-axis pairwise
  relation-finding (file overlap, dependency) over every pair of
  backlogged items.
- Demonstrable increment: run manually against a fixture backlog with a
  known bundle pair and a known parallel pair (a scratch `.project/
  features/` fixture, not a real project) and confirm the grading and
  relations match the expected classification.

### Phase 3: Classification, presentation, and next-step handoff (depends on Phase 2)
- Implement step 5: bucket items into bundle / parallel set /
  solo-deferred, render the report (grouping + rationale + recommended
  `/ardd-plan` invocation(s)), and wire the `next_step_prompt: true`
  `AskUserQuestion` offer for the top recommendation.
- Demonstrable increment: a full `/ardd-plan --slate` run against the
  same fixture from Phase 2 produces the expected bundle/parallel-
  set/solo-deferred report and a correct top-recommendation prompt.

### Phase 4: Docs (depends on Phase 3)
- Update `docs/reference/skills/ardd-plan.md` with the `--slate` usage
  form (mirroring how `--list` and `--from` are already documented
  there).

## Open Questions

- **Scalability past ~N=12.** The atelier pass explicitly flagged that
  hand-computing all pairwise overlap/dependency comparisons doesn't
  scale much past a dozen items (66 pairs at N=12 was already effortful
  by hand) and suggested either a cheap pre-filter (shared artifact
  section, shared top-level directory) or accepting that exhaustive
  pairwise grounding needs tooling support beyond this MVP. This plan
  deliberately ships the N≤12-ish manual-judgment version and defers a
  pre-filter/graph-structure redesign to a future feature if the backlog
  ever grows that large in practice.
- **Confidence-grading rubric consistency.** Both research passes used
  judgment calls that a purely code-grep-based grader wouldn't replicate
  (e.g. grading a licensing gate as `medium` even though the code seam
  itself is concrete). This plan keeps grading as agent judgment,
  documented via worked examples in the skill prose rather than a rigid
  rubric — worth revisiting if slate output turns out inconsistent
  across runs.
- Should `--slate` accept an optional `--epic <name>` filter (scoping the
  backlog enumeration the same way `feature-list.sh --epic` already
  supports for other views)? Left out of this plan's scope — no reported
  need yet, and the current backlog is small enough that scoping doesn't
  matter today.
