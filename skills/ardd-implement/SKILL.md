# /ardd-implement

Execute uncompleted tasks from `.project/tasks/tasks.md` sequentially.
Each task is self-contained; the agent loads only the artifacts it declares.

## Steps

1. **Load `.project/tasks/tasks.md`.** If it does not exist, tell the user to
   run `/ardd-tasks` first.

2. **Find the next uncompleted task** (first `- [ ]` in document order).
   If all tasks are complete, report success and stop.

3. **Load declared artifacts.** Parse the `[artifacts: ...]` tag on the task
   and read each named file from `.project/artifacts/<name>.md`.

4. **Execute the task:**
   - For test tasks: write the test first, confirm it fails, then stop at the
     red state. Mark the test task complete. The paired implementation task
     follows.
   - For implementation tasks: implement the minimum code to satisfy the task
     description and make the paired test(s) pass.
   - For research or decision tasks: produce the output described and write it
     to the appropriate location.

5. **Verify** the task is complete: tests pass, the feature works as described,
   no regressions in previously completed tasks.

6. **Mark the task complete** in `tasks.md`: change `- [ ]` to `- [x]`.

7. **Commit** the work with a concise message referencing the task ID.

8. **Proceed to the next task** and repeat from step 2.

## Rules

- **Never skip a test task.** If a task has a test requirement, write and fail
  the test before any implementation begins (Principle II).
- **Stop and surface blockers** rather than working around them. If a task
  cannot be completed as written, update `tasks.md` with a note and ask the user.
- **Add Principle VI annotations** at the point of any production shortcut
  identified in the task or encountered during implementation.
- **Do not modify artifacts** during implementation. If a decision in an artifact
  turns out to be wrong, stop, surface it, and let the user run `/ardd-refine` first.
