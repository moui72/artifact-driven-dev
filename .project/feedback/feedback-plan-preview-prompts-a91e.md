---
status: open      # open -> planned
created: 2026-07-21
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## UX
- [ ] F001 `/ardd-plan`'s approval checkpoint (step 10): the
  browser-preview question and the approve/revise/stop question must be
  INDEPENDENT, sequential asks — never combined into one
  AskUserQuestion call. Observed live (2026-07-21): an agent bundled
  both questions in a single prompt, so answering "yes, browser view"
  gave no chance to actually see the preview before deciding approval —
  the preview must be presented (published, opened, URL shown) before
  the three-way question fires. The skill prose already sequences them
  ("ask a one-time preliminary question ... then proceed to the
  three-way question") but doesn't forbid batching; add an explicit
  "two separate prompts — the preview, when requested, is presented
  before the approval question is asked" clause so no agent collapses
  them again. (The related new-capability idea — an open-in-editor
  option with a configurable editor command — was re-filed to the
  register as `plan-preview-editor-option`.)
