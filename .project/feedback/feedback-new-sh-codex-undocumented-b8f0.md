---
status: planned      # open -> planned
created: 2026-07-21
plan: plan-new-sh-codex-docs-2026-07-21-302a.md
---

# Feedback

## Bugs
- [x] F001 `docs/install.md` documents `install.sh --harness codex` (its
  own "Codex CLI: `install.sh --harness codex`" section) but never
  mentions that `new.sh` — the acquisition bootstrap `docs/install.md`
  itself introduces and covers elsewhere in the same page — also has
  full Codex support: `new.sh --harness claude|codex` (or
  `--harness=<name>`), an interactive `ask_harness` prompt when no flag
  is given and a tty is available (3 tries, falls back to `claude` on no
  clear answer or no tty per the `/dev/tty` interactivity rules in
  `docs/decisions/0008-new-sh-tty-interactivity.md`), passed straight
  through to `install.sh --harness "$harness"`, and an adapted
  post-install handoff (`codex '<handoff_cmd>'` instead of the Claude
  Code launch). A reader following `docs/install.md`'s `new.sh` coverage
  would have no way to discover `new.sh` can target Codex at all — they'd
  have to already know to go look at `new.sh --help` or the source.
  Fix direction: add a `new.sh`-specific mention of `--harness
  claude|codex` near `docs/install.md`'s existing `new.sh` coverage
  (around the acquisition-bootstrap intro / `--beta`/`--source` flag
  documentation), and/or a cross-reference from the `new.sh` section to
  the existing "Codex CLI: `install.sh --harness codex`" section.
