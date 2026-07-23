---
plan: plan-chore-feedback-status-readines-2026-07-23-a4a4.md
generated: 2026-07-23
status: completed
---

# Tasks

## Phase 1: `ardd-state.sh stamp` rejects unexpected trailing args

- [x] T001 In `scripts/test-ardd-state.sh`'s existing `stamp` section
      (~line 463 onward, alongside the existing bad-date/bad-diagram-status
      cases), add a red-first case: run
      `sh "$STATE" stamp "$AF" last_updated 2026-07-06 extra-arg` and
      capture its exit code — confirm this currently exits `0` (the bug:
      the extra arg is silently dropped and the stamp still succeeds), so
      the test genuinely demonstrates the pre-fix silent-drop behavior
      before Phase 1's fix goes in. Do not yet assert the fixed behavior in
      this task — that assertion belongs to T003.
- [x] T002 In `.claude/skills/ardd-scripts/ardd-state.sh`'s `cmd_stamp`
      function (currently lines 330-332), add a trailing-argument guard
      immediately after the existing
      `[ -n "$file" ] && [ -n "$key" ] && [ -n "$val" ] || dieu ...` check:
      `shift 3 2>/dev/null || shift $#` then
      `[ "$#" -eq 0 ] || dieu "stamp: unexpected extra argument(s): $*"`.
      This makes a 4th-or-later positional argument a usage error instead
      of being silently ignored — a positional-count check, not a
      value/`-z` check, so an explicitly empty trailing argument (still a
      real extra positional parameter) is rejected too, not just a
      non-empty one. (Revised from an earlier `[ -z "${1:-}" ]` draft of
      this guard per CodeRabbit review on PR #15 — see that PR's
      `scripts/ardd-state.sh` commit for the actual implementation.)
- [x] T003 In `scripts/test-ardd-state.sh`, update the case added in T001
      (or add a new case immediately after it) to assert the fixed
      behavior: `sh "$STATE" stamp "$AF" last_updated 2026-07-06 extra-arg`
      now exits with the usage-error code `dieu` produces (matching the
      exit-code convention used by the existing "stamp: unknown key usage
      error" case at ~line 499-501), and that the emitted message names the
      unexpected extra argument. Confirm every other existing `stamp` case
      in this section (single `key val` pair) still passes unchanged. Run
      `sh scripts/test-ardd-state.sh` and confirm all cases, including the
      new one, are green. [feedback:
      feedback-ardd-state-stamp-silent-extra-args-1625.md F001]

## Phase 2: Widen the delegation pre-flight's committed-path coverage

- [x] T004 In `.claude/skills/ardd-implement/SKILL.md`'s pre-flight step
      (currently lines 161-195), after the existing step that resolves the
      tasks file's bound plan filename via its `plan:` frontmatter, add
      prose describing three additional path-resolution steps run against
      that same resolved plan file: (a) read the plan's `features:`
      frontmatter list and resolve each slug to
      `.project/features/<slug>.md`; (b) glob
      `.project/feedback/feedback-*.md` and keep any file whose `plan:`
      frontmatter names this plan's filename; (c) note that
      `.project/artifacts/` will be checked as a whole directory in the
      `git status --short` step below, rather than resolved to specific
      files, since artifact edits carry no back-reference to the plan that
      produced them.
- [x] T005 In the same pre-flight step, change the existing
      `git status --short <plan-file> <tasks-file>` invocation to include
      every path resolved in T004 — the plan file, the tasks file, each
      resolved feature-register file, each resolved feedback file, and
      `.project/artifacts/` (the directory, so any dirty/untracked file
      under it is caught). Update the solo-mode auto-commit's `git add`
      list to match this same widened set of paths (still never a broad
      sweep — every path in the list is either resolved above or the
      specific directory). Update the collaborative-mode uncommitted-file
      message to name every affected path found dirty/untracked, not just
      the plan/tasks pair. [feedback:
      feedback-delegation-preflight-artifact-gap-44dc.md F001]

      **Revised post-review (CodeRabbit, PR #14/#16):** the initial
      implementation folded `.project/artifacts/` into the same
      unconditional, no-prompt solo-mode `git add` as the plan/tasks/
      feature/feedback files. That's unsafe specifically for solo mode's
      auto-commit path — an artifact carries no back-reference proving it
      belongs to *this* plan (unlike the other four kinds, which are exact
      matches), so a blind `git add .project/artifacts/` risked silently
      committing an unrelated, still-in-progress artifact edit without
      asking. Split the behavior: `.project/artifacts/` is still checked
      (directory-wide, for detection only) alongside the other paths, but
      it is no longer part of the automatic `git add` in solo mode — if it
      shows anything dirty/untracked, the user is asked (a narrow,
      deliberate exception to solo's no-prompt default) whether to include
      it in a second commit, rather than it being swept in silently.
      Collaborative mode's behavior (surface everything, ask/block) was
      already safe as originally written and is unchanged. (Actual
      implementation landed on PR #15's
      `chore/stamp-arg-safety-and-preflight-gap` branch, in
      `skills/ardd-implement/SKILL.md`.)
- [x] T006 Manually verify the widened pre-flight prose from T004/T005
      against a worked example: trace through a hypothetical plan run that
      targeted one feature slug and had one feedback file bound to it via
      `plan:` frontmatter, and confirm the described resolution steps
      correctly identify `.project/features/<that-slug>.md` and the
      feedback file as additional paths to check/commit, and that the
      collaborative-mode message text as written would name all of them.
      This is prose-only skill behavior with no `scripts/test-*.sh`
      harness to run against it — record the trace as confirmation in this
      task's completion, not as a new test file. [feedback:
      feedback-delegation-preflight-artifact-gap-44dc.md F001]
