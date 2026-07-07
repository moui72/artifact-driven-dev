---
status: planned      # open -> planned
created: 2026-07-06
plan: plan-built-with-ardd-badge-2026-07-06.md
---

# Feedback

Source: first real downstream upgrade (2026-07-06, installing 89314a4
into assisted-review and sync-tab-scroll).

## Bugs

- [x] F001 Migration 0003-per-feature-files leaves dangling
  `[artifacts: features]` tags: it converts the register and removes
  `.project/artifacts/features.md`, but task/feedback lines still
  carrying `[artifacts: features]` (valid pre-migration, when the
  register was an artifact file) now fail lint-project's
  artifact-reference check with a generic "no artifacts/features.md"
  message. Observed live in
  sync-tab-scroll (tasks-lobby-cursor-modes-0bea.md:31,
  feedback-lobby-cursor-mode-e13b.md:14) — our own repo never exposed it
  because no local file used the tag. Fix either by having the migration
  rewrite/drop the `[artifacts: features]` tags in .project/tasks/ and
  .project/feedback/ (preferred — same one-final-parse spirit as the
  register split), or by lint special-casing `features` with a pointed
  message ("the register is .project/features/ now; retag or drop").
  Fixture test must include a pre-migration project carrying the tag.

## UX

None.

## Reconsidered

None.
