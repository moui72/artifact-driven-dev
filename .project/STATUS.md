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

1 open feedback file: `feedback-status-conflicts-disposable-56a9.md`
(2026-07-07, 1 UX) — agents over-deliberate STATUS.md merge conflicts;
state the disposable-regenerate rule at the point of action (skill
prose + CLAUDE.md), optionally a merge-driver suggestion. The 12 older
feedback files are `planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 4 implemented —
`self-update-from-consumer` completed 2026-07-07 (flip rides branch
`self-update-from-consumer`, lands on merge).

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

All planned work is merged and pushed (cd7dbbe); both consumers are
self-update capable and up to date. One small open feedback file
(status-conflicts-disposable, above) awaits the next `/ardd-plan` —
bundle it with whatever comes next. Standing threads: smoke-key
provisioning (DEFECTS.md 970d935b); the self-hosted update-check's
inherent one-commit "behind" reading after version-bump commits (noted
2026-07-07, harmless, feedback-worthy only if the noise bothers).
