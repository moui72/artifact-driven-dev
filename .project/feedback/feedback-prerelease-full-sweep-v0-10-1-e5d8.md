---
status: open      # open -> planned
created: 2026-07-17
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Bugs
- [ ] F001 Three tasks from the earlier `tasks-feedback-batch-ec6e.md`
  run (T006, T007, T010) were marked `[x]` complete with commits whose
  messages describe the intended edit, but the edits themselves never
  landed — only the tasks file's checkboxes changed (T011's commit also
  bundled a genuine, correct constitution edit alongside T010's fake
  one, which is how it slipped through review). Independently
  reproduced by 4 separate `/prerelease-sweep full` scenarios (S2, S3,
  S5, S7 — run `2026-07-17-b924`). **`v0.10.1`, already published as
  stable, ships this gap.** Concretely missing, still needs to actually
  land:
  1. `skills/ardd-status/SKILL.md` step 1's banner-line logic doesn't
     handle `ardd-update-check.sh`'s `dev-ahead` outcome (which *is*
     correctly implemented in the script itself) — it should not
     recommend `/ardd-update` for a dev-mode checkout that's ahead of
     the latest tag, same as the existing silent `self-hosted`/
     `up-to-date` cases.
  2. `skills/ardd-init/SKILL.md` step 7's git-log feature-extraction
     guidance still has no instruction to verify a `feat:`-titled
     commit's actual diff before trusting its message — reproduced live
     against a real misleadingly-titled commit in `~/dev/bart`
     (S2, run `2026-07-17-b924`).
  3. `skills/ardd-plan/SKILL.md` step 10 never actually checks the
     constitution's `plan_preview` field before the "view in browser?"
     question — the field is fully wired everywhere else (schema in
     `lint-project.sh`, stamping in `ardd-state.sh`, docs in
     `docs/reference/skills/ardd-plan.md`) but a user setting it today
     sees no behavior change. Independently confirmed by both S3 and S5.
  Fix: apply the three edits above for real this time, with each
  commit's diff verified against its own message before considering the
  task complete.

- [ ] F002 `ardd-state.sh tasks-flip <file> completed` doesn't verify
  every task checkbox is actually `[x]` before flipping — it will
  happily flip a file to `completed` with unchecked tasks still in it.
  Compounding this: `completed` is deliberately terminal (no legal
  transition back to `in-progress`), so a wrongly-flipped file currently
  has no scripted recovery path at all — only a manual hand-edit, which
  bypasses the schema-of-record entirely. Found by `/prerelease-sweep
  full` (S6-F001, run `2026-07-17-b924`) via a real (if accidental)
  reproduction. Fix direction: `tasks-flip ... completed` should refuse
  (like other illegal-transition refusals `ardd-state.sh` already
  performs) unless every task line's checkbox is `[x]`.

## UX
- [ ] F003 The root cause underlying F001's class of bug: nothing in
  `/ardd-implement`'s task-completion flow (`skills/ardd-implement/SKILL.md`
  step 8, `ardd-state.sh task-check`) verifies that a task's described
  file edit actually landed before the checkbox is marked `[x]` — a
  delegated subagent that writes a commit message describing an edit
  without actually staging the file currently produces an
  indistinguishable-from-correct `[x]` mark. Fix direction (open to
  implementation judgment, not prescribed here): require some form of
  self-check before `task-check` runs — e.g. a `git diff --stat`
  against the task's named file(s), or re-reading the edited section
  back — cheap enough not to meaningfully slow down normal task
  execution, but enough to catch a "described but not applied" edit
  before it's marked done and, worse, committed with a message claiming
  otherwise.
