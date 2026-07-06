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

Both critique plans are fully landed on `main` and pushed. Nothing is
in flight. The one open thread is smoke-harness promotion: provision
the `ANTHROPIC_API_KEY` secret, prove the two scenarios actually run
(expect a tuning pass — headless `claude -p` against interactive skill
gates is unexercised), drop `continue-on-error`, then extend scenarios
toward the uncovered paths (converge/feedback/refine/sync) so the last
DEFECTS.md entry clears. Otherwise: normal feature work via
`/ardd-feature` → `/ardd-plan <slug>`.
