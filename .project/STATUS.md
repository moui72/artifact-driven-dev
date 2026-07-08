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

None open — all 14 feedback files are `status: planned`.
`feedback-self-hosted-update-check-7531.md` was consumed this run by
`plan-self-hosted-update-check-2026-07-08.md`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 4 implemented —
`self-update-from-consumer` completed 2026-07-07 (flip rides branch
`self-update-from-consumer`, lands on merge).

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

`tasks-self-hosted-update-check-36fd.md` is **completed** (3/3): the
update-check now prints `self-hosted commit=<x>` when source == target
(toplevel comparison, symlink-proof, live-verified), and /ardd-analyze
treats it as silent — the perpetual false "ARDD update available" in
this repo is gone. Merge into main and push. Remaining standing thread:
smoke-key provisioning (970d935b).
