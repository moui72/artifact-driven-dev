---
status: planned
created: 2026-07-22
plan: plan-35f6-2026-07-22-93b3.md
---

# Feedback

## Bugs
- [x] F001 Skill prose universally hardcodes Claude's `/<skill>` invocation
  syntax when suggesting a next step or cross-referencing another skill,
  even though the same prose file is installed verbatim into Codex's
  `.agents/skills/` (dollar-prefixed convention, per `new.sh`'s own
  `--harness codex` usage text). Reported live: running ArDD under Codex,
  `/ardd-backlog` printed "When ready to design it: `/ardd-plan
  codex-ai-provider-support.`" — Claude syntax in a Codex session, where
  the correct invocation is `$ardd-plan codex-ai-provider-support`.
  Confirmed this is systemic, not an `ardd-backlog`-only gap: every skill's
  terminal-handoff and cross-reference prose is written with the `/ardd-*`
  form baked in (`skills/ardd-backlog/SKILL.md:161` is the reported
  instance; `skills/ardd-plan/SKILL.md` and `skills/ardd-status/SKILL.md`
  each contain dozens more). Only the root-side acquisition scripts
  (`new.sh`, `install.sh`) are harness-aware about the `/` vs `$` prefix
  today — the installed skill prose itself never adjusts. Needs a
  systemic fix, not a one-line patch: either a harness-neutral phrasing
  convention adopted across every skill (e.g. "run `ardd-plan
  <slug>`" without a hardcoded sigil, or an explicit
  "`/ardd-plan` in Claude Code, `$ardd-plan` in Codex" parenthetical), or
  some other mechanism that keeps the two installed skill trees from
  silently drifting on this going forward. Worth sequencing with (or at
  least considering alongside) `codex-second-harness-support`'s remaining
  design work and `multi-harness-install-metadata`, since it's the same
  underlying dual-harness-prose-drift risk class those already guard
  against for install-time metadata, just for skill-body prose instead.
