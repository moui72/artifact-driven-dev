# artifact-driven-dev — Project Status

_Updated: 2026-07-04. Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ | — |

## Open Questions

None.

## Code-vs-Artifact Defects

Never checked — run `/ardd-verify` to compare artifacts against the codebase.

## Feedback

None open — `feedback-plan-defects-check-4cdb.md` was incorporated into
`plan-worktree-state-hygiene-2026-07-04.md` this run and is now
`status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 2 implemented — see `.project/artifacts/features.md`.

## Recommended Next Step

`tasks-worktree-state-hygiene-5dd6.md` is now `status: completed` — all 17
tasks done (14 original + 3 gap tasks T015–T017 found by a
`/ardd-converge` reconciliation mid-session) on the `worktree-state-hygiene`
branch. **Every commit on this branch is unsigned** — 1Password was locked
this session — **the whole range needs re-signing before this branch is
pushed**.

Final shape: `/ardd-implement`/`/ardd-converge` default to creating a
worktree and delegating to a subagent, with the coarse
`ready→in-progress` flip committed to the default branch *before* the
worktree is created (satisfying `worktree-info.sh`'s own precondition —
the first attempt at this, T004/T007/T010, skipped that ordering
entirely, which a mid-session `/ardd-converge` + advisor review caught).
`/ardd-plan` deliberately never delegates — its draft plan file is itself
the state `/ardd-tasks` needs to see, so a worktree would trap it there
until manual merge. `/ardd-analyze` now also detects and offers to fix
orphaned completion flips (a merged branch whose feature never got flipped
to `implemented` because no conversation checked back after merge) via the
new `scripts/completion-flip-check.sh`. Plan's `features: []`, so nothing
in `features.md` changed from any of this.

Next: review the diff, re-sign the commit range, then merge
`worktree-state-hygiene` into `main` (this repo's dogfooded `.project/`
files were not exempted from that — they're on this branch too).

Separately, unrelated to this plan: `tasks-process-review-fixes-cfd8.md`
(bound to the already-merged `process-review-fixes` branch, PR #1) is at
`status: ready` with none of its tasks checked off, even though its branch
is merged into `main` — worth confirming whether that work actually landed
before treating it as done. No code-vs-artifact baseline has ever been
taken — run `/ardd-verify` when convenient.
