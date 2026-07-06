---
status: planned      # open -> planned
created: 2026-07-06
plan: plan-built-with-ardd-badge-2026-07-06.md
---

# Feedback

Source: downstream upgrade inspection 2026-07-06 — an agent in
assisted-review produced a task line tagged with the literal artifact
name `none` (tasks-refactpr-3a50.md:53), which lint-project correctly
rejects (no artifacts/none.md). The interesting part is *why* the agent
invented it.

## Bugs

None — lint behaved correctly; the invented tag is the symptom.

## UX

- [x] F001 There is no sanctioned way to annotate a task that needs no
  artifact, and ardd-tasks step 3 says every task "MUST state which
  artifacts must be loaded" — which pressures an agent into inventing a
  placeholder like the literal name `none` when nothing applies. De
  facto, omission already works: this repo's own dogfooded tasks files
  freely omit the bracket-tag on artifact-less tasks, ardd-implement
  step 5 only loads artifacts when a tag is present, and lint only
  validates tags that exist. Decide and document the convention —
  recommended: (a) soften ardd-tasks step 3 to "declare the artifacts
  the task needs, omitting the tag entirely when none apply — never
  write a placeholder name"; (b) optionally have lint special-case a
  literal `none`/`n/a` inside a bracket-tag with a pointed message
  ("omit the tag instead") rather than the generic missing-file error,
  with a bad-fixture test. Alternative if explicitness is preferred:
  bless a literal `none` keyword in lint's schema — but that adds an
  enum where omission already carries the meaning.

## Reconsidered

None.
