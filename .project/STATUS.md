# artifact-driven-dev — Project Status

_Updated: 2026-07-13 (`github-pages-docs-site` planned and tasked:
`plan-github-pages-docs-site-2026-07-13-3fb8.md` approved,
`tasks-github-pages-docs-site-d8e2.md` ready — 9 tasks / 3 phases:
MkDocs Material scaffold, Actions deploy to Pages, README/USAGE
wire-up. No artifact changes were needed — source-side infrastructure
only.) Keep this current as artifacts are refined and open questions
are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.8.0; `delegation: eager`, `merge_policy: auto`) | — |

## Open Questions

None in the artifact. One plan-scoped item remains, non-blocking
(`plan-quickstart-new-project-2026-07-09.md` — optional `gh repo create`).
The new docs-site plan carries one implementation-time judgment call
(`beta-release.yml` skip-list treatment of `mkdocs.yml`, its T009).

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-12 (seventh pass). The
smoke-tier entry (`7efff3a5`) clears when the deliberately-unprovisioned
`ANTHROPIC_API_KEY` is provisioned; the next `/ardd-defects` pass
re-derives it.

## Feedback

None open. Most recently consumed:
`feedback-constitution-suggestions-quality-review-123a.md` → delivered
via `tasks-constitution-suggestions-quality-e071.md` (completed 12/12,
2026-07-13, merged to `main`; final catalog count 23, not the predicted
20 — content delivered exactly as specified).

## Recent Releases

v0.9.1 (2026-07-13) — first fully-automatic two-channel cycle:
v0.9.1-beta.1 on push, stable cut by dispatch, `release` branch created
and protected. v0.9.0 (2026-07-12) — first GitHub release; all five
consumers repointed. Full history: GitHub Releases and
`docs/decisions/0006`/`0007`.

## Feature Backlog

0 backlogged · 1 tasked · 11 implemented · 1 retired — see
`.project/features/`. Tasked: `github-pages-docs-site` →
`tasks-github-pages-docs-site-d8e2.md` (`ready`) — run
`/ardd-implement` to execute it.

## Audit

`.project/audit.md`: 4 open items — 3 suggestions (new.sh tty narrative →
decision record; Governance workflow-field exemption; primary-on-main
deterministic guard, MOOT after the v1.7.0 retirement — reject/close it)
and 1 risk (smoke key unprovisioned).

## In Flight

Nothing — no sibling worktrees, no reap candidates.

## Recommended Next Step

`/ardd-implement` — execute `tasks-github-pages-docs-site-d8e2.md` (the
user has already asked for the docs site to be built). Note: `main` is
16 commits ahead of `origin/main`; the Phase 2 deploy push will also
publish those as the next beta — expected, flagged in T007.
