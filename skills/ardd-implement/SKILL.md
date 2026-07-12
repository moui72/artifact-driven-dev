---
name: ardd-implement
tier: core
description: Execute tasks sequentially; offers worktree delegation, all state rides the work branch and lands on merge.
---

# /ardd-implement

Execute uncompleted tasks from a chosen tasks file sequentially. Each task is
self-contained; the agent loads only the artifacts it declares.

## Steps

1. **Pick a tasks file.** Run
   `.claude/skills/ardd-scripts/tasks-list.sh` — it lists every
   non-abandoned `.project/tasks/tasks-*.md` with status, checkbox
   progress (`x/y`), and plan binding. If it prints nothing, tell the
   user to run `/ardd-plan` first (it generates the tasks file after its
   approval checkpoint). Present the list and ask the user
   which to work on. If only one exists, still confirm rather than
   auto-selecting.

   **Before presenting the list, run
   `.claude/skills/ardd-scripts/inflight-worktrees.sh`** — it enumerates
   every *other* worktree of this repo and prints each one's branch and any
   `tasks-*.md` at `in-progress`/`completed` with checkbox progress. If a
   listed worktree already claims one of the tasks files above (same
   filename) at `in-progress`, that file's real state lives in that
   worktree, not here — surface it (worktree path, branch, progress) and
   exclude it from the pick list (or warn hard if the user insists) — the
   in-flight truth is on disk in that worktree, not in any conversation's
   memory.

2. **Resolve mode and branch state (no commit here).** Read
   `workflow_mode` from `.project/artifacts/constitution.md` frontmatter
   (grep the frontmatter, same pattern as other frontmatter reads) — one of
   `solo` | `collaborative`; **absent means `solo`**. Then run
   `.claude/skills/ardd-scripts/branch-info.sh` for `current`, `default`,
   and `on_default`. If the chosen file's status is already `completed`, run
   `/ardd-analyze` now to refresh `STATUS.md`, report success, and stop —
   nothing to branch or delegate for. Otherwise proceed to step 3.

   **Nothing is committed in this step.** Under this design all state a run
   produces — the tasks file's `ready→in-progress` flip, every checkbox, the
   `→completed` flip, and the `tasked→implemented` flip in the register —
   rides the branch the work happens on and reaches the default branch only
   on merge, atomically with the code. There is no pre-delegation flip
   commit to land on the default branch first. An abandoned worktree
   simply never lands; the default branch keeps saying `ready`/`tasked`,
   which is accurate again the moment that worktree is deleted.

3. **Delegation gate.** Behavior splits on `workflow_mode`.

   **Solo mode — offer delegation eagerly, regardless of `on_default`.**
   Being already on a feature branch is *not* a reason to run in the
   foreground: a branch isolates state, but the point of backgrounding is to
   free the focused session. So offer to delegate whether or not `on_default`
   is true. `on_default` no longer decides *whether* to offer — only *how* to
   prepare (the fold step below).

   First, **check for in-flight work** using the
   `inflight-worktrees.sh` output from step 1. If another worktree is
   mid-run against this repo, surface it (branch, tasks file, progress) and
   ask whether to wait before starting a second delegated run.

   **Consult the `delegation` knob.** Read `delegation` from
   `.project/artifacts/constitution.md` frontmatter (grep the frontmatter
   block, same as `workflow_mode`; **absent = `ask`** — schema-of-record:
   `scripts/lint-project.sh`):
   - `eager` — delegate to a background worktree subagent **without
     prompting**: treat this as an accepted "yes" and go straight to the
     preparation below. (The in-flight check above still asks when it found
     another run mid-flight — that's a safety question, not the delegation
     offer.)
   - `ask` (or absent) — **offer delegation, suggesting "yes."** Ask the
     user:
     - "Yes, delegate to a background subagent in an isolated worktree"
       (recommended)
     - "No, continue inline on the current branch"
   - `inline` — proceed inline at step 4 without offering.

   On **no** (or `delegation: inline`), continue inline at step 4 on the
   current branch (if `on_default` is `true` and the user wants isolation
   without a subagent, a plain `git checkout -b <name>` here is fine — the
   inline path on a branch, state riding that branch the same way).

   On **yes** (or `delegation: eager`), prepare based on `on_default`. A
   delegated subagent's worktree
   branches from `<default>` and is fast-forwarded onto local `<default>` by
   `worktree-align.sh`, so it can only see run state that has reached local
   `<default>`:
   - If `on_default` is `false` — a recovery path now that solo
     `/ardd-plan` no longer creates a branch (a resumed older run, or a
     branch made by hand) — **fold that
     branch into local `<default>` and return the focused session to it**:
     run `.claude/skills/ardd-scripts/fold-to-main.sh`. On `folded=true` you
     are now on `<default>` with the branch's state fast-forwarded in — a
     fast-forward authors no new commit, so the "nothing is committed in this
     step" note above still holds — proceed to delegate. On `folded=false`,
     **stop and surface the `reason=` verbatim; never resolve** (a `dirty`,
     `detached`, or `diverged` tree is the user's to sort out). At this gate
     the tasks file is still `ready` (step 4 does the `ready→in-progress`
     flip), so the fold carries only *planned* truth onto `<default>`; the
     in-flight truth then rides the subagent's worktree as usual. (Resuming a
     partially-done run on a branch folds the same way, but briefly carries
     in-progress state onto `<default>` until the subagent's branch merges.)
   - If `on_default` is `true`, delegate directly — no fold needed.

   Then delegate step 4 onward to a subagent via the `Agent` tool with
   `isolation: "worktree"`, handing it this skill's remaining steps
   verbatim, the chosen tasks file, and the current task pointer.
   `isolation: "worktree"` creates and names its own worktree/branch
   (there's no parameter to point it at a pre-made one) — do not pre-create
   a worktree with any other script, and do not name it; the branch name is
   whatever the subagent reports back. **The delegated subagent's
   instructions must begin with these two steps, before any task work:**
   1. Run `worktree-align.sh` — the worktree's own copy at
      `.claude/skills/ardd-scripts/worktree-align.sh` if it exists, else
      the coordinator's copy by absolute path. It normally exists:
      `install.sh` adds `.claude/skills/ardd-*/` to the target's
      `.worktreeinclude`, so Claude Code copies the installed (gitignored)
      ardd files into every new worktree. But the coordinator must still
      expand `<primary-checkout>/.claude/skills/ardd-scripts/
      worktree-align.sh` to a real absolute path in the subagent's
      instructions as the fallback — `.worktreeinclude` is skipped when a
      `WorktreeCreate` hook is configured, older installs predate it, and
      a worktree's base commit may predate the scripts entirely. Git
      worktrees share the repo's object store and local refs, so wherever
      the worktree branched from (never trust the harness base in either
      direction), the local default branch's unpushed commits are
      reachable, and the script fast-forwards them into the fresh branch. If it does not print `aligned=true`, **stop and
      report the failure output verbatim — do not attempt any task, and
      never try a manual conflicted merge.** The same present-or-fallback
      rule applies to every other `.claude/skills/ardd-scripts/*.sh` call
      in the remaining steps (`project-lock.sh`,
      `sibling-tasks-complete.sh`, `ardd-state.sh`): if the worktree copy
      is missing, use the coordinator's absolute path.
   2. Verify the chosen tasks file exists at its expected path — a cheap
      end-to-end proof the alignment actually delivered the expected state.

   Then the subagent flips the tasks file `ready→in-progress`
   (`ardd-state.sh tasks-flip <file> in-progress`) and commits that *in
   the worktree*, and proceeds through the remaining steps
   normally, committing per task as usual. The subagent runs independently;
   the coordinating conversation is free to do other things meanwhile.

   **When the subagent reports back**, the coordinator:
   - Runs `git config --get core.bare` in the primary checkout; if it prints
     `true`, runs `git config core.bare false` and tells the user (a known
     side effect of `Agent` worktree creation flipping the primary
     checkout's config, which otherwise breaks ordinary git there).
   - Consults the **`merge_policy` knob**: read `merge_policy` from
     `.project/artifacts/constitution.md` frontmatter (grep the frontmatter
     block; **absent = `ask`** — schema-of-record:
     `scripts/lint-project.sh`). Solo mode only — collaborative mode merges
     through the PR and never consults it.
     - `auto` — merge the **subagent-reported** branch (never an in-memory
       name) into the local default branch now, without prompting, when the
       merge fast-forwards or completes without conflicts; then run the
       existing post-merge steps unchanged (`/ardd-analyze`). On **any**
       conflict: `git merge --abort`, surface the conflict, and fall back
       to asking — never auto-resolve, not even the disposable report
       files (their take-either-side rule stays an interactive judgment
       until the merge-driver feature lands).
     - `ask` (or absent) — offer to merge the worktree branch into the
       default branch now,
       suggesting **yes** — eager merge is what keeps the in-flight window
       short in solo mode, landing code and all its state (checkboxes,
       `→completed`, any register flip) together. Single-writer report
       files (STATUS.md, DEFECTS.md, SYNC.md, audit.md) are disposable
       at merge/rebase: take either side without deliberation — never
       hand-reconcile, never re-apply — and let the owning skill
       regenerate from disk. Conflict markers in a generated report are
       noise, not data loss.
       On merge, run `/ardd-analyze`. On decline, note the work stays visible via
       `inflight-worktrees.sh` and `/ardd-analyze`'s in-flight section until
       merged.

   Note: a delegated subagent must **never** run `/ardd-analyze` or write
   `STATUS.md` — either would trap `STATUS.md` inside the worktree branch.
   The terminal analyze handoff belongs to the coordinator (or the inline
   path), never the delegated subagent.

   **Collaborative mode.** Nothing may be committed to the local default
   branch, ever — branch protection makes it unlandable anyway. If
   `on_default` is `true`, the work *must* move to a branch before step 4:
   either a delegated worktree (same align-first subagent preamble,
   in-flight check, and `core.bare` check as solo mode) or a plain
   `git checkout -b`. All state rides that branch exactly as in
   solo-delegated. After the first commit, offer to push the branch and open
   a draft PR titled with the feature slug(s) — that pushed draft PR is
   collaborative mode's in-flight visibility channel (`gh pr list --draft`),
   checked alongside `inflight-worktrees.sh` in the in-flight step. **Never
   push without confirming with the user** (repo convention: commits may be
   unsigned when 1Password is locked and must not be pushed silently). There
   is no eager local merge in collaborative mode — merging happens through
   the PR, and the register flip rides the branch and lands when the PR
   merges, atomically.

4. **Flip to `in-progress` (if needed), then find the next uncompleted
   task.** If the file's status is still `ready` (a first-task run on the
   inline path — the delegated path already flipped it in step 3's
   preamble), run `.claude/skills/ardd-scripts/ardd-state.sh tasks-flip
   <file> in-progress` and commit that now, on the current branch. This
   flip rides the branch like all other state — there is no separate
   default-branch pre-commit. Then locate the next uncompleted task via
   `ardd-state.sh next-task <file>`; no further status flip in this step.

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

8. **Mark the task complete**: `.claude/skills/ardd-scripts/ardd-state.sh
   task-check <file> <task-id>`. If this was the last incomplete task
   (`ardd-state.sh next-task <file>` exits 1), run `.claude/skills/
   ardd-scripts/project-lock.sh check ardd-implement` first — surface any
   warning to the user (another invocation touched `.project/` recently)
   but proceed regardless; this is advisory, never a block. Then run
   `ardd-state.sh tasks-flip <file> completed`, and run
   `.claude/skills/ardd-scripts/sibling-tasks-complete.sh <this file's path>`
   — it reports every tasks file bound to the same plan (a plan can have
   more than one) and whether they're collectively done.

   If its `all_complete=true`, **flip the bound features now — uniformly,
   whether inline or delegated.** Load the plan and for each slug in its
   `features:` list run `ardd-state.sh feature-flip <slug> implemented`,
   right here (in the worktree, if this is a delegated run) — the flip
   rides the branch and cannot reach the default branch before the code
   does. Run `... touch ardd-implement` once this step's writes are done.

   **On the inline (non-delegated) path, this is the run's terminal step:**
   once step 9 commits this final work, **run `/ardd-analyze` now** to refresh
   `STATUS.md` — don't rely on the next loop iteration's early-exit (step 2)
   to discover completion after the fact. A delegated subagent must **not**
   run it here (see the note in step 3); its `/ardd-analyze` runs on the
   coordinator after the worktree branch merges.

9. **Commit** the work with a concise message referencing the task ID.

10. **Proceed to the next task** and repeat from step 4.

## Rules

- **Never skip a test task.** Follow the constitution's declared testing
  paradigm (step 6) — under TDD, write and fail the test before any
  implementation begins; under test-after or no stated paradigm, write and
  pass it as described in step 6. Don't assume TDD or reference a specific
  principle number if the constitution doesn't name one.
- **`completed` is terminal.** A tasks file that has reached
  `status: completed` never reopens — never edit its status back to an
  earlier value or invent a new one. Failures discovered after completion
  (a bug in the delivered work, a verification pass that finds problems)
  are new work: capture them with `/ardd-feedback` and let the next
  `/ardd-plan` consume them.
- **Stop and surface blockers** rather than working around them. If a task
  cannot be completed as written, update the tasks file with a note and ask
  the user.
- **Add Production Annotations** at the point of any production shortcut
  identified in the task or encountered during implementation, per the
  convention in the constitution's Development Workflow section.
- **Do not modify artifacts** during implementation. If a decision in an artifact
  turns out to be wrong, stop, surface it, and let the user run `/ardd-refine` first.
  The one exception is flipping a bound feature's register status
  (`ardd-state.sh feature-flip <slug> implemented`) on task-file completion
  (step 8, uniformly whether inline or delegated — the flip rides the
  branch and lands only on merge) — that's status bookkeeping, not a
  design decision.
- **Do not touch `DEFECTS.md`.** If a task incidentally reveals a pre-existing
  code-vs-artifact violation unrelated to the task itself, don't write to
  `.project/DEFECTS.md` directly — that would break its single-writer
  ownership by `/ardd-verify`. Report the finding in the task's output instead
  and tell the user to run `/ardd-verify` to capture it properly on its next
  full pass.
