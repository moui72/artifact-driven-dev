---
plan: plan-next-step-prompt-2026-07-09.md
generated: 2026-07-09
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                     # (or -> abandoned, if superseded by a new tasks
                     # file generated for the same plan)
                     # completed is terminal — post-completion failures
                     # become new feedback (/ardd-feedback), never a
                     # status edit.
---

# Tasks

## Phase 1: Schema-of-record groundwork (test-first)

- [x] T001 [artifacts: constitution] Add optional `next_step_prompt` boolean validation to `scripts/lint-project.sh`: in constitution frontmatter, the field may be absent (fine) or exactly `true`/`false`; any other value is an error naming the file, field, and allowed values. Test-first (Principle V): add `next_step_prompt: true` to `tests/fixtures/good-project`'s constitution and an invalid value (e.g. `next_step_prompt: yes`) to `tests/fixtures/bad-project`'s, extend `scripts/test-lint-project.sh` (including the bad-project findings count), and confirm the new bad case fails before the lint change lands. Same commit.
- [x] T002 [parallel] Extend `scripts/defects-unsurfaced.sh` with `--id <id>` (repeatable) and `--all` modes that print the named / all current `DEFECTS.md` entries as `<id>\t<claim>` lines *bypassing* the surfaced-union filter; `--id` with an identifier not present in DEFECTS.md errors; default no-argument behavior byte-identical to today. Test-first: extend its regression test (`scripts/test-defects-unsurfaced.sh`) with cases for `--id` hit, `--id` miss, `--all` including already-surfaced ids, and unchanged default mode; confirm red before the change. Same commit.

## Phase 2: Prompt behavior in the three seam skills (depends on T001)

The shared convention all three tasks implement: grep `.project/artifacts/constitution.md` frontmatter for `next_step_prompt: true` (absent or `false` = plain-text behavior, unchanged); when `true` AND the skill's recommended next step is a concrete runnable `/ardd-*` invocation, end by presenting it via AskUserQuestion — option 1 "Yes — run `/ardd-<next>` now", option 2 "No — stop here" (Esc = option 2); on yes, invoke that skill by name (existing terminal-handoff mechanism, no value passed back). Recommendations that are not a skill invocation ("merge and push", "provision the key") always stay plain text. Doc-prose change, no script test; `./scripts/lint-docs.sh` must pass.

- [x] T003 Apply the convention to `skills/ardd-analyze/SKILL.md`: after step 6's STATUS.md write (and step 7 if it ran), gate the Summary's "Recommended next step" per the convention above. Note in prose that delegated/scripted contexts are unaffected because absent = false.
- [x] T004 [parallel] Apply the convention to `skills/ardd-plan/SKILL.md` step 10, offering `/ardd-tasks` (the prompt fires only when analyze isn't about to be the endpoint — plan's step 10 already ends by running /ardd-analyze, so place the gate there consistently: the offer belongs to whichever skill actually ends the turn; state this explicitly to avoid double-prompting when plan hands off to analyze).
- [ ] T005 [parallel] Apply the convention to `skills/ardd-tasks/SKILL.md` step 7, offering `/ardd-implement` — same double-prompt caveat as T004: tasks ends by running /ardd-analyze, so the prose must ensure exactly one prompt per user-visible turn end.

## Phase 3: The ask-once question (depends on T001)

- [ ] T006 Verify whether `ardd-state.sh stamp` can already set a constitution frontmatter field to an arbitrary validated value (Principle VIII — check before building). If not, extend `stamp` (or add a subcommand) to set `next_step_prompt` with boolean validation, refusing other values. Test-first: extend `scripts/test-ardd-state.sh` (set-true, set-false, replace-existing, bad-value-refused); confirm red first. Same commit. Skip the code change (but keep the verification note in the commit/PR body) if stamp already handles it.
- [ ] T007 [artifacts: constitution] `skills/ardd-bootstrap/SKILL.md`: ask the next-step-prompt question once, alongside the existing `workflow_mode` question ("Should skills end by offering their recommended next step as a one-keypress prompt?"); write the answer into constitution frontmatter via T006's script path. State explicitly in the prose: this is a frontmatter workflow field like `workflow_mode` — no Sync Impact Report or constitution version bump applies.
- [ ] T008 `skills/ardd-update/SKILL.md`: after re-running install.sh, if the target's constitution frontmatter lacks `next_step_prompt` entirely, ask the same question once and write the answer via T006's script path; field presence (either value) suppresses re-asking forever. Absent stays = false on paths that skip the ask (bare ./install.sh, headless runs) — never block or default-on. Same no-version-bump note as T007.

## Phase 4: Defect-scoping argument (depends on T002)

- [ ] T009 `skills/ardd-plan/SKILL.md`: extend Usage and step 5 — arguments of the form `defect:<id>` name specific `DEFECTS.md` entries and the literal argument `defects` names all current entries; for these, run `defects-unsurfaced.sh --id <id> .../--all` instead of the default mode, re-offering the entries even if their ids already appear in some plan's `surfaced-defects:` list; the present/accept/decline flow, `[defect: <id>]` task tagging, and recording in the drafted plan's `surfaced-defects:` are identical to the existing step 5. The `defect:` prefix is what disambiguates from feature slugs and feedback filenames in the same argument list — state that in Usage. `lint-docs.sh` must pass. [feedback: F001, feedback-plan-target-defects-6a36.md]

## Phase 5: Docs + dogfood

- [ ] T010 Docs: README.md and USAGE.md — document `next_step_prompt` (both values, absent = false, the ask-once behavior via bootstrap/update) and `/ardd-plan`'s `defect:<id>`/`defects` arguments; update CLAUDE.md's architecture notes if the three-skill scope or the no-version-bump decision needs stating source-side. `./scripts/lint-docs.sh` must pass.
- [ ] T011 [artifacts: constitution] Dogfood (confirm with user first — their choice at implement time): set `next_step_prompt: true` in this repo's own constitution frontmatter via T006's script path, then re-run `./install.sh .` so the dogfooded skill copies under `.claude/skills/` pick up the Phase 2/3 prose changes.
