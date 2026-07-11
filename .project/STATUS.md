# artifact-driven-dev — Project Status

_Updated: 2026-07-11 (catalog-consolidation MERGED to main — 21→18 skills; npx-channel-scrap feedback open). Keep this current as artifacts are refined and open questions are resolved._

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

1 open — `feedback-scrap-npx-channel-9c51.md`: scrap the `npx skills add`
acquisition channel, replace with an existing-project curl bootstrap (sibling
to `new.sh`), and delete `/ardd-setup` as dead architecture. F002/F004 tagged
`[artifacts: constitution]` (reverses the three-channels standing decision).
Keep separate from the in-flight consolidation run. Will be picked up by the
next `/ardd-plan`. (`feedback-consolidate-setup-skills-8541.md` is now
`planned`, consumed by `plan-consolidate-setup-skills-2026-07-11.md`.)

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.

## In Flight

Nothing in flight — no sibling worktrees, no unmerged branches. The
generic-render work (generic `diagram_type`-driven `/ardd-render`, lint
schema, standard templates, migration `0005`, docs → mermaid.js.org) merged
into `main` (`316705d`); its delegated worktree and the `generic-render` /
`worktree-agent-*` branches were removed.

## Recently Landed

- **Catalog consolidation** merged to `main` (`d9d6d76`, tasks file
  `tasks-consolidate-setup-skills-1c3f.md` completed 10/10, all commits
  signed). Source skills 21→18: `/ardd-kickoff`→`/ardd-bootstrap`,
  `/ardd-featurize`→`/ardd-codify`, `/ardd-tasks`→`/ardd-plan` (now 481
  lines — the T007 length flag was reviewed and accepted). `analyze`/`lint`
  re-tiered `core`. `install.sh` now prunes removed ardd skill dirs
  (`test-install-prune.sh` + CI). No constitution version bump (T009: no
  principle changed). Three plan open questions remain unresolved (curated
  default install F006b, deprecation stubs, and the accepted-for-now
  prose-length gate).
- **Note:** this repo's own dogfooded install (`.claude/skills/ardd-*/`)
  still carries the removed `ardd-kickoff`/`ardd-featurize`/`ardd-tasks`
  dirs — re-run `./install.sh .` to sync and exercise the new prune.

## Recommended Next Step

`/ardd-plan feedback-scrap-npx-channel-9c51.md` to draft the npx-channel
replacement (scrap npx → existing-project curl bootstrap → delete
`/ardd-setup`; touches `constitution.md`). Optionally first `./install.sh .`
to sync this repo's own install and validate the prune. `main` holds
unpushed commits — push when ready.
