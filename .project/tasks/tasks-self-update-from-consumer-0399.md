---
plan: plan-self-update-from-consumer-2026-07-06.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-07
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

Testing paradigm (constitution Principle V, test-first): script tasks
(T001, T002) extend/add fixture tests first, confirmed red, then
implement. Skill/doc tasks are the stated exception. Mutations via
`.claude/skills/ardd-scripts/ardd-state.sh`.

## Phase 1: Record the source path

- [x] T001 install.sh writes a machine-readable source-path line into
  the target's `.project/ardd-version.md`: a line of the exact form
  `Source-Path: /absolute/path/to/artifact-driven-dev` (resolved
  SCRIPT_DIR), placed on its own line after the `_Source: ..._` line.
  Idempotent — a reinstall rewrites the existing line, never
  duplicates it (the whole file is regenerated each install, so this
  falls out naturally; assert it anyway). Test-first: extend the
  install fixture test (red: no Source-Path line) asserting the line
  exists, is absolute, and appears exactly once after two installs.

## Phase 2: Deterministic update check

- [x] T002 `scripts/ardd-update-check.sh [target-dir]` (target-side):
  greps `Source-Path:` and the installed commit out of
  `.project/ardd-version.md`; prints exactly one line —
  `no-version-file` (exit 0) when the file is absent;
  `source-missing path=<p>` when the recorded path doesn't exist OR
  exists but isn't an ARDD source checkout (no install.sh + skills/
  there — the moved-checkout open question resolves to the same
  outcome with the same reason format);
  `up-to-date commit=<x>` when installed commit == `git -C <source>
  rev-parse --short HEAD`;
  `behind installed=<x> source-tip=<y>` otherwise. Local git only, no
  network. Test-first (fixture temp repos for all four outcomes, red),
  CI job, ship via install.sh copy + chmod (`.worktreeinclude` already
  covers ardd-scripts), extend the install test to assert it arrives.
- [ ] T003 Wire visibility into `/ardd-analyze`: its SKILL.md step 1
  additionally runs `ardd-update-check.sh` (present-or-fallback path
  rule) and, on `behind`, the report and STATUS.md gain one line —
  "ARDD update available: installed <x>, source at <y> — run
  /ardd-update." On `source-missing`, a gentler line recommending
  /ardd-update to re-record the path. `no-version-file`/`up-to-date`
  stay silent. lint-project.sh deliberately untouched (stays
  offline-pure). Doc-only skill edit; lint-docs green.

## Phase 3: /ardd-update skill

- [ ] T004 New extension skill `skills/ardd-update/SKILL.md` with
  frontmatter (`name: ardd-update`, `tier: extension`, one-line
  `description:`). Steps: (1) read `Source-Path:` from
  .project/ardd-version.md — if absent or not a valid ARDD checkout,
  ask the user for the path (the reinstall re-records it via
  install.sh); (2) run ardd-update-check.sh and report standing;
  (3) if the source has a remote and a clean tree, OFFER `git -C
  <source> pull` (never without confirmation; on a dirty source tree
  skip the offer and surface the dirtiness instead; never push);
  (4) run `<source>/install.sh <this repo>` and relay its FULL output —
  migrations applied and install-time suggestions (badge, gitignore)
  must reach the user verbatim, closing the invisible-offer gap;
  (5) report what changed (old commit → new commit, migrations,
  suggestions) and run /ardd-analyze as the terminal handoff.
- [ ] T005 Register the new skill: add `ardd-update` to
  gen-skill-docs.sh's ORDER_extension list, run the generator
  (README + templates/WORKFLOW.md regenerate; drift check green);
  verify lint-docs green (README/USAGE references now resolve since
  the skill exists); install.sh picks the skill up automatically via
  its skills/*/ glob — confirm by extending no test (the install test
  already asserts skill arrival generically) unless it doesn't, in
  which case add the assertion.
- [ ] T006 [parallel] Doc alignment: guides/continuing.md's periodic-
  hygiene bullet becomes "run /ardd-update after upgrading ARDD (or
  when /ardd-analyze reports an update available)"; README's Install
  section gains one line: updating from inside a consumer =
  /ardd-update. Doc-only; lint-docs + gen-skill-docs --check green.
