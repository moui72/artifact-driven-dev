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

1 open feedback file: `feedback-repo-critique-docs-ca1d.md`
(docs/positioning half of the 2026-07-06 critique) — feed it to the next
`/ardd-plan` (it now supports feedback-file scoping, though with only one
open file scoping is moot). The other 3 feedback files are `planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 2 implemented — now as per-feature
files in `.project/features/` (migration 0003 ran; legacy features.md
removed).

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

Merged. The plan's tasks file is `completed` (23/23); what landed:

- constitution v1.2.0 (Principle II covers mutations; behavioral-test
  tier; per-feature register decision)
- `ardd-state.sh` (13 subcommands, all state transitions script-performed)
  + `defects-unsurfaced.sh`, `tasks-list.sh`, `upsert-section.sh`,
  `smoke-assert.sh` — each with fixture tests + CI jobs
- migration `0003-per-feature-files` (applied live to this repo),
  `lint-project.sh` per-feature schema + governance-consistency check
- all ten state-touching skills rewired: prose decides, scripts write
- `/ardd-plan` feedback-file scoping
- key-gated smoke workflow (`.github/workflows/smoke.yml`) — skips fast
  until the `ANTHROPIC_API_KEY` secret is provisioned (deliberate);
  promotion = provision the secret + drop `continue-on-error`

Pushed and verified. Next:
`/ardd-plan feedback-repo-critique-docs-ca1d.md` for the docs half of
the critique — that run will also surface the two new DEFECTS.md entries
(via `defects-unsurfaced.sh`) and offer fix tasks; the sed -i
portability fix is small and worth accepting into that plan.
