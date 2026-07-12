---
plan: plan-background-by-default-flow-2026-07-12.md
generated: 2026-07-12
status: in-progress
---

# Tasks

## Phase 1: Schema of record (test-first)

- [x] T001 [artifacts: constitution] Add `delegation` (`eager|ask|inline`) and
  `merge_policy` (`auto|ask`) to `scripts/lint-project.sh`'s
  constitution-frontmatter validation as optional, enum-checked-when-present
  fields, declared in the enum block at the top of the script (schema-of-record).
  Test-first (Principle V): first extend `tests/fixtures/bad-project`'s
  constitution with an invalid value for each new field and add the two
  expected-failure assertions to `scripts/test-lint-project.sh`, confirm the
  test fails; then implement the validation; then add valid values
  (`delegation: eager`, `merge_policy: auto`) to
  `tests/fixtures/good-project`'s constitution and confirm the full test
  passes. Before locking names, get user confirmation on `delegation` /
  `merge_policy` (plan Open Question 1).

## Phase 2: Solo plan commits to default

- [x] T002 [artifacts: constitution] Rewrite `skills/ardd-plan/SKILL.md`
  step 1: in solo mode (`workflow_mode` absent or `solo`) there is no
  branch-gate prompt — the run proceeds on the current branch (normally the
  default branch) and commits plan+tasks there; derive the plan-name slug
  from the first feature-slug argument, else a 4-hex token, exactly as
  today's "no" path. Collaborative mode keeps the existing gate verbatim.
  Preserve the stale-branch/disposable-reports note and the
  set-up-a-worktree-yourself escape hatch as prose. State explicitly what the
  plan's `branch:` frontmatter means when no branch is created (name the
  branch `/ardd-implement`'s inline path *would* create, or omit — resolve
  with T009's findings; keep the two consistent).

- [ ] T003 [parallel] Update the docs that narrate the plan branch gate:
  CLAUDE.md's "ardd-plan is the branch-gate exception" paragraph and
  two-operating-modes section, plus USAGE.md/README.md wherever they describe
  `/ardd-plan` prompting for a branch. Run `./scripts/lint-docs.sh` and the
  pre-commit hook to verify green.

## Phase 3: Knob consumption in implement/converge

- [ ] T004 [artifacts: constitution] Edit the delegation gate in
  `skills/ardd-implement/SKILL.md` (step 3) and
  `skills/ardd-converge/SKILL.md` (its equivalent step): read `delegation`
  from `.project/artifacts/constitution.md` frontmatter (grep the
  frontmatter block; absent = `ask`). `eager` = delegate to a background
  worktree subagent without prompting (still folding first if on a branch —
  now recovery-path framing); `ask` = today's prompt verbatim; `inline` =
  proceed inline without offering. The same edit lands in both skills (the
  interactive half is deliberately duplicated prose — CLAUDE.md).

- [ ] T005 [artifacts: constitution] Edit the post-delegation completion step
  in the same two skills: read `merge_policy` (absent = `ask`). `auto` =
  merge the subagent-reported branch into the local default branch when the
  merge is fast-forward or completes without conflicts, then run the existing
  post-merge steps (core.bare check, `/ardd-analyze` handoff) unchanged; on
  any conflict, abort the merge, surface it, and fall back to asking — never
  auto-resolve (disposable-report rule stays interactive prose until the
  merge-driver feature lands). `merge_policy` is consulted in solo mode only.
  Reword `fold-to-main.sh` mentions in both skills to recovery-path framing.

- [ ] T006 [parallel] Write
  `docs/decisions/0005-background-by-default.md`: what changed relative to
  decision 0004 (plan stops authoring the branch fold-to-main existed to
  undo), why fold demotes to a recovery path rather than being deleted
  (Principle VII check: it still serves runs that find themselves on a
  branch), why absent = `ask` (existing installs unaffected, no migration),
  and why `merge_policy` is solo-only. Link it from 0004 and
  `docs/decisions/README.md` if that file indexes records.

## Phase 4: Ask-once wiring

- [ ] T007 [artifacts: constitution] Add the two questions to
  `skills/ardd-bootstrap/SKILL.md` alongside the existing
  `workflow_mode`/`next_step_prompt` questions: `delegation` asked in both
  modes; `merge_policy` asked only when the answered mode is `solo` (it is
  never consulted in collaborative — plan Open Question 3, resolved: don't
  ask). Answers stamped via `ardd-state.sh stamp <constitution> <field>
  <value>`, never hand-edited.

- [ ] T008 [artifacts: constitution] Add the backfill-ask to
  `skills/ardd-update/SKILL.md`, exactly mirroring the `next_step_prompt`
  backfill: after re-running install.sh, if the target's constitution
  frontmatter lacks `delegation` (or, in solo mode, `merge_policy`), ask the
  same bootstrap question(s) and stamp the answer; presence of the field
  (either value) suppresses re-asking. Bare `install.sh`/scripted runs skip
  the ask and absent stays = `ask`.

## Phase 5: Dogfood and closeout

- [ ] T009 Verify `scripts/completion-flip-check.sh` degrades gracefully when
  a plan's `branch:` names a branch that was never created (the solo
  no-branch flow): build a throwaway-repo test case with a completed tasks
  file whose plan `branch:` has no ref, confirm the script reports
  nothing/cleanly rather than erroring, and add that case to
  `scripts/test-completion-flip-check.sh`. If behavior needed a fix, fix the
  script in the same commit (test-first). Feed the outcome back into T002's
  `branch:` field wording if they landed inconsistently.

- [ ] T010 [artifacts: constitution] Stamp this repo's own constitution with
  the user-chosen dogfood values (plan Open Question 4 — ask before
  stamping: `eager`+`auto` exercises the feature, `ask`+`ask` is
  conservative) via `ardd-state.sh stamp`, run `./scripts/lint-project.sh`
  against the live `.project/`, run the full pre-commit hook suite, and
  sweep README/USAGE once more for stale branch-gate narration
  (`lint-docs.sh` green).
