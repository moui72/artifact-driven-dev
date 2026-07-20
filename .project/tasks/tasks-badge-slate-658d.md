---
plan: plan-badge-slate-2026-07-20-e059.md
generated: 2026-07-20
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Make the workflow template real (ff0c)

- [x] T001 Create `scripts/lint-templates-yaml.sh` (source-side, POSIX
  sh): YAML-parse every `templates/*.yml` and `.github/workflows/*.yml`
  via `python3 -c 'import sys,yaml; yaml.safe_load(open(sys.argv[1]))'`,
  reporting each failing file with the parser error; when `python3` or
  PyYAML is unavailable, print a clear skip notice and exit 0 (CI always
  has it). Add `scripts/test-lint-templates-yaml.sh` (fixture repos in a
  temp dir: one valid workflow, one with a column-0 heredoc inside a
  `run: |` block) and a CI job in `.github/workflows/lint.yml` — script,
  test, and CI wiring in the same commit (house rule for new
  deterministic checks). Test-first checkpoint: with the script in
  place, running it against the tree must go RED on the current broken
  `templates/ardd-badge-workflow.yml` before T002 fixes it.
- [x] T002 Fix `templates/ardd-badge-workflow.yml` (addresses ff0c
  F001/F003/F004, all three verified in the field by
  moui72/assisted-review's corrected copy): indent the badge-JSON
  heredoc body AND its `JSON` terminator to the enclosing `run: |` block
  scalar's indentation (YAML strips the common indent before the shell
  sees the script, so the emitted JSON is unchanged); add `branches:
  [main]` to the `push` trigger and a `workflow_dispatch` trigger;
  append `[skip ci]` to the sync commit message. Verify:
  `scripts/lint-templates-yaml.sh` goes green, and extract the step's
  `run` script and execute it against a fixture
  `.project/ardd-version.md` confirming the emitted JSON is unchanged in
  content.

## Phase 2: Centralize appearance in the JSON

- [x] T003 Create `templates/ardd-icon.svg`: a deliberately simple,
  single-colour (`currentColor` or plain black fill) geometric mark
  legible at 14px — no gradients, no multiple fills, no fine detail.
  Keep the file small (aim well under 2KB). Add a one-line comment in
  the SVG naming it the source of truth the badge workflow inlines.
- [ ] T004 Publish the brand colour and wire both new fields into the
  workflow: state the canonical brand hex `#7C3AED` in
  `docs/reference/configuration.md` (or the page the badge docs live
  on) as "the ArDD brand colour"; then edit
  `templates/ardd-badge-workflow.yml` so the generated
  `.github/badges/ardd-version.json` gains `"labelColor": "#7C3AED"`
  (brand, left half — channel signal stays in `color`) and `"logoSvg":
  <contents of the repo's templates/ardd-icon.svg>` inlined at
  generation time from the icon file shipped into the consumer repo by
  install.sh — read the file and embed it (e.g. `jq --rawfile` or a
  POSIX-safe equivalent), NEVER escaped SVG pasted into the heredoc.
  Note install.sh must copy `templates/ardd-icon.svg` alongside the
  workflow when `ARDD_VERSION_BADGE=1` — extend the badge section
  accordingly. Verify with `lint-templates-yaml.sh` green + the
  extracted-run-script check emitting valid JSON containing both new
  fields.
- [ ] T005 Extend `scripts/test-install-version-badge.sh` for the new
  behavior: opted-in installs receive `templates/ardd-icon.svg` (at the
  path T004's workflow reads), and the seeded/generated badge JSON
  carries `labelColor` and `logoSvg`. Red-first where practical; suite
  green before completing.

## Phase 3: README-side shapes and caveats

- [ ] T006 Restructure `templates/badge.md` around three shapes: keep
  static-only as today; add the **split badge** — one shields endpoint
  badge whose JSON supplies both halves ("built with ArDD │ vX.Y.Z") —
  as the recommended default for `ARDD_VERSION_BADGE=1` repos; keep the
  existing two-badge pair for separated marks. Add the renderer caveat
  note (addresses bf75 F001): endpoint-style readers (shields.io
  `/endpoint`) consume `label`/`message`/`color`/`labelColor`/`logoSvg`
  from the JSON, but dynamic-JSON readers (e.g. shieldcn
  `dynamic/json`) take only the query-selected field — label, colour,
  and logo must ride the URL there, using the pre-encoded
  `data:image/svg+xml;base64,...` form of the icon (document how to
  produce it: `base64 < templates/ardd-icon.svg`).
- [ ] T007 Update install.sh's `ARDD_VERSION_BADGE=1` printed snippet to
  the split-badge shape (the pair remains documented in `badge.md` for
  those who want it), keeping the existing OWNER/REPO/BRANCH
  coordinate-fill, reprint-guard, misdirected-badge advisory, and
  private-repo caveat behaviors intact; update the badge-related docs
  pages (`docs/reference/configuration.md`, USAGE routing if any) to
  match. Extend/adjust `test-install-version-badge.sh` assertions for
  the snippet change; full suite + `lint-docs.sh` green.
