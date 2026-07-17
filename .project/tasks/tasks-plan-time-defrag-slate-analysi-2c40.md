---
plan: plan-plan-time-defrag-slate-analysi-2026-07-17-1a95.md
generated: 2026-07-17
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: `--slate` mode skeleton, N=0/N=1 branch [feature: plan-time-defrag-slate-analysi]
- [x] T001 [artifacts: constitution] Edit `skills/ardd-plan/SKILL.md`'s
  Usage section and argument-shape dispatch (where `--from`,
  `feedback-*.md`, and `defect:`/`defects` are already distinguished by
  argument shape) to add a new `--slate` form that, when present, skips
  steps 1–15 entirely and enters a new "Slate mode" section (to be added
  at the end of the skill file, after the tasking-half steps). No test
  task — prose-only skill-file change, matching the precedent set by
  `list-mode-for-plan-and-impleme`'s `--list` addition (no state
  mutation, no new invariant to regression-test).
- [x] T002 [artifacts: constitution] In the new "Slate mode" section,
  write step 1 (enumerate `backlogged` items via `scripts/feature-list.sh
  --status backlogged`, unmodified — the register-direct-read discipline)
  and step 2 (the N=0/N=1 degenerate branch: N=0 reports "nothing to
  defrag" and stops; N=1 reports "nothing to defrag — single open item"
  and recommends `/ardd-plan <that slug>` directly, then stops — never
  fabricate a slate at N≤1). Verify manually against a throwaway scratch
  `.project/features/` fixture with 0, then 1, `backlogged` file(s) —
  this repo's own current backlog (N≥2) is covered by Phase 2/3 instead.

## Phase 2: N≥2 footprint grading and pairwise relations (depends on Phase 1) [feature: plan-time-defrag-slate-analysi]
- [ ] T003 [artifacts: constitution] In the Slate mode section, write
  step 3 (per-item footprint confidence grading): for each `backlogged`
  item, read its register entry and ground a footprint estimate in real
  greps/reads of the codebase (never free-associated from the prose
  alone), grading confidence `high`/`medium`/`low` with the worked
  criteria from the plan's Technical Approach (high = concrete existing
  seam found; medium = seam exists but a real unknown remains, e.g. a
  non-code gate; low = greenfield/no seam/explicitly flagged speculative
  or deferred in the artifact). Include the two worked examples from the
  plan (`wasm-hunspell-backend` = high, `llm-assistance` = low) as
  in-prose illustrations so the grading is legible to whoever runs this
  mode.
- [ ] T004 [artifacts: constitution] [parallel] In the same section,
  write step 4 (pairwise relations, two axes computed separately): for
  every pair of `backlogged` items, determine file-set overlap and
  ordering dependency as two independent judgments — overlap without
  dependency is safely parallel even when topically related; dependency
  without full file overlap still forces sequencing. Include both worked
  examples from the plan (the spellcheck-label false-bundle case; the
  typography→export ordering case) as in-prose illustrations.
- [ ] T005 Verify Phase 2's prose against a throwaway scratch
  `.project/features/` fixture (not a real project) seeded with at least
  one known bundle pair (shared file or explicit dependency) and one
  known parallel pair (disjoint files, unrelated), and confirm the
  written grading/relation-finding steps, followed by hand, reach the
  expected classification for each pair. Record the fixture setup and
  result inline in this task's completion note — no fixture file needs
  to be committed (this is prose verification, not a regression test).

## Phase 3: Classification, presentation, and next-step handoff (depends on Phase 2) [feature: plan-time-defrag-slate-analysi]
- [ ] T006 [artifacts: constitution] In the Slate mode section, write
  step 5 (classify and present): bucket every `backlogged` item into
  exactly one of Bundle / Parallel set / Solo-deferred per the plan's
  Technical Approach rules (bundle = dependency edge or unsafe-to-
  reorder file overlap, recommended as one multi-slug `/ardd-plan
  <slug1> <slug2> ...` call in dependency order; parallel set =
  pairwise file-disjoint, no dependency edge, not `low` confidence,
  recommended as separate `/ardd-plan <slug>` calls; solo-deferred =
  `low`/speculative confidence or gated on a non-code decision,
  recommended as its own single-slug `/ardd-plan <slug>` call). Render
  the report format: full grouping with the specific shared file or
  dependency named for each bundle, then the recommended next
  command(s).
- [ ] T007 [artifacts: constitution] [parallel] Wire the
  `next_step_prompt: true` `AskUserQuestion` offer for the single
  top-priority recommendation from T006's report, using the same
  mechanism `/ardd-plan`'s and `/ardd-status`'s own next-step prompts
  already use (option 1 "Yes — run `<recommendation>` now", option 2
  "No — stop here", Esc = option 2) — never more than one such prompt
  per user-visible turn end. Absent or `false` `next_step_prompt`: stay
  plain text, unchanged.
- [ ] T008 Verify end-to-end: run `/ardd-plan --slate` against this
  repo's own real current backlog (`codex-second-harness-support` and
  `plan-time-defrag-slate-analysi` itself — 2 items, N≥2) and confirm it
  produces a grouping, rationale, and recommended `/ardd-plan`
  invocation(s) without writing any file (read-only mode — verify `git
  status --short` is unchanged after the run). Note: this feature's own
  entry will still be `planned`/`tasked` at that point (not yet
  `implemented`), so it is legitimately part of the backlog this run
  analyzes — that's expected, not a bug.

## Phase 4: Docs (depends on Phase 3) [feature: plan-time-defrag-slate-analysi]
- [ ] T009 [artifacts: constitution] Update
  `docs/reference/skills/ardd-plan.md` with the `--slate` usage form —
  mirroring how `--list` and `--from` are already documented there (a
  short paragraph: what it does, that it's read-only/ephemeral, and a
  pointer to the plan's Technical Approach shape). No test task — docs
  change only.
