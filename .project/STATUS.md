# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-implement, render-output-target tasks completed on branch). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. One plan-scoped set remains, non-blocking:

- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

(The render-output-target plan's three open questions were resolved during
implementation: per-artifact frontmatter was chosen for granularity, both
`render_target` and `render_section` shipped, and path-safety validation was
deliberately deferred — the lint only checks the fields are non-empty, trusting
a project to edit its own artifacts.)

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-09 (fifth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); no scenario has ever executed
because `ANTHROPIC_API_KEY` is unprovisioned. Nothing unsurfaced. The README
rewrite, `new.sh` fix, and now the render-destination change will all be folded
in on the next `/ardd-verify` pass; none contradicts a `DEFECTS.md` claim.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.
(The render-output-target work came from feedback, not the feature register, so
it targets no register slug.)

## In Flight

- Branch `render-output-target` (this checkout): tasks file
  `tasks-render-output-target-3b3b.md` **completed** (3/3), 5 commits ahead of
  `main`, awaiting merge. Delivered: `/ardd-render` reads per-artifact
  `render_target`/`render_section` (default `README.md`), `lint-project.sh`
  validates the fields with fixtures + regression test, and USAGE documents the
  knob.

## Recommended Next Step

Merge `render-output-target` into `main` (5 commits) — the render-destination
work is complete and green under the pre-commit hook. After merging, a
`/ardd-verify` pass would fold this change plus the already-merged README
rewrite and `new.sh` fix into `DEFECTS.md`.

`main` also holds unpushed commits (README rewrite, `new.sh` fix, render
feedback); push when ready. The standing thread is unchanged: provisioning
`ANTHROPIC_API_KEY` so the two existing smoke scenarios actually run.
