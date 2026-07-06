---
plan: plan-repo-critique-docs-2026-07-06.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-06
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

Testing paradigm (constitution Principle V, test-first): doc-only tasks
are the stated exception; tasks adding a deterministic script or check
(T009, T010, T011) write the fixture test first and confirm it fails
before implementing. State mutations go through
`.claude/skills/ardd-scripts/ardd-state.sh` (Principle II).

## Phase 1: README/USAGE restructure (sequential — all four edit the same files)

- [x] T001 [artifacts: constitution] Confirm the project name with the
  user — ADD vs ARDD (recommendation on record: ARDD; matches every
  skill name, avoids the collision) — then apply the chosen name
  consistently across README.md, USAGE.md, guides/*.md, CLAUDE.md
  prose, and constitution.md's Project Scope wording ("artifact-driven-
  dev (ADD/ARDD)" dual-naming collapses to the one name; repo/dir names
  and `ardd-*` skill names unchanged). Constitution edit is a wording
  fix — PATCH bump (v1.2.0 → v1.2.1) with Sync Impact Report per
  Governance. Doc task — no test; run lint-docs.sh.
- [x] T002 Tier README.md and USAGE.md around the core loop:
  bootstrap/codify → refine → plan → tasks → implement (analyze
  auto-running) presented as *the* workflow, with
  sync/render/critique/verify/featurize/converge/feedback/lint/
  research/add-artifact moved under an "Extensions" section described
  as opt-in. Restructure only — every skill keeps its documented
  behavior; lint-docs.sh must stay green.
- [x] T003 Demote the four-artifact set in README.md and USAGE.md: the
  system is "a declared set of living artifacts — typically a
  constitution plus the concerns your project actually has," with
  constitution/infrastructure/datamodel/ui as suggested defaults per
  project shape, not the definition. Align `skills/ardd-bootstrap/
  SKILL.md` step 2's framing (it already uses judgment; make the prose
  say so). Doc task — no test; lint-docs.sh.
- [x] T004 Add a short README/USAGE note documenting inline-on-a-branch
  (`git checkout -b` + inline run) as the blessed degradation path when
  worktree delegation misbehaves — the harness `worktree.baseRef`
  behavior has regressed in both directions before; a regression
  degrades the workflow, never outages it. Doc task — no test.

## Phase 2: Archaeology strip (parallel-safe vs Phase 1 — touches CLAUDE.md + skills, not README/USAGE)

- [x] T005 [parallel] Create `docs/decisions/` (source-repo-only, never
  installed) and move CLAUDE.md's development history into dated
  decision records: the three branch-identity bugs' full narratives,
  the state-commit-before-branch removal story, the gitignore
  twice-burned story, the worktree-info.sh removal note. CLAUDE.md
  keeps current invariants + one-line pointers to the records. Doc
  task — no test; pre-commit suite must stay green.
- [x] T006 [parallel] Strip embedded history from shipped skill prose:
  ardd-implement step 2's "History note", step 3's smoke-test
  validation dates, ardd-converge's history note and validation dates,
  ardd-plan's reverted-design explanation in the branch gate — each
  replaced by the current rule plus (where needed) a one-line pointer
  to docs/decisions/. Zero behavior change intended: every step's
  *instructions* survive verbatim in meaning; target ≥25% token
  reduction across the three files. Land after T011 if the smoke key
  exists by then, else on careful prose review (Production Annotation
  in the plan). [note 2026-07-06: history fully stripped, behavior
  preserved, landed on prose review (smoke key still unprovisioned);
  actual reduction 8.5% (40,468→37,046 chars) not ≥25% — the T013/T014
  rewires had already removed most archaeology, and the remainder is
  operational instruction, deliberately not cut to hit the number]

## Phase 3: Single-source skill descriptions (T007 parallel-safe; T008 after Phase 1 lands so tables generate from settled text)

- [x] T007 [parallel] Add YAML frontmatter to every `skills/*/SKILL.md`:
  `name: <skill-name>` and a one-line `description:` (drawn from the
  current README table wording where accurate). Verify skills still
  load as slash commands after install (frontmatter is the standard
  Claude Code skill format). Doc/format task — no new test yet (T008
  adds the deterministic check).
- [x] T008 Build `scripts/gen-skill-docs.sh` (source-side): reads each
  SKILL.md's frontmatter and regenerates (a) the README.md skill table
  via `scripts/upsert-section.sh` and (b) a static
  `templates/WORKFLOW.md` that install.sh copies into targets —
  removing the embedded WORKFLOW.md templates from ardd-bootstrap
  step 6 and ardd-codify's equivalent (they `cp` the installed static
  file instead). Extend lint-docs.sh to fail when the generated table
  drifts from frontmatter. Test-first: fixture with a mismatched
  description, red, then green; CI job in the same commit.

## Phase 4: Verify-run defects

- [x] T009 [defect: 58bd7dd2] Backfill fixture tests for migrations
  0001-diagram-stale.sh and 0002-diagram-status.sh (temp-dir fixture
  with pre-migration artifacts; assert resulting frontmatter), added
  to CI — on ubuntu these tests are RED today because both scripts use
  BSD-only `sed -i ''`. Then fix: replace with the portable
  `sed -i.bak` + `rm` pattern migration 0003 uses; tests go green on
  both platforms. Same commit per Principle V.
- [x] T010 [defect: 970d935b] Extend `.github/workflows/smoke.yml` with
  a second scenario covering the tasks→implement mutation path: fixture
  target gets a pre-written 1-task plan+tasks pair (or the scenario
  runs `/ardd-tasks` selecting the scenario-one plan), then a headless
  `/ardd-implement` run; assert via `scripts/smoke-assert.sh` — plan
  `approved`, tasks file `completed`, feature `implemented`,
  single-writer files untouched. Same key-gate + `continue-on-error`
  and the same promotion annotation; remains unexecutable until the
  `ANTHROPIC_API_KEY` secret is provisioned.
- [ ] T011 Dry-run the full smoke workflow logic locally as far as
  possible without the key (fixture setup + smoke-assert calls against
  a hand-simulated post-run state) so both scenarios' assertion logic
  is itself exercised in CI — extend `scripts/test-smoke-assert.sh`
  with the scenario-two assertion set (test-first).
