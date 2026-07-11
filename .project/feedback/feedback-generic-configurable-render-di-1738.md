---
status: open      # open -> planned
created: 2026-07-11
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Reconsidered
- [ ] F001 Make `/ardd-render` generic and fully artifact-driven. Today the
  diagram *kind* is a fixed, closed 1:1 lookup table hardcoded in
  `skills/ardd-render/SKILL.md` (`datamodel`→ERD, `infrastructure`→container,
  `ui`→component hierarchy), keyed by the argument name — the artifact's
  content only fills the diagram, never decides its type, and any artifact
  without a table row (`api.md`, adapters, custom artifacts) simply can't
  render. Reconsidered: render should instead **look at the frontmatter of
  every artifact**, and each artifact should **declare its own diagram type
  and Mermaid syntax** in its frontmatter, rather than the closed
  three-argument table. This is the natural continuation of the just-shipped
  `render_target`/`render_section` per-artifact frontmatter (issue #2) —
  extend the same "artifact declares its own render config" pattern from
  *destination* to *diagram type*. Bare `/ardd-render` would then iterate
  every renderable artifact (those carrying the frontmatter), not just three
  fixed rows.

  **Spike to resolve before/at planning (the crux):** how much needs to be
  *defined* vs. relied on from the agent's own knowledge?
  - Do diagram *types* need to be enumerated/registered anywhere (a schema,
    an enum in `lint-project.sh`, a per-type generation recipe like the
    current step 3), or does the agent just know how to draw "an ERD" / "a
    sequence diagram" / "a state diagram" from a type name the artifact
    declares?
  - Do Mermaid *syntaxes* need to be enumerated in the skill, or is pointing
    the agent at the Mermaid docs (or trusting its Mermaid knowledge)
    sufficient and more maintainable?
  - Trade-off to weigh: determinism/consistency (enumerated recipes, lintable
    types) vs. genericity/low-maintenance (agent-knowledge, open-ended types).
    Resolve which side wins — or a hybrid (declared type is free-form, but an
    optional per-artifact recipe/hint in frontmatter refines it) — before
    committing the design.

  Location: `skills/ardd-render/SKILL.md` (render config table + steps 1–3);
  interacts with `lint-project.sh` (which fields become schema) and the
  `RENDERABLE_ARTIFACTS` enum. Untagged — no `.project/artifacts/` file
  records render's diagram-type config; it lives in the skill.
