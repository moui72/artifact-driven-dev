---
name: ardd-diagram
tier: extension
description: "Generate a Mermaid diagram from any artifact that declares a diagram_type and upsert it into a configurable destination — README.md by default."
---

# /ardd-diagram

Generate a Mermaid diagram from a project artifact and upsert it into a
target markdown file — `README.md` by default, or a per-artifact override
(see Render config). GitHub renders Mermaid code fences natively; a project
whose `README.md` must stay clean of raw Mermaid (e.g. an npm package page,
which doesn't render Mermaid fences) can point its diagrams at a
GitHub-only doc instead.

Usage: `/ardd-diagram [<artifact>]` where `<artifact>` is the filename stem of
an artifact that declares a `diagram_type` (e.g. `datamodel`). With no
argument, every artifact that declares one is rendered.

## Render config

An artifact is **renderable when it declares `diagram_type`** in its
frontmatter. There is no fixed list of renderable artifacts and no enumerated
set of diagram types — any artifact opts in by declaring the Mermaid type it
should be drawn as. The full render-related frontmatter surface:

```yaml
# .project/artifacts/<name>.md
diagram_type: erDiagram        # a Mermaid diagram-type declaration — makes the artifact renderable
render_hint: |                 # optional; domain guidance for what to draw/omit
  One block per entity; derive relationships from FK refs; omit index detail.
render_target: docs/ARCHITECTURE.md   # optional; default README.md
render_section: Datamodel             # optional; default = capitalized artifact stem
diagram_status: unrendered            # required once diagram_type is present
```

- **`diagram_type`** is the *literal Mermaid diagram-type declaration* — the
  exact token Mermaid uses to open that diagram (`erDiagram`,
  `sequenceDiagram`, `classDiagram`, `stateDiagram-v2`, `graph TD` /
  `flowchart LR`, `gantt`, `pie`, `journey`, `mindmap`, `timeline`, …). It is
  used **verbatim as the first line** of the ```` ```mermaid ```` fence, so a
  flowchart value carries its own direction (`graph TD`) and needs no
  orientation guesswork. ArDD keeps no enumerated list of valid values and
  does not lint against one; the value must nonetheless be a real Mermaid type
  (not an English label like `entity-relationship`). A typo'd or unsupported
  value surfaces here, at render time, not at lint. See
  [mermaid.js.org](https://mermaid.js.org) for the supported types and their
  syntax.
- **`render_hint`** (optional) carries domain "emphasize / omit" guidance for
  what the diagram should show — co-located with the artifact rather than
  baked into this skill.
- **`render_target`** is a path relative to the project root; absent →
  `README.md`.
- **`render_section`** is the header text without the leading `##`; absent →
  the artifact's filename stem with its first letter capitalized (`datamodel`
  → `Datamodel`). Standard templates declare `render_section` explicitly where
  capitalization wouldn't produce the exact header (e.g. `UI`).

When `render_target` and `render_section` are both absent, a diagram lands in
`README.md` under the capitalized-stem section.

## Steps

1. **Resolve the target artifact(s).**
   - **Argument given** (`/ardd-diagram <name>`): read
     `.project/artifacts/<name>.md`. If it doesn't exist, or exists but does
     not declare `diagram_type`, report that it isn't renderable (only
     artifacts declaring `diagram_type` can be rendered) and exit.
   - **No argument**: glob `.project/artifacts/*.md` and select every artifact
     whose frontmatter declares a non-empty `diagram_type`. Run steps 2–7 for
     each in turn, then report all diagrams written in a single summary. If
     none declare `diagram_type`, say so and exit.

2. **Read the artifact and its render config.** Load the artifact. Capture
   from its frontmatter:
   - `diagram_type` — the Mermaid type declaration (used verbatim in step 4).
   - `render_hint` — optional generation guidance (used in step 3).
   - `render_target` → the target file (path relative to project root);
     absent → `README.md`.
   - `render_section` → the section header text (without `##`); absent → the
     artifact's filename stem with its first letter capitalized.

   Then check the frontmatter for a `related` field — if present, load each
   listed artifact from `.project/artifacts/` as supplementary context. Skip
   any related artifact that does not exist.

3. **Generate the diagram.** Produce a Mermaid diagram of the declared
   `diagram_type` from the artifact's content, shaped by `render_hint` if
   present. The hint states what to emphasize or omit for this artifact's
   domain; honor it. There is no per-type recipe here — draw the artifact as
   the type it declares, using idiomatic Mermaid for that type (see
   [mermaid.js.org](https://mermaid.js.org) for syntax). Keep the diagram
   high-level: structure and relationships, not implementation detail.

4. **Wrap the diagram** in a Mermaid code fence whose first line is the
   `diagram_type` value verbatim:

   ````
   ```mermaid
   <diagram_type>
   <diagram body>
   ```
   ````

5. **Ensure the resolved target file exists.** Using the target from step 2
   (`README.md` unless overridden): if it's missing, `mkdir -p` its parent
   directory and create the file empty (the upsert step appends the
   section). When the target didn't already exist, note that explicitly in
   step 8's report — e.g. "creating README.md (none existed)" — instead of
   silently originating it via the upsert path.

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
   ran (all renderable artifacts), do this for each rendered artifact.

8. **Report** in one sentence what was generated and where it was written —
   including the "creating <file> (none existed)" note from step 5 when it
   applies.
