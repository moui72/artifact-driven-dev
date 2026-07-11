---
name: datamodel
status: draft
last_updated: YYYY-MM-DD
diagram_status: unrendered
diagram_type: erDiagram
render_section: Datamodel
render_hint: |
  One block per entity with its fields and types. Derive relationships from
  FK references (e.g. patient_id FK -> patients). Omit index and
  normalization detail — the diagram represents structure, not implementation.
---

# Data Model

## Overview

[Describe the canonical data model: purpose, source of truth, key design
decisions.]

## Entities

### [Entity 1]

| Field | Type | Notes |
|-------|------|-------|
| id | string | |
| [field] | [type] | |

### [Entity 2]

| Field | Type | Notes |
|-------|------|-------|
| id | string | |
| [field] | [type] | |

## Normalization Rules

[Describe rules for normalizing data from source systems into the canonical
model: date formats, ID schemes, enum values, string parsing, etc.]

## Indexes

[List query patterns that require indexes and the indexes that support them.]

## Production Annotations

[List known shortcuts or gaps with notes on what the production approach
would be — per the constitution's Development Workflow convention, this is
the only place in this artifact such notes belong; don't scatter them inline
in other sections.]

- **[Shortcut]**: [What it does] — in production, [correct approach].
