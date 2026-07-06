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

`tasks-repo-critique-docs-46a1.md` is **completed** (11/11) on branch
`repo-critique-docs` — docs tiered (core loop vs extensions), ARDD is the
single name (constitution v1.2.1), the artifact set is declared-not-fixed,
inline-on-a-branch is the documented delegation fallback, development
archaeology moved to `docs/decisions/`, skill descriptions are
single-sourced from SKILL.md frontmatter (`gen-skill-docs.sh` +
lint-docs drift check; WORKFLOW.md now static via install.sh), and both
DEFECTS.md entries are fixed (portable sed in migrations 0001/0002 with
backfilled ubuntu-red tests; smoke scenario 2 for tasks→implement).
T006 note: archaeology strip achieved 8.5% token reduction, not the
plan's 25% estimate — earlier rewires had already removed most of it.

All commits on this branch are signed (the two made while 1Password was
locked were re-signed 2026-07-06). Next: merge `repo-critique-docs` into `main`, re-run `./install.sh .`,
push, and run `/ardd-verify` to confirm the two defects clear from
DEFECTS.md.
