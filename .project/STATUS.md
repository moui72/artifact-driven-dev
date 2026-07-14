# artifact-driven-dev — Project Status

_Updated: 2026-07-14 (`/ardd-plan` — drafted and approved
`plan-actor-language-skill-prose-aud-2026-07-14-d4b6.md`, a full audit of
`skills/*/SKILL.md` for constitution Principle IX ("Unambiguous Actor
Language in Agent-Facing Prose," added earlier this session via
`/ardd-refine constitution`, v1.9.0). 11 tasks generated
(`tasks-actor-language-skill-prose-aud-df2a.md`, `status: ready`) — 10
parallel per-file review tasks plus a consistency/lint pass. Feedback item
`feedback-next-step-prompt-terminology-6ce3.md` (F001) marked incorporated
and flipped to `status: planned`, bound to this plan — 0 open feedback
files remain. Not yet committed, alongside the still-uncommitted v1.8.0 →
v1.8.2 audit resolutions and the new `docs/decisions/0008` decision
record from earlier this session.)
Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.9.0; `delegation: eager`, `merge_policy: auto`) | — |

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
`feedback-next-step-prompt-terminology-6ce3.md` → delivered via
`tasks-actor-language-skill-prose-aud-df2a.md` (11 tasks, `ready`, not yet
run).

## Recent Releases

The Phase 2 docs-site push published the accumulated `main` commits
(catalog revision, stale-update-network-check, docs site) as the next
beta; cut a stable via the dispatch workflow whenever consumers should
get them. v0.9.1 (2026-07-13) — first fully-automatic two-channel
cycle. v0.9.0 (2026-07-12) — first GitHub release. Full history: GitHub
Releases and `docs/decisions/0006`/`0007`.

## Feature Backlog

0 backlogged · 0 tasked · 13 implemented · 1 retired — see
`.project/features/`.
Newest implemented: `plan-approval-presentation` — `/ardd-plan`'s approval
checkpoint now presents the plan's real structure instead of a freehand
re-summary (`tasks-plan-approval-presentation-99dd.md`, completed 3/3).

## Audit

`.project/audit.md`: 1 open suggestion (two-channel release paragraph →
decision-record pointer) + 1 open risk (smoke key unprovisioned, now
documented as a deliberate standing state). 2 suggestions resolved this
pass (new.sh tty narrative → decision record, v1.8.1; Governance
workflow-field exemption, v1.8.2).

## In Flight

Nothing — no sibling worktrees, no reap candidates; `main` is even with
`origin/main`.

## Recommended Next Step

`tasks-actor-language-skill-prose-aud-df2a.md` is `ready` — run
`/ardd-implement` to execute the 11-task actor-language pass. Other
standing options once that's done: dispatch the stable release workflow
when you want consumers on the accumulated work; resolve the one
remaining `.project/audit.md` suggestion via `/ardd-refine constitution
trim the two-channel release-publishing paragraph...`; or `/ardd-defects`
to re-verify against the docs-site surfaces (unchanged since 2026-07-12).
