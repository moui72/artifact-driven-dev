# artifact-driven-dev — Project Status

_Updated: 2026-07-06 (post-/ardd-implement, ardd-state-determinism complete). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.0) | — |

## Open Questions

None.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-06 (third pass):
the behavioral-smoke-tier claim still exceeds coverage (2 scenarios
exist, converge/feedback/refine/sync paths uncovered, none executable
until the API key is provisioned). This is the reduced-scope residue of
already-surfaced 970d935b — /ardd-plan won't re-prompt it. The BSD-sed
defect (58bd7dd2) cleared this run. Run `/ardd-verify` to refresh.

## Feedback

None open — all 10 feedback files are `status: planned`. The two from
the vocabulary/lint batch were consumed this run by
`plan-status-vocab-lint-fixes-2026-07-06.md`.

## Feature Backlog

1 backlogged · 0 planned · 0 tasked · 3 implemented — backlogged:
`self-update-from-consumer` (update ARDD from inside a consuming repo +
pending-update notification; both downstream repos silently fell a full
release behind before today's manual sweep). Target with
`/ardd-plan self-update-from-consumer`.

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

The delegated `status-vocab-lint-fixes` run is **merged** (2026-07-06):
6/6 tasks, first fully-delegated worktree run under the new machinery —
align verified, all state rode the branch, eager merge landed code and
completion atomically, `core.bare` stayed clean. Landed: the
terminal-completion rule in prose, three pointed lint messages for
invented statuses (`reopened*`/`superseded`/`split` — the sync-tab-scroll
`split` file turned out to be ordinary partial consumption), bracket-tag
checks scoped to checklist item lines (mention-vs-use fixed; historical
prose restored to literal phrasing).

Next: `/ardd-tasks` for `plan-self-update-from-consumer-2026-07-06.md`
(draft, on branch `self-update-from-consumer` — a plain branch, so it
won't appear in inflight-worktrees output; don't lose track of it), then
`/ardd-implement`. `main` is 2 commits ahead of origin — push when
ready.
