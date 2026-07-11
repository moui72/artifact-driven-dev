# artifact-driven-dev — Project Status

_Updated: 2026-07-11 (npx-scrap plan approved, 6 tasks ready on branch `scrap-npx-channel`; catalog consolidation already merged to main). Keep this current as artifacts are refined and open questions are resolved._

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

None open — `feedback-scrap-npx-channel-9c51.md` consumed by
`plan-scrap-npx-channel-2026-07-11.md` (F001–F004 all incorporated);
`feedback-consolidate-setup-skills-8541.md` consumed by the (merged)
consolidation plan. All feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.

## In Flight

- Branch `scrap-npx-channel` (this checkout) — plan
  `plan-scrap-npx-channel-2026-07-11.md` **approved**, tasks
  `tasks-scrap-npx-channel-0d1d.md` **ready** (0/6). Scrap the npx acquisition
  channel: P1 constitution revision (`[artifacts: constitution]`, needs a
  version bump), P2 existing-project curl bootstrap (test-first `new.sh`
  mode), P3 delete `/ardd-setup`, P4 docs, P5 verify. Three open questions
  carried (constitution bump magnitude, mode-vs-sibling, orphaned-npx-user
  handling). Not yet committed/merged.

## Recently Landed

- **Catalog consolidation** merged to `main` (`d9d6d76`): source skills
  21→18 (`/ardd-kickoff`→`/ardd-bootstrap`, `/ardd-featurize`→`/ardd-codify`,
  `/ardd-tasks`→`/ardd-plan`), `analyze`/`lint` re-tiered `core`, `install.sh`
  prunes removed skill dirs. This repo's own install was re-synced
  (`./install.sh .`, `ardd-version.md` → `d9d6d76`) — the prune was validated
  live. Three consolidation-plan open questions still unresolved (curated
  default install F006b, deprecation stubs, the accepted plan-prose length).

## Recommended Next Step

`/ardd-implement` to execute `tasks-scrap-npx-channel-0d1d.md` (start Phase 1,
the constitution revision — note T001 wants `/ardd-refine constitution` for
correct versioning). `main` holds unpushed commits — push when ready.
