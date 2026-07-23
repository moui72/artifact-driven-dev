---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: codex-scenario-sweep-fixes       # the branch inline implementation would use; may never be created (see step 1)
created: 2026-07-22
features: []
surfaced-defects: []
---

# Plan: codex-scenario-sweep-fixes

## Goal

Fix the two still-live gaps from the Codex scenario-sweep feedback
(`feedback-codex-scenario-sweep-findings-565e.md`): `/ardd-defects` can
silently drop still-open defects on regeneration, and `/ardd-status`'s
`STATUS.md`-writing prose carries no explicit rule against overwriting
prior re-entry chronology with just a fresh summary.

## Scope

**In scope:**
- F002 [artifacts: none — this is a skill-prose fix, not an artifact
  edit]: `/ardd-defects` step 5 (full-overwrite regeneration) gains an
  explicit reconciliation sub-step — before overwriting, diff the new
  survey's findings against the *previous* `DEFECTS.md`'s claims; for any
  claim present before but absent from this run's fresh survey, spot-check
  that specific location directly before letting it drop, rather than
  trusting survey completeness implicitly. A claim confirmed still-true on
  spot-check is carried forward into the new file even if the general
  survey pass missed it; a claim confirmed fixed drops as today.
- F003: `/ardd-status` step 6 (Write `.project/STATUS.md`) gains an
  explicit preservation rule: a new run's `_Updated:` entry is *prepended*
  as a new top block, and every prior `_Updated:` block is preserved
  verbatim below it — never summarized away, condensed, or replaced. This
  codifies the convention already followed in this repo's own `STATUS.md`
  history into skill prose, so it holds regardless of which
  session/agent runs `/ardd-status` next.
- F001 was investigated and declined as stale: the current
  `skills/ardd-update/SKILL.md` text already reads "Claude-oriented
  `.claude/skills` output" (line 120) — the wording the item asked for.
  No trace of the reported wrong wording (`.agents/skills`) exists
  anywhere in the repo. Not touched by this plan.

**Out of scope:**
- Any bound/growth-management concern for `STATUS.md` itself (it is
  already very large from this preservation convention) — F003 asked only
  that chronology not be *dropped*, not that the file be kept short; a
  size-management redesign is a separate decision, not implied by this
  feedback item.
- Re-litigating F001.

## Technical Approach

Both fixes are skill-prose edits to existing steps already responsible for
this behavior — no new scripts, no artifact changes (this project only has
`constitution.md`, and neither fix touches a declared principle).

For F002, the reconciliation sub-step reads the *current on-disk*
`DEFECTS.md` (before it's overwritten) as the "previous claims" set,
computes the set difference against this run's fresh survey findings, and
spot-checks each difference item individually (re-read the specific
artifact claim + the specific code location the old entry cited) before
deciding to drop it. This keeps the "full regenerate, no manual removal
needed" design intact (constitution Principle II's spirit — the fix
mechanism stays the actual code check, not a human remembering) while
closing the gap where an incomplete general survey pass silently loses a
still-valid finding.

For F003, the fix is additive prose in step 6 stating the prepend-and-
preserve rule explicitly, plus one clarifying sentence that this is why
`STATUS.md` grows over time by design (its history is durable, not
a snapshot) — matching the file's own existing self-description
elsewhere ("STATUS.md is the single re-entry point after any
interruption").

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

### Phase 1: /ardd-defects reconciliation step [feedback: F002]
- Edit `skills/ardd-defects/SKILL.md` step 5: before the full-overwrite
  write, add a reconciliation sub-step that reads the current on-disk
  `DEFECTS.md`, computes claims present there but absent from this run's
  fresh survey, and spot-checks each one's specific artifact claim and
  code location before dropping it — carrying forward any claim confirmed
  still-true on spot-check.

### Phase 2: /ardd-status prepend-and-preserve rule [feedback: F003]
- Edit `skills/ardd-status/SKILL.md` step 6: add an explicit rule that a
  new `_Updated:` entry is prepended and every prior entry is preserved
  verbatim below it, never summarized away — plus the one-sentence
  rationale that `STATUS.md`'s durable growth is by design.

Both phases are documentation/prose-only changes with no deterministic
script behind them, so under constitution Principle V's documented
exception (a pure research/decision or documentation-only task), neither
carries a test requirement.

## Open Questions

- None. Both fixes are narrowly scoped prose additions to steps that
  already own this exact behavior.
