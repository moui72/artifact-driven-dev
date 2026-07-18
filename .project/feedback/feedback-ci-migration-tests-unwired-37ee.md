---
status: planned      # open -> planned
created: 2026-07-18
plan: plan-status-view-mode-2026-07-18-ce1f.md
---

# Feedback

## Bugs
- [x] F001 Three regression test scripts exist on disk but are not wired
  into `.github/workflows/lint.yml`: `scripts/test-migration-critique-to-audit.sh`
  (migration 0006), `scripts/test-migration-sync-to-tracker.sh` (migration
  0007), and `scripts/test-migration-workflow-table.sh` (migration 0008).
  Migrations 0003–0005 each have a CI job mirroring the
  `test-migration-retag`/`test-migration-diagram-type` job pattern; these
  three never got their jobs added, so they silently don't run in CI even
  though `install.sh` applies these migrations against real consumer
  `.project/` state. Found via an agent survey of the repo's CI/prerelease
  surface area for coverage gaps.
