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

`plan-self-update-from-consumer-2026-07-06.md` is **approved** and
tasked: `tasks-self-update-from-consumer-0399.md` (`status: ready`, 6
tasks in 3 phases, branch `self-update-from-consumer`, feature flipped
to `tasked`). Phase 1: Source-Path recording in ardd-version.md
(test-first). Phase 2: `ardd-update-check.sh` (four machine-readable
outcomes, local-only) + /ardd-analyze visibility. Phase 3: the
/ardd-update skill (offer-never-assume pull; relays install output so
suggestions reach the user), generator registration, doc alignment.
Next: `/ardd-implement` (inline — already on the work branch). `main`
is 10 signed commits ahead of origin — push anytime.
