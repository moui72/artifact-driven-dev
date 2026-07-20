---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: badge-slate
created: 2026-07-20
features: [badge-split-variant, badge-brand-color-in-json, badge-icon-logosvg]
surfaced-defects: []
---

# Plan: Badge slate — workflow fix + centralized badge appearance

## Goal

Ship a badge workflow template that actually runs (valid YAML, safe
triggers) and turn the generated `ardd-version.json` into the central
carrier of ArDD badge appearance — version, brand colour, and mark — so
consumer repos get brand updates from the sync workflow instead of
hand-maintained README snippets.

## Scope

**In:** the verified YAML fix for `templates/ardd-badge-workflow.yml`
plus trigger hardening and `[skip ci]` (feedback `ff0c` F001/F003/F004);
a deterministic YAML-parse check over shipped `*.yml` templates (`ff0c`
F002 — CI job + regression test in the same commit, per the house rule
for new deterministic checks); the renderer caveat note in `badge.md`
(`bf75` F001); the split-badge third variant (`badge-split-variant`);
the published brand colour emitted as `labelColor`
(`badge-brand-color-in-json`); and the mark shipped as
`templates/ardd-icon.svg`, inlined by the workflow as `logoSvg` with a
documented base64-URL form (`badge-icon-logosvg`).

**Out:** simple-icons registration (`namedLogo`) — later nice-to-have
with notability requirements, not a dependency; in-place README
rewriting in consumers (unchanged never-edit posture); any change to the
sync workflow's push/commit model beyond the trigger filter.

## Technical Approach

All three features ride the same leverage point: the workflow already
regenerates `.github/badges/ardd-version.json` per repo, and shields'
endpoint schema accepts `label`, `message`, `color`, `labelColor`, and
`logoSvg` in that JSON — so appearance becomes centrally propagated
data, not per-README markup.

- **Workflow template fix first** (everything else edits the same file):
  indent the heredoc body *and* terminator to the `run: |` block
  scalar's indentation (YAML strips the common indent before the shell
  sees it — fix already verified in the field, with a corrected copy in
  moui72/assisted-review to check against); add `branches: [main]` and
  `workflow_dispatch` to the trigger; append `[skip ci]` to the sync
  commit message.
- **Deterministic template lint:** a source-side script parsing every
  `templates/*.yml` (and `.github/workflows/*.yml`) — YAML parse via
  `python3 -c 'yaml.safe_load'` with a clean skip-with-notice when
  `python3`/PyYAML is unavailable locally (CI always has it). Source-side
  because it checks this repo's shipped files, not a target's
  `.project/`. Script + fixture regression test + CI job land together.
- **Badge JSON gains the brand:** the workflow writes `labelColor:
  <brand hex>` (brand, left half) alongside the existing channel-driven
  `color` (status, right half), and inlines `templates/ardd-icon.svg` as
  `logoSvg` at generation time — never escaped SVG pasted into the
  heredoc; the icon file is the source of truth, read and embedded by
  the script (e.g. via `jq --rawfile` or equivalent POSIX-safe
  technique decided at implementation).
- **`badge.md` restructures around three shapes:** static-only (as
  today), the new **split badge** ("built with ArDD │ vX.Y.Z", one slot,
  same JSON) as the recommended default for opted-in repos, and the
  existing two-badge pair kept for separated marks; plus the renderer
  caveat note — endpoint readers consume the JSON's label/colour,
  dynamic-JSON readers (shieldcn) take only the query-selected field, so
  label/colour/logo must ride the URL there (the documented base64
  `data:` form of the icon exists for exactly this case).
- **Brand colour value:** proposed `#7C3AED` (a violet in the family
  ArDD's docs site already leans on) — recorded in `docs/` as the
  canonical brand hex; trivially changeable later precisely because the
  workflow propagates it. The mark: a deliberately simple single-colour
  geometric monogram (legible at 14px), drawn fresh; the
  assisted-review working versions are a reference if offered, not a
  dependency.

Phase 1 is test-first where deterministic (the YAML lint); template and
docs edits are prose/template work with the lint as their check.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

**Phase 1 — Make the workflow template real (ff0c).**
- YAML-parse lint script + fixture test + CI job (test-first: red on the
  current broken template).
- Fix the heredoc indentation; add `branches: [main]` +
  `workflow_dispatch`; `[skip ci]` on the sync commit. Lint goes green.

**Phase 2 — Centralize appearance in the JSON (after Phase 1).**
- Publish the brand hex in docs; workflow emits `labelColor`.
- Create `templates/ardd-icon.svg`; workflow inlines it as `logoSvg`;
  document the base64 URL form.
- Extend the install badge test for the new JSON fields.

**Phase 3 — README-side shapes and caveats (after Phase 2).**
- `badge.md`: add the split variant (recommended default), keep the
  pair, add the renderer caveat note (bf75).
- install.sh's printed snippet + docs pages updated to match.

## Open Questions

- Brand hex final value: `#7C3AED` is a proposal — confirm or replace at
  implementation (one-line change; the propagation mechanism is the
  point).
- Should the split variant become the *printed default* in install.sh's
  opted-in path, or just the first-listed option in `badge.md`? Plan
  assumes printed default; cheap to flip.
