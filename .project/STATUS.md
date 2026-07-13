# artifact-driven-dev — Project Status

_Updated: 2026-07-13 (constitution-suggestions catalog review planned and
tasked: 14 feedback findings negotiated — 13 incorporated, F013 secrets
entry declined —
`plan-constitution-suggestions-quality-2026-07-13-4de0.md` approved,
`tasks-constitution-suggestions-quality-e071.md` ready, 12 tasks / 4
phases, net 21→20 catalog entries). Keep this current as artifacts are
refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.8.0; `delegation: eager`, `merge_policy: auto`) | — |

## Open Questions

None in the artifact. One plan-scoped item remains, non-blocking
(`plan-quickstart-new-project-2026-07-09.md` — optional `gh repo create`).

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-12 (seventh pass). The
smoke-tier entry (`7efff3a5`) clears when the deliberately-unprovisioned
`ANTHROPIC_API_KEY` is provisioned; the next `/ardd-defects` pass
re-derives it. Note: the docs rewrite (uncommitted) touches doc/script
surfaces DEFECTS.md was verified against — worth a re-run after it lands.

## Feedback

None open —
`feedback-constitution-suggestions-quality-review-123a.md` (14 items:
13 incorporated, F013 secrets-hygiene entry declined) was consumed by
`plan-constitution-suggestions-quality-2026-07-13-4de0.md` (approved
2026-07-13); its tasks file
`tasks-constitution-suggestions-quality-e071.md` is **ready**, 0/12.

## Recent Releases

v0.9.1 (2026-07-13) — first fully-automatic two-channel cycle:
v0.9.1-beta.1 on push, stable cut by dispatch, `release` branch created
and protected. v0.9.0 (2026-07-12) — first GitHub release; all five
consumers repointed. Full history: GitHub Releases and
`docs/decisions/0006`/`0007`.

## Feature Backlog

0 backlogged · 11 implemented · 1 retired — see `.project/features/`.
Newest implemented: `stale-update-network-check` (2026-07-13) — opt-in
`update_check_max_age_days` workflow knob; `ardd-update-check.sh` now
fetches tags on the owned checkout when opted in and `FETCH_HEAD` is
older than N days (`note=fetch-failed` fallback; dev-mode/self-hosted
exempt). Delivered test-first: +19 regression cases across three test
files.

## Audit

`.project/audit.md`: 4 open items — 3 suggestions (new.sh tty narrative →
decision record; Governance workflow-field exemption; primary-on-main
deterministic guard, MOOT after the v1.7.0 retirement — reject/close it)
and 1 risk (smoke key unprovisioned).

## In Flight

Nothing — the delegated docs-review-findings run merged and its worktree
was reaped.

## Recommended Next Step

`/ardd-implement` — execute
`tasks-constitution-suggestions-quality-e071.md` (12 tasks: catalog
header criterion, 3 removals, Production Annotations move, Deterministic
Gates merge, Single Source of State reword, Test-First fold-in, 4 new
agent-failure-mode entries, verification pass). (Push of `main` for the
stale-update-network-check beta remains available whenever wanted.)
