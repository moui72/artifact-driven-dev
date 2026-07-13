# artifact-driven-dev — Project Status

_Updated: 2026-07-13 (`plan-approval-presentation` planned+tasked —
`plan-plan-approval-presentation-2026-07-13-14cf.md` approved,
`tasks-plan-approval-presentation-99dd.md` ready (3 tasks), feature →
`tasked`. Refines `/ardd-plan`'s approval checkpoint to present the plan's
real structure instead of a freehand re-summary; browser/Artifact rendering
vetted and dropped (`research-plan-approval-rendering-termin-2026-07-13-3758.md`).
Not yet committed. Prior: `github-pages-docs-site` delivered and pushed.)
Keep this current as artifacts are refined and open questions are resolved._

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
re-derives it. The docs-site work added `mkdocs.yml`, `docs/index.md`,
and `.github/workflows/docs.yml` (all source-side) — a re-run would
verify DEFECTS.md against the enlarged doc/workflow surface.

## Feedback

None open. Most recently consumed:
`feedback-constitution-suggestions-quality-review-123a.md` → delivered
via `tasks-constitution-suggestions-quality-e071.md` (completed 12/12,
2026-07-13, merged to `main`).

## Recent Releases

The Phase 2 docs-site push published the accumulated `main` commits
(catalog revision, stale-update-network-check, docs site) as the next
beta; cut a stable via the dispatch workflow whenever consumers should
get them. v0.9.1 (2026-07-13) — first fully-automatic two-channel
cycle. v0.9.0 (2026-07-12) — first GitHub release. Full history: GitHub
Releases and `docs/decisions/0006`/`0007`.

## Feature Backlog

0 backlogged · 1 tasked · 12 implemented · 1 retired — see
`.project/features/`. Tasked: `plan-approval-presentation` —
`tasks-plan-approval-presentation-99dd.md` ready (3 tasks); run
`/ardd-implement` to execute.
Newest implemented: `github-pages-docs-site` (2026-07-13) — docs/ rendered
at https://moui72.github.io/artifact-driven-dev/ (MkDocs Material; PR
builds are the link check via `mkdocs build --strict`; docs-config-only
pushes exempted from beta-release; README/USAGE link the site).

## Audit

`.project/audit.md`: 4 open items — 3 suggestions (new.sh tty narrative →
decision record; Governance workflow-field exemption; primary-on-main
deterministic guard, MOOT after the v1.7.0 retirement — reject/close it)
and 1 risk (smoke key unprovisioned).

## In Flight

Nothing — no sibling worktrees, no reap candidates; `main` is even with
`origin/main`.

## Recommended Next Step

`/ardd-implement` to execute `tasks-plan-approval-presentation-99dd.md`
(3 tasks, the approval-checkpoint refinement). Also standing: dispatch the
stable release workflow when you want consumers on the accumulated work;
optionally `/ardd-defects` to re-verify against the docs-site surfaces.
Everything else is clean.
