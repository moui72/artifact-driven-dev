---
status: open
created: 2026-07-22
plan: null
---

# Feedback

## Bugs
- [ ] F001 `/ardd-update`'s SKILL.md step 4 unconditionally passes `--harness <harness>` to `install.sh`, but its compat guard only checks `HARNESS=codex`. A stable tag predating `--harness` support (e.g. v1.0.4) hard-fails the reinstall for a plain-claude-harness consumer running `/ardd-update --stable`, with `Error: target directory '--harness' does not exist.`. Fails cleanly (no state corruption); workaround is omitting `--harness` for that source version. Found in scenario-sweep S3 (run 2026-07-21-d816).
- [ ] F002 `ardd-scripts` CWD-relative subcommands (`ardd-state.sh feature-create`, `project-lock.sh`, etc.) resolve `.project/` against the invoking shell's CWD even when the script itself is invoked by an absolute path elsewhere — a silent wrong-target write with no error. Found in scenario-sweep S6 (run 2026-07-21-d816) when a command was run with the shell's CWD still at the ArDD source repo instead of the scratch target; wrote a stray feature file into the source repo's own `.project/features/` (caught and reverted, no lasting damage).
- [ ] F003 Reverse-engineered `constitution.md` (via `/ardd-init`'s existing-codebase path) overclaimed a principle — asserted every canonical entity has both a compile-time type and a runtime Zod schema, when one entity actually lacked a Zod schema (4/5 real coverage). This drift was correctly self-caught by a subsequent `/ardd-defects` run rather than silently persisting, but `/ardd-init`'s reverse-engineer step should be more conservative about asserting universal coverage claims without verifying each entity. Found in scenario-sweep S2 (run 2026-07-21-d816).

## UX
- [ ] F004 A drafted task carried "confirm it fails first" TDD phrasing that couldn't be honored because its dependency task was already implemented earlier in the same plan phase (recurrence of a 2026-07-15 finding class). `/ardd-plan`'s task-drafting guidance should explicitly flag or avoid TDD-red-first phrasing for a task whose precondition work already landed in an earlier task of the same plan. Found in scenario-sweep S5 (run 2026-07-21-d816).
- [ ] F005 The printed dynamic version badge snippet (`ARDD_VERSION_BADGE=1` output) contains a literal `PLACEHOLDER` string in its `logo=` param — likely an unintentional leftover, worth a maintainer glance. Found in scenario-sweep S1 (run 2026-07-21-d816).
- [ ] F006 `/ardd-status`'s Feature Backlog summary line omits "0 planned" (and presumably other zero-count buckets) instead of showing it explicitly — only non-zero counts print, which can read as an omission rather than a confirmed zero. Found in scenario-sweep S7 (run 2026-07-21-d816).
