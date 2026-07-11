# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-feedback, skill/constitution principle coupling captured). Keep this current as artifacts are refined and open questions are resolved._

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

## Feedback

2 open feedback file(s) — see `.project/feedback/`, picked up by the next
`/ardd-plan`:

- `feedback-repo-critique-6ad1.md` — standing repo-critique items.
- `feedback-skill-constitution-principle-c-1058.md` — **new.** Skills
  hardcode target-constitution principle names (`ardd-plan`'s simplicity /
  Complexity Tracking, `ardd-critique`'s Simplicity section) a given target
  may not define; skills should read the target's actual constitution and
  enforce whatever principles it finds. Carries a scope guard so the fix
  leaves ARDD's own "Principle II" meta-references intact.

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

Merge `render-output-target` into `main` (6 commits) — the render-destination
work is complete and green under the pre-commit hook. After merging, a
`/ardd-verify` pass would fold this change plus the already-merged README
rewrite and `new.sh` fix into `DEFECTS.md`.

Then plan the newly captured skill/constitution coupling feedback with
`/ardd-plan feedback-skill-constitution-principle-c-1058.md` (scope it so the
older `feedback-repo-critique` file isn't swept into the same plan).

`main` also holds unpushed commits (README rewrite, `new.sh` fix, render
feedback); push when ready. The standing thread is unchanged: provisioning
`ANTHROPIC_API_KEY` so the two existing smoke scenarios actually run.
