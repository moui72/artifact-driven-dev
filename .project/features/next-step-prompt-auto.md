---
slug: next-step-prompt-auto
status: backlogged
logged: 2026-07-20
---

A third next_step_prompt enum value, 'auto' (prompt / plain-text / auto): when set, /ardd-status and /ardd-plan auto-run their recommended next step whenever it is a concrete runnable /ardd-* invocation, instead of prompting via AskUserQuestion — the explicit, harness-agnostic alternative to coupling prompt behavior to Claude Code's permission mode (vetted 2026-07-20: mode is only visible via hook payloads, would force target-side hook shipping, and acceptEdits/auto modes still show AskUserQuestion so they don't mean 'don't ask'). Stamped via ardd-state.sh stamp; lint-project.sh enum widened in the same commit; non-runnable recommendations stay plain text as today.
