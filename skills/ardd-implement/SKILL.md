# /ardd-implement

Execute uncompleted tasks from a chosen tasks file sequentially. Each task is
self-contained; the agent loads only the artifacts it declares.

## Steps

1. **Check branch.** Run `.claude/skills/ardd-scripts/branch-info.sh` for
   `current`, `default`, and `on_default`. If `on_default` is `false`, skip to
   step 2.

   If `on_default` is `true`, suggest a branch name — a semantic kebab-case slug derived
   from the conversation/artifacts if the topic is clear, otherwise a short
   arbitrary slug (4 hex chars, e.g. `openssl rand -hex 2` → `f2ed`). Ask the
   user:
   - "Yes, create `<suggested-name>`"
   - "Yes, create a branch, but name it: ___"
   - "No, continue on default" (a worktree works too — set one up yourself
     and re-run from there; this gate doesn't automate worktree creation
     since it's environment-specific)

   On yes, run `git checkout -b <name>`. On no, proceed on the default branch
   without asking again this run.

2. **Pick a tasks file.** Glob `.project/tasks/tasks-*.md`, excluding any at
   `status: abandoned` — a superseded fork with nothing left to execute
   against. If none remain, tell the user to run `/ardd-tasks` first. For
   each remaining file, read its frontmatter `status` and compute live
   progress from checkboxes (`x/y complete`). Present the list and ask the
   user which to work on. If only one exists, still confirm rather than
   auto-selecting.

3. **Find the next uncompleted task** (first `- [ ]` in document order) in
   the chosen file. If all tasks are complete, run `/ardd-analyze` now to
   refresh `STATUS.md` — completing a tasks file changes `features.md`
   Status (step 7) and is the natural wrap-up point for this run — then
   report success and stop.

   If this is the first task being started in this file (status is `ready`),
   flip the file's frontmatter `status` to `in-progress` before proceeding.

4. **Load declared artifacts.** Parse the `[artifacts: ...]` tag on the task
   and read each named file from `.project/artifacts/<name>.md`.

5. **Execute the task:**
   - **Check `constitution.md`** (Quality Standards or Core Principles) for a
     declared testing paradigm before touching a test task — TDD, test-after,
     coverage threshold, or none. Tasks are paradigm-agnostic: follow
     whichever the constitution declares, never default to one it doesn't
     state.
   - For test tasks under a TDD paradigm: write the test first, confirm it
     fails, then stop at the red state. Mark the test task complete. The
     paired implementation task follows.
   - For test tasks under a test-after paradigm (or no paradigm stated):
     implement first, then write the test and confirm it passes.
   - For implementation tasks: implement the minimum code to satisfy the task
     description and make the paired test(s) pass.
   - For research or decision tasks: produce the output described and write it
     to the appropriate location.

6. **Verify** the task is complete: tests pass, the feature works as described,
   no regressions in previously completed tasks.

7. **Mark the task complete** in the tasks file: change `- [ ]` to `- [x]`. If
   this was the last incomplete task, flip the file's frontmatter `status` to
   `completed`, then run
   `.claude/skills/ardd-scripts/sibling-tasks-complete.sh <this file's path>`
   — it reports every tasks file bound to the same plan (a plan can have
   more than one) and whether they're collectively done. Only if its
   `all_complete=true`, load the plan and for each slug in its `features:`
   list flip that entry's `Status` in `.project/artifacts/features.md` from
   `tasked` to `implemented`.

8. **Commit** the work with a concise message referencing the task ID.

9. **Proceed to the next task** and repeat from step 3.

## Rules

- **Never skip a test task.** Follow the constitution's declared testing
  paradigm (step 5) — under TDD, write and fail the test before any
  implementation begins; under test-after or no stated paradigm, write and
  pass it as described in step 5. Don't assume TDD or reference a specific
  principle number if the constitution doesn't name one.
- **Stop and surface blockers** rather than working around them. If a task
  cannot be completed as written, update the tasks file with a note and ask
  the user.
- **Add Production Annotations** at the point of any production shortcut
  identified in the task or encountered during implementation, per the
  convention in the constitution's Development Workflow section.
- **Do not modify artifacts** during implementation. If a decision in an artifact
  turns out to be wrong, stop, surface it, and let the user run `/ardd-refine` first.
  The one exception is flipping a bound feature's `Status` line in
  `features.md` on task-file completion (step 7) — that's status bookkeeping,
  not a design decision.
- **Do not touch `DEFECTS.md`.** If a task incidentally reveals a pre-existing
  code-vs-artifact violation unrelated to the task itself, don't write to
  `.project/DEFECTS.md` directly — that would break its single-writer
  ownership by `/ardd-verify`. Report the finding in the task's output instead
  and tell the user to run `/ardd-verify` to capture it properly on its next
  full pass.
