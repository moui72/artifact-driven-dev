---
name: ardd-render
tier: extension
description: Generate a Mermaid diagram from a renderable artifact and upsert it into a configurable destination (README.md by default).
---

# /ardd-render

Generate a Mermaid diagram from a project artifact and upsert it into a
target markdown file — `README.md` by default, or a per-artifact override
(see Render config). GitHub renders Mermaid code fences natively; a project
whose `README.md` must stay clean of raw Mermaid (e.g. an npm package page,
which doesn't render Mermaid fences) can point its diagrams at a
GitHub-only doc instead.

Usage: `/ardd-render <artifact>` where `<artifact>` is one of the supported types
listed below.

## Render config

| Argument | Artifact(s) to read | Diagram type | Default section |
|---|---|---|---|
| `datamodel` | `datamodel.md` | ERD (`erDiagram`) | `## Datamodel` |
| `infrastructure` | `infrastructure.md` | Container diagram (`graph TD`) | `## Infrastructure` |
| `ui` | `ui.md` | Component hierarchy (`graph TD`) | `## UI` |

**Destination is per-artifact and optional.** The default target file is
`README.md` and the default section is the "Default section" column above.
A renderable artifact may override either via its own frontmatter:

```yaml
# .project/artifacts/datamodel.md
render_target: docs/ARCHITECTURE.md   # optional; default README.md
render_section: Datamodel             # optional; default = the config-table section
```

`render_target` is a path relative to the project root; `render_section` is
the header text without the leading `##`. When both are absent, behavior is
exactly as before — `README.md` and the config-table section.

## Steps

1. **Parse the argument.**
   - If not in the render config table, list supported arguments and exit.
   - If not provided, run steps 2–7 for every row in the render config table
     in order, then report all diagrams written in a single summary.

2. **Read the artifact(s).** Load the primary artifact from the config table.
   Then check its frontmatter for a `related` field — if present, load each
   listed artifact from `.project/artifacts/` as supplementary context.
   Skip any related artifact that does not exist.

   While reading the primary artifact's frontmatter, also capture the
   optional `render_target` and `render_section` fields. Resolve the
   destination now, so steps 5–6 use it:
   - `render_target` → the target file (path relative to project root);
     absent → `README.md`.
   - `render_section` → the section header text (without `##`); absent →
     the config-table "Default section" for this argument (`Datamodel` /
     `Infrastructure` / `UI`).

3. **Generate the diagram** appropriate for the argument type:

   ### `datamodel` → ERD
   - Use Mermaid `erDiagram` syntax.
   - Include one block per entity with its fields and types.
   - Derive relationships from FK references in the artifact (e.g.,
     `patient_id FK → patients` becomes a `patients ||--o{ appointments : ""`
     relationship line).
   - Omit index and normalization detail — the diagram represents structure,
     not implementation.

   ### `ui` → Component hierarchy
   - Use Mermaid `graph TD` syntax.
   - Show each component as a node. Draw parent→child edges based on the
     component nesting described in the artifact.
   - Annotate leaf nodes that receive computed data (e.g., badges computed
     from encounter history) with a short edge label.
   - Omit state management detail — structure only.

   ### `infrastructure` → Container diagram
   - Use Mermaid `graph TD` syntax.
   - Show the major runtime components (UI, server/API layer, database, sync
     engine, external EHR APIs) as nodes.
   - Show data flow between components as directed edges with short labels.
   - Draw from both `infrastructure.md` and `adapters.md` if available —
     include one node per EHR adapter.
   - Keep it high-level: components and flows, not implementation detail.

4. **Wrap the diagram** in a Mermaid code fence:

   ````
   ```mermaid
   <diagram content>
   ```
   ````

5. **Ensure the resolved target file exists.** Using the target from step
   2 (`README.md` unless overridden): if it's missing, `mkdir -p` its parent
   directory and create the file empty (the upsert step appends the
   section).

6. **Upsert the section — script-performed** (constitution Principle II;
   generating the Mermaid content is judgment, splicing it into the target
   is not). Pipe the diagram block into:

   ```
   .claude/skills/ardd-scripts/upsert-section.sh <target file> "<Section>"
   ```

   where `<target file>` is the resolved target from step 2 (`README.md`
   unless overridden) and `<Section>` is the resolved section header without
   the `##` (e.g. `Datamodel`). It replaces exactly that section's body (or
   appends the section if absent) and never touches any other line.

7. **Mark it current**:
   `.claude/skills/ardd-scripts/ardd-state.sh stamp
   .project/artifacts/<name>.md diagram_status current`. If the bare form
   ran (all artifacts), do this for each rendered artifact.

8. **Report** in one sentence what was generated and where it was written.
