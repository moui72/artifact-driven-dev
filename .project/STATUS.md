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

1 open feedback file: `feedback-self-hosted-update-check-7531.md`
(2026-07-08, 1 UX) — the self-hosted update-check chase: when source ==
target repo, the check perpetually reads `behind` by the version-bump
commit; add a distinct `self-hosted` outcome that analyze treats as
silent. Small (~5 lines + fixture). The 13 older feedback files are
`planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 4 implemented —
`self-update-from-consumer` completed 2026-07-07 (flip rides branch
`self-update-from-consumer`, lands on merge).

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

Queue: one small open feedback file (self-hosted-update-check, above)
for the next `/ardd-plan` — bundle with whatever comes next, or run it
solo as a quick fix. Standing thread: smoke-key provisioning (970d935b).
