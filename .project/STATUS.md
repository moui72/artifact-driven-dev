# artifact-driven-dev — Project Status

_Updated: 2026-07-06 (post-/ardd-implement, ardd-state-determinism complete). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.0) | — |

## Open Questions

None.

## Code-vs-Artifact Defects

No defects found — see `DEFECTS.md`, last checked 2026-07-05. Since then
the constitution was amended to v1.2.0 (Principle II extended to state
mutations; behavioral smoke-test tier; per-feature register standing
decision) and the implementing work landed on this branch — run
`/ardd-verify` after merge to confirm code and constitution still agree.

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

No sibling worktrees; `completion-flip-check.sh` clean against all six
completed tasks files. This branch (`ardd-state-determinism`, 24 commits
ahead of `main`) carries the completed work and is ready to merge.

## Recommended Next Step

**Merge `ardd-state-determinism` into `main`.** The plan's tasks file is
`completed` (23/23):

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

After merge: re-run `./install.sh .` (refresh dogfooded skill copies),
run `/ardd-verify`, then plan the docs half via
`/ardd-plan feedback-repo-critique-docs-ca1d.md`.
