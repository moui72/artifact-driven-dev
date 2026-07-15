# artifact-driven-dev — Project Status

_Updated: 2026-07-14 (`/ardd-plan redrive-configuration-choices` —
drafted, approved, and tasked `plan-redrive-configuration-choices-2026-07-14-1e00.md`
(solo mode, no branch gate, on `main`). No artifact changes: constitution.md's
Governance section already exempts workflow frontmatter fields
(`workflow_mode`, `next_step_prompt`, `delegation`, `merge_policy`) from
Sync Impact Report/versioning even when *changed*, not just set. Design
chosen: extend `/ardd-update` with a new `--reconfigure` flag (over a
standalone `/ardd-configure` skill or an `/ardd-init --reconfigure` flag)
that re-asks all four fields regardless of presence, showing current
values, and stamps only what changes — generalizing step 5's existing
backfill-only logic rather than duplicating it. 4 tasks generated across 2
phases in `tasks-redrive-configuration-choices-29ae.md` (`ready`): T001
rewrites `skills/ardd-update/SKILL.md`'s Usage and step 5; T002–T004
(parallel, depend on T001) update `docs/reference/skills/ardd-update.md`,
`docs/reference/configuration.md`, and `CLAUDE.md`'s two "asked once"
passages to match. No test tasks — all documentation/prose changes, the
explicit exception under Constitution Principle V. Feature
`redrive-configuration-choices` flipped `backlogged` → `planned` →
`tasked`. Prior update, same day, `/ardd-backlog` — logged
`redrive-configuration-choices`, a request for a way to re-answer/redrive
one-time configuration choices (e.g. `workflow_mode`, `next_step_prompt`)
if the user changes their mind after initial setup — currently only
askable once by `/ardd-init` or `/ardd-update`, or by hand-editing
constitution frontmatter. Earlier update, same day, `/ardd-implement` — delegated worktree run completed
and merged all 4 tasks of `tasks-203c-6b16.md` (now `completed`).
**First delegation attempt failed live**, demonstrating the exact bug
`feedback-uncommitted-plan-tasks-delegat-a3ff.md` described: the worktree
subagent aligned cleanly (`aligned=true`) but the plan/tasks files didn't
exist there because they'd never been committed — it stopped correctly
per its instructions rather than fabricating work. Recovered by removing
the empty worktree, committing the session's plan/tasks/feedback/backlog
files to `main` (commit `f837b7f`), and relaunching. The second run
completed: T001 added a delegation pre-flight `git status` check to
`skills/ardd-implement/SKILL.md` (the fix for the very bug just
reproduced); T002/T003 added the "committing the red state"
expected-failure-marker note + framework table to
`templates/constitution-suggestions.md`'s Test-First Development and
Deterministic Gates entries; T004 mirrored the marker handling in
`ardd-implement`'s TDD execution step. Merged to `main` (fast-forward,
`merge_policy: auto`, `f837b7f..e8a6e0c`) and the worktree reaped. No
features bound to this plan (`features: []`), so no register flip.
Everything from this session is now on `main`. Prior update, same day,
`/ardd-plan` — drafted, approved, and tasked
`plan-203c-2026-07-14-bf43.md` (solo mode, no branch gate, on `main`),
consuming both open feedback files: `feedback-uncommitted-plan-tasks-delegat-a3ff.md`
(F001) and `feedback-tdd-xfail-precommit-contradiction-a639.md` (F001,
F002). Both flipped to `planned`. No feature slugs targeted this run.
4 tasks generated across 2 independent phases in
`tasks-203c-6b16.md` (`ready`): T001 adds a delegation pre-flight
uncommitted-files check to `ardd-implement`'s delegation gate; T002–T004
add the expected-failure-marker (`xfail`) resolution to
`templates/constitution-suggestions.md`'s Test-First Development and
Deterministic Gates entries and to `ardd-implement`'s TDD execution step.
Deliberately out of scope: this repo's own `.project/artifacts/constitution.md`
— its test-added-in-the-same-commit paradigm never produces the
separately-committed red state the contradiction depends on, so nothing
there needed to change. Prior update, same day, `/ardd-feedback` — logged
`feedback-tdd-xfail-precommit-contradiction-a639.md`, a design suggestion
from an Atelier consumer project. Earlier update, same day, `/ardd-backlog` — logged
`list-mode-for-plan-and-impleme`, a request for `/ardd-plan` and
`/ardd-implement` to gain a `--list` mode printing eligible
slugs/tasks-files with basic info, bypassing the interactive pick flow.
Earlier update, same day, `/ardd-feedback` — logged
`feedback-uncommitted-plan-tasks-delegat-a3ff.md`, a bug report from
inspecting a real delegation failure: `/ardd-plan` writes the plan and
tasks files to disk without committing them, and in solo mode — where
`/ardd-plan` often runs directly on the default branch — that leaves a
window where a `status: ready` tasks file is real on disk but absent from
commit history. `/ardd-implement`'s delegation gate has no pre-flight
check for this, so a worktree subagent can get `aligned=true` from
`worktree-align.sh` (which only fast-forwards committed history) and then
fail cleanly when the tasks file isn't there — after a full agent launch
round-trip. This is the second observed occurrence of this exact failure
mode.)
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

None open. Both consumed by `plan-203c-2026-07-14-bf43.md`:
`feedback-uncommitted-plan-tasks-delegat-a3ff.md` and
`feedback-tdd-xfail-precommit-contradiction-a639.md` → delivered via
`tasks-203c-6b16.md` (4/4 complete, merged to `main`).

## Recent Releases

The Phase 2 docs-site push published the accumulated `main` commits
(catalog revision, stale-update-network-check, docs site) as the next
beta; cut a stable via the dispatch workflow whenever consumers should
get them. v0.9.1 (2026-07-13) — first fully-automatic two-channel
cycle. v0.9.0 (2026-07-12) — first GitHub release. Full history: GitHub
Releases and `docs/decisions/0006`/`0007`.

## Feature Backlog

1 backlogged · 1 tasked · 13 implemented · 1 retired — see
`.project/features/`.
Newest tasked: `redrive-configuration-choices` — `/ardd-update
--reconfigure` to re-answer `workflow_mode`, `next_step_prompt`,
`delegation`, `merge_policy` on demand
(`tasks-redrive-configuration-choices-29ae.md`, `ready`, 0/4). Run
`/ardd-implement` to execute it.
Backlogged: `list-mode-for-plan-and-impleme` — a `--list` mode for
`/ardd-plan` and `/ardd-implement` to print eligible slugs/tasks files
with basic info without entering the interactive pick flow. Target with
`/ardd-plan list-mode-for-plan-and-impleme`.
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

Nothing — the `tasks-203c-6b16.md` worktree merged and was reaped; no
sibling worktrees remain. `main` is ahead of `origin/main` (multiple
local commits not yet pushed).

## Recommended Next Step

Run `/ardd-implement` to execute `tasks-redrive-configuration-choices-29ae.md`
(4 tasks, ready, 0/4). Other standing options: dispatch the stable release
workflow when consumers should get this session's accumulated work
(constitution v1.9.0, the actor-language rewrites, the delegation
pre-flight check, the TDD/xfail catalog resolution); resolve the one
remaining `.project/audit.md` suggestion; or `/ardd-defects` to re-verify
against the docs-site and skill-prose surfaces.
