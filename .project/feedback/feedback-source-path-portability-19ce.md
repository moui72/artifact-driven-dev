---
status: open
created: 2026-07-20
plan: null
---

# Feedback

## Bugs
- [ ] F001 install.sh records `Source-Path: $SCRIPT_DIR` (install.sh:416) — a machine-specific absolute path like `/Users/<user>/.ardd/source` — into the committed `.project/ardd-version.md`, leaking the developer's username into every consumer repo's git history (flagged by CodeRabbit on moui72/assisted-review#105). For the owned checkout it should record the portable `~/.ardd/source` form; every reader of the field (`scripts/source-resolve.sh`, `scripts/ardd-update-check.sh`) must expand a leading `~`/`$HOME` when parsing. Dev-mode paths outside `~` may stay absolute, but a path under `$HOME` should be recorded home-relative too.

## UX
- [ ] F002 /ardd-update (and/or install.sh on re-install) should detect a legacy machine-specific absolute `Source-Path` in a consumer's `.project/ardd-version.md`, rewrite it to the portable form, and — since the absolute path is already in the consumer's git history — advise the user that repairing history (e.g. rewrite/squash before the repo is shared, or accept the leak if already public) is their call, with a brief recommendation.
