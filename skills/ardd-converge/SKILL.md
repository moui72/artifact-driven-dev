# /ardd-converge

Compare the current codebase to a chosen tasks file and append any remaining
unbuilt work as new tasks. Use after an interrupted `/ardd-implement` run or
when resuming work in a new session.

## Steps

1. **Pick a tasks file.** Glob `.project/tasks/tasks-*.md`. If none exist,
   tell the user to run `/ardd-tasks` first. For each file, read its
   frontmatter `status` and compute live progress from checkboxes (`x/y
   complete`). Present the list and ask the user which to reconcile. If only
   one exists, still confirm rather than auto-selecting.

2. **Load the chosen file.** Identify all tasks marked `- [x]` (complete) and
   `- [ ]` (incomplete).

3. **Inspect the codebase** against each incomplete task. For each `- [ ]` task:
   - Determine whether the work is actually done despite the checkbox being open
     (e.g., a previous `/ardd-implement` run completed it but didn't mark it)
   - Determine whether it is partially done
   - Determine whether it is truly not started

4. **Reconcile the task list:**
   - Mark tasks complete (`- [x]`) if the work is verifiably done in the codebase
   - Add a `[partial: <what remains>]` note inline for partially done tasks
   - Leave genuinely unstarted tasks unchanged

5. **Identify gaps** — work that exists in the codebase but has no corresponding
   task (e.g., added during a hotfix), or work implied by the artifacts that
   was never tasked. Append these as new tasks at the end of the relevant phase,
   using the next available task ID.

6. **Write the updated file back** to its original path. Update the
   frontmatter `status` to reflect the reconciled state: `completed` if every
   task is now `- [x]` with no gaps appended, `in-progress` otherwise.

7. **Report:**
   - Tasks newly marked complete
   - Tasks found partial (with what remains)
   - New tasks appended
   - Recommended next step (usually: run `/ardd-implement` to continue)
