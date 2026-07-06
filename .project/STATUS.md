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

Two threads in flight:

1. **Delegated implementation** — a worktree subagent is executing
   `tasks-status-vocab-lint-fixes-ff86.md` (visible via
   `inflight-worktrees.sh`); on report-back the coordinator checks
   `core.bare` and offers the eager merge.
2. **New draft plan** — `plan-self-update-from-consumer-2026-07-06.md`
   (branch `self-update-from-consumer`, targets the
   `self-update-from-consumer` feature): source-path recording in
   ardd-version.md, `ardd-update-check.sh`, an `/ardd-update` extension
   skill (which also closes the invisible-install-suggestions gap that
   surfaced when the badge offer was never seen), analyze visibility,
   doc alignment. Next: `/ardd-tasks` to approve it — safe to do while
   the delegated run is in flight (disjoint files).

Also done out-of-band (2026-07-06): badge injected into both consumer
READMEs at the user's request — uncommitted in those repos.
