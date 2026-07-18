---
plan: plan-constitution-trim-review-relev-2026-07-18-8c82.md
generated: 2026-07-18
status: completed
---

# Tasks

## Phase 1: Spec and implement `--review` mode in `skills/ardd-refine/SKILL.md`
- [x] T001 [artifacts: constitution] Add a `--review` usage line and mode
  description to `skills/ardd-refine/SKILL.md`'s top usage block, alongside
  the existing "No-argument mode" section — new heading (e.g. "Review mode
  (`--review`)"), same doc location, parallel structure/tone to the
  existing no-argument mode section. State plainly that `--review` only
  applies to `constitution` (`/ardd-refine constitution --review`) and is
  rejected (or ignored with a note) for any other artifact name.
- [x] T002 [artifacts: constitution] Write the `--review` step sequence in
  `skills/ardd-refine/SKILL.md`: (1) load `constitution.md` (reuse step
  1's load), (2) enumerate every principle under whatever heading
  structure the project's constitution actually declares (never assume a
  fixed principle set/count — mirror `/ardd-status`'s "act only on
  declared principles" discipline), (3) for each principle, ground a
  keep/trim-candidate judgment in the current project's
  `.project/artifacts/*.md` and a light codebase grep where useful — not
  from the principle's own prose in isolation — with a one-line rationale
  for every trim-candidate, (4) if zero are flagged, report that and stop
  with no write, (5) present the full trim-candidate list with rationale
  in one batched message and ask for confirmation via multi-select
  accept/decline — never one-at-a-time, never all-or-nothing, (6) apply
  confirmed removals then invoke the skill's existing constitution
  special-case handling (current step 4: version bump, Sync Impact Report
  entry naming what was removed and why, `last_updated` stamp), (7) report
  what was trimmed (if anything), the new version, and recommend
  `/ardd-status`. Declined candidates get no persistent suppression
  bookkeeping — a later `--review` run re-derives judgment fresh.
- [x] T003 [artifacts: constitution] In the same `--review` section, add an
  explicit cross-reference note that its batched-confirmation step follows
  the same shape as `/ardd-plan` step 3c (list every candidate with
  rationale, single confirmation step, never applied one at a time) — so
  the two batched-confirm UIs in this skill family read as one consistent
  pattern to a future editor.

## Phase 2: Docs
- [x] T004 Update `docs/reference/skills/ardd-refine.md`:
  add a `--review` line to the Usage code block
  (`/ardd-refine constitution --review  # audit + propose trimming non-load-bearing principles`),
  add a bullet under Writes noting `--review` also performs the
  constitution version-bump/Sync-Impact-Report writes when a trim is
  confirmed, and add a Behavior notes bullet describing the batched
  keep/trim confirmation and that declined candidates aren't persistently
  suppressed.
- [x] T005 Update `USAGE.md`'s command table (near its
  existing `/ardd-refine <artifact> <the decision>` row) with a new row
  for the review mode, matching the table's existing terse two-column
  style, and add a corresponding line to the `/ardd-refine <artifact>`
  usage block further down the file (the block already listed around line
  77) showing `/ardd-refine constitution --review`.

## Phase 3: Verification
- [x] T006 [artifacts: constitution] Manually exercise `--review` (as
  specified by T001–T003) against this repo's own
  `.project/artifacts/constitution.md`: enumerate all current principles,
  produce a keep/trim judgment with rationale for each, and confirm the
  batched-confirmation presentation reads correctly (expect mostly "keep"
  results, since this constitution was recently pruned by the
  `constitution-suggestions-quality` work). Record the outcome in this
  task's completion notes rather than writing a separate report file —
  there is no deterministic script to unit-test here (Constitution
  Principle II: relevance judgment isn't a pure function of file state),
  so this dogfood run is the verification, matching how `--slate` mode was
  verified. Do not apply any trim from this dry run to the real
  constitution.md unless a trim is genuinely warranted and the user
  confirms it live.

  **Outcome:** Dry-run executed against this repo's real
  `.project/artifacts/constitution.md` (v1.11.1, 9 principles under `##
  Core Principles`). Enumerated I–IX and grounded each against
  `CLAUDE.md`/`.project/artifacts/*.md` and the codebase:
  - I. Skill Files Are the Product — **keep**: this is the repo's core
    deliverable framing, reflected everywhere (CLAUDE.md's "Skill files
    are the product" convention).
  - II. Deterministic Checks and Mutations Over Prose — **keep**: directly
    load-bearing; `ardd-state.sh` and a dozen sibling scripts exist
    because of this principle, and the 500+ line test suite just run
    during this task's own align/commit steps exercises them.
  - III. Never Suggest Ignoring More Than Is Actually Regenerated —
    **keep**: still enforced today in `install.sh`'s gitignore-check
    section and `docs/decisions/0002-gitignore-ceiling.md`.
  - IV. Two Install Targets, Never Conflated — **keep**: this is the
    repo's central architectural split (CLAUDE.md's "Two install
    targets, don't conflate them"), actively guiding where new scripts
    land.
  - V. Deterministic Checks Are Test-First — **keep**: every
    `scripts/*.sh` has a paired `test-*.sh`, actively enforced.
  - VI. Simplicity / YAGNI — **keep**: general but still load-bearing —
    plans' "Complexity Tracking" sections invoke it routinely.
  - VII. No Dead Architecture — **keep**: reflected in retired
    scripts/migrations removing stale mechanisms rather than archiving
    them (e.g. `scripts/release.sh` retirement noted in CLAUDE.md).
  - VIII. Check Library/Tool Idioms Before Building Custom Mechanism —
    **keep**: the git `merge=ours` driver (vs. a hand-built merge tool)
    is a direct application of this principle, still in force.
  - IX. Unambiguous Actor Language in Agent-Facing Prose — **keep**:
    recently added (2026-07-xx actor-language-skill-prose-aud work) and
    still being applied to new/edited skill prose.

  **Result: zero trim-candidates** — all nine kept. This matches the
  task's own expectation ("expect mostly keep — recently pruned"), so
  per the `--review` step sequence's step 4, the correct behavior is to
  report this outcome and stop: no write, no version bump, nothing to
  batch-confirm. No trim was applied to the real `constitution.md`.

  The batched-confirmation UI itself (step 5 of the new mode) was not
  exercised end-to-end by this dry run since there were no candidates to
  present — its shape (single AskUserQuestion, multiSelect on,
  accept/decline per item) was cross-checked by inspection against
  `/ardd-plan` step 3c's proposed-changes-then-confirm text and reads
  consistently with it.
