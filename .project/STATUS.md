# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-plan, eager-backgrounding draft plan on branch). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. Two plan-scoped sets remain, both non-blocking:

- `plan-eager-backgrounding-2026-07-10.md` (draft) — (1) whether folding a
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

- Branch `eager-backgrounding` (this checkout): draft plan
  `plan-eager-backgrounding-2026-07-10.md` written, feedback F001+F002
  planned — not yet tasked, not yet merged to `main`.

(Note: `main` is mutated by a concurrent session; its own STATUS.md may
describe different in-flight state. At merge, STATUS.md is disposable — the
owning skill regenerates it.)

## Recommended Next Step

Run `/ardd-tasks` and select `plan-eager-backgrounding-2026-07-10.md` to
approve it and generate its task list — but first consider weighing in on the
plan's central open question (folding onto `main` at delegation time), since
it shapes what the tasks implement.

`main` also holds unpushed commits; push when ready. The `ANTHROPIC_API_KEY`
smoke thread is unchanged.
