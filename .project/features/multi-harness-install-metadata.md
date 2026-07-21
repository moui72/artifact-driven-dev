---
slug: multi-harness-install-metadata
status: tasked
logged: 2026-07-21
plan: plan-multi-harness-2026-07-21-76ba.md
tasks: tasks-multi-harness-49bb.md
---

First-class multi-harness install metadata: dual Claude+Codex installs (.claude/skills/ardd-*/ and .agents/skills/ardd-*/) coexist mechanically, but .project/ardd-version.md and .project/README.md are single shared install-owned files — the last-run harness install owns the Harness: line and reviewer-guide path wording, misrepresenting the repo's actual installed harness set. Direction (no parallel skill source trees, no diverging Claude/Codex prose): Harnesses: claude,codex with preserve/update semantics, or a per-harness install manifest under .project/ (skills root, sigil, source commit/ref/channel, last installed), plus harness-neutral reviewer-guide language listing all installed roots. Acceptance: install.sh --harness claude/codex in either order leaves both trees intact; shared metadata represents both; $ardd-update//ardd-update preserve the invoking harness and never silently remove or misrepresent the other; gitignore/.worktreeinclude guidance stays bounded per harness (never blanket .claude/ or .agents/); Claude-only stays backward-compatible; Codex-only records enough for update/check/status; deterministic tests cover Claude-only, Codex-only, and dual-install both orders. From inbox capture 2026-07-21.
