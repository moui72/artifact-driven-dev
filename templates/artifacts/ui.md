---
name: ui
status: draft
last_updated: YYYY-MM-DD
diagram_status: unrendered
diagram_type: graph TD
render_section: UI
render_hint: |
  Each component as a node, with parent -> child edges based on the component
  nesting described here. Annotate leaf nodes that receive computed data with
  a short edge label. Omit state management detail — structure only.
---

# UI

## Overview

[Describe the UI: purpose, target user, key interactions, technology choices.]

## [View 1]

[Layout, components, interactions.]

## [View 2]

[Layout, components, interactions.]

## States

- **Loading**: [Description]
- **Empty**: [Description]
- **Error**: [Description]

## Production Annotations

[List known shortcuts or gaps with notes on what the production approach
would be — per the constitution's Development Workflow convention, this is
the only place in this artifact such notes belong; don't scatter them inline
in other sections (e.g. in States above).]

- **[Shortcut]**: [What it does] — in production, [correct approach].
