# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-tasks, eager-backgrounding tasks generated on branch). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. Two plan-scoped sets remain, both non-blocking:

- `plan-eager-backgrounding-2026-07-10.md` (approved) — (1) whether folding a
  feature branch onto `main` at delegation time blurs "default branch =
  merged truth" (fine at run start; mid-run would put in-progress state on
  `main` briefly); (2) auto-delete the folded branch?; (3) solo-mode only?;
  (4) dedicated `fold-to-main.sh` vs inline git commands.
- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

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

- Branch `eager-backgrounding` (this checkout): plan
  `plan-eager-backgrounding-2026-07-10.md` **approved**, tasks file
  `tasks-eager-backgrounding-98b6.md` **ready** (0/3) — not yet started, not
  yet merged to `main`.

(Note: `main` is mutated by a concurrent session; its own STATUS.md may
describe different in-flight state. At merge, STATUS.md is disposable — the
owning skill regenerates it.)

## Recommended Next Step

Run `/ardd-implement` and select `tasks-eager-backgrounding-98b6.md` to
execute the three tasks (fold-to-main.sh + test → gate rewrite → doc sweep).
T001 carries the deterministic test; T002/T003 are skill-prose + doc changes.

`main` also holds unpushed commits; push when ready. The `ANTHROPIC_API_KEY`
smoke thread is unchanged.
