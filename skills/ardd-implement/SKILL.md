# /ardd-implement

Execute uncompleted tasks from a chosen tasks file sequentially. Each task is
self-contained; the agent loads only the artifacts it declares.

## Steps

1. **Check branch.** Get the current branch (`git branch --show-current`) and
   the repo's default branch (`git symbolic-ref refs/remotes/origin/HEAD`
   stripped of `refs/remotes/origin/`, falling back to `main` then `master`
   if no remote is configured). If they differ, skip to step 2.

   If they match, suggest a branch name — a semantic kebab-case slug derived
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

2. **Pick a tasks file.** Glob `.project/tasks/tasks-*.md`. If none exist,
   tell the user to run `/ardd-tasks` first. For each file, read its
   frontmatter `status` and compute live progress from checkboxes (`x/y
   complete`). Present the list and ask the user which to work on. If only
   one exists, still confirm rather than auto-selecting.

3. **Find the next uncompleted task** (first `- [ ]` in document order) in
   the chosen file. If all tasks are complete, report success and stop.

   If this is the first task being started in this file (status is `ready`),
   flip the file's frontmatter `status` to `in-progress` before proceeding.

4. **Load declared artifacts.** Parse the `[artifacts: ...]` tag on the task
   and read each named file from `.project/artifacts/<name>.md`.

5. **Execute the task:**
   - For test tasks: write the test first, confirm it fails, then stop at the
     red state. Mark the test task complete. The paired implementation task
     follows.
   - For implementation tasks: implement the minimum code to satisfy the task
     description and make the paired test(s) pass.
   - For research or decision tasks: produce the output described and write it
     to the appropriate location.

6. **Verify** the task is complete: tests pass, the feature works as described,
   no regressions in previously completed tasks.

7. **Mark the task complete** in the tasks file: change `- [ ]` to `- [x]`. If
   this was the last incomplete task, flip the file's frontmatter `status` to
   `completed`. Then read this tasks file's `plan:` frontmatter and glob
   `.project/tasks/tasks-*.md` for any other file whose `plan:` frontmatter
   matches the same plan — a plan can have more than one tasks file. Only if
   every one of them is now `completed` (i.e. this wasn't the last of several
   in-flight tasks files for the plan), load the plan and for each slug in
   its `features:` list flip that entry's `Status` in
   `.project/artifacts/features.md` from `tasked` to `implemented`.

8. **Commit** the work with a concise message referencing the task ID.

9. **Proceed to the next task** and repeat from step 3.

## Rules

- **Never skip a test task.** If a task has a test requirement, write and fail
  the test before any implementation begins (Principle II).
- **Stop and surface blockers** rather than working around them. If a task
  cannot be completed as written, update the tasks file with a note and ask
  the user.
- **Add Principle VI annotations** at the point of any production shortcut
  identified in the task or encountered during implementation.
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
