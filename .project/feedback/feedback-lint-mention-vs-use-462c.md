---
status: planned      # open -> planned
created: 2026-07-06
plan: plan-status-vocab-lint-fixes-2026-07-06.md
---

# Feedback

Source: three false positives in one day (2026-07-06) while writing
.project/ content *about* the tagging system: the b959 feedback file's
description of the dangling-tag bug, the 2ebc tasks file's T004/T005
descriptions, and the 50a5 feedback file's mention of the placeholder
name — each tripped lint and had to be reworded to dodge it.

## Bugs

- [x] F001 lint-project.sh cannot distinguish a line that USES an
  artifacts bracket-tag from prose that MENTIONS the syntax: it greps
  every line of tasks/feedback files, so meta-content about ARDD inside
  an ARDD-managed project fights the linter (this repo constantly, via
  dogfooding; any downstream repo whose task says "fix the artifacts
  bracket-tag handling in X"). Deterministic fix: restrict tag-parsing
  (both the reference check and the placeholder-name check) to item
  lines only — lines matching the checklist prefix (`- [ ]`, `- [x]`,
  `- [-]`) — since the tag convention is only load-bearing there.
  Accepted residual: a syntax mention within an item line's own prose
  still matches; that's where tags are real, so strictness is correct
  there. Test-first: add a bad-project fixture body-prose line carrying
  a literal tag that must NOT be reported (drives EXPECTED_BAD_FINDINGS
  down or holds it steady — assert the specific absence), keep an
  item-line violation asserting presence.

## UX

None.

## Reconsidered

None.
