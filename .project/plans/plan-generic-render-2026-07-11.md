---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: generic-render
created: 2026-07-11
features: []
surfaced-defects: []
---

# Plan — generic, artifact-driven `/ardd-render`

## Goal

Make `/ardd-render` fully artifact-driven: any artifact that declares a
`diagram_type` in its frontmatter is renderable, with the agent generating the
Mermaid from that type (+ an optional per-artifact hint) — retiring the closed
three-argument diagram-type table.

## Scope

**Included**
- Rewrite `skills/ardd-render/SKILL.md` to a generic, frontmatter-driven flow.
- New optional artifact frontmatter: `diagram_type` (a Mermaid type name) and
  `render_hint` (domain "emphasize/omit" guidance). Renderability becomes a
  *property* (declares `diagram_type`), not a fixed name-list.
- `lint-project.sh` schema for the new fields + retire `RENDERABLE_ARTIFACTS`;
  fixtures + regression test in the same commit.
- Standard artifact templates (`datamodel`/`infrastructure`/`ui`) declare
  their `diagram_type` + `render_hint` (carrying the old step-3 recipes).
- A migration so existing installs' artifacts keep rendering.
- User-facing docs pointing to the Mermaid reference (F002).

**Not included**
- No enumeration/registry of Mermaid diagram types or syntax anywhere — the
  spike is resolved *fully generic* (agent knowledge; see feedback F001).
- No change to `upsert-section.sh` or to `render_target`/`render_section`
  behavior (shipped in `plan-render-output-target`); this builds on them.
- `api.md`/`generic.md` templates do not ship a `diagram_type` — those
  artifacts render only if the author opts in by declaring one.

Addresses feedback F001 + F002
(`feedback-generic-configurable-render-di-1738.md`). Builds on the shipped
`render_target`/`render_section` work (does not supersede it — that plan is
implemented).

## Technical Approach

Extend the "artifact declares its own render config" pattern from *destination*
(shipped) to *diagram type*. The full frontmatter surface on a renderable
artifact:

```yaml
# .project/artifacts/<name>.md
diagram_type: erDiagram        # a Mermaid diagram-type declaration — makes the artifact renderable
render_hint: |                 # optional; domain guidance for what to draw/omit
  One block per entity; derive relationships from FK refs; omit index detail.
render_target: docs/ARCHITECTURE.md   # optional; default README.md (shipped)
render_section: Datamodel             # optional; default = capitalized artifact stem
diagram_status: unrendered            # existing; required once diagram_type is present
```

**What `diagram_type` holds (design decision, 2026-07-11).** It is the
*literal Mermaid diagram-type declaration* — the exact token Mermaid uses to
open that diagram (`erDiagram`, `sequenceDiagram`, `classDiagram`,
`stateDiagram-v2`, `graph TD`/`flowchart LR`, `gantt`, `pie`, `journey`,
`mindmap`, `timeline`, …). The render step uses it **verbatim as the first
line** of the ```` ```mermaid ```` fence, then generates the body. For
flowcharts the value carries the direction (`graph TD`), used as-is — no
agent guesswork about orientation; `render_hint` may still refine layout.
"Free-form" means only that ARDD keeps **no enumerated list** of these and
does not lint against one — the value must nonetheless be a *real Mermaid
type* (not an English label like `entity-relationship`). An invalid/typo'd
value surfaces at render (interactive), not at lint. mermaid.js.org is the
canonical reference for valid values — which is exactly what the user docs
(F002) point to.

Resolution / behavior:
- **Renderability = declares `diagram_type`.** `/ardd-render <name>` renders
  that artifact (error if it doesn't declare `diagram_type`); bare
  `/ardd-render` globs `.project/artifacts/*.md` and renders every artifact
  that declares one. The closed render-config table and `RENDERABLE_ARTIFACTS`
  name-list are deleted (Principle VII).
- **Generation is generic:** produce a Mermaid diagram of the declared
  `diagram_type` from the artifact content, shaped by `render_hint` if present.
  No per-type recipe in the skill; a one-line pointer to the Mermaid docs
  covers syntax. The three old domain recipes move into the standard
  templates' `render_hint`, co-located with the artifact.
- **`render_section` default changes:** with no config table, when
  `render_section` is absent it defaults to the artifact's filename stem with
  its first letter capitalized. The standard templates declare `render_section`
  explicitly (`Datamodel`/`Infrastructure`/`UI`) so headers stay exact (esp.
  `UI`, which capitalization wouldn't produce).
- **lint:** `diagram_type`/`render_hint` non-empty when present (mirrors
  `render_target`/`render_section`); require `diagram_status` when
  `diagram_type` is present; drop the `RENDERABLE_ARTIFACTS` name-list.

Accepted cost (feedback-resolved): a typo'd/unsupported `diagram_type` is
caught at render (an interactive agent step), not at lint — no type enum.

## Phase Breakdown

**Phase 1 — Skill rewrite (core, demonstrable).**
- `skills/ardd-render/SKILL.md`: replace the render-config table with the
  frontmatter contract above; step 1 resolves the target artifact(s) by
  `diagram_type` presence (named arg or glob); step 2 reads
  `diagram_type`/`render_hint` alongside the existing fields; step 3 becomes a
  single generic generation step (draw a `<diagram_type>` Mermaid diagram,
  guided by `render_hint`, pointer to mermaid.js.org); `render_section` default
  = capitalized stem. Update the frontmatter `description`.
- *Demo:* an artifact declaring `diagram_type: sequenceDiagram` renders a
  sequence diagram; one with no `diagram_type` is skipped/errors. (F001)

**Phase 2 — Lint schema (depends on P1 field names).**
- `scripts/lint-project.sh`: validate `diagram_type` and `render_hint`
  (non-empty when present); require `diagram_status` when `diagram_type` is
  present; remove `RENDERABLE_ARTIFACTS` and its name-list check.
- Update `tests/fixtures/{good,bad}-project` + `scripts/test-lint-project.sh`
  (test-first, same commit; adjust the finding count). (F001)

**Phase 3 — Standard artifact templates (depends on P1).**
- `templates/artifacts/{datamodel,infrastructure,ui}.md`: add `diagram_type`
  (`erDiagram` / `graph TD` / `graph TD`), `render_hint` (the retired step-3
  recipes, verbatim-ish), and explicit `render_section`. Leave
  `api.md`/`generic.md` without `diagram_type`. (F001)

**Phase 4 — Migration for existing installs (depends on P3 values).**
- `migrations/0005-artifact-diagram-type.sh` (modeled on
  `0002-diagram-status.sh`): for a target's existing
  `.project/artifacts/{datamodel,infrastructure,ui}.md` that lack
  `diagram_type`, insert the same `diagram_type`/`render_section` P3 uses, so
  upgrades keep rendering (Principle VII: the table is gone, carry projects
  forward). Idempotent; recorded in `.ardd-applied`. Add a regression test
  (throwaway target dir), CI job, pre-commit auto-discovery. (F001)

**Phase 5 — User docs (depends on P1).**
- `README.md` / `USAGE.md`: describe generic, `diagram_type`-driven render and
  **point users to the Mermaid docs (mermaid.js.org) for supported diagram
  types + syntax** (F002). Regenerate the skill-doc tables for the updated
  description. Keep `lint-docs.sh` green. (F001, F002)

## Complexity Tracking

| Deviation | Justification |
|---|---|
| New migration `0005-artifact-diagram-type.sh` | Principle VII (No Dead Architecture) mandates deleting the closed table rather than keeping it as a fallback; a migration is the established mechanism (precedent: `0001-diagram-stale`, `0002-diagram-status`) for carrying existing target projects forward so they don't silently stop rendering. The net change is a *simplification* (closed table + enum → one declared property). |

## Open Questions

1. **`render_section` default derivation.** Capitalized filename stem, with
   standard templates declaring `render_section` explicitly for exact headers.
   Confirm acceptable (non-standard artifact names get a best-effort header).
2. **`render_hint` lint validation** — non-empty when present (this plan) vs.
   left unvalidated as free prose. Leaning non-empty-when-present, cheap and
   consistent with the other optional fields.
3. **Migration scope** — only the three historically-renderable artifacts get
   auto-migrated; any custom artifact a project wants to render, it declares
   `diagram_type` by hand. Confirm that's the right boundary.
