# artifact-driven-dev — Project Status

_Updated: 2026-07-12 (background-by-default-flow MERGED — delegated worktree run, ff to `b5ff7c8`; knobs live: `delegation: eager`, `merge_policy: auto`). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.4.0, + `delegation`/`merge_policy` workflow fields) | — |

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

None open — all feedback files are `status: planned`.

## Feature Backlog

3 backlogged · 0 planned · 0 tasked · 8 implemented — see `.project/features/`.

- `remote-install-source` — backlogged: install.sh//ardd-update default to
  the latest tagged GitHub release instead of a live local checkout
  (release-cutting process included); endgame retires the
  primary-stays-on-main mandate via constitution amendment.
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

Run `/ardd-plan remote-install-source` — it's the root-cause fix (retires
the primary-stays-on-main mandate) and defines the release discipline the
other consumers update against. Other threads: `main` has 2 unpushed
commits (STATUS refreshes); log the reaped-worktree observation via
`/ardd-feedback`; critique checklist; `disposable-report-merge-driver`.
