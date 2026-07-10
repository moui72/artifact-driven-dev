---
status: open      # open -> planned
created: 2026-07-10
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Reconsidered
- [ ] F001 `/ardd-render` hardcodes `README.md` as the upsert target for
  every diagram type (`skills/ardd-render/SKILL.md` step 6 pipes generated
  Mermaid into `upsert-section.sh README.md "<Section>"` with no override).
  The prior decision — one fixed render target — no longer holds:
  npm-published projects (motivating case: `assisted-review`) render their
  README on npm, whose markdown renderer doesn't render Mermaid fences, so
  diagrams show up as broken/raw code blocks to npm consumers. The render
  destination (file + section) should be configurable per-project — e.g. a
  project-level config entry per render argument (datamodel / infrastructure
  / ui) — so a project can point diagrams at a GitHub-only doc (e.g.
  `docs/ARCHITECTURE.md`) while keeping `README.md` npm-clean. Source:
  GitHub issue #2 (imported via `/ardd-sync`, `ardd-import` label).
