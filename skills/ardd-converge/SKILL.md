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

   **Before presenting the list, run
   `.claude/skills/ardd-scripts/inflight-worktrees.sh`** — it enumerates
   every *other* worktree of this repo with its branch and any `tasks-*.md`
   at `in-progress`/`completed` and checkbox progress. If a listed worktree
   already claims one of these tasks files (same filename), its real state
   lives there, not here — surface it (worktree path, branch, progress) and
   exclude/warn before the user picks, so a second run doesn't reconcile
   against state a sibling worktree is actively changing.

   Nothing pre-commits here — under this design no run commits state to the
   default branch before its work happens on a branch. (This was already
   true for `/ardd-converge` for a different reason — reconciliation's
   outcome isn't knowable until steps 4–6 run — but it now holds uniformly
   across both skills: all state rides the branch and lands on merge.)

2. **Resolve mode and delegation gate.** Read `workflow_mode` from
   `.project/artifacts/constitution.md` frontmatter (grep it; `solo` |
   `collaborative`, **absent = `solo`**). Run
   `.claude/skills/ardd-scripts/branch-info.sh` for `current`, `default`,
   and `on_default`. Nothing is committed in this step.

   **Solo mode.** If `on_default` is `false`, continue inline at step 3 —
   already isolated, state already rides this branch. If `on_default` is
   `true`, offer delegation.

   First, **check for in-flight work** using step 1's
   `inflight-worktrees.sh` output (this replaces the old harness-`TaskList`
   check — deterministic, scriptable, and it survives conversation death, so
   an abandoned subagent's worktree shows up even when no conversation
   remembers it). If another worktree is mid-run against this repo, surface
   it and ask whether to wait before starting a second delegated run.

   **Offer delegation, suggesting "yes"** — same live-smoke-test validation
   as `/ardd-implement` (2026-07-05: a real delegated worktree branched
   from `origin/<default>` and `worktree-align.sh` fast-forwarded it onto
   the coordinator's unpushed local commit). Ask:
   - "Yes, delegate to a subagent in an isolated worktree" (recommended)
   - "No, continue on the current branch without a worktree"

   If the user declines but wants isolation, a plain `git checkout -b` here
   is fine — the inline path on a branch, state riding that branch.

   On yes, delegate step 3 onward to a subagent via the `Agent` tool with
   `isolation: "worktree"`, handing it this skill's remaining steps verbatim
   and the chosen tasks file. `isolation: "worktree"` creates and names its
   own worktree/branch (no parameter points it at a pre-made one) — don't
   pre-create one or name it; the branch name is whatever the subagent
   reports back. **The delegated subagent's instructions must begin with
   these two steps, before any reconciliation:**
   1. Run `worktree-align.sh` — the worktree's own copy at
      `.claude/skills/ardd-scripts/worktree-align.sh` if it exists (it
      normally does: `install.sh` adds `.claude/skills/ardd-*/` to the
      target's `.worktreeinclude`, so the installed gitignored ardd files
      are copied into every new worktree), else the coordinator's copy by
      an absolute path the coordinator must always include in these
      instructions as the fallback (`.worktreeinclude` is skipped under a
      `WorktreeCreate` hook, older installs predate it, and the base commit
      may predate the scripts). Worktrees share the repo's object store and
      local refs, so even though the worktree branched from
      `origin/<default>` (the harness `worktree.baseRef: fresh` default —
      not steerable from prose, and it has regressed in both directions
      across harness versions, so never trust it), the local default
      branch's unpushed commits are reachable, and the script fast-forwards
      them in. If it does not print `aligned=true`, **stop and report the
      failure verbatim — do not attempt reconciliation, and never try a
      manual conflicted merge.** The same present-or-fallback rule applies
      to the other `.claude/skills/ardd-scripts/*.sh` calls in the
      remaining steps (`project-lock.sh`, `sibling-tasks-complete.sh`, `ardd-state.sh`).
   2. Verify the chosen tasks file exists at its expected path — a cheap
      proof the alignment delivered the state.

   Then the subagent proceeds through the remaining steps normally,
   committing in the worktree. It runs independently; the coordinating
   conversation is free to do other things meanwhile.

   **When the subagent reports back**, the coordinator:
   - Runs `git config --get core.bare` in the primary checkout; if `true`,
     runs `git config core.bare false` and tells the user (a known side
     effect of `Agent` worktree creation flipping the primary checkout's
     config).
   - Offers to merge the worktree branch into the default branch now,
     suggesting **yes** — eager merge keeps the in-flight window short in
     solo mode, landing code and all its state (checkbox reconciliation, the
     `→completed` flip, any register flip) together. On merge, run
     `/ardd-analyze`. On decline, note the work stays visible via
     `inflight-worktrees.sh` and `/ardd-analyze`'s in-flight section.

   A delegated subagent must **never** run `/ardd-analyze` or write
   `STATUS.md` — either traps `STATUS.md` in the worktree branch. The
   terminal analyze handoff belongs to the coordinator (or inline path).

   **Collaborative mode.** Nothing may be committed to the local default
   branch, ever (branch protection makes it unlandable anyway). If
   `on_default` is `true`, the work must move to a branch before step 3 —
   delegated worktree (same align-first preamble, in-flight check, and
   `core.bare` check) or plain `git checkout -b`. All state rides that
   branch as in solo-delegated. After the first commit, offer to push the
   branch and open a draft PR titled with the feature slug(s) — the pushed
   draft PR is collaborative mode's in-flight channel (`gh pr list --draft`),
   checked alongside `inflight-worktrees.sh`. **Never push without confirming
   with the user** (commits may be unsigned when 1Password is locked and must
   not be pushed silently). No eager local merge — merging goes through the
   PR, and the register flip rides the branch and lands when the PR
   merges.

   (History note: earlier versions persisted a `worktree_branch:` field and
   ran a post-merge held-flip step (old step 9) so `features.md` flipped only
   after a live coordinating conversation confirmed the branch merged. That
   whole machinery is gone — the flip now rides the branch and lands
   atomically on merge, so there's nothing to defer or bookkeep.)

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
   Update the frontmatter `status` to reflect the reconciled state via
   `.claude/skills/ardd-scripts/ardd-state.sh tasks-flip <file> <status>`:
   `completed` if every task is now `- [x]` with no gaps appended,
   `in-progress` otherwise. (Checkbox marks made in step 5 go through
   `ardd-state.sh task-check <file> <task-id>` too — deciding *whether*
   work is done is judgment; the mark itself is script-performed.)

   If the status is now `completed`, run
   `.claude/skills/ardd-scripts/sibling-tasks-complete.sh <this file's path>`
   — the same shared check `/ardd-implement` runs on a tasks file's own
   completion, since a plan can have more than one tasks file.

   If its `all_complete=true`, **flip the bound features now — uniformly,
   whether inline or delegated.** Load the plan and for each slug in its
   `features:` list run `.claude/skills/ardd-scripts/ardd-state.sh
   feature-flip <slug> implemented`, right here (in the worktree, if
   delegated). The flip rides the branch, so it can't reach the default
   branch until the branch merges — the register never claims
   "implemented" before the code lands, and there's no
   held-flip-until-merge step or inline/delegated split. Run
   `... touch ardd-converge` once this step's writes are done.

8. **Report:**
   - Tasks newly marked complete
   - Tasks found partial (with what remains)
   - New tasks appended
   - Any features flipped to `implemented` (the flip rides this branch and
     lands on merge)
   - Recommended next step (usually: run `/ardd-implement` to continue)

   If step 7 flipped the file to `completed`, run `/ardd-analyze` now to
   refresh `STATUS.md` — same trigger condition as `/ardd-implement`'s
   tasks-file completion. Otherwise (still `in-progress`), skip it; nothing
   changed that `STATUS.md` needs to reflect yet. (If this run is a delegated
   subagent, it does *not* run `/ardd-analyze` — see step 2; the coordinator
   does, after merge.)
