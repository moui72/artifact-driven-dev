---
slug: codex-second-harness-support
status: backlogged
logged: 2026-07-15
---

Single-source Codex CLI support: install.sh --harness codex installs the same SKILL.md files to .agents/skills/ with the ~4 Claude-specific clauses (AskUserQuestion, Agent worktree delegation, .worktreeinclude, next_step_prompt) substituted at install time; Codex v1 is deliberately degraded to inline-only implementation (no delegation/fan-out), plain-text prompts, no lint hook. No parallel prose tree, no adapter build system (premature at two harnesses).
Why: spec = .project/plans/research-codex-cli-second-harness-2026-07-15-2d3d.md (accepted recommendation). FIRST STEP is a de-risking spike on the go/no-go gates (does Codex support exact-name skill invocation and reliable skill-to-skill chaining?) before any install work. Requires a MINOR constitution amendment (constitution scopes ArDD as "a Claude Code skill pack" — this is a named scope reversal, needs a Sync Impact Report + version bump when planned). Fallback if the spike fails is don't-do-it.
