# artifact-driven-dev — Project Status

_Updated: 2026-07-11 (npx-scrap MERGED to main — constitution v1.3.0, npx channel + /ardd-setup removed, new.sh --existing added). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.3.0) | — |

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

None open — `feedback-scrap-npx-channel-9c51.md` consumed by
`plan-scrap-npx-channel-2026-07-11.md` (F001–F004 all incorporated);
`feedback-consolidate-setup-skills-8541.md` consumed by the (merged)
consolidation plan. All feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.

## Recently Landed

- **npx-channel scrap** merged to `main` (`dc70e63`, tasks
  `tasks-scrap-npx-channel-0d1d.md` completed 6/6, all commits signed):
  constitution → **v1.3.0** (npx channel + `/ardd-setup` bridge removed from
  the acquisition standing decision, MINOR bump w/ SIR); `new.sh` gained an
  **`--existing`** mode (test-first, cases 15–18) that installs into a
  populated project and routes the handoff to `/ardd-codify`; `skills/ardd-setup/`
  deleted; docs (README/USAGE/CLAUDE/WORKFLOW) reconciled to two routes with
  an orphaned-npx recovery note. Full local CI green (30 checks).
- **Catalog consolidation** merged earlier (`d9d6d76`): source skills 21→18,
  `analyze`/`lint` re-tiered `core`, `install.sh` prunes removed skill dirs.
- **Note:** this repo's own dogfooded install still carries a stale
  `.claude/skills/ardd-setup/` — re-run `./install.sh .` to prune it.
- **Anomaly (resolved, worth watching):** during the T005 commit an external
  `ardd-update` process stashed the branch WIP and checked out `main`
  mid-commit (ref-lock failure). Work was recovered from the stash and
  re-committed; nothing lost. If it recurs, an external/scheduled ardd-update
  is contending for the working tree.

## Recommended Next Step

Push `main` when ready (it holds unpushed commits). Optionally `./install.sh .`
to prune the stale `ardd-setup` from this repo's own install. Two feature-idea
threads remain from the consolidation plan's open questions (curated default
install F006b; plan/tasks prose length) if you want to pursue them.
