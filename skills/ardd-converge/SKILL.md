# /ardd-converge

Compare the current codebase to a chosen tasks file and append any remaining
unbuilt work as new tasks. Use after an interrupted `/ardd-implement` run or
when resuming work in a new session.

## Steps

1. **Pick a tasks file.** Glob `.project/tasks/tasks-*.md`, excluding any at
   `status: abandoned` — a superseded fork with nothing left to reconcile.
   If none remain, tell the user to run `/ardd-tasks` first. For each
   remaining file, read its frontmatter `status` and compute live progress
   from checkboxes (`x/y complete`). Present the list and ask the user which
   to reconcile. If only one exists, still confirm rather than
   auto-selecting.

   Unlike `/ardd-implement`, there's no separate coarse "work has started"
   marker to commit before delegating here — reconciliation's outcome
   (whether the file ends up `completed` or `in-progress`) isn't knowable
   until after the inspection work in steps 4–6 actually runs, so there's
   nothing meaningful to pre-commit. Picking the file first (rather than
   inside the delegated subagent, as before) just lets the coordinating
   conversation name the worktree after it and hand the subagent an
   already-resolved target.

2. **Check branch and delegate, if applicable.** Run
   `.claude/skills/ardd-scripts/branch-info.sh` for `current`, `default`,
   and `on_default`. If `on_default` is `false`, skip to step 3 (already on
   a branch/worktree — no delegation to set up here).

   If `on_default` is `true`: **check for in-flight work first** — list
   active background subagents (harness `TaskList`). If one is already
   touching this repo or its `.project/` directory, surface it to the user
   (what it's doing, since when) and ask whether to wait for it to finish
   before starting another delegated run — two worktrees racing on
   overlapping state flips to the default branch is exactly what this
   coordination check exists to catch.

   Then ask the user, defaulting the suggested answer to "yes" (reconciling
   a tasks file against the codebase can run long, same as
   `/ardd-implement`):
   - "Yes, delegate to a subagent in an isolated worktree"
   - "No, continue on the current branch without a worktree"

   On yes, delegate step 3 onward to a subagent using the `Agent` tool with
   `isolation: "worktree"` — give it this skill's remaining steps verbatim
   as its instructions, along with the chosen tasks file. `isolation:
   "worktree"` creates its own worktree and branch (there's no parameter to
   point it at a pre-made one) — do not pre-create a worktree via any other
   script first, and do not ask the user to name it; the branch name is
   reported back in the subagent's result. The subagent runs independently;
   the coordinating conversation is free to do other things while it runs.

   **As soon as the subagent reports back**, write its reported branch name
   into the tasks file's frontmatter as `worktree_branch: <branch>` and
   commit that to the current (default) branch immediately — do not hold
   this only in conversation memory. This is what lets step 9 (or a
   completely separate later run) still find the right branch on disk. On
   no, continue step 3 onward inline, without delegating, and no
   `worktree_branch:` is written.

3. **Load the chosen file.** Identify all tasks marked `- [x]` (complete) and
   `- [ ]` (incomplete).

4. **Inspect the codebase** against each incomplete task. For each `- [ ]` task:
   - Determine whether the work is actually done despite the checkbox being open
     (e.g., a previous `/ardd-implement` run completed it but didn't mark it)
   - Determine whether it is partially done
   - Determine whether it is truly not started

5. **Reconcile the task list:**
   - Mark tasks complete (`- [x]`) if the work is verifiably done in the codebase
   - Add a `[partial: <what remains>]` note inline for partially done tasks
   - Leave genuinely unstarted tasks unchanged

6. **Identify gaps** — work that exists in the codebase but has no corresponding
   task (e.g., added during a hotfix), or work implied by the artifacts that
   was never tasked. Append these as new tasks at the end of the relevant phase,
   using the next available task ID.

7. **Write the updated file back** to its original path. Run
   `.claude/skills/ardd-scripts/project-lock.sh check ardd-converge` first —
   surface any warning to the user (another invocation touched `.project/`
   recently) but proceed regardless; this is advisory, never a block.
   Update the frontmatter `status` to reflect the reconciled state:
   `completed` if every task is now `- [x]` with no gaps appended,
   `in-progress` otherwise.

   If the status is now `completed`, run
   `.claude/skills/ardd-scripts/sibling-tasks-complete.sh <this file's path>`
   — the same shared check `/ardd-implement` runs on a tasks file's own
   completion, since a plan can have more than one tasks file.

   If its `all_complete=true`: **when running inline (step 2 was declined or
   skipped)**, load the plan and for each slug in its `features:` list flip
   that entry's `Status` in `.project/artifacts/features.md` from `tasked`
   to `implemented` now, same as always. **When running as a delegated
   subagent**, do not touch `features.md` — note in this run's final report
   which feature slugs would flip, and leave the actual flip to the
   coordinating conversation's step 9, once this worktree's branch is
   merged. Either way, run `... touch ardd-converge` once this step's
   writes are done.

8. **Report:**
   - Tasks newly marked complete
   - Tasks found partial (with what remains)
   - New tasks appended
   - Any features flipped to `implemented` (or pending merge, if delegated)
   - Recommended next step (usually: run `/ardd-implement` to continue)

   If step 7 flipped the file to `completed`, run `/ardd-analyze` now to
   refresh `STATUS.md` — same trigger condition as `/ardd-implement`'s
   tasks-file completion. Otherwise (still `in-progress`), skip it; nothing
   changed that `STATUS.md` needs to reflect yet.

9. **(Coordinating conversation only, after a delegated subagent reports
   done.)** If the subagent's tasks file is `completed` with pending feature
   flips (step 7), read `worktree_branch:` from the tasks file's frontmatter
   (written to disk in step 2 — not held only in memory) and check whether
   it has already been merged: `git merge-base --is-ancestor
   <worktree_branch> main`. If it has, load the plan and perform the
   `tasked→implemented` flip in `.project/artifacts/features.md` on `main`
   immediately — the same mechanics as step 7's inline case, just performed
   here instead. If it hasn't been merged yet, tell the user the flip is
   pending merge and do not write it; re-check next time this conversation
   (or `/ardd-analyze`'s `completion-flip-check.sh`) revisits the branch. As
   with `/ardd-implement`, the tasks file's own `→completed` flip (step 7)
   is *not* relocated — it's plan-specific with
   no cross-branch conflict risk, so it stays immediate/in-worktree.
