# Parallel work: delegation, worktrees, and merging

How ArDD runs implementation in the background, several runs at once, and
what happens when branches meet. This is the deepest part of the system;
the mental model comes first, the mechanics after.

## The model: state rides the branch

Every piece of state a run produces — the tasks file's
`ready → in-progress → completed` flips, its checkboxes, and the feature
register's `tasked → implemented` flip — is committed **on the branch the
work happens on** and reaches your default branch only when that branch
merges, atomically with the code.

Consequences worth internalizing:

- The default branch means **merged truth**; worktrees (and feature
  branches) mean **in-flight truth**.
- The register never claims work is done before the code has landed.
- An abandoned run never poisons the default branch — main keeps saying
  `ready`/`tasked`, which becomes accurate again the moment the worktree
  is deleted.
- Merge is the single atomic event. There is no separate bookkeeping
  step to forget.

(The design history — why the earlier "commit state before branching"
approach died — is in decision record
[0001](https://github.com/moui72/artifact-driven-dev/blob/main/docs/decisions/0001-branch-identity-and-worktree-native-state.md).)

## Solo mode: the delegation cycle

With `workflow_mode: solo` (or absent), `/ardd-implement` offers to
delegate execution to a background subagent in an isolated git worktree —
**eagerly, regardless of which branch you're on** (a branch isolates
state; backgrounding is about freeing your session). The constitution's
`delegation` knob makes the gate automatic (`eager`), interactive (`ask`),
or off (`inline`) — see [configuration.md](../reference/configuration.md).

One full cycle:

1. **In-flight check** — `inflight-worktrees.sh` enumerates sibling
   worktrees and their tasks-file progress. Other runs in flight are
   information, not a reason to wait; only a tasks file a live worktree
   already claims is excluded from the pick.
2. **Fold, if needed** — a run already on a feature branch is
   fast-forward-folded into local `<default>` first (`fold-to-main.sh`),
   so the delegated worktree can see its state. Anything non-trivial
   (`dirty`, `diverged`) refuses and is yours to sort out.
3. **Align** — the subagent's mandatory first act is
   `worktree-align.sh`, which fast-forwards the local default branch's
   unpushed commits into the fresh worktree branch. No `aligned=true`,
   no work.
4. **Execute** — the subagent flips the tasks file `in-progress`, works
   the tasks, commits per task, and flips register state at completion —
   all in the worktree.
5. **Merge** — on report-back the coordinator offers an eager merge (or
   merges automatically under `merge_policy: auto` when fast-forward or
   conflict-free; a conflict always aborts and asks, never auto-resolves).
6. **Reap** — after a successful merge, `worktree-reap.sh` removes the
   landed worktree and deletes its branch (`git branch -d`, never
   forced). Unmerged or dirty worktrees are reported and left alone.

**Fan-out**: with several independent `ready` tasks files, the pick can be
a multi-select — one parallel worktree run per file, each merging and
reaped as it completes. The unit of parallelism is the tasks file, never
phases within one — so to fan out N features, plan them *separately* (one
`/ardd-plan <slug>` run per feature): passing several slugs to a single
plan run produces one plan, one tasks file, and therefore one run.

## Collaborative mode: branches and draft PRs

With `workflow_mode: collaborative`, nothing is ever committed to the
*local* default branch. Work always moves to a branch; after the first
commit the skill offers to push and open a **draft PR** titled with the
feature slug(s) — that pushed PR is the mode's shared in-flight signal
(`gh pr list --draft`). Merging happens through the PR (never an eager
local merge; `merge_policy` is not consulted), and the register flip rides
the branch to land when the PR merges. Pushes always require explicit
confirmation.

One extra constraint: a delegated worktree branches from
`origin/<default>`, so plan and tasks files must have reached the remote
before delegated implementation can see them. Solo mode doesn't have this
constraint — align carries unpushed local commits in.

## Visibility: how you see in-flight work

- `/ardd-status`'s **In Flight** section — per-worktree branch, tasks
  file, and checkbox progress; "merged, reapable" candidates; draft PRs
  in collaborative mode.
- The same data comes from `inflight-worktrees.sh` directly. It reads
  disk, not memory — an abandoned subagent's worktree is still visible
  when no conversation remembers it.

**A dead delegated run** (the session that launched it is gone) is
therefore never lost, just stranded: its worktree keeps showing up In
Flight until you decide. To keep the work, merge the worktree's branch
into your default branch — its state (checkboxes, flips) lands with the
code, and the next merge-time reap removes the worktree. To discard it,
delete the worktree and its branch by hand — the default branch's
`ready`/`tasked` claims become accurate again the moment it's gone (the
reap script deliberately never deletes unmerged work for you).

## When `.project/` files conflict on merge

The four generated report files (`STATUS.md`, `DEFECTS.md`, `TRACKER.md`,
`audit.md`) are **disposable at merge**: take either side without
deliberation — never hand-reconcile — and let the owning skill regenerate
from disk. This is git mechanism, not just convention: install.sh ships
`.project/.gitattributes` marking them `merge=ours`, and with the
per-clone opt-in

```sh
git config merge.ours.driver true
```

they merge clean automatically, keeping the current side. (Git refuses to
honor repo-committed driver definitions, hence the opt-in.) Without it,
git degrades to a normal text merge and the take-either-side rule covers
it.

`.project/features/` is per-feature files, so independently-added features
can't conflict at all; a conflict *inside* one file means the same feature
advanced on two branches — take the further-along status and run
`/ardd-lint`.

A related note on the concurrency guard: `project-lock.sh` is a warn-only
marker with no visibility across worktrees (each worktree has its own
`.project/`). It's insurance against two sessions sharing one checkout,
not cross-worktree locking — the worktree model above is what actually
keeps parallel runs safe.

## If delegation misbehaves

The worktree path leans on harness behavior that has regressed before
(`worktree.baseRef`); `worktree-align.sh` compensates, and a subagent that
can't align refuses rather than working on the wrong base. If delegation
misbehaves anyway, the blessed fallback is **a plain branch, inline**:
decline the offer, `git checkout -b <name>`, and run the same skill in the
foreground — all state rides that branch identically and lands on merge.
A harness regression degrades the workflow to ordinary branching; it never
blocks it.
