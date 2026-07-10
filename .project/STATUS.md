# artifact-driven-dev — Project Status

_Updated: 2026-07-09 (post-/ardd-implement, defect-doc-drift complete). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. Two plan-scoped questions remain recorded in
`plan-quickstart-new-project-2026-07-09.md`: whether `new.sh` should
optionally `gh repo create`, and whether it should pin a tag rather than
track `main`. Neither blocks anything.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-09 (fifth pass). Down from
3: `b7d2252c` and `f666274c` were closed today by
`plan-defect-doc-drift-2026-07-09.md`, and the regenerated `DEFECTS.md`
confirms they dropped out.

The remaining entry is the `970d935b` residue — the behavioral-smoke-tier
standard still exceeds coverage, and no scenario has ever executed because
`ANTHROPIC_API_KEY` is deliberately unprovisioned. Tracked, not re-promptable.
Nothing is unsurfaced, so the next `/ardd-plan` has no defects to offer.

## Feedback

None open — all 15 feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see
`.project/features/`. Today's `defect-doc-drift` work carried no feature
slug: it came from `DEFECTS.md`, not the backlog.

## In Flight

Branch `defect-doc-drift` (this checkout): 1 commit ahead of `main`, work
complete, awaiting merge. No sibling worktrees.

## Recommended Next Step

Merge `defect-doc-drift` into `main`, re-run `./install.sh .`, and push. The
standing thread is provisioning `ANTHROPIC_API_KEY` so the two existing smoke
scenarios actually run — until they do, the behavioral-test tier is a claim
the repo makes but has never once exercised, which is the last real gap
between what the constitution says and what CI proves.
