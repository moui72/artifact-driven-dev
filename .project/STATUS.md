# artifact-driven-dev — Project Status

_Updated: 2026-07-12 (background-by-default-flow planned and tasked — ready for /ardd-implement). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.4.0) | — |

## Open Questions

None in the artifact. One plan-scoped set remains, non-blocking:

- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-11 (sixth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); no scenario has ever executed
because `ANTHROPIC_API_KEY` is unprovisioned. Nothing unsurfaced.

## Feedback

None open — all feedback files are `status: planned`.

## Feature Backlog

2 backlogged · 0 planned · 1 tasked · 7 implemented — see `.project/features/`.

- `background-by-default-flow` — **tasked**:
  `plan-background-by-default-flow-2026-07-12.md` (approved) →
  `tasks-background-by-default-flow-8e91.md` (ready, 10 tasks / 5 phases).
- `disposable-report-merge-driver` — backlogged: mechanize the
  disposable-report rule as a `.gitattributes` merge driver so parallel
  merges never conflict on generated reports.
- `worktree-reap-and-fanout` — backlogged: reap merged delegated worktrees;
  delegation gate fans out one worktree per independent ready tasks file.
  (Depends on the merge driver for safe out-of-order landings.)

## Critique

`.project/critique.md` (2026-07-11) has 5 open findings on the constitution:
3 suggestions (each with a `/ardd-refine`//`/ardd-feature` command), 1
question (register enum lacks a removed/retired state — `npx-skills-install`
still reads `implemented`), 1 risk (smoke CI never runs). Work them from the
checklist directly.

## Recently Landed (2026-07-11 session)

- **Primary-stays-on-main invariant** merged (`7338a6b`, constitution
  **v1.4.0**): this repo's primary worktree never leaves `main`; feature work
  lives in separate worktrees.
- **npx-channel scrap** merged (`dc70e63`, v1.3.0): two install routes remain,
  both converging directly on `install.sh`.
- **Catalog consolidation** merged (`d9d6d76`): source skills 21→18.

## Recommended Next Step

Run `/ardd-implement` to execute `tasks-background-by-default-flow-8e91.md`
(10 tasks; T001 and T010 carry user checkpoints for knob names and dogfood
values). The critique checklist and the unpushed `main` commits remain open
threads.
