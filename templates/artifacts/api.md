---
name: api
status: draft
last_updated: YYYY-MM-DD
---

# API

## Overview

[Describe the API layer: framework, transport (REST, tRPC, GraphQL), how the
UI consumes it, and any auth approach. Note any auth/security shortcut under
Production Annotations below, not inline here.]

## Dev Setup

| Service | Port | Command |
|---|---|---|
| API server | `[port]` | `[command]` |
| Frontend | `[port]` | `[command]` |
| Both | — | `[command]` (via `concurrently` or similar) |

## Router / Endpoint Structure

[Describe the top-level structure of the API surface. For tRPC, show the
router tree. For REST, list resource paths. For GraphQL, show root types.]

## Procedures / Endpoints

[One subsection per procedure or resource. Include:]

### `[procedure or path]`

**Input**: [Zod schema, JSON body shape, or query params]

**Output**: [TypeScript type or JSON shape]

**Logic**: [Any non-trivial computation this procedure performs — e.g.,
recommended action resolution, aggregation, joins]

## Shared Types

[Describe how types are shared between server and client — e.g., exported
AppRouter type for tRPC, generated OpenAPI client, shared types package.]

## File Structure

```
[Sketch the relevant directory layout]
```

## Production Annotations

[List known shortcuts or gaps with notes on what the production approach
would be — per the constitution's Development Workflow convention, this is
the only place in this artifact such notes belong; don't scatter them inline
in other sections.]

- **[Shortcut]**: [What it does] — in production, [correct approach].
