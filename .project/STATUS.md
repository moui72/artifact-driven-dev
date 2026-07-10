# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-implement, README rewrite complete on branch). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. One plan-scoped set remains, non-blocking:
`plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
optionally `gh repo create`, and whether it should pin a tag rather than
track `main`. (The README-rewrite plan's two open questions were both
resolved during implementation: the skill count was dropped rather than
corrected, and `workflow_mode` was documented in the README.)

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-09 (fifth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); no scenario has ever executed
because `ANTHROPIC_API_KEY` is unprovisioned. Nothing unsurfaced.

Today's `new.sh` stdin fix (`212d9c1`, on `main`) landed after this verify
pass and hasn't been verified against; it contradicted no `DEFECTS.md` claim.

## Feedback

None open — all 16 feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see
`.project/features/`.

## In Flight

- Branch `readme-rewrite` (this checkout): 6 commits ahead of `main`, tasks
  file `tasks-readme-rewrite-2e05.md` **completed** (5/5), awaiting merge.
- Worktree `dev/ardd-feedback-render` (branch `feedback-render-output-target`):
  no active tasks file — a separate line of work, unrelated to this rewrite.

## Recommended Next Step

Merge `readme-rewrite` into `main` and push. Note the scope: the run touched
`README.md`, `scripts/gen-skill-docs.sh`, and `templates/WORKFLOW.md` — wider
than the plan's original README-only intent, by explicit decision, because the
README's core-loop region is generated and the `workflow_mode` docs had to
live in the generator to survive regeneration. After merge, `/ardd-verify`
would fold in both today's `new.sh` fix and this rewrite on its next pass.

The standing thread is unchanged: provisioning `ANTHROPIC_API_KEY` so the two
existing smoke scenarios actually run.
