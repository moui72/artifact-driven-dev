---
plan: plan-v0-10-2-fixes-2026-07-17-4465.md
generated: 2026-07-17
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Land the three missing v0.10.1 edits
- [x] T001 Update `skills/ardd-status/SKILL.md` step 1's banner-line
  template to handle `ardd-update-check.sh`'s `dev-ahead` outcome
  distinctly from `behind`: do not recommend `/ardd-update` when doing
  so would regress the target. Either treat it as a silent case
  (matching the existing `self-hosted`/`up-to-date` silent outcomes) or
  print a clearly different, non-misleading note. **Before marking this
  task complete, run `git diff skills/ardd-status/SKILL.md` and confirm
  it actually shows the `dev-ahead` handling — do not mark complete on
  the strength of the commit message alone** (this exact task was
  claimed-but-not-applied once already; this explicit self-check is the
  new discipline this plan's Phase 3 formalizes). No test task —
  prose-only skill-file change. [feedback: F001]
- [x] T002 [parallel] Edit `skills/ardd-init/SKILL.md` step 7's git-log
  feature-extraction guidance: add an explicit instruction that a
  `feat:`-titled commit's message is not proof of its diff, and
  instruct verifying the commit's actual diff (or cross-referencing
  against the step-2 code survey) before treating it as evidence a
  capability is actually implemented and shipped, rather than merely
  proposed or documented. **Before marking this task complete, run
  `git diff skills/ardd-init/SKILL.md` and confirm the new guidance is
  actually present in the diff.** No test task — prose-only skill-file
  change. [feedback: F001]
- [x] T003 [parallel] Edit `skills/ardd-plan/SKILL.md` step 10: before
  the existing "view the plan in the browser first?" `AskUserQuestion`,
  grep `.project/artifacts/constitution.md` frontmatter for
  `plan_preview` (absent = `ask`, current behavior — keep asking as
  today). On `always-browser`: skip the question, always publish via
  `Artifact` and open it, then proceed to the three-way
  approve/revise/stop question unchanged. On `always-console`: skip the
  question, never publish, go straight to the three-way question. On
  `ask` (or absent): behavior unchanged from today. **Before marking
  this task complete, run `git diff skills/ardd-plan/SKILL.md` and
  confirm the `plan_preview` gating is actually present in the diff —
  this exact task was claimed-complete-but-unapplied once already
  (T010, prior tasks file).** No test task — prose-only skill-file
  change. [feedback: F001]

## Phase 2: `tasks-flip completed` checkbox verification (depends on nothing; independent of Phase 1)
- [x] T004 (test-first) Add a regression case to `ardd-state.sh`'s test
  suite (`scripts/test-ardd-state.sh`) covering: `tasks-flip <file>
  completed` refuses (non-zero exit, message naming the still-open task
  ID(s)) when any task line in the file is still `- [ ]`, and succeeds
  when every task line is `- [x]`. Confirm the refusal case fails
  against current `ardd-state.sh` first (red — the script doesn't check
  checkbox state today). Apply the test framework's expected-failure
  marker on this red commit per the constitution's full-suite
  pre-commit hook convention. [feedback: F002]
- [ ] T005 Fix `scripts/ardd-state.sh`'s `tasks-flip` case statement:
  before performing the `in-progress -> completed` transition, grep the
  tasks file for any `- [ ]` line (unchecked); if any exist, refuse with
  a message naming the still-open task ID(s), mirroring the script's
  existing refusal style (e.g. `ready -> completed refused (skips
  in-progress)`). Remove T004's expected-failure marker — its case
  should now pass (green). [feedback: F002]

## Phase 3: `/ardd-implement` process tightening (depends on nothing; independent of Phases 1-2)
- [ ] T006 Edit `skills/ardd-implement/SKILL.md` step 8: immediately
  before the existing instruction to run `ardd-state.sh task-check
  <file> <task-id>`, add a mandatory self-check — state which file(s)
  the task named, run `git diff` (or `git diff --stat`) against those
  files, and confirm the change described in the task's own text is
  genuinely present before proceeding to `task-check`. Frame this as a
  lightweight, always-required step, not optional diligence — its
  purpose is to make a "described but not actually applied" edit
  visibly fail this check rather than silently reach `[x]`. No test
  task — prose-only skill-file change; the check itself is judgment
  against free-text task descriptions, not a mechanizable pure
  function. [feedback: F003]

## Phase 4: v0.10.2 cut (depends on Phases 1-3)
- [ ] T007 Run the full test suite (`scripts/lint-docs.sh`,
  `scripts/lint-project.sh .`, every `scripts/test-*.sh`) and confirm
  all green; confirm `git status --short` is clean. This is a
  verification task, not a code change — no commit expected unless a
  prior task's work needs a fixup.
