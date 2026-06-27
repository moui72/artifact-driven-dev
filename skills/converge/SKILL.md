# /converge

Compare the current codebase to `.project/tasks/tasks.md` and append any
remaining unbuilt work as new tasks. Use after an interrupted `/implement` run
or when resuming work in a new session.

## Steps

1. **Load `.project/tasks/tasks.md`.** Identify all tasks marked `- [x]`
   (complete) and `- [ ]` (incomplete).

2. **Inspect the codebase** against each incomplete task. For each `- [ ]` task:
   - Determine whether the work is actually done despite the checkbox being open
     (e.g., a previous `/implement` run completed it but didn't mark it)
   - Determine whether it is partially done
   - Determine whether it is truly not started

3. **Reconcile the task list:**
   - Mark tasks complete (`- [x]`) if the work is verifiably done in the codebase
   - Add a `[partial: <what remains>]` note inline for partially done tasks
   - Leave genuinely unstarted tasks unchanged

4. **Identify gaps** — work that exists in the codebase but has no corresponding
   task (e.g., added during a hotfix), or work implied by the artifacts that
   was never tasked. Append these as new tasks at the end of the relevant phase,
   using the next available task ID.

5. **Write the updated `tasks.md`** back to `.project/tasks/tasks.md`.

6. **Report:**
   - Tasks newly marked complete
   - Tasks found partial (with what remains)
   - New tasks appended
   - Recommended next step (usually: run `/implement` to continue)
