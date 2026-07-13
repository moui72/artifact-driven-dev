# Visualizing artifacts as diagrams

`/ardd-diagram` turns artifacts into Mermaid diagrams and splices them
into a markdown file — `README.md` by default. GitHub renders Mermaid
fences natively, so there's no tooling to install.

## Making an artifact renderable

An artifact opts in by declaring `diagram_type` in its frontmatter — the
literal Mermaid diagram-type token it should be drawn as (`erDiagram`,
`sequenceDiagram`, `graph TD`, `classDiagram`, …). There is no fixed list
of renderable artifacts and no enumerated set of types;
[mermaid.js.org](https://mermaid.js.org) is the canonical source of valid
values, and a typo surfaces at render time, not at lint.

```yaml
# .project/artifacts/datamodel.md
diagram_type: erDiagram
render_hint: |
  One block per entity; derive relationships from FK refs; omit index detail.
render_target: docs/ARCHITECTURE.md   # optional; default README.md
render_section: Datamodel             # optional; default = capitalized stem
```

- `render_hint` carries domain emphasize/omit guidance, co-located with
  the artifact rather than baked into the skill.
- `render_target` matters when `README.md` must stay clean of raw Mermaid
  (e.g. an npm package page, whose renderer doesn't draw Mermaid fences) —
  the diagram still renders on GitHub in the target doc.

The standard `datamodel` / `infrastructure` / `ui` templates ship with a
`diagram_type` and `render_hint` already; other artifacts render only if
you add one.

## Rendering

```
/ardd-diagram datamodel      # one artifact
/ardd-diagram                # every artifact that declares a diagram_type
```

The diagram is generated from the artifact's content (judgment), then
spliced into the target **by script** (`upsert-section.sh` replaces
exactly the named `## Section`'s body and never touches any other line).

## Staleness

Each renderable artifact tracks `diagram_status`:

- `unrendered` — declared but never generated (how every renderable
  artifact starts)
- `current` — `/ardd-diagram` ran against the artifact's current content
- `stale` — the artifact changed since (stamped automatically by
  `/ardd-refine` and `/ardd-plan` when they edit a renderable artifact)

`/ardd-status` reports the state per artifact and names which to
re-render. Re-running `/ardd-diagram` is always safe — the upsert replaces
the section in place.
