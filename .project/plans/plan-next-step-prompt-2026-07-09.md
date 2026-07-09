---
status: draft        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: next-step-prompt
created: 2026-07-09
features: [next-step-prompt]
surfaced-defects: []
---

# Plan: next-step-prompt + defect-scoping argument

## Goal

Add the opt-in `next_step_prompt` boolean (actionable next-step prompt at
the analyze/plan/tasks handoff seams) and give `/ardd-plan` a defect-scoping
argument so previously-declined `DEFECTS.md` entries can be re-offered
(feedback F001, feedback-plan-target-defects-6a36.md).

## Scope

**In:** `lint-project.sh` boolean validation + fixtures; prompt behavior in
`/ardd-analyze`, `/ardd-plan`, `/ardd-tasks` SKILL.md; the ask-once question
in `/ardd-bootstrap` (greenfield) and `/ardd-update` (existing installs);
`defects-unsurfaced.sh` extension + test; docs; optional dogfood flip of
this repo's own constitution.

**Out:** prompts in any other skill (analyze is the sink most skills
terminal-handoff into — adding more duplicates prompt prose for no seam);
any auto-proceed-without-asking mode (boolean, not enum — add later via
migration only if it earns its way in); new smoke-test scenarios (the
coverage gap is already-surfaced defect 970d935b; expand when the key is
provisioned).

## Technical Approach

- **Field semantics (decided):** `next_step_prompt: true | false` in the
  target constitution's frontmatter; absent = `false`. When `true`,
  `/ardd-analyze`, `/ardd-plan`, and `/ardd-tasks` end by offering their
  recommended next step via AskUserQuestion (option 1 = run it now via the
  existing terminal-handoff mechanism; option 2 / Esc = stop) — but only
  when the recommendation is a concrete runnable `/ardd-*` invocation.
  Non-skill recommendations ("merge and push", "provision the key") always
  fall back to plain text, as does `false`/absent everywhere.
- **Ask-once for existing installs (decided):** `/ardd-update`, after
  re-running install.sh, checks constitution frontmatter; if the field is
  absent, asks the same question `/ardd-bootstrap` asks and writes the
  answer. Field presence (either value) suppresses re-asking. Not a
  `migrations/*.sh` job — migrations are non-interactive and bare
  `install.sh` may run headless; those paths silently keep absent=false.
- **No constitution version bump for the field write (decided):**
  `next_step_prompt`, like `workflow_mode`, is a frontmatter workflow
  field, not a governed principle — writing it (bootstrap or update)
  requires no Sync Impact Report or version increment. State this in both
  skills' prose so the question doesn't recur.
- **Mutation is script-performed (Principle II):** the frontmatter write
  goes through `ardd-state.sh` (extend `stamp` — or add a subcommand — to
  set constitution frontmatter fields, if it doesn't already), never
  hand-edited markdown.
- **Defect scoping (decided syntax):** `/ardd-plan defect:<id> [...]`
  re-offers the named `DEFECTS.md` entries, and the literal argument
  `defects` re-offers every entry currently in `DEFECTS.md`, in both cases
  regardless of whether their ids already appear in some plan's
  `surfaced-defects:` list. The `defect:` prefix avoids collision with
  feature slugs and feedback filenames in the same argument list. Accepted
  entries become `[defect: <id>]` fix tasks exactly as step 5 produces
  today; the drafted plan records them in `surfaced-defects:` either way.
  Deterministic half lives in `defects-unsurfaced.sh` (new `--id <id>` /
  `--all` modes that skip the surfaced-union filter); judgment half
  (present/accept/decline) stays prose.

## Phase Breakdown

### Phase 1 — schema-of-record groundwork (test-first)

- [ ] T001 `scripts/lint-project.sh`: validate optional constitution
  frontmatter `next_step_prompt` as boolean (`true|false`; any other value
  is an error; absence is fine). Update `tests/fixtures/good-project`
  (field present) and `tests/fixtures/bad-project` (invalid value) and
  `test-lint-project.sh` in the same commit.
- [ ] T002 `scripts/defects-unsurfaced.sh`: add `--id <id>` (repeatable)
  and `--all` modes that print the named/all current `DEFECTS.md` entries
  bypassing the surfaced-union filter; default no-arg behavior unchanged.
  Extend its regression test in the same commit. [feedback: F001]

### Phase 2 — prompt behavior in the three seam skills [feature: next-step-prompt]

(Depends on Phase 1: the field must lint clean before skills read it.)

- [ ] T003 `skills/ardd-analyze/SKILL.md`: final step — grep constitution
  frontmatter for `next_step_prompt: true`; if true and the Summary's
  recommended next step is a concrete runnable `/ardd-*` invocation,
  present it via AskUserQuestion (run now / stop, Esc = stop); on yes,
  invoke that skill (existing terminal-handoff mechanism). Otherwise plain
  text as today.
- [ ] T004 `skills/ardd-plan/SKILL.md` step 10: same gated prompt offering
  `/ardd-tasks`.
- [ ] T005 `skills/ardd-tasks/SKILL.md` final step: same gated prompt
  offering `/ardd-implement`.

### Phase 3 — the ask-once question [feature: next-step-prompt]

- [ ] T006 `ardd-state.sh`: ensure a validated script path exists to set a
  constitution frontmatter field (`stamp` extension or new subcommand);
  regression test in same commit. (Skip if `stamp` already handles it —
  verify first, Principle VIII.)
- [ ] T007 `skills/ardd-bootstrap/SKILL.md`: ask the next-step-prompt
  question alongside the existing `workflow_mode` question; write the
  answer via T006's path; note explicitly that no version bump applies.
- [ ] T008 `skills/ardd-update/SKILL.md`: post-install, if constitution
  frontmatter lacks `next_step_prompt`, ask once and write via T006's
  path; field presence suppresses re-asking; note no version bump.

### Phase 4 — defect-scoping argument [feedback: F001]

- [ ] T009 `skills/ardd-plan/SKILL.md`: Usage + step 5 — recognize
  `defect:<id>` arguments and the literal `defects`; run
  `defects-unsurfaced.sh --id/--all` accordingly; present/accept/decline
  and record in `surfaced-defects:` exactly as the existing flow does.

### Phase 5 — docs + dogfood

- [ ] T010 Docs: README/USAGE — describe `next_step_prompt` (both values,
  ask-once behavior) and `/ardd-plan`'s defect-scoping arguments;
  `lint-docs.sh` must pass. Update CLAUDE.md's skill-handoff notes if the
  three-skill scope needs stating source-side.
- [ ] T011 Dogfood (user choice at implement time): set
  `next_step_prompt: true` in this repo's own constitution frontmatter and
  re-run `./install.sh .` to refresh the installed skill copies.

## Complexity Tracking

None — no new abstractions; one boolean field, two script extensions with
tests, prose edits scoped to five skills.

## Open Questions

None — argument syntax, boolean-vs-enum, version-bump question, and
ask-once channel were all decided pre-plan (see Technical Approach and the
feature register entry).

## Production Annotation Summary

None. (Smoke-test coverage for the new prompt paths is deliberately out of
scope — already-surfaced defect 970d935b governs when that tier expands.)
