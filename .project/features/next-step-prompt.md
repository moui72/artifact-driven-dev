---
slug: next-step-prompt
status: implemented
logged: 2026-07-09
plan: plan-next-step-prompt-2026-07-09.md
tasks: tasks-next-step-prompt-fe51.md
---

Opt-in constitution frontmatter boolean next_step_prompt: true | false (absent = false): when true, /ardd-analyze, /ardd-plan, and /ardd-tasks end by offering their recommended next step as a selectable AskUserQuestion (yes = invoke that skill now via the existing terminal-handoff; no/Esc = stop), but only when the recommendation is a concrete runnable /ardd-* invocation — otherwise, and always when false/absent, it stays plain text as today.
Why: replaces typing 'yes, run X' with one keypress at the three handoff seams; scoped to those three skills (analyze is the sink most skills terminal-handoff into) to avoid duplicated prompt prose; opt-in so scripted/delegated invocations are never prompt-blocked. Needs the lint-project.sh boolean validation added in the same commit (schema-of-record) and a /ardd-bootstrap question per the workflow_mode precedent. Existing (already-bootstrapped) projects get asked once via /ardd-update: after re-running install.sh, if constitution frontmatter lacks next_step_prompt, ask the same question and write the answer; field presence (either value) suppresses re-asking. Absent stays = false for paths that skip the ask (bare install.sh, scripted runs). Not a migrations/*.sh job — migrations are non-interactive. Plan must state explicitly whether this frontmatter-only write needs /ardd-refine's constitution version bump (workflow_mode precedent suggests no).
