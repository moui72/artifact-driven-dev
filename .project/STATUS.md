# artifact-driven-dev — Project Status

_Updated: 2026-07-09 (post-/ardd-plan, quickstart-new-project drafted). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.3) | — |

## Open Questions

None in the artifact itself. The draft plan
`plan-quickstart-new-project-2026-07-09.md` carries two of its own
(optional `gh repo create`; whether `new.sh` should pin a tag rather than
track `main`) — plan-scoped, not artifact-scoped, so they don't gate
planning.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-06 (third pass):
the behavioral-smoke-tier claim still exceeds coverage. Reduced-scope
residue of already-surfaced 970d935b. Run `/ardd-verify` to refresh —
increasingly worth doing: next-step-prompt and npx-skills-install (both
merged) added behavior verify has never checked, and quickstart-new-project
will add `new.sh` plus a `/ardd-kickoff` skill on top of that.

## Feedback

None open — all 14 feedback files are `status: planned`.

## Feature Backlog

1 backlogged · 0 planned · 0 tasked · 6 implemented — see
`.project/features/`. `quickstart-new-project` is backlogged and now has a
draft plan; selecting that plan in `/ardd-tasks` is what flips it to
`planned`.

## In Flight

Branch `quickstart-new-project` (this checkout): constitution amended to
v1.2.3 and a draft plan written, not yet committed. No sibling worktrees.

## Recommended Next Step

Run `/ardd-tasks` to select and approve
`plan-quickstart-new-project-2026-07-09.md`, which flips the plan to
`approved` and the `quickstart-new-project` feature from `backlogged` to
`planned`, then generates its task list.
