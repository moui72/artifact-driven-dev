# /ardd-implement

Execute uncompleted tasks from a chosen tasks file sequentially. Each task is
self-contained; the agent loads only the artifacts it declares.

## Steps

1. **Pick a tasks file.** Glob `.project/tasks/tasks-*.md`, excluding any at
   `status: abandoned` — a superseded fork with nothing left to execute
   against. If none remain, tell the user to run `/ardd-tasks` first. For
   each remaining file, read its frontmatter `status` and compute live
   progress from checkboxes (`x/y complete`). Present the list and ask the
   user which to work on. If only one exists, still confirm rather than
   auto-selecting.

2. **Establish start state, and commit it before any delegation decision.**
   If the chosen file's status is already `completed`, run `/ardd-analyze`
   now to refresh `STATUS.md`, report success, and stop — nothing to check
   branches or delegate for. Otherwise, if this is the first task being
   started in this file (status is `ready`), flip the file's frontmatter
   `status` to `in-progress` and commit that now, on whatever branch this
   run was invoked from. This is the coarse "work has started" signal, and
   it must be committed here — before step 3 even considers creating a
   worktree — so it reaches the default branch immediately rather than
   being trapped inside a worktree that doesn't exist yet. (If status was
   already `in-progress`, this is a continuation run — nothing new to
   commit here.)

3. **Check branch and delegate, if applicable.** Run
   `.claude/skills/ardd-scripts/branch-info.sh` for `current`, `default`,
   and `on_default`. If `on_default` is `false`, skip to step 4 (already on
   a branch/worktree — no delegation to set up here).

   If `on_default` is `true`: **check for in-flight work first** — list
   active background subagents (harness `TaskList`). If one is already
   touching this repo or its `.project/` directory, surface it to the user
   (what it's doing, since when) and ask whether to wait for it to finish
   before starting another delegated run — two worktrees racing on
   overlapping state flips to the default branch is exactly what this
   coordination check exists to catch.

   Then ask the user, defaulting the suggested answer to "yes" (executing
   tasks is exactly the kind of long-running, code-producing work this gate
   exists to isolate):
   - "Yes, delegate to a subagent in an isolated worktree"
   - "No, continue on the current branch without a worktree"

   On yes, delegate step 4 onward to a subagent using the `Agent` tool with
   `isolation: "worktree"` — give it this skill's remaining steps verbatim
   as its instructions, along with the chosen tasks file and current task
   pointer. `isolation: "worktree"` creates its own worktree and branch
   (there's no parameter to point it at a pre-made one, and no need for
   one: it branches from the current commit, which already carries step 2's
   flip) — do not pre-create a worktree via any other script first, and do
   not ask the user to name it; the branch name isn't chosen, it's reported
   back in the subagent's result. The subagent runs independently; the
   coordinating conversation is free to do other things while it runs.

   **As soon as the subagent reports back** (whether or not all tasks are
   done yet), write its reported branch name into the tasks file's
   frontmatter as `worktree_branch: <branch>` and commit that to the
   current (default) branch immediately — do not hold this only in
   conversation memory. This is what lets step 11 (or, if this conversation
   ends first, a completely separate later run) still find the right
   branch on disk. On no, continue step 4 onward inline, without
   delegating — behavior is unchanged from before this gate existed, and no
   `worktree_branch:` is written.

4. **Find the next uncompleted task** (first `- [ ]` in document order) in
   the chosen file. (Its status is already `in-progress` by this point, per
   step 2 — this step only locates the next unchecked box, no status flip.)

5. **Load declared artifacts.** Parse the `[artifacts: ...]` tag on the task
   and read each named file from `.project/artifacts/<name>.md`.

6. **Execute the task:**
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

7. **Verify** the task is complete: tests pass, the feature works as described,
   no regressions in previously completed tasks.

8. **Mark the task complete** in the tasks file: change `- [ ]` to `- [x]`. If
   this was the last incomplete task, run `.claude/skills/ardd-scripts/
   project-lock.sh check ardd-implement` first — surface any warning to the
   user (another invocation touched `.project/` recently) but proceed
   regardless; this is advisory, never a block. Then flip the file's
   frontmatter `status` to `completed`, and run
   `.claude/skills/ardd-scripts/sibling-tasks-complete.sh <this file's path>`
   — it reports every tasks file bound to the same plan (a plan can have
   more than one) and whether they're collectively done.

   If its `all_complete=true`: **when running inline (step 3 was declined or
   skipped)**, load the plan and for each slug in its `features:` list flip
   that entry's `Status` in `.project/artifacts/features.md` from `tasked`
   to `implemented` now, same as always. **When running as a delegated
   subagent**, do not touch `features.md` — note in this run's final report
   which feature slugs would flip, and leave the actual flip to the
   coordinating conversation's step 11, once this worktree's branch is
   merged. Either way, run `... touch ardd-implement` once this step's
   writes are done.

9. **Commit** the work with a concise message referencing the task ID.

10. **Proceed to the next task** and repeat from step 4.

11. **(Coordinating conversation only, after a delegated subagent reports
    done.)** If the subagent's tasks file is `completed` with pending
    feature flips (step 8), read `worktree_branch:` from the tasks file's
    frontmatter (written to disk in step 3 — not held only in memory, so
    this works even if a different conversation ends up running this step)
    and check whether it has already been merged: `git merge-base
    --is-ancestor <worktree_branch> main`. If it has, load the plan and
    perform the `tasked→implemented` flip in `.project/artifacts/
    features.md` on `main` immediately — the same mechanics as step 8's
    inline case, just performed here instead. If it hasn't been merged yet,
    tell the user the flip is pending merge and do not write it; re-check
    the next time this conversation (or `/ardd-analyze`'s
    `completion-flip-check.sh`) revisits the branch. This is what keeps
    `features.md` from claiming "implemented" before the code has actually
    landed on the default branch — checking against the wrong branch here
    (e.g. the plan's own `branch:` field, which records something
    unrelated) would silently defeat the entire point of this step.

## Rules

- **Never skip a test task.** Follow the constitution's declared testing
  paradigm (step 6) — under TDD, write and fail the test before any
  implementation begins; under test-after or no stated paradigm, write and
  pass it as described in step 6. Don't assume TDD or reference a specific
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
  `features.md` on task-file completion (step 8 when running inline, step 11
  when running as a delegated subagent and merged) — that's status
  bookkeeping, not a design decision.
- **Do not touch `DEFECTS.md`.** If a task incidentally reveals a pre-existing
  code-vs-artifact violation unrelated to the task itself, don't write to
  `.project/DEFECTS.md` directly — that would break its single-writer
  ownership by `/ardd-verify`. Report the finding in the task's output instead
  and tell the user to run `/ardd-verify` to capture it properly on its next
  full pass.
