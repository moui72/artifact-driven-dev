---
status: open      # open -> planned
created: 2026-07-17
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Reconsidered
- [ ] F001 `/ardd-plan`'s approval checkpoint (step 10) always asks "view
  the plan in the browser first?" via `AskUserQuestion` (yes/no) on
  every single run — added in `62052ae feat(T003): offer a browser
  preview at /ardd-plan's approval checkpoint`. Reconsidered: this
  should be a configurable workflow setting instead, so a user who
  already knows their preference can eliminate the repeated prompt from
  their workflow. Proposed values (constitution frontmatter field,
  analogous to the existing `delegation`/`merge_policy`/`next_step_prompt`
  workflow fields, stamped via `ardd-state.sh stamp`, schema-of-record in
  `lint-project.sh`): `always-browser` (skip the question, always
  publish and open), `always-console` (skip the question, never publish
  — go straight to the terminal skeleton-plus-pointer presentation),
  `ask` (current behavior, and the default/absent value — preserves
  existing behavior for anyone who hasn't opted in). [artifacts: constitution]
