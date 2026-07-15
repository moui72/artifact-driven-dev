# artifact-driven-dev — Project Status

_Updated: 2026-07-14 (`/ardd-plan` — drafted, approved, and tasked
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
`tasks-203c-6b16.md` (ready, 0/4).

## Recent Releases

The Phase 2 docs-site push published the accumulated `main` commits
(catalog revision, stale-update-network-check, docs site) as the next
beta; cut a stable via the dispatch workflow whenever consumers should
get them. v0.9.1 (2026-07-13) — first fully-automatic two-channel
cycle. v0.9.0 (2026-07-12) — first GitHub release. Full history: GitHub
Releases and `docs/decisions/0006`/`0007`.

## Feature Backlog

1 backlogged · 0 tasked · 13 implemented · 1 retired — see
`.project/features/`.
Newest backlogged: `list-mode-for-plan-and-impleme` — a `--list` mode for
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

Nothing — the actor-language worktree merged and was reaped; no sibling
worktrees remain. `main` is ahead of `origin/main` (multiple local commits
not yet pushed).

## Recommended Next Step

`tasks-203c-6b16.md` is `ready` (0/4) — run `/ardd-implement` to execute
it (T001 delegation pre-flight check; T002–T004 catalog + skill xfail
resolution, T002/T003 parallel). Other standing options remain available
alongside it: dispatching the stable release workflow when consumers
should get this session's accumulated work; resolving the one remaining
`.project/audit.md` suggestion; or `/ardd-defects` to re-verify against
the docs-site and skill-prose surfaces.
