# /ardd-render

Generate a Mermaid diagram from a project artifact and upsert it into
`README.md`. GitHub renders Mermaid code fences natively.

Usage: `/render <artifact>` where `<artifact>` is one of the supported types
listed below.

## Render config

| Argument | Artifact(s) to read | Diagram type | README section |
|---|---|---|---|
| `datamodel` | `datamodel.md` | ERD (`erDiagram`) | `## Datamodel` |
| `infrastructure` | `infrastructure.md` | Container diagram (`graph TD`) | `## Infrastructure` |
| `ui` | `ui.md` | Component hierarchy (`graph TD`) | `## UI` |

## Steps

1. **Parse the argument.**
   - If not in the render config table, list supported arguments and exit.
   - If not provided, run steps 2–7 for every row in the render config table
     in order, then report all diagrams written in a single summary.

2. **Read the artifact(s).** Load the primary artifact from the config table.
   Then check its frontmatter for a `related` field — if present, load each
   listed artifact from `.project/artifacts/` as supplementary context.
   Skip any related artifact that does not exist.

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

5. **Read `README.md`** from the project root. If it does not exist, create it
   with only the target section and the diagram.

6. **Upsert the section:**
   - Search for the exact target header (e.g., `## Datamodel`) in `README.md`.
   - **If found**: replace everything between that header line and the next
     `##`-level header (or end of file) with a blank line followed by the
     diagram block and a trailing blank line.
   - **If not found**: append the target header, a blank line, and the diagram
     block to the end of the file.

7. **Write `README.md`** back to the project root.

8. **Clear the stale flag.** In the artifact's frontmatter, set `diagram_stale: false`.
   Write the updated artifact back to `.project/artifacts/<name>.md`.
   If the bare form ran (all artifacts), do this for each rendered artifact.

9. **Report** in one sentence what was generated and where it was written.
