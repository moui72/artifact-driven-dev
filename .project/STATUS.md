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

2 open feedback files:
`feedback-status-vocabulary-gaps-50a5.md` (3 UX — agents invent enum
values: `reopened`/`superseded`/`split`; missing reopen affordance and
pointed guidance) and `feedback-lint-mention-vs-use-462c.md` (1 bug —
lint can't tell tag *use* from syntax *mention*; fix: parse tags on
checklist item lines only; hit three times in one day). Both small;
bundle into the next plan. The 8 older feedback files are `planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 3 implemented —
`built-with-ardd-badge` completed this run (flip rides branch
`built-with-ardd-badge`, lands on merge).

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

All planned work is merged and pushed (ffd3628); downstream consumers
reinstalled (migration 0004 fixed sync-tab-scroll's dangling tags; both
received the badge offer). Two small open feedback files
(status-vocabulary-gaps; lint mention-vs-use) await the next
`/ardd-plan`. Remaining threads otherwise: smoke-harness key
provisioning (DEFECTS.md 970d935b), and downstream repos' own content
fixes (invented statuses, the assisted-review placeholder tag,
sync-tab-scroll's constitution governance drift — now caught by lint).
