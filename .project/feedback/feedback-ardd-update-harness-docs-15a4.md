---
status: open
created: 2026-07-24
plan: null
---

# Feedback

## Bugs
- [ ] F001 `docs/reference/skills/ardd-update.md:82-94` only describes the Codex-side refuse-and-ask guard for a pre-`--harness` source. `skills/ardd-update/SKILL.md:105-129` broadened this so `HARNESS=claude` against a pre-`--harness` source is instead treated as safe (omit `--harness claude`, proceed) rather than refusing. Fix: add a sentence distinguishing the two harnesses' behavior against a pre-`--harness` source. Found via `/docs-sweep`.
