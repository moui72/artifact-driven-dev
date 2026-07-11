---
plan: plan-render-output-target-2026-07-10.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-10
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Skill wiring

- [ ] T001 Update `skills/ardd-render/SKILL.md` so the render destination is
  read from the artifact's own frontmatter instead of hardcoded `README.md`.
  In step 2 (already loads the artifact) capture optional `render_target`
  (path, relative to project root) and `render_section` (header text without
  `##`). Add resolution rules that preserve current behavior exactly when
  both are absent: `render_target` absent → `README.md`; `render_section`
  absent → the config-table section for that argument
  (`Datamodel`/`Infrastructure`/`UI`). Generalize step 5 from "ensure
  `README.md` exists" to: `mkdir -p` the resolved target's parent and create
  the resolved target empty if missing. In step 6 pass the resolved
  `<file>` and `<section>` to `upsert-section.sh` (script unchanged — it
  already parameterizes both). Reframe the config table's "README section"
  column as "Default section" and note the default target is `README.md`.
  Update the skill's frontmatter `description` line so it no longer says
  "into README.md". Verify: an artifact with `render_target:
  docs/ARCHITECTURE.md` would write there; one without it still writes
  `README.md` unchanged. (F001)

## Phase 2: Schema + lint

- [ ] T002 [parallel] Extend `scripts/lint-project.sh` to accept the two new
  optional artifact-frontmatter fields from T001: `render_target` (non-empty
  string; reject empty/whitespace-only) and `render_section` (non-empty
  string). Unknown-but-valid values pass; malformed (empty) values fail with
  a clear message. In the SAME commit (repo rule: no unverified validator),
  add coverage: give an artifact in `tests/fixtures/good-project` a valid
  `render_target`/`render_section`, add a `bad-project` case with an empty
  value, and extend `scripts/test-lint-project.sh` to assert good-project
  passes and bad-project fails. Run `scripts/test-lint-project.sh` — it must
  pass. (Depends on T001's field names.) (F001)

## Phase 3: Doc sync

- [ ] T003 [parallel] Update `README.md` and `USAGE.md` where they describe
  `/ardd-render` so they state the diagram destination is configurable
  per-artifact via `render_target`/`render_section`, with `README.md` the
  default when absent. Keep the "GitHub renders Mermaid natively" framing.
  Run `scripts/lint-docs.sh` — it must stay green (only references real skill
  names). (Depends on T001's field names.) (F001)
