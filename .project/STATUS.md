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

`tasks-worktree-state-hygiene-5dd6.md` is now `status: completed` — all 21
tasks done (14 original + 7 gap tasks across three `/ardd-converge`
reconciliation passes mid-session, T015–T021) on the
`worktree-state-hygiene` branch. **Every commit on this branch is
unsigned** — 1Password was locked this session — **the whole range needs
re-signing before this branch is pushed**.

Final shape: `/ardd-implement`/`/ardd-converge` default to delegating to a
subagent via the `Agent` tool's own `isolation: "worktree"` (no custom
worktree script — a hand-built one, `worktree-info.sh`, was tried and
removed after review found it both redundant with the Agent tool and,
worse, incompatible with it). The coarse `ready→in-progress` flip still
commits to the default branch before delegating. The Agent-reported branch
is now *persisted to the tasks file's own `worktree_branch:` frontmatter*
the moment the subagent reports back — not just held in conversation
memory — after a second review found the post-merge completion-flip
fallback detector (`completion-flip-check.sh`) had no durable way to see
it and was silently checking the wrong (plan's) branch field instead.
`/ardd-plan` deliberately never delegates — its draft plan file is itself
the state `/ardd-tasks` needs to see, so a worktree would trap it there
until manual merge. Plan's `features: []`, so nothing in `features.md`
changed from any of this.

Next: review the diff, re-sign the commit range, then merge
`worktree-state-hygiene` into `main` (this repo's dogfooded `.project/`
files were not exempted from that — they're on this branch too). Given
how many delegation-composition bugs surfaced from reasoning alone, it's
worth actually exercising one delegated `/ardd-implement` run against a
throwaway tasks file before relying on this in practice.

Separately, unrelated to this plan: `tasks-process-review-fixes-cfd8.md`
(bound to the already-merged `process-review-fixes` branch, PR #1) is at
`status: ready` with none of its tasks checked off, even though its branch
is merged into `main` — worth confirming whether that work actually landed
before treating it as done. No code-vs-artifact baseline has ever been
taken — run `/ardd-verify` when convenient.
