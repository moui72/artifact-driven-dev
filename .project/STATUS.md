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

`tasks-worktree-state-hygiene-5dd6.md` is now `status: completed` — all 19
tasks done (14 original + 5 gap tasks across two `/ardd-converge`
reconciliation passes mid-session, T015–T019) on the
`worktree-state-hygiene` branch. **Every commit on this branch is
unsigned** — 1Password was locked this session — **the whole range needs
re-signing before this branch is pushed**.

Final shape: `/ardd-implement`/`/ardd-converge` default to delegating to a
subagent via the `Agent` tool's own `isolation: "worktree"` (no custom
worktree script — a hand-built one, `worktree-info.sh`, was tried and
removed after an advisor review found it was both redundant with the
Agent tool and, worse, incompatible with it: composing the two produced a
false "merged" detection that would have flipped `features.md` to
`implemented` while the real code sat on a different, unmerged branch).
The coarse `ready→in-progress` flip still commits to the default branch
before delegating; the post-merge completion-flip check now correctly
uses the branch the subagent actually reports back. `/ardd-plan`
deliberately never delegates — its draft plan file is itself the state
`/ardd-tasks` needs to see, so a worktree would trap it there until manual
merge. `/ardd-analyze` now also detects and offers to fix orphaned
completion flips via `scripts/completion-flip-check.sh`. Plan's `features:
[]`, so nothing in `features.md` changed from any of this.

Next: review the diff, re-sign the commit range, then merge
`worktree-state-hygiene` into `main` (this repo's dogfooded `.project/`
files were not exempted from that — they're on this branch too).

Separately, unrelated to this plan: `tasks-process-review-fixes-cfd8.md`
(bound to the already-merged `process-review-fixes` branch, PR #1) is at
`status: ready` with none of its tasks checked off, even though its branch
is merged into `main` — worth confirming whether that work actually landed
before treating it as done. No code-vs-artifact baseline has ever been
taken — run `/ardd-verify` when convenient.
