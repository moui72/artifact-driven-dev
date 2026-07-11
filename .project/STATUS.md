# artifact-driven-dev — Project Status

_Updated: 2026-07-10 (post-/ardd-feedback, eager-backgrounding note captured on main). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.5) | — |

## Open Questions

None in the artifact. One plan-scoped set remains, non-blocking:

- `plan-quickstart-new-project-2026-07-09.md` — whether `new.sh` should
  optionally `gh repo create`, and whether it should pin a tag rather than
  track `main`.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-09 (fifth pass). Unchanged:
the behavioral-smoke-tier residue (`970d935b`); no scenario has ever executed
because `ANTHROPIC_API_KEY` is unprovisioned. Nothing unsurfaced. The recently
merged work (README rewrite, `new.sh` fix, render destination, principle-
agnostic skills) will all be folded in on the next `/ardd-verify` pass; none
contradicts a `DEFECTS.md` claim.

## Feedback

1 open feedback file — see `.project/feedback/`, picked up by the next
`/ardd-plan`:

- `feedback-eager-backgrounding-return-to-5cde.md` — **new.** The solo-mode
  delegation gate defaults to inline whenever already on a feature
  branch/worktree, never offering to background (F001, Reconsidered); and when
  the user does opt to delegate from such a session, the focused session
  should return to `main` while the subagent works (F002, UX). Touches
  `skills/ardd-implement` / `skills/ardd-converge` step 3; untagged (no
  artifact records the delegation rule).

(`feedback-repo-critique-6ad1.md`, `-docs-ca1d.md`, and
`feedback-skill-constitution-principle-c-1058.md` are all `status: planned`.)

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see `.project/features/`.

## In Flight

Nothing in flight — no sibling worktrees, no unmerged feature branches.
`principle-agnostic-skills` merged into `main` (`4c4bbc2`) and its branch was
deleted; `render-output-target` merged earlier (`eaff4a0`).

## Recommended Next Step

`main` holds 5 unpushed commits (principle-agnostic skills + the render work's
tail) — push when ready. The just-captured `feedback-eager-backgrounding-
return-to-5cde.md` is queued for a future `/ardd-plan` (scope it to that file
so the older planned feedback isn't re-swept); no rush to plan it now.

Standing threads, unchanged: a `/ardd-verify` pass would fold the recent merges
into `DEFECTS.md`, and provisioning `ANTHROPIC_API_KEY` would let the two
existing smoke scenarios actually run.
