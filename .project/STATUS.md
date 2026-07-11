# artifact-driven-dev — Project Status

_Updated: 2026-07-11 (post-/ardd-tasks, generic-render tasks generated on branch). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. Two plan-scoped sets remain, both non-blocking:

- `plan-generic-render-2026-07-11.md` (approved) — (1) `render_section` default
  derivation (capitalized stem; standard templates declare explicit headers);
  (2) `render_hint` lint validation (non-empty when present vs. free prose);
  (3) migration scope (only the three historically-renderable artifacts
  auto-migrate). The core spike (enumerate diagram types/Mermaid syntax vs.
  agent knowledge) was resolved before planning: **fully generic**.
- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-11 (sixth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); no scenario has ever executed
because `ANTHROPIC_API_KEY` is unprovisioned. Nothing unsurfaced. The sixth
pass confirmed the render, principle-agnostic-skills, and eager-backgrounding
merges introduced no new drift.

## Feedback

None open — all feedback files are `status: planned`.
(`feedback-generic-configurable-render-di-1738.md` was just consumed by
`plan-generic-render-2026-07-11.md`.)

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.

## In Flight

- Branch `generic-render` (this checkout): plan
  `plan-generic-render-2026-07-11.md` **approved**, tasks file
  `tasks-generic-render-803c.md` **ready** (0/5) — not yet started, not yet
  merged to `main`. Delivers generic, `diagram_type`-driven `/ardd-render`
  (retiring the closed 3-argument table): skill rewrite → lint schema →
  standard templates → migration for existing installs → user docs pointing
  to the Mermaid reference.

## Recommended Next Step

Run `/ardd-implement` and select `tasks-generic-render-803c.md` to execute the
five tasks (skill rewrite → lint schema / templates / docs in parallel →
migration). T002 and T004 carry the deterministic tests.

`main` also holds unpushed commits; push when ready. The `ANTHROPIC_API_KEY`
smoke thread is unchanged.
