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

`plan-status-vocab-lint-fixes-2026-07-06.md` is **approved** and tasked:
`tasks-status-vocab-lint-fixes-ff86.md` (`status: ready`, 6 tasks in 2
phases, branch `status-vocab-lint-fixes`). Phase 1: terminal-completion
rule in implement/converge/tasks prose (T001), the sync-tab-scroll
`split`-file reading (T002, resolves the plan's one open question),
three pointed lint status messages test-first (T003). Phase 2:
item-line-scoped tag parsing — absence-assertion red first (T004),
implementation (T005), then unwinding this repo's dodge-vocabulary
prose (T006). Next: `/ardd-implement` (inline — already on the work
branch).
