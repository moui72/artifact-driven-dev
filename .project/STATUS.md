# artifact-driven-dev — Project Status

_Updated: 2026-07-06 (post-/ardd-implement, ardd-state-determinism complete). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.0) | — |

## Open Questions

None.

## Code-vs-Artifact Defects

2 defects — see `DEFECTS.md`, last checked 2026-07-06 (post-v1.2.0
verify): (1) **broken-contract** — migrations 0001/0002 use BSD-only
`sed -i ''`, which breaks `install.sh` on Linux targets with pre-0002
state (predates this plan; missed by the 2026-07-05 run; neither has a
fixture test, which is why ubuntu CI never caught it); (2) **drift** —
the v1.2.0 behavioral-smoke-test standard says "required for
state-mutating skill paths" but only one scenario exists. The next
`/ardd-plan` run surfaces both via `defects-unsurfaced.sh`. All other
spot-checks passed. Run `/ardd-verify` to refresh.

## Feedback

None open — all 4 feedback files are `status: planned`.
`feedback-repo-critique-docs-ca1d.md` was consumed by
`plan-repo-critique-docs-2026-07-06.md` this run (all 6 items
incorporated, marked and flipped via `ardd-state.sh feedback-mark` /
`feedback-planned`).

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 2 implemented — now as per-feature
files in `.project/features/` (migration 0003 ran; legacy features.md
removed).

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

`plan-repo-critique-docs-2026-07-06.md` is **approved** and tasked:
`tasks-repo-critique-docs-46a1.md` (`status: ready`, 11 tasks in 4
phases, on branch `repo-critique-docs`). Phase 1 (README/USAGE
restructure — name decision T001, tiering, artifact-set demotion,
delegation-fallback note) is sequential; Phases 2/3 carry parallel-safe
tasks; Phase 4 fixes both surfaced defects (sed portability with
backfilled migration tests; second smoke scenario). Next:
`/ardd-implement` and select that tasks file — T001 asks the ADD-vs-ARDD
name question first (ARDD recommended). Note this branch also carries
the still-uncommitted plan/feedback bookkeeping from the /ardd-plan run;
implement's first commit will land it.
