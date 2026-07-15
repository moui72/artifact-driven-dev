---
status: approved
branch: v1-0-0-pre-cut-testing-finding
created: 2026-07-15
features: []
surfaced-defects: []
---

# Plan: fix v1.0.0 pre-cut testing findings

## Goal

Fix the 6 issues (2 bugs, 4 UX) surfaced by the v1.0.0 pre-cut dry-run
testing pass, recorded in
`feedback-v1-0-0-pre-cut-testing-findings-0344.md`.

## Scope

**In scope:** F001 (`worktree-align.sh` silent non-worktree collapse),
F002 (`/ardd-init` reverse-engineering entity-completeness gap), F003
(gitignore suggestion visibility — scoped narrower than the feedback's
literal ask, see below), F004 (constitution-suggestion catalog scale
sensitivity), F005 (`/ardd-defects` nudge after brownfield init), F006
(`/ardd-update` resolution diagnostics).

**Out of scope, with reasoning:**
- **F003 as literally proposed** ("self-apply the `.gitignore` pattern
  the way `.worktreeinclude` does") conflicts with a deliberate, standing
  decision: install.sh never modifies a target's `.gitignore` — only
  suggests — precisely because `.gitignore` is content the user owns and
  controls, unlike `.worktreeinclude`, which is a harness-internal
  mechanism with no user-authorship expectation (CLAUDE.md's gitignore
  ceiling discipline, install.sh's own comments around its suggestion
  block). This plan does NOT add auto-editing of `.gitignore`. Instead it
  scopes F003 to what the underlying complaint actually needs: making the
  existing suggestion harder to miss (a distinct, clearly-marked block
  rather than one line among many), not auto-applying it.
- Re-running the 3 untested scenarios (S4 collaborative, S5 solo inline
  core loop, S7 peripheral-skills sweep) from the testing pass — that's
  new testing work, not a fix, and belongs to a future `/ardd-status`
  recommendation or a fresh dry-run pass, not this plan.

## Technical Approach

Six independent fixes across five files, none touching `.project/artifacts/`
(no artifact declares any of this behavior — it's all skill-prose and
script logic). Grouped into 3 phases by which surface they touch:
worktree/delegation machinery (F001), `/ardd-init` (F002, F004, F005), and
install/update reporting (F003, F006). No shared dependencies between
phases; within a phase, tasks touch different files and are independent.

## Phase Breakdown

### Phase 1: delegation machinery — F001

- [ ] T001 [artifacts: none] Fix `scripts/worktree-align.sh` to positively
  verify it's running in a genuine linked worktree, not the primary
  checkout. A linked worktree's `.git` is a regular *file* (pointing at
  the real gitdir); the primary checkout's `.git` is a *directory*. Add a
  check early (after the existing `is-inside-work-tree` check, before the
  dirty check) that `[ -f .git ]` — i.e. `.git` at the repo root is a
  file, not a directory — and if not, print `aligned=false` /
  `reason=not-a-worktree` and exit 1, mirroring the existing
  reason-code output format exactly. Update the script's header comment
  block to document the new failure mode alongside the existing four.
  Test-first (constitution Principle V, deterministic-check paradigm):
  add a case to `scripts/test-worktree-align.sh` that runs the script
  from the **primary checkout itself** (not a linked worktree) against a
  fixture repo and asserts `aligned=false reason=not-a-worktree` exit 1 —
  confirm this fixture fails before the fix, passes after. [feedback: F001]

### Phase 2: `/ardd-init` — F002, F004, F005

- [ ] T002 [artifacts: none] In `skills/ardd-init/SKILL.md`'s
  existing-codebase reverse-engineering steps: strengthen the entity/schema
  discovery instruction so it doesn't rely on a single structural
  convention (e.g. "every entity has a colocated Zod schema") to enumerate
  entities. Add explicit guidance to cross-check entity completeness using
  at least two independent signals where the codebase offers them (e.g.
  ORM/schema files AND database migration files AND route handlers AND
  type definitions — whichever the detected stack actually has), and to
  flag in the generated artifact's `[OPEN: ...]` items any entity the
  survey found via only one signal, as a lower-confidence claim worth a
  human second look. Documentation-only change — no test task (Constitution
  Principle V's documentation-only exception). [feedback: F002]
- [ ] T003 [artifacts: none] [parallel] In `skills/ardd-init/SKILL.md`:
  add project-scale sensitivity to the constitution-suggestion catalog
  step. Alongside the existing stack-signal detection, detect a
  "trivial project" signal (e.g. fewer than some small file-count
  threshold, no dependency manifest, or a single source file) and when
  present, default to offering only the catalog's "Always" tier rather
  than the full stack-matched set — with a note the user can ask to see
  the full catalog if they want it. Keep the existing full-catalog
  behavior unchanged for anything not detected as trivial.
  Documentation-only change — no test task. [feedback: F004]
- [ ] T004 [artifacts: none] [parallel] In `skills/ardd-init/SKILL.md`:
  at the end of the existing-codebase (brownfield reverse-engineering)
  path's final report step, add an explicit recommendation to run
  `/ardd-defects` next, in the same session, before treating the
  reverse-engineered artifacts as ready to plan against — with one
  sentence on why (freshly-reverse-engineered artifacts are exactly the
  case where a code-vs-artifact drift check is most likely to catch a
  survey mistake). If this project's `next_step_prompt: true`, this
  recommendation should be eligible for the existing next-step-prompt
  mechanism the same way `/ardd-status` and `/ardd-plan` already offer
  one — check whether `/ardd-init`'s SKILL.md already participates in
  that convention before adding a new one; if it doesn't, a plain-text
  recommendation is sufficient here (don't widen the two-skill
  next-step-prompt scope as a side effect of this task — CLAUDE.md notes
  that scope is deliberately narrow). Documentation-only change — no test
  task. [feedback: F005]

### Phase 3: install/update reporting — F003, F006

- [ ] T005 [artifacts: none] In `install.sh`'s `.gitignore` suggestion
  block (near the `.claude/skills/ardd-*/` guidance): make the suggestion
  visually distinct from the surrounding output — a clearly bounded
  block (e.g. a `---` separator or an all-caps `ACTION NEEDED` marker,
  matching whatever the script's existing warning-block convention is, if
  it has one) rather than one line among general install output — so it
  survives being read in a long transcript. Do NOT add any code that
  writes to the target's `.gitignore` — this stays suggestion-only per
  the standing ceiling decision (see Scope). Add/update a case in
  `scripts/test-install.sh` asserting the suggestion block's distinct
  marker text appears in output when `.gitignore` doesn't cover
  `.claude/skills/ardd-*/`. [feedback: F003]
- [ ] T006 [artifacts: none] [parallel] In `scripts/source-resolve.sh`:
  when resolution completes but the resulting ref is NOT the newest tag
  the remote actually has (i.e. a fetch happened, tags were seen, but an
  older tag was selected than what's technically available — the
  propagation-lag scenario F006 hit), emit a diagnostic line distinguishing
  "resolved to the newest tag we could see" from cases where something
  prevented seeing a newer one (e.g. `note=fetch-skipped-fresh-cache` when
  the offline-tolerant fetch skip logic applied, vs. no note when the
  fetch genuinely ran and this really is the newest available tag).
  Relay this note through `/ardd-update`'s step-1 reporting in
  `skills/ardd-update/SKILL.md` (it already relays `warning=offline` and
  `warning=no-tags` the same way — extend that existing relay list, don't
  invent a new mechanism). Add a case to
  `scripts/test-source-resolve.sh` covering the fresh-cache-skip note.
  [feedback: F006]

## Open Questions

None — each task is independently scoped and testable; nothing here
depends on a design decision not already made in this plan.

## Summary of decisions made this run

- F003 accepted with narrowed scope: visibility/prominence fix, not
  auto-editing `.gitignore` — the literal ask conflicts with a standing,
  deliberate ceiling decision documented in CLAUDE.md and would need its
  own explicit reversal decision, not a side effect of this cleanup plan.
- No artifact changes: nothing here is a `.project/artifacts/*.md`-level
  decision: all six fixes are skill-prose or deterministic-script
  behavior.
