# artifact-driven-dev — Project Status

_Updated: 2026-07-11 (post-/ardd-implement, generic-render merged to main via delegated subagent). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. One plan-scoped set remains, non-blocking:

- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

(The generic-render plan's three open questions were resolved during
implementation: `render_section` defaults to the capitalized filename stem
with standard templates declaring explicit headers; `render_hint` is
non-empty-checked when present; the migration auto-backfills only the three
historically-renderable artifacts.)

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-11 (sixth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); no scenario has ever executed
because `ANTHROPIC_API_KEY` is unprovisioned. Nothing unsurfaced. The
generic-render merge post-dates the sixth pass and hasn't been verified
against yet; it contradicts no `DEFECTS.md` claim.

## Feedback

None open — all feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.

## In Flight

Nothing in flight — no sibling worktrees, no unmerged branches. The
generic-render work (generic `diagram_type`-driven `/ardd-render`, lint
schema, standard templates, migration `0005`, docs → mermaid.js.org) merged
into `main` (`316705d`); its delegated worktree and the `generic-render` /
`worktree-agent-*` branches were removed.

## Recommended Next Step

`main` holds 15 unpushed commits (the render-genericity work plus earlier
session commits) — push when ready. A `/ardd-verify` pass would fold the
generic-render, eager-backgrounding, and render-destination merges into
`DEFECTS.md` (last checked 2026-07-11, sixth pass). The `ANTHROPIC_API_KEY`
smoke thread is unchanged.
