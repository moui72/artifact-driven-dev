# 0001 — Branch identity bugs and the move to worktree-native state

_Recorded 2026-07-06 (events June–July 2026). Source-repo history only —
never installed into targets._

Getting the branch-identity question wrong produced three real bugs, and
their fixes are why the current design looks the way it does. Bugs #1 and
#2 describe machinery (`worktree_branch:` persistence, a post-merge
held-flip step) that worktree-native state later removed entirely; they're
recorded because they document *why* in-memory branch names and
wrong-branch ancestry checks are traps, which still applies.

## Bug #1 — the ephemeral-name mismatch

An early version called a hand-built `worktree-info.sh` to create one
branch, delegated via `Agent` (which silently created a *different*
worktree/branch of its own), then checked merge-ancestry against the
first, empty branch — which trivially reported "merged" and flipped the
feature register to `implemented` while the real code sat unmerged
elsewhere. Fixed by deleting `worktree-info.sh` and using the
`Agent`-reported branch directly. `worktree-info.sh` is also the
cautionary tale behind Constitution Principle VIII (check tool idioms
before building custom mechanism): it duplicated what the `Agent` tool
already does, incompatibly.

## Bug #2 — the fallback detector read the wrong field

Even after that fix, `completion-flip-check.sh` (the orphaned-flip
detector for when the coordinating conversation is gone by merge time)
kept reading the *plan's* `branch:` field — unrelated to the ephemeral
worktree branch — so it silently never caught the case it exists for.
Fixed at the time by persisting `worktree_branch:` into the tasks file
and having the check read that first. (The field is legacy now — nothing
writes it — but the check still honors it for old files.)

## Bug #3 — the bug that killed state-commit-before-branch

The earlier design pre-committed coarse state to the default branch
before delegating. A live smoke test (2026-07-04/05: committing a
throwaway plan+tasks file, delegating via `Agent` with
`isolation: "worktree"`, and inspecting the result rather than reasoning
about it) found the delegated worktree's branch had a merge-base with
`origin/main`, not the coordinator's branch — it never saw either
pre-delegation commit. Root cause: the harness's `worktree.baseRef`
setting (default `fresh` branches from `origin/<default>`; `head` from
local HEAD), not overridable from skill prose, and per the harness issue
tracker it has regressed in both directions across versions — so neither
value can be trusted. The fix is `worktree-align.sh`: the subagent
deterministically fast-forwards the local default branch in as its first
act and refuses to proceed (`aligned=false`) if it can't.

The same live test surfaced that `Agent` worktree creation flipped the
primary checkout's `.git/config` to `core.bare = true`, breaking ordinary
git there until manually reverted — which is why the coordinator checks
exactly that after every delegated run.

A follow-up live validation (2026-07-05) confirmed the align path end to
end: a real delegated worktree based well behind local state
fast-forwarded cleanly onto an unpushed local commit (`aligned=true`);
the `core.bare` corruption did not reproduce on that run, but the
coordinator's check stays.

## Why /ardd-plan never delegates to a worktree

Plan-drafting was briefly made "consistent with implement/converge"
(delegable to a worktree) and reverted: the draft plan file is itself the
artifact `/ardd-tasks` needs to see, and `/ardd-tasks` globs
`.project/plans/` on whatever branch it's invoked from — isolating the
plan in a worktree traps it there until a manual merge, severing the
plan→tasks handoff. Remember this if the consistency temptation recurs.
