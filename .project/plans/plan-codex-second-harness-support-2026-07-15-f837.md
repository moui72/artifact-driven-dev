---
status: draft
branch: codex-second-harness-support
created: 2026-07-15
features: [codex-second-harness-support]
surfaced-defects: []
---

# Plan: Codex CLI second-harness support (single-source, install-time substitution)

## Goal

Ship `install.sh --harness codex`, installing the existing `skills/*/SKILL.md`
files unmodified in body to a target project's `.agents/skills/` for OpenAI
Codex CLI, with exactly five localized install-time substitutions applied by
one transformer, and a degraded, inline-only Codex v1 — gated by a live
skill-to-skill-chaining smoke test as the first task and true final go/no-go.

## Scope

**In scope:**
- A live throwaway-install smoke test of Codex skill-to-skill chaining
  (Phase 1) — the residual gate the de-risking spike could not close from
  docs alone. Its result decides whether Phases 2+ proceed.
- `install.sh --harness codex` installing to `.agents/skills/`.
- One install-time substitution transformer applying exactly five
  localized rewrites (per the constitution's new "Multi-harness install"
  subsection): `AskUserQuestion` → plain-text prompts, `Agent`
  worktree-delegation/fan-out → dropped (inline-only), `.worktreeinclude`
  → not carried over (pending Open Question), `next_step_prompt` →
  plain-text offer, and the `/ardd-X` → `$ardd-X` invocation-sigil rewrite
  (including terminal-handoff prose).
- `ardd-scripts`/`ardd-constitution-data`/`ardd-artifact-templates`
  reference-directory install re-rooted under `.agents/` alongside
  `.agents/skills/`.
- Regression coverage for the new `--harness` flag and the transformer's
  substitution set.
- Doc updates: README, USAGE.md, `docs/concepts.md` (the "currently Claude
  Code-specific" line the parent research flagged as now stale).

**Out of scope (explicitly deferred, per the accepted research and the
constitution's YAGNI note):**
- A general per-harness adapter/build system. Two harnesses does not
  justify one; a third harness is the concrete case that would.
- Worktree delegation/fan-out on Codex (no structured launch-and-report-back
  primitive exists there today).
- Porting `hook-lint-on-write.sh` to Codex's feature-flagged `codex_hooks`.
- Resolving `.worktreeinclude`-equivalent behavior on Codex — ship without
  it; revisit only if the smoke test or later use surfaces a real gap.

## Technical Approach

The constitution's Project Scope & Intent (v1.10.0, "Multi-harness install")
is the source of truth for the five-substitution list and the
strip-not-emit rule for Claude-only tool calls — this plan implements that
decision, it doesn't re-derive it. `install.sh` gains a `--harness
<claude|codex>` flag (default `claude`, today's behavior unchanged). For
`--harness codex`, a new transformer function reads each
`skills/*/SKILL.md`, applies the five substitutions as a single pass, and
writes the result to `.agents/skills/<name>/SKILL.md` in the target
project — never touching the source files themselves (Principle I: one
prose surface, transformed at install time, not forked). The
`$ardd-X` sigil rewrite additionally touches any invocation hint in skill
frontmatter/prose and every terminal-handoff line matching `` `/ardd-`` in
skill bodies.

Reference directories (`ardd-scripts`, `ardd-constitution-data`,
`ardd-artifact-templates`) install under `.agents/` for the Codex path,
mirroring today's `.claude/skills/` placement, so every skill's fixed
reference path resolves the same way regardless of harness (each skill's
path references become harness-relative, resolved by the transformer, not
hardcoded per-harness in skill prose).

Phase 1's live smoke test must run before Phase 2+ are built out: create a
throwaway target directory, run the transformer manually (or a minimal
early version of it) to produce a `.agents/skills/` tree, and drive a real
Codex CLI session through at least one terminal handoff (e.g. an
`ardd-status`-equivalent stub invoking a second stub skill by
`$`-name) to confirm chaining fires reliably. A hostile result here means
stop and report — per the feature's fallback, don't-do-it (option d) — before
sinking further effort into Phases 2–5.

## Phase Breakdown

### Phase 1: Live chaining smoke test (blocking gate — do not proceed past this phase without a passing result)
- [ ] T001 [defect: none] Build a minimal two-skill throwaway fixture
  (`skill-a` with body prose "run `$skill-b`", `skill-b` a trivial
  no-op) under a scratch target directory's `.agents/skills/`. Drive a
  real Codex CLI session invoking `skill-a` by `$skill-a` and confirm it
  reliably triggers `skill-b`. Run this at least 3 times to catch
  flakiness, not just a single pass. Record the outcome (pass/fail, and
  any nuance — e.g. requires exact phrasing, works only with
  explicit `$`-mention in the handoff line) directly in this tasks file's
  checkbox notes or a follow-up feedback file if surprising.
- [ ] T002 Also confirm trailing-argument passthrough: `$skill-a
  some-arg` reaches `skill-b`'s context the way `$ARGUMENTS` is documented
  to work (Open Question 2 from the spike). Record the result.
- [ ] T003 **Go/no-go checkpoint.** If T001/T002 come back reliably
  positive, continue to Phase 2. If chaining is unreliable or
  argument-passing doesn't work as expected, stop here, write the finding
  up as a defect/feedback entry recommending the feature move to
  `implemented: false` / don't-do-it, and do not proceed to Phase 2.

### Phase 2: `install.sh --harness` flag and the substitution transformer
- [ ] T004 [artifacts: constitution] Add `--harness <claude|codex>` argument
  parsing to `install.sh` (default `claude`); validate the value and
  refuse unknown harnesses rather than silently defaulting.
- [ ] T005 Write the install-time substitution transformer as a distinct
  function/script invoked only for `--harness codex`: reads each
  `skills/*/SKILL.md`, applies the five substitutions listed in the
  constitution's "Multi-harness install" subsection, writes to
  `.agents/skills/<name>/SKILL.md` in the target. Add a regression test
  fixture (a small sample `SKILL.md` with one of each substitutable
  clause) asserting the transformer's output — this is the deterministic,
  scriptable part (constitution Principle II), not LLM judgment.
- [ ] T006 [parallel] Re-root reference-directory installation
  (`ardd-scripts`, `ardd-constitution-data`, `ardd-artifact-templates`)
  under `.agents/` for the Codex path; extend
  `scripts/test-install-gitattributes.sh`-style coverage or add a sibling
  test asserting both harness paths produce the expected directory shape.
- [ ] T007 [parallel] Extend `install.sh`'s existing regression test
  (or add `scripts/test-install-harness.sh`) covering: default (no flag)
  behavior unchanged; `--harness codex` produces `.agents/skills/` with
  substituted content; unknown `--harness` value refuses.

### Phase 3: Substitution correctness — the five clauses
- [ ] T008 Implement and test the `AskUserQuestion` → plain-text
  numbered-question substitution across every skill that uses it
  (`ardd-status`, `ardd-init`, `ardd-plan`, `ardd-feedback`).
- [ ] T009 Implement and test the `Agent` worktree-delegation/fan-out
  removal for `ardd-implement` (and the reference to it in `ardd-plan`'s
  "why it must not delegate" prose) — Codex output must show inline-only
  execution steps, no delegation offer.
- [ ] T010 Implement and test the `next_step_prompt` → plain-text
  next-step-suggestion substitution.
- [ ] T011 Implement and test the `/ardd-X` → `$ardd-X` invocation-sigil
  rewrite across every skill's invocation hints and terminal-handoff
  lines ("run `/ardd-status`" → "run `$ardd-status`"), verified against
  the fixture from T005 plus at least one real skill file end-to-end.
- [ ] T012 Confirm `.worktreeinclude` handling: for `--harness codex`,
  `install.sh` does not attempt to write/maintain `.worktreeinclude`
  (Claude Code-specific mechanism) — add a test asserting no
  `.worktreeinclude` mutation occurs on the Codex install path.

### Phase 4: Documentation
- [ ] T013 [parallel] Update `docs/concepts.md`'s "currently Claude
  Code-specific" line (flagged stale by the parent research) to reflect
  the new multi-harness reality.
- [ ] T014 [parallel] Update `README.md` and `USAGE.md` to document
  `install.sh --harness codex`, the degraded-v1 scope (inline-only, no
  lint hook), and point to the constitution's "Multi-harness install"
  subsection as the source of truth for the substitution list.
- [ ] T015 [parallel] Run `./scripts/lint-docs.sh` to confirm no new doc
  references an invalid skill name.

### Phase 5: Full regression pass
- [ ] T016 Run the full test suite (`scripts/test-*.sh`) plus the new
  harness tests from Phases 2–3; confirm CI-equivalent green locally
  before considering the feature done.

## Open Questions

1. Carried from the spike: does Codex's worktree mechanism copy gitignored
   `.agents/skills/` content into a fresh worktree the way Claude Code's
   `.worktreeinclude` does? Deferred (Phase out-of-scope) — resolve only if
   inline-only Codex use later surfaces a real gap in worktree contexts.
2. `codex_hooks` stability (feature-flagged) — still open, non-blocking;
   `hook-lint-on-write.sh` stays Claude-only indefinitely until resolved.
3. If Phase 1's smoke test comes back hostile, this plan's Phases 2–5 are
   abandoned in favor of the don't-do-it fallback — the tasks file should
   be marked `abandoned` at that point rather than worked further.
