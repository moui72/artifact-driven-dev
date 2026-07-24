---
status: open
created: 2026-07-24
plan: null
---

# Feedback

## Bugs
- [ ] F001 `.project/STATUS.md` carries a legacy `## Recent Releases` / `## Feature Backlog` structural section near the very bottom of the file (currently ~line 1897-1930 of a 2011-line file) — the oldest content, predating this file's current pure prepend-and-preserve `_Updated:` log convention. It reports stale, frozen counts (`2 backlogged`, `38 implemented`, naming `codex-second-harness-support` and `plan-preview-editor-option` as still-backlogged) that no longer match reality (both are `implemented` now) and is not maintained by any current `/ardd-status` run — every run since has only ever prepended a new `_Updated:` block above it, never touched this legacy tail. Found live via CodeRabbit review on PR #15 (`https://github.com/moui72/artifact-driven-dev/pull/15`), which correctly flagged it as an inconsistency in the file even after the reviewer initially (and reasonably) assumed no such live-looking section existed outside the `_Updated:` log. Fix direction: either delete the legacy `## Recent Releases`/`## Feature Backlog` section entirely (its content is now redundant with what the `_Updated:` log already covers, and STATUS.md's schema-of-record shape is the prose log, not this older structured-section format), or explicitly relabel it as historical/frozen (e.g. a one-line note dating it and stating it's no longer maintained) so a future reader — human or reviewer bot — doesn't mistake it for live state. Low priority, cosmetic — no functional impact, since `/ardd-status`'s actual current backlog counts always live in the newest `_Updated:` entry at the top of the file.
