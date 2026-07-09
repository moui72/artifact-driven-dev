# artifact-driven-dev — Project Status

_Updated: 2026-07-09 (post-/ardd-tasks, next-step-prompt tasked). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.1) | — |

## Open Questions

None.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-06 (third pass):
the behavioral-smoke-tier claim still exceeds coverage (2 scenarios
exist, converge/feedback/refine/sync paths uncovered, none executable
until the API key is provisioned). This is the reduced-scope residue of
already-surfaced 970d935b — /ardd-plan won't re-prompt it. Run
`/ardd-verify` to refresh.

## Feedback

None open — all 14 feedback files are `status: planned`.

## Feature Backlog

1 backlogged · 0 planned · 1 tasked · 4 implemented — see
`.project/features/`. `next-step-prompt` is `tasked`
(plan approved: `plan-next-step-prompt-2026-07-09.md`; tasks:
`tasks-next-step-prompt-fe51.md`, ready, 0/11). `npx-skills-install`
is backlogged — target it with `/ardd-plan npx-skills-install`.

## In Flight

On `main` (uncommitted): the plan approval, `next-step-prompt`
`backlogged→tasked` flips, and the new ready tasks file from this
/ardd-tasks run. No sibling worktrees.

## Recommended Next Step

Run `/ardd-implement` and pick `tasks-next-step-prompt-fe51.md` (11
tasks, 5 phases: lint boolean + defects-unsurfaced modes, the prompt
convention in analyze/plan/tasks, bootstrap/update ask-once, defect
scoping, docs + dogfood). Remaining standing thread: smoke-key
provisioning (970d935b).
