---
plan: plan-ardd-state-determinism-2026-07-06.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-06
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

Testing paradigm (constitution Principle V, test-first): every script
task writes its fixture-based regression test FIRST and confirms it
fails (or runs the check against a deliberately-bad fixture) before the
implementation is considered complete. Doc-only tasks are the stated
exception. New test scripts are auto-enforced by the glob-based
pre-commit hook; each task adding a script also adds its CI job in the
same commit.

## Phase 1: Governance and format decision (sequential — both edit constitution.md)

- [x] T001 [artifacts: constitution] Record the per-feature-files
  decision in the constitution (standing decision under Quality
  Standards): `.project/features/<slug>.md` with frontmatter replaces
  the single-file `· `-separated features.md register. Specify the
  frontmatter schema in the same note — required: `slug`, `status`
  (backlogged|planned|tasked|implemented), `logged` (YYYY-MM-DD);
  optional: `plan`, `tasks` (filenames), `gh_issue` (number); body:
  one-sentence description + optional `Why:` line. This schema is the
  input contract for T006, T008, and T009. Doc task — no test.
- [x] T002 [artifacts: constitution] Amend the constitution, v1.1.0 →
  v1.2.0 (one MINOR bump), Sync Impact Report prepended, footer +
  frontmatter `last_updated` updated: (1) extend Principle II to state
  *mutations* — deterministic transitions that are pure functions of
  file state get scripts; prose decides when, scripts write; (2) add a
  behavioral-test tier to Quality Standards — fixture-project smoke
  scenarios running skills headlessly, asserting on file outcomes,
  required for state-mutating skill paths. Doc task — no test.

## Phase 2: ardd-state.sh (after Phase 1; subcommand tasks are sequential in one growing script + test file)

- [x] T003 Scaffold `scripts/ardd-state.sh` (POSIX sh, target-side) with
  subcommand dispatch + usage, and `scripts/test-ardd-state.sh` with the
  fixture harness (temp-dir project skeleton; good + bad cases per
  subcommand). Write the test harness first with one failing placeholder
  case; add the CI job to `.github/workflows/lint.yml` in the same
  commit (pre-commit hook picks the test up by glob automatically).
- [x] T004 `slug`/`mint` subcommands: kebab-sanitization (lowercase,
  non-alphanumeric runs → `-`), ~30-char truncation, 4-hex token
  generation, and filename minting for plan/tasks/feedback/research
  files. Tests first (fixture strings incl. unicode, punctuation, long
  input), red, then implement.
- [x] T005 `plan-flip <file> approved|superseded`: validates current
  status is a legal predecessor, edits frontmatter in place, refuses
  illegal transitions with nonzero exit. Tests first (good draft file;
  bad: already-superseded, missing frontmatter).
- [x] T006 `tasks-flip <file> <status>`, `task-check <file> <task-id>`,
  `next-task <file>`: status transitions per the
  generating→ready→in-progress→completed/abandoned chain, checkbox flip
  by task ID, first-`- [ ]` locator. Tests first (good fixtures; bad:
  unknown task ID, illegal status jump).
- [x] T007 `feedback-mark <file> <item-id> x|-` and
  `feedback-planned <file> <plan-filename>`: items addressed by stable
  `F001`-style IDs; `feedback-planned` refuses if any item is still
  `[ ]`. Update `skills/ardd-feedback/SKILL.md`'s template so new
  feedback items are written with `F###` ID prefixes (existing feedback
  files are all `planned` — no migration). Tests first.
- [x] T008 `feature-create <slug>`, `feature-flip <slug> <status>`,
  `feature-field <slug> <key> <value>`: per-feature files at
  `.project/features/<slug>.md` per T001's schema; `feature-flip`
  enforces backlogged→planned→tasked→implemented ordering;
  `feature-field` sets `plan`/`tasks`/`gh_issue`. Tests first (good;
  bad: duplicate create, illegal flip, unknown slug).
- [x] T009 `stamp <artifact-file> last_updated|diagram_status <value>`:
  frontmatter stamping with enum validation (`diagram_status`:
  unrendered|stale|current). Tests first.
- [x] T010 Update `scripts/lint-project.sh` to validate the per-feature
  schema (`.project/features/*.md` frontmatter enums/required fields,
  cross-file pointers `plan:`/`tasks:` resolve) and drop the
  single-file features.md checks; update `tests/fixtures/good-project`
  and `bad-project` to the new layout in the same commit (Principle V:
  bad fixtures red first). Also update `scripts/completion-flip-check.sh`
  and `scripts/inflight-worktrees.sh` if they read features.md/the
  register (check; adjust tests likewise).
- [x] T011 Migration `migrations/0003-per-feature-files.sh`: split a
  legacy `features.md` into per-feature files (parse the
  `· `-separated metadata line one final time: Slug, Status, Logged,
  Plan, Tasks, GH), idempotent, leaves a pointer stub or removes
  features.md (decide in-task; stub preferred for old links), recorded
  in `.ardd-applied`. Fixture test with this repo's own current
  features.md copied as fixture, red first. Run it against this repo's
  live `.project/` as the verification step.
- [x] T012 Ship via `install.sh`: add `ardd-state.sh` (and nothing else
  new) to the copied-scripts set; confirm `.worktreeinclude` coverage
  (`.claude/skills/ardd-*/` already covers it); extend
  `scripts/test-install-worktreeinclude.sh` or sibling install test to
  assert the script arrives. Test first.

## Phase 3: Rewire skills to ardd-state.sh (big-bang, after Phase 2; one commit per field-group)

- [x] T013 [artifacts: constitution] Rewire plan/feedback bookkeeping:
  `skills/ardd-plan/SKILL.md` (feedback `[x]`/`[-]` marks →
  `feedback-mark`, status flip → `feedback-planned`, plan supersession →
  `plan-flip`, slug/filename generation → `slug`/`mint`) and
  `skills/ardd-feedback/SKILL.md` (filename minting → `mint`). Prose
  keeps all judgment (what to accept, when to flip); mutations go
  through subcommands. Doc-only skill edits — no new test; run
  `lint-docs.sh` + full hook.
- [x] T014 [artifacts: constitution] Rewire tasks/implement/converge:
  `skills/ardd-tasks/SKILL.md` (plan approval → `plan-flip`, tasks-file
  minting → `mint`, generating→ready → `tasks-flip`, feature flips →
  `feature-flip`/`feature-field`), `skills/ardd-implement/SKILL.md` and
  `skills/ardd-converge/SKILL.md` (status flips → `tasks-flip`, checkbox
  → `task-check`, next task → `next-task`, feature flip →
  `feature-flip`). Same judgment/mutation split; delegated-subagent
  preamble gets the same present-or-fallback path rule as other
  ardd-scripts calls.
- [x] T015 [artifacts: constitution] Rewire the register writers/readers
  to per-feature files: `skills/ardd-feature/SKILL.md`
  (`feature-create`), `skills/ardd-featurize/SKILL.md` (bulk
  `feature-create`), `skills/ardd-sync/SKILL.md` (`feature-field` for
  `gh_issue`, per-feature reads for push/pull),
  `skills/ardd-analyze/SKILL.md` + `skills/ardd-refine/SKILL.md` +
  `skills/ardd-research/SKILL.md` (register reads → glob
  `.project/features/*.md`; `stamp` for artifact frontmatter; `mint`
  for research filenames). Update README/USAGE task-format or
  features.md references ONLY where factually broken by the format
  change (full docs restructure belongs to the docs plan).

## Phase 4: Sibling deterministic helpers (each [parallel] — independent scripts, own tests + CI jobs; only their small SKILL.md rewires touch shared files)

- [ ] T016 [parallel] `scripts/defects-unsurfaced.sh <project-dir>`:
  hash each DEFECTS.md defect description (shasum, first 8 chars),
  union all plans' `surfaced-defects:` frontmatter lists, print
  unsurfaced `id<TAB>description` pairs. Fixture tests first (defects
  all surfaced / some unsurfaced / no DEFECTS.md). CI job. Rewire
  `skills/ardd-plan/SKILL.md` step 5 to call it, keeping only the
  ask-the-user half. Add to `install.sh` copied set.
- [ ] T017 [parallel] `scripts/tasks-list.sh [project-dir]`: enumerate
  `.project/tasks/tasks-*.md` with status, x/y checkbox progress, and
  `plan:` binding; exclude `abandoned` behind a flag. Fixture tests
  first. CI job. Rewire the pick-list prose in
  `skills/ardd-implement/SKILL.md` step 1,
  `skills/ardd-converge/SKILL.md` step 1, `skills/ardd-tasks/SKILL.md`
  step 1 to consume its output. Add to `install.sh` copied set.
- [ ] T018 [parallel] `scripts/upsert-section.sh <file> <header>`
  (reads new body on stdin): replace from `## <header>` to the next
  `##` (or EOF), append the section if absent, never touch anything
  else. Fixture tests first (replace-middle, replace-last, append,
  header-substring false-match guard). CI job. Rewire
  `skills/ardd-render/SKILL.md` step 6 (Mermaid content stays prose).
  Add to `install.sh` copied set.
- [ ] T019 [parallel] [artifacts: constitution] Governance-consistency
  check in `scripts/lint-project.sh`: constitution footer `Version`/
  `Last Amended` vs frontmatter `last_updated` vs Sync Impact Report
  version agree. Bad fixture (mismatched footer) red first; good
  fixture updated.

## Phase 5: ardd-plan feedback scoping

- [ ] T020 [parallel] Add optional feedback-file argument(s) to
  `skills/ardd-plan/SKILL.md`: `/ardd-plan [--feedback <file> ...]`
  (or bare filenames recognized by the `feedback-` prefix) scopes the
  step-5 glob to the named file(s); unnamed open files are neither
  presented nor marked. Update the usage line and USAGE.md's one-line
  description. Doc-only — run `lint-docs.sh`.

## Phase 6: Behavioral smoke test (after Phase 3 — assertions target script-driven state)

- [ ] T021 Build the smoke fixture: `tests/fixtures/smoke-project/` — a
  minimal installable target (git repo initialized in the test, ADD
  installed via `./install.sh`, one stable artifact, empty register).
  Plus `scripts/smoke-assert.sh`: given the fixture after a skill run,
  assert expected files exist, statuses are legal
  (`lint-project.sh` clean), and single-writer files are untouched.
  Test-first: assertion script gets its own good/bad fixture test and
  CI job (runs without any API key — pure file checks).
- [ ] T022 CI smoke job in `.github/workflows/`: triggers only on
  `pull_request` with `paths: [skills/**]`; guard step skips fast when
  `ANTHROPIC_API_KEY` secret is absent; `continue-on-error: true`
  (Production Annotation: key deliberately unprovisioned — promotion =
  provision secret + drop continue-on-error, stated in a workflow
  comment). Job: install ADD into the smoke fixture, run headless
  `claude -p "/ardd-feature <desc>"` then
  `claude -p "/ardd-plan <slug>"`, then `scripts/smoke-assert.sh`.

## Phase 7: Bookkeeping

- [ ] T023 [parallel] Record the mechanization non-goals in CLAUDE.md
  (short list: critique.md staleness compare, STATUS.md count assembly,
  ardd-sync `gh` glue, `core.bare` one-liner, judgment steps —
  deliberately not scripted per Principle VI) so they stop resurfacing.
  Doc task — no test.
