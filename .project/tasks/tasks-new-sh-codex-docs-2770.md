---
plan: plan-new-sh-codex-docs-2026-07-21-302a.md
generated: 2026-07-21
status: completed
---

# Tasks

## Phase 1: Document `new.sh --harness`
- [x] T001 In `docs/install.md`, add `--harness claude|codex` to the
  existing `new.sh` flag documentation. Place it alongside the existing
  `--kickoff`/`--no-kickoff` bullet under "Quickstart: a brand-new
  project" (docs/install.md, the bullet list right after the `curl | sh`
  code block around line 20) — a new bullet covering: the flag itself
  (`--harness claude|codex` or `--harness=<name>`), that omitting it
  prompts interactively when a tty is available (`ask_harness`: 3 tries,
  falls back to `claude` on no clear answer or no tty — same
  `/dev/tty` discipline as the existing kickoff-handoff prompt
  documented in `docs/decisions/0008-new-sh-tty-interactivity.md`), and
  that the choice is passed straight through to `install.sh --harness
  "$harness"`. End the bullet with a forward cross-reference to the
  existing "Codex CLI: `install.sh --harness codex`" section
  (docs/install.md:103) for the full behavior/caveats of choosing
  `codex`. Verify with `./scripts/lint-docs.sh` that the addition
  introduces no broken `/ardd-*` references (it shouldn't — this is
  prose about `new.sh`/`install.sh` flags, not a skill reference).
