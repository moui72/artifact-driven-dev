---
status: approved
branch: chore-docs-sweep-feedback
created: 2026-07-24
features: []
surfaced-defects: []
---

# Plan: chore-docs-sweep-feedback

## Goal

Fix five `docs/reference/skills/*.md` pages that have drifted from their
current `SKILL.md` behavior, as surfaced by `/docs-sweep` and filed as
open feedback.

## Scope

In scope: the specific stale passages named in each of the five feedback
items below, in `docs/reference/skills/ardd-defects.md`,
`docs/reference/skills/ardd-implement.md`, `docs/reference/skills/ardd-init.md`,
`docs/reference/skills/ardd-plan.md`, and `docs/reference/skills/ardd-update.md`.

Out of scope: any other doc page, any `SKILL.md` behavior change (the
feedback items are all doc-only drift — the code/skill behavior already
does the right thing; only the docs are stale), and any other open
feedback (none remains open at this time).

## Technical Approach

Each item is a targeted prose fix bringing a hand-written reference-page
body paragraph back in line with the current `SKILL.md` it documents.
No frontmatter, generated-header, or structural changes — edits land
below each page's `generated:end` marker per `USAGE.md`'s documented
split.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

### Phase 1: Fix stale reference-page passages

- Fix `docs/reference/skills/ardd-defects.md`'s defect-drop description to
  note the pre-drop reconciliation spot-check added at
  `skills/ardd-defects/SKILL.md:80-89`. [feedback:
  feedback-ardd-defects-reconciliation-docs-4cbd F001]
- Rewrite `docs/reference/skills/ardd-implement.md`'s Pre-flight bullet to
  name all four resolved-path kinds (plan/tasks/features/feedback) plus
  the separate artifacts-directory check that always asks in both modes,
  per `skills/ardd-implement/SKILL.md:176-225`. [feedback:
  feedback-ardd-implement-pre-flight-docs-e370 F001]
- Add a clause to `docs/reference/skills/ardd-init.md`'s "Never invents
  decisions" bullet distinguishing "never guesses" from "never overclaims
  observed-vs-universal coverage," per the overclaim guard at
  `skills/ardd-init/SKILL.md:192-200`. [feedback:
  feedback-ardd-init-overclaim-docs-fb81 F001]
- Add a sentence to `docs/reference/skills/ardd-plan.md` covering
  `plan_preview_editor`'s `{path}`-template mechanism and how it composes
  with (doesn't replace) `plan_preview`. [feedback:
  feedback-ardd-plan-preview-editor-docs-2301 F001]
- Add a sentence to `docs/reference/skills/ardd-update.md` distinguishing
  the Codex harness's refuse-and-ask guard from Claude's safe-proceed
  behavior against a pre-`--harness` source, per
  `skills/ardd-update/SKILL.md:105-129`. [feedback:
  feedback-ardd-update-harness-docs-15a4 F001]

## Open Questions

None.
