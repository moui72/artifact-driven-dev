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

`tasks-worktree-state-hygiene-5dd6.md` is now `status: completed` — all 14
tasks done on the `worktree-state-hygiene` branch (commits `168a6e6`
through `25d3ba8`, all unsigned — 1Password was locked this session; **the
whole range needs re-signing before this branch is pushed**). It reworked
the branch/worktree gate across `/ardd-plan`, `/ardd-tasks`,
`/ardd-implement`, `/ardd-converge` so coarse state (`features.md`
`Status`, plan/tasks frontmatter) lands on the default branch promptly
while long-running work delegates to a worktree subagent; added
`scripts/worktree-info.sh` + its test and wired it into `install.sh`,
`hooks/pre-commit`, and CI. Plan's `features: []`, so nothing in
`features.md` changed.

Next: review the diff, re-sign the commit range, then merge
`worktree-state-hygiene` into `main` (this repo's dogfooded `.project/`
files were not exempted from that — they're on this branch too).

Separately, unrelated to this plan: `tasks-process-review-fixes-cfd8.md`
(bound to the already-merged `process-review-fixes` branch, PR #1) is at
`status: ready` with none of its tasks checked off, even though its branch
is merged into `main` — worth confirming whether that work actually landed
before treating it as done. No code-vs-artifact baseline has ever been
taken — run `/ardd-verify` when convenient.
