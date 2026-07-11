# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-implement, eager-backgrounding complete on branch). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. One plan-scoped set remains, non-blocking:

- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

(The eager-backgrounding plan's open questions were resolved during
implementation: fold restricted to the clean case at the gate (tasks still
`ready`), converge's in-progress fold accepted as bounded; `fold-to-main.sh`
does not delete the folded branch (caller's choice); solo-mode only; a
dedicated script, per the `worktree-align` precedent — see decision record
0004.)

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-09 (fifth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); no scenario has ever executed
because `ANTHROPIC_API_KEY` is unprovisioned. Nothing unsurfaced.

## Feedback

None open — all feedback files are `status: planned`.
(`feedback-eager-backgrounding-return-to-5cde.md` was just consumed by
`plan-eager-backgrounding-2026-07-10.md`.)

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.

## In Flight

- Branch `eager-backgrounding` (this checkout): tasks file
  `tasks-eager-backgrounding-98b6.md` **completed** (3/3), 7 commits ahead of
  `main`, awaiting merge. Delivered: `fold-to-main.sh` (+ test, CI, install
  wiring); `/ardd-implement` & `/ardd-converge` gates now offer backgrounding
  regardless of `on_default`, folding to `main` first; CLAUDE.md/USAGE/decision
  record 0004 updated.

(Note: `main` is mutated by a concurrent session; its own STATUS.md may
describe different in-flight state. At merge, STATUS.md is disposable — the
owning skill regenerates it.)

## Recommended Next Step

Merge `eager-backgrounding` into `main` (7 commits) — the change is complete
and green under the pre-commit hook. Note it edits the product skills
`ardd-implement`/`ardd-converge` and adds `fold-to-main.sh`; this repo's own
installed copies under `.claude/skills/` won't reflect them until the next
`install.sh`/`/ardd-update`.

`main` also holds unpushed commits; push when ready. The `ANTHROPIC_API_KEY`
smoke thread is unchanged.
