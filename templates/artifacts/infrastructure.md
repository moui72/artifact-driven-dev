---
name: infrastructure
status: draft
last_updated: YYYY-MM-DD
diagram_status: unrendered
diagram_type: graph TD
render_section: Infrastructure
render_hint: |
  Major runtime components as nodes (UI, server/API layer, database, sync
  engine, external APIs). Draw data flow between them as directed edges with
  short labels. Include one node per adapter if an adapters artifact exists.
  Keep it high-level: components and flows, not implementation detail.
---

# Infrastructure

## Overview

[Describe the system's infrastructure: storage choice, external integrations,
sync strategy, rationale for key decisions.]

## [Component 1]

[Description, approach, rationale.]

## [Component 2]

[Description, approach, rationale.]

## Production Annotations

[List known shortcuts or gaps with notes on what the production approach
would be — per the constitution's Development Workflow convention, this is
the only place in this artifact such notes belong; don't scatter them inline
in other sections.]

- **[Shortcut]**: [What it does] — in production, [correct approach].
