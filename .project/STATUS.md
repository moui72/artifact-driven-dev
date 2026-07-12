# artifact-driven-dev — Project Status

_Updated: 2026-07-12 (skill-surface cleanup approved and tasked after 3-agent review; release plan paused at 7/10 pending it). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.5.0; `delegation: eager`, `merge_policy: auto`) | — |

## Open Questions

None in the artifact. One plan-scoped set remains, non-blocking:

- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-11 (sixth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); `ANTHROPIC_API_KEY` still
unprovisioned. The background-by-default-flow merge post-dates the sixth pass
and hasn't been verified against yet.

## Feedback

None open — `feedback-critique-design-vetting-gap-0779.md` (9 items, all
accepted) consumed by `plan-skill-surface-cleanup-2026-07-12.md`.

## Two plans in flight, strictly sequenced

1. **skill-surface-cleanup** (approved; `tasks-skill-surface-cleanup-be30.md`
   ready, 0/18): 17→13 skills — renames (audit/status/defects/tracker/
   backlog/diagram), folds (converge→implement, add-artifact→refine,
   bootstrap+codify→init), research proposal mode, guards, cross-routing,
   tombstones, migrations 0006–0008. Revised through three independent
   reviews (UX/DevX, architecture, release-path). **One worktree branch,
   single merge — no per-phase merges** (consumers read this checkout live).
2. **remote-install-source** (`tasks-remote-install-source-18d3.md`
   in-progress, 7/10): T008 cut v1.0.0 (+ `docs/release-notes-v1.md` from
   the cleanup as `--notes-file`), T009 repoint five consumers, T010 retire
   the primary-stays-on-main mandate — **resumes only after the cleanup
   merges** (renames after v1.0.0 would be breaking).

## Feature Backlog

2 backlogged · 0 planned · 1 tasked · 8 implemented — see `.project/features/`.

- `remote-install-source` — **tasked**:
  `plan-remote-install-source-2026-07-12.md` (approved) →
  `tasks-remote-install-source-18d3.md` (ready, 10 tasks / 6 phases;
  constitution v1.5.0 amendment already applied). Phase 6 retires the
  primary-stays-on-main mandate.
- `disposable-report-merge-driver` — backlogged: `.gitattributes` merge
  driver for the disposable single-writer reports; what makes parallel
  auto-merges conflict-free.
- `worktree-reap-and-fanout` — backlogged: deterministic reap of merged
  delegated worktrees + delegation-gate fan-out. (Depends on the merge
  driver.)

## Critique

`.project/critique.md` (2026-07-11) has 5 open findings on the constitution:
3 suggestions, 1 question (register enum lacks a removed/retired state), 1
risk (smoke CI never runs). Work them from the checklist directly.

## Recently Landed (2026-07-12)

- **background-by-default-flow** merged (`b5ff7c8`, 12 commits, delegated
  worktree run): solo `/ardd-plan` commits plan+tasks straight to the default
  branch (no branch gate); `delegation: eager|ask|inline` and
  `merge_policy: auto|ask` constitution workflow knobs consumed by
  `/ardd-implement`//`/ardd-converge` (bootstrap asks once, update
  backfills); `fold-to-main.sh` reframed as recovery path; decision record
  0005; `ardd-state.sh stamp` learned both keys; this repo dogfoods
  `eager`+`auto`. Skills reinstalled into `.claude/skills/`.
- **Field note from the run**: the first delegation attempt blocked because
  the plan/tasks files were written but uncommitted on `main` — exactly the
  gap T002 closed (solo plan *commits* to default; the commit is the
  handoff). Also observed: a paused delegated run with zero commits had its
  harness worktree auto-reaped between turns — candidate `/ardd-feedback`.

## Recommended Next Step

Run `/ardd-implement` to execute `tasks-skill-surface-cleanup-be30.md`
(18 tasks, delegated as ONE background run, single merge on completion).
Then resume `tasks-remote-install-source-18d3.md` T008–T010 (release cut,
consumer repoint, mandate retirement). Other threads: unpushed `main`
commits; reaped-worktree `/ardd-feedback`; critique checklist (migrates to
audit.md during the cleanup); `disposable-report-merge-driver`.
