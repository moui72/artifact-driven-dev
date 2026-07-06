---
plan: plan-built-with-ardd-badge-2026-07-06.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-06
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

Testing paradigm (constitution Principle V, test-first): script/lint
tasks (T002, T003, T005, T006) write their fixture test first and
confirm it fails before implementing; doc-only tasks are the stated
exception. State mutations go through
`.claude/skills/ardd-scripts/ardd-state.sh` (Principle II).

## Phase 1: Built-with-ARDD badge (feature: built-with-ardd-badge)

- [x] T001 Add the badge snippet as a source-of-truth template
  (`templates/badge.md`): shields.io markdown
  `[![built with ARDD](https://img.shields.io/badge/built%20with-ARDD-blue)](https://github.com/moui72/artifact-driven-dev)`
  wrapped in `<!-- ardd-badge-start -->` / `<!-- ardd-badge-end -->`
  marker comments (detection + idempotent reinjection). Doc/template
  task — no test (T002 covers behavior).
- [x] T002 install.sh badge offer, strictly opt-in: after the existing
  gitignore-check section, if the target README.md exists and lacks the
  start marker, print the snippet and a one-line suggestion telling the
  user to paste it (or re-run interactively) — install.sh NEVER edits a
  target README itself; injection happens only if the user asks Claude
  to do it or pastes manually. This resolves the plan's decline-memory
  open question by having no state to remember: a suggestion printed at
  install time, exactly like the gitignore suggestion, nags no one.
  Extend the install fixture test first (red): assert README untouched
  by install, suggestion printed when marker absent, silent when marker
  present or README missing.

## Phase 2: Migration 0004 — dangling register tags [defect-adjacent; feedback b959 F001]

- [x] T003 [parallel] `migrations/0004-retag-features-refs.sh`: in
  `.project/tasks/*.md` and `.project/feedback/*.md`, rewrite
  bracket-tags naming the removed `features` artifact — drop `features`
  from multi-name tags, remove the whole tag when it named only
  `features`. Idempotent. Fixture test first (project carrying both tag
  shapes plus an unrelated tag that must survive; red), CI job, same
  commit. Note for downstream: applied automatically on their next
  install.sh run via `.ardd-applied`.

## Phase 3: Artifacts-none convention [feedback 9fc6 F001]

- [x] T004 [parallel] Soften `skills/ardd-tasks/SKILL.md` step 3's
  artifact requirement: "state which artifacts must be loaded, omitting
  the artifacts bracket-tag entirely when none apply — never write a
  placeholder name like `none`." Doc-only; lint-docs must stay green.
- [x] T005 [parallel] lint-project.sh: when a bracket-tag names the
  literal `none` or `n/a`, report the pointed message "placeholder
  artifact name — omit the artifacts bracket-tag instead" in place of
  the generic missing-file error. Bad fixture line added first (red),
  EXPECTED_BAD_FINDINGS adjusted, test-lint-project green after.

## Phase 4: Docs review batch [feedback 5ef3]

- [x] T006 (F005) gen-skill-docs.sh: explicit per-tier workflow
  ordering via ordered name lists in the generator (resolves the plan's
  open question — the order is editorial, so it lives with the other
  editorial text in the generator; unknown/unlisted skills append
  alphabetically so a new skill can't silently vanish). Extend
  test-gen-skill-docs.sh first to assert core-loop order (red: current
  output is alphabetical), then implement; regenerate README +
  templates/WORKFLOW.md.
- [x] T007 (F009, user-confirmed reversal 2026-07-06) Three-tier
  reframe: retag frontmatter `tier:` values — `setup`: bootstrap,
  codify, featurize; `core`: feature, feedback, refine, plan, tasks,
  implement; `extension`: the rest — teach gen-skill-docs.sh and its
  fixture test the `setup` tier (a "Getting started" README section +
  WORKFLOW.md grouping), regenerate, and realign USAGE: numbered steps
  become the delivery loop (feature/feedback intake → plan → tasks →
  implement → converge), setup gets its own short section, research
  moves under Extensions. Depends on T006.
- [x] T008 (F008) Write guides/continuing.md — "Working an established
  project": log ideas the moment you have them (`/ardd-feature`),
  capture observations from using the built thing (`/ardd-feedback`),
  targeted plans by slug, feedback-scoped plans
  (two-open-files-two-plans), when to run `/ardd-converge`, and a
  `/ardd-verify`/`/ardd-critique` cadence. Remove both existing guides'
  "Adding features after..." tail sections, replacing each with a
  pointer to the new guide; link it from README's Install section and
  USAGE. lint-docs green (it validates guide skill references).
- [x] T009 (F001) Rewrite USAGE step 1 (well, the setup section after
  T007) to match ardd-bootstrap's actual behavior: bootstrap creates
  the constitution too (suggestion catalog, workflow_mode question),
  artifact set is judgment-driven; drop the "if you want a
  constitution, run /ardd-refine constitution" instruction.
- [ ] T010 (F002, F003, F004) [parallel] Staleness sweep:
  greenfield.md — research is NOT auto-read by /ardd-plan (fold into
  artifacts via /ardd-refine instead) and plan approval happens by
  selection in /ardd-tasks; replace all 7 "ArDD" occurrences with ARDD;
  existing-project.md — per-feature register wording (features.md →
  `.project/features/`); README "four-plus living documents" intro;
  USAGE "reads all four artifacts"; CLAUDE.md's remaining features.md
  mentions including the lint-enum description (now: per-feature
  register `status` plus the other five enums). Doc-only; lint-docs +
  gen-skill-docs --check green.
- [ ] T011 (F006, F007) [parallel] README structure: move "Future
  directions" and "Credits" to the bottom (after Contributing); move
  "Recovering from a rewritten main" into
  docs/decisions/0003-rewritten-main-recovery.md with a one-line
  pointer from Contributing. Doc-only.
