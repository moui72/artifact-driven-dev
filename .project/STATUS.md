# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-tasks, principle-agnostic-skills tasks ready on branch). Keep this current as artifacts are refined and open questions are resolved._

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

1 open feedback file — see `.project/feedback/`, picked up by the next
`/ardd-plan`:

- `feedback-repo-critique-6ad1.md` — standing repo-critique items.

(`feedback-skill-constitution-principle-c-1058.md` was consumed by
`plan-principle-agnostic-skills-2026-07-10.md` and is now `status: planned`.)

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.
(The render-output-target work came from feedback, not the feature register, so
it targets no register slug.)

## In Flight

- Branch `principle-agnostic-skills` (this checkout): plan approved,
  `tasks-principle-agnostic-skills-857b.md` **ready** (0/4). Makes
  `/ardd-plan` naive to which principles a target constitution declares —
  three conditional-phrasing edits to `skills/ardd-plan/SKILL.md` (Complexity
  Tracking + Production Annotation Summary gated on the constitution actually
  declaring those principles), mirroring `/ardd-analyze` step 3, plus a
  read-through verification task.

  (`render-output-target` merged into `main` at `eaff4a0`.)

## Recommended Next Step

Run `/ardd-implement` to execute `tasks-principle-agnostic-skills-857b.md`
(4 tasks, all in `skills/ardd-plan/SKILL.md`).

Standing threads, unchanged: `main` holds unpushed commits (push when ready),
and a `/ardd-verify` pass would fold the merged render-destination change plus
the README rewrite and `new.sh` fix into `DEFECTS.md`. The
`ANTHROPIC_API_KEY`-for-smoke-scenarios thread also remains.
