# /ardd-diagram

_Tier: extension_

> Generate a Mermaid diagram from any artifact that declares a diagram_type and upsert it into a configurable destination — README.md by default (formerly ardd-render).

<!-- generated:end — the header above is generated from skills/ardd-diagram/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-diagram <artifact>    # render one artifact
/ardd-diagram               # render every artifact that declares a diagram_type
```

An artifact is renderable when it declares `diagram_type` in its
frontmatter — there is no fixed list of renderable artifacts and no
enumerated set of diagram types. GitHub renders Mermaid fences natively.

## Render config (artifact frontmatter)

```yaml
diagram_type: erDiagram               # the Mermaid type — declaring it makes the artifact renderable
render_hint: |                        # optional; what to emphasize/omit
  One block per entity; derive relationships from FK refs; omit index detail.
render_target: docs/ARCHITECTURE.md   # optional; default README.md
render_section: Datamodel             # optional; default = capitalized artifact stem
diagram_status: unrendered            # required once diagram_type is present
```

`diagram_type` is the **literal Mermaid diagram-type declaration**, used
verbatim as the first line of the fence (`erDiagram`, `sequenceDiagram`,
`graph TD`, `classDiagram`, …). ARDD keeps no list of valid values —
[mermaid.js.org](https://mermaid.js.org) is the canonical source; a typo'd
value surfaces at render time, not at lint. `render_target` keeps
`README.md` clean of raw Mermaid where it must stay so (e.g. an npm
package page).

## Reads

- The artifact and its render config; any `related:` artifacts as
  supplementary context

## Writes

- The resolved target file (`README.md` unless overridden) — the diagram
  is spliced in **script-performed** via `upsert-section.sh`, which
  replaces exactly the named section's body (or appends it) and never
  touches any other line. Generating the diagram content is judgment;
  splicing is not.
- The artifact's `diagram_status`, stamped `current`

## Staleness lifecycle

`unrendered` (declared but never generated) → `current` (this skill ran) →
`stale` (stamped by `/ardd-refine` and `/ardd-plan` whenever they edit a
renderable artifact). `/ardd-status` reports each renderable artifact's
state and which to re-render.

## Related

- `/ardd-status` — surfaces stale/unrendered diagrams
- `/ardd-refine` — the edits that mark a diagram stale
