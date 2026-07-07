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

0 backlogged · 0 planned · 0 tasked · 4 implemented —
`self-update-from-consumer` completed 2026-07-07 (flip rides branch
`self-update-from-consumer`, lands on merge).

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

`tasks-self-update-from-consumer-0399.md` is **completed** (6/6) on
branch `self-update-from-consumer`: Source-Path recorded by install.sh,
`ardd-update-check.sh` (six machine-readable outcomes, local-only,
fixture-tested), /ardd-analyze update-availability line, the
`/ardd-update` extension skill (registered + docs regenerated — the
drift check correctly forced T004+T005 into one commit), and doc
alignment. Next: merge this branch into `main` (fast-forward — it
already contains main), push, and re-install downstream so both
consumer repos get Source-Path recorded and the /ardd-update skill —
after which they can self-update without this coordinator.
