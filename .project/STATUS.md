# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-tasks, README rewrite tasks ready). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. Plan-scoped questions, none blocking:

- `plan-readme-rewrite-2026-07-10.md` — whether to state a skill count in the
  README at all (a count is drift-by-construction), and whether
  `workflow_mode` belongs in the README or only in `CLAUDE.md`.
- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-09 (fifth pass). Unchanged.

The remaining entry is the `970d935b` residue — the behavioral-smoke-tier
standard still exceeds coverage, and no scenario has ever executed because
`ANTHROPIC_API_KEY` is deliberately unprovisioned. Tracked, not re-promptable.
Nothing is unsurfaced, so the next `/ardd-plan` has no defects to offer.

Today's `new.sh` stdin fix (`212d9c1`) landed after this verify pass. It
contradicted no `DEFECTS.md` claim, but `/ardd-verify` has not run against it.

## Feedback

None open — all 16 feedback files are `status: planned`.
`feedback-readme-rewrite-current-state-ec3e.md` was consumed today by
`plan-readme-rewrite-2026-07-10.md`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see
`.project/features/`. The README rewrite carries no feature slug: it came
from feedback, not the backlog.

## In Flight

On branch `readme-rewrite` (this checkout), uncommitted work: the approved
plan `plan-readme-rewrite-2026-07-10.md`, its tasks file
`tasks-readme-rewrite-2e05.md` (`ready`, 0/5), the consumed feedback file,
and this file. No sibling worktrees. `main` is clean and pushed through
`212d9c1` (the `new.sh` stdin fix).

## Recommended Next Step

Run `/ardd-implement` to execute `tasks-readme-rewrite-2e05.md` (5 tasks, 4
phases, all sequential). Solo mode + a docs-only, single-file diff makes this
a natural inline run rather than a delegated worktree — the whole task set
edits `README.md`. The plan is README-only by design; `USAGE.md` and
`guides/*.md` were deliberately excluded to keep the diff from colliding with
the same merge-conflict problem the 2026-07-06 docs plan hit.

The standing thread is unchanged: provisioning `ANTHROPIC_API_KEY` so the two
existing smoke scenarios actually run — until they do, the behavioral-test
tier is a claim the repo makes but has never once exercised.
