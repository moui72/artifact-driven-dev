---
plan: plan-generic-render-2026-07-11.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-11
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Skill rewrite

- [x] T001 Rewrite `skills/ardd-render/SKILL.md` to be generic and
  frontmatter-driven. Replace the closed render-config table with the
  `diagram_type`/`render_hint` contract: an artifact is renderable iff it
  declares `diagram_type` (the literal Mermaid diagram-type declaration —
  e.g. `erDiagram`, `sequenceDiagram`, `graph TD` — used verbatim as the
  first line of the ```mermaid fence). Step 1: `/ardd-render <name>` targets
  that artifact (error if it lacks `diagram_type`); bare `/ardd-render` globs
  `.project/artifacts/*.md` and renders each that declares one. Step 2: read
  `diagram_type` + optional `render_hint` alongside the existing
  `render_target`/`render_section`. Step 3: collapse the three per-type
  recipes into one generic generation step (emit a `<diagram_type>` diagram
  from the artifact content, shaped by `render_hint`; one-line pointer to
  mermaid.js.org for syntax). `render_section` default becomes the artifact
  filename stem with its first letter capitalized. Update the frontmatter
  `description`, then run `scripts/gen-skill-docs.sh` to regenerate the
  README/WORKFLOW skill tables in this same commit (the description change
  otherwise fails `lint-docs.sh` under the pre-commit hook). Verify: an
  artifact with `diagram_type: sequenceDiagram` would render a sequence
  diagram; one without `diagram_type` is skipped/errors. (F001)

## Phase 2: Lint schema

- [ ] T002 [parallel] Extend `scripts/lint-project.sh` for the generic model:
  validate `diagram_type` and `render_hint` as non-empty when present
  (mirroring the `render_target`/`render_section` checks); require
  `diagram_status` when `diagram_type` is present; remove the
  `RENDERABLE_ARTIFACTS` name-list and its name-keyed `diagram_status`
  requirement. In the SAME commit (Principle V, test-first): update
  `tests/fixtures/good-project` (give a renderable artifact `diagram_type`)
  and `tests/fixtures/bad-project` (an artifact with `diagram_type` but no
  `diagram_status`, and an empty `diagram_type`), extend
  `scripts/test-lint-project.sh` with the new assertions and adjust
  `EXPECTED_BAD_FINDINGS`, and confirm red-then-green. Run
  `scripts/test-lint-project.sh`. Depends on T001's field names. (F001)

## Phase 3: Standard artifact templates

- [x] T003 [parallel] Add the generic render frontmatter to
  `templates/artifacts/{datamodel,infrastructure,ui}.md`: `diagram_type`
  (`erDiagram`, `graph TD`, `graph TD` respectively), an explicit
  `render_section` (`Datamodel`, `Infrastructure`, `UI`), and a `render_hint`
  carrying that type's domain guidance from the retired step-3 recipes
  (datamodel: one block per entity, FK→relationships, omit indexes;
  infrastructure: major runtime components + labeled data-flow edges, include
  adapters, stay high-level; ui: component nodes, parent→child edges,
  annotate computed-data leaves, omit state detail). Leave
  `templates/artifacts/{api,generic}.md` without `diagram_type` (author opts
  in). Depends on T001. (F001)

## Phase 4: Migration for existing installs

- [ ] T004 Create `migrations/0005-artifact-diagram-type.sh` (modeled on
  `migrations/0002-diagram-status.sh`): for a target project's existing
  `.project/artifacts/{datamodel,infrastructure,ui}.md` that lack a
  `diagram_type` field, insert the same `diagram_type` + `render_section`
  values T003 uses, so upgrades keep rendering (Principle VII — the closed
  table is gone). Idempotent (no-op if `diagram_type` already present or the
  artifact is absent); recorded in the target's `.ardd-applied` by the
  existing migration runner. In the same commit add
  `scripts/test-migration-diagram-type.sh` (throwaway target dir: artifact
  missing the field → added; artifact already having it → untouched; absent
  artifact → skipped) and a CI job in `.github/workflows/lint.yml` (the
  pre-commit hook glob-discovers the new `test-*.sh`). Run it. Depends on
  T003's exact values. (F001)

## Phase 5: User docs

- [ ] T005 [parallel] Update `README.md` and `USAGE.md` so the `/ardd-render`
  description reflects the generic, `diagram_type`-driven model, and **point
  users to the Mermaid docs (mermaid.js.org) for the supported diagram types
  and their syntax** — the canonical source of valid `diagram_type` values
  now that ARDD keeps no enumerated list (F002). Cover that an artifact
  becomes renderable by declaring `diagram_type` in its frontmatter. (The
  auto-generated skill tables were regenerated in T001; this task is the
  hand-written render prose.) Run `scripts/lint-docs.sh` — it must stay
  green. Depends on T001. (F001, F002)
