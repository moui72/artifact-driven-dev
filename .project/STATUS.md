# artifact-driven-dev — Project Status

_Updated: 2026-07-09 (post-/ardd-feature, npx-skills-install). Keep this current as artifacts are refined and open questions are resolved._

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
`feedback-plan-target-defects-6a36.md` was consumed this run by
`plan-next-step-prompt-2026-07-09.md` (F001 incorporated).

## Feature Backlog

2 backlogged · 0 planned · 0 tasked · 4 implemented — see
`.project/features/`. `next-step-prompt` is backlogged but already has a
draft plan (`plan-next-step-prompt-2026-07-09.md`); it flips to `planned`
when `/ardd-tasks` selects that plan. `npx-skills-install` (install via
the vercel-labs skills CLI) is backlogged with no plan — target it with
`/ardd-plan npx-skills-install`.

## In Flight

On branch `next-step-prompt` (this checkout, not yet merged to `main`):
draft `plan-next-step-prompt-2026-07-09.md` covering the opt-in
`next_step_prompt` boolean (prompt at analyze/plan/tasks seams, ask-once
via bootstrap/update) and `/ardd-plan`'s `defect:<id>`/`defects` scoping
argument (feedback F001). No sibling worktrees.

## Recommended Next Step

Run `/ardd-tasks` and select `plan-next-step-prompt-2026-07-09.md` — that
approves the plan, flips `next-step-prompt` to `planned`, and generates
its task list. Remaining standing thread: smoke-key provisioning
(970d935b).
