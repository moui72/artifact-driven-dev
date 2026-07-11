# artifact-driven-dev — Project Status

_Updated: 2026-07-11 (post-/ardd-update, reinstall to 0d053f0; principle-agnostic-skills merged). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. One plan-scoped set remains, non-blocking:

- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

(The eager-backgrounding plan's open questions were resolved during
implementation: fold restricted to the clean case at the gate (tasks still
`ready`), converge's in-progress fold accepted as bounded; `fold-to-main.sh`
does not delete the folded branch (caller's choice); solo-mode only; a
dedicated script, per the `worktree-align` precedent — see decision record
0004.)

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-09 (fifth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); no scenario has ever executed
because `ANTHROPIC_API_KEY` is unprovisioned. Nothing unsurfaced.

## Feedback

1 open feedback file — see `.project/feedback/`, picked up by the next
`/ardd-plan`:

- `feedback-repo-critique-6ad1.md` — standing repo-critique items.

(`feedback-skill-constitution-principle-c-1058.md` was consumed by
`plan-principle-agnostic-skills-2026-07-10.md` and is now `status: planned`.)

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.

## In Flight

Nothing in flight — no other worktrees, no unmerged branches. Both recent
efforts are merged into `main` (`0d053f0`): the eager-backgrounding work
(`fold-to-main.sh` + delegation-gate changes) and principle-agnostic-skills
(`/ardd-plan` steps 6 & 8 now gate Complexity Tracking / Production Annotation
Summary on the constitution's *declared* principles). The installed
`.claude/skills/` copies were just regenerated to match via `/ardd-update`.

## Recommended Next Step

No pending implementation work. Standing threads:

- 1 open feedback file (`feedback-repo-critique-6ad1.md`) — run `/ardd-plan`
  when ready to consume it.
- A `/ardd-verify` pass would fold recent merges into `DEFECTS.md`
  (last checked 2026-07-09).
- The `ANTHROPIC_API_KEY` smoke thread remains (no scenario has ever run).
