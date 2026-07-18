---
status: open      # open -> planned
created: 2026-07-18
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Bugs
- [ ] F001 `docs/reference/skills/ardd-status.md` never documents
  `/ardd-status --view` (the read-only side-door mode defined at
  `skills/ardd-status/SKILL.md:35` and steps around line 225) — the
  Usage section only shows bare `/ardd-status`, and USAGE.md's routing
  table has no row for it either, even though other read-only modes
  (`/ardd-plan --list`, `/ardd-implement --list`) are documented
  elsewhere. [artifacts: none — docs-only]
- [ ] F002 `docs/reference/skills/ardd-status.md` never mentions the
  register's `epic:` field or the by-epic Feature Backlog breakdown
  (`skills/ardd-status/SKILL.md:103-110,197-199`) — a docs-site reader
  has no way to discover epics exist from this page. [artifacts: none —
  docs-only]
