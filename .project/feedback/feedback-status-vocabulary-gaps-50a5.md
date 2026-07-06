---
status: planned      # open -> planned
created: 2026-07-06
plan: plan-status-vocab-lint-fixes-2026-07-06.md
---

# Feedback

Source: post-0004 downstream lint (2026-07-06). Three independent agent
runs in consumer repos invented status values the enums don't have —
the same failure shape as the placeholder-artifact-name `none` (9fc6):
when the sanctioned vocabulary lacks a state real use wants, agents
invent one instead of stopping.

## Bugs

None — lint correctly rejected all three inventions; the gaps are in
the vocabulary/affordances, not the validator.

## UX

- [x] F001 No sanctioned way to reopen a completed tasks file. Observed:
  sync-tab-scroll's tasks-lyrics-ticker-75dd.md at
  `status: reopened (T004 failed live-browser verification ...)` — an
  invented value plus an inline annotation, because a task that passed
  implementation later failed live verification and the agent wanted the
  file active again. The intended path is `/ardd-converge` (which can
  reconcile checkboxes and set `in-progress`), but (a) nothing tells an
  agent that at the moment of need, and (b) `ardd-state.sh tasks-flip`
  has no `completed → in-progress` transition, so even converge can't
  legally reopen a completed file. Decide: either add a sanctioned
  `completed → in-progress` transition (converge-only, with a note
  requirement), or rule that post-completion failures are new work
  (feedback → plan → new tasks file) and say so in ardd-implement/
  ardd-converge prose + the tasks-file status comment. Either way,
  lint's unknown-status message should point at the sanctioned path.
- [x] F002 Tasks-file vocabulary confusion: `superseded` (a plan status)
  used on a tasks file where the enum wants `abandoned` — observed in
  sync-tab-scroll's tasks-settings-modal-followup-bbd2.md. Cheap fix:
  lint special-cases known cross-schema values (`superseded` on tasks →
  "did you mean abandoned? superseded is a plan status"), mirroring the
  placeholder-name special-case from 9fc6.
- [x] F003 No sanctioned way to split/partially-consume a feedback file:
  `status: split` invented on sync-tab-scroll's
  feedback-manual-verification-pass-4b3c.md. The current design already
  handles partial consumption (items marked per-item; file stays `open`
  until all are resolved), so the likely fix is prose + a lint hint
  ("split is not a status — mark items individually; the file flips to
  planned when all are resolved"), not a new enum value. Verify that
  reading against whatever that agent was actually trying to do before
  deciding.

## Reconsidered

None — the enums themselves may be right; what's missing is either a
transition, an affordance, or a pointed message at the moment an agent
reaches for a nonexistent value.
