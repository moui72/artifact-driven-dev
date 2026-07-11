# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-tasks, render-output-target tasks generated on branch). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. Two plan-scoped sets remain, both non-blocking:

- `plan-render-output-target-2026-07-10.md` (approved) — (1) config
  granularity: per-artifact `render_target` frontmatter vs. a project-level
  default with per-artifact override; (2) whether to ship `render_section`
  too or file-only now (YAGNI); (3) path-safety guarding for `render_target`.
  All three are design confirmations to settle during implementation of
  `tasks-render-output-target-3b3b.md`.
- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-09 (fifth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); no scenario has ever executed
because `ANTHROPIC_API_KEY` is unprovisioned. Nothing unsurfaced. Both the
README rewrite and the `new.sh` stdin fix are now merged to `main` and will be
folded in on the next `/ardd-verify` pass; neither contradicts a `DEFECTS.md`
claim.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.
(The render-output-target work came from feedback, not the feature register, so
it targets no register slug.)

## In Flight

- Branch `render-output-target` (this checkout): plan
  `plan-render-output-target-2026-07-10.md` **approved**, tasks file
  `tasks-render-output-target-3b3b.md` **ready** (0/3) — not yet started, not
  yet merged to `main`.

## Recommended Next Step

Run `/ardd-implement` and select `tasks-render-output-target-3b3b.md` to
execute the three tasks (skill wiring → lint+fixtures → doc sync). T002 and
T003 can run in parallel once T001 settles the `render_target`/`render_section`
field names.

The standing thread is unchanged: provisioning `ANTHROPIC_API_KEY` so the two
existing smoke scenarios actually run. `main` also holds unpushed commits
(README rewrite, `new.sh` fix, the render feedback) — push when ready.
