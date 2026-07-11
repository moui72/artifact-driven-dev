# artifact-driven-dev — Project Status

_Updated: 2026-07-11 (primary-stays-on-main invariant MERGED — constitution v1.4.0; worked in a worktree, primary never left main). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.4.0) | — |

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

None open — `feedback-primary-worktree-stays-on-main-4985.md` consumed by
`plan-primary-stays-on-main-2026-07-11.md`; `feedback-scrap-npx-channel-9c51.md`
and `feedback-consolidate-setup-skills-8541.md` consumed by their (merged)
plans. All feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.

## Recently Landed (2026-07-11 session)

- **Primary-stays-on-main invariant** merged (`7338a6b`, constitution
  **v1.4.0**): this repo is the local source consumers install/update from,
  so its primary/default worktree never leaves `main`; feature work lives in
  separate worktrees. First exercised on its own implementation — worked in a
  worktree, primary never left `main`. Also fixes the root cause of the
  ref-lock anomaly below (a consumer's `ardd-update` found this source off
  `main` and forced it back mid-commit).
- **npx-channel scrap** merged (`dc70e63`, v1.3.0): npx channel + `/ardd-setup`
  removed; `new.sh --existing` mode added (test-first); docs reconciled to two
  install routes. This repo's own install was re-synced (`ardd-setup` pruned).
- **Catalog consolidation** merged (`d9d6d76`): source skills 21→18,
  `analyze`/`lint` re-tiered `core`, `install.sh` prunes removed skill dirs.

## Recommended Next Step

Push `main` when ready (it holds this session's unpushed commits). Going
forward, all feature work in this repo uses a worktree (constitution v1.4.0).
Optional idea threads still open from the consolidation plan (curated default
install F006b; plan/tasks prose length) if you want to pursue them.
