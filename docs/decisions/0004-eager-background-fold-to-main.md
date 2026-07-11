# 0004 — Eager background delegation via fold-to-main

_2026-07-10. Reverses the "on a branch → run inline" delegation default
(`/ardd-implement`, `/ardd-converge`)._

## The old default and why it was wrong

The solo-mode delegation gate used to skip the "delegate to a background
subagent?" offer whenever `on_default` was false — i.e. whenever the run was
already on a feature branch or worktree. The stated reason: "the run is
already isolated on a branch, so all its state already rides that branch."

That conflated two different things. A branch handles **state isolation**;
backgrounding is about **execution locus** — freeing the interactive
session while long-running work proceeds elsewhere. Being on a branch is no
reason to run in the foreground. In practice the gate defaulted to inline for
the entire common case (every `/ardd-plan`→`/ardd-tasks`→`/ardd-implement`
chain runs on the feature branch `/ardd-plan` created), so backgrounding was
almost never offered. (Feedback `feedback-eager-backgrounding-return-to-5cde`.)

## The obstacle that made inline look necessary

`Agent isolation: "worktree"` branches the subagent's worktree from
`origin/<default>` (fresh base), and `worktree-align.sh` fast-forwards *local
`<default>`* into it. There is **no** way to branch a delegated worktree from
the current feature branch. So a delegated run can only see state that lives
on local `<default>`. When you're on a feature branch, the tasks file and its
progress live on *that branch* — a delegated worktree branched from
`<default>` wouldn't see them. Inline was the path of least resistance, not a
principled choice.

## The decision

Offer backgrounding **eagerly, regardless of `on_default`**. When the user
backgrounds while on a feature branch, first **fold that branch into local
`<default>` and return the focused session there** — a new deterministic
`scripts/fold-to-main.sh` does the fast-forward fold + checkout, refusing
(`folded=false reason=dirty|detached|diverged|checkout-failed`) rather than
resolving, exactly like `worktree-align.sh`. Then delegate: the subagent's
worktree branches from `<default>`, align carries the just-folded state in,
and the interactive session is left clean on `<default>`.

This ties the two feedback asks into one operation: **return-to-main is the
mechanism that makes eager backgrounding possible on a branch.** `fold-to-main`
and `worktree-align` are counterparts — one pushes branch state onto local
`<default>`, the other pulls local `<default>` into the worktree.

## Invariants preserved

- **"No state-commit before the branch."** A fast-forward authors no new
  commit — folding only advances the `<default>` ref to commits that already
  exist on the branch. The "nothing is committed in the delegation-gate step"
  note still holds.
- **"Default branch = merged truth."** At the gate the tasks file is still
  `ready` (the `ready→in-progress` flip happens later, in the worktree), so
  the fold carries only *planned* truth onto `<default>`; in-flight truth
  rides the subagent's worktree as before. `/ardd-converge` is the one case
  that may fold an already-in-progress tasks file, briefly placing
  in-progress state on `<default>` until the subagent's branch merges — an
  accepted, bounded exception.
- **Refuse, never resolve.** Same discipline as `worktree-align.sh`: a
  dirty/detached/diverged tree stops the run with a reason, never a
  hand-reconciled merge.

Scope: solo mode only. Collaborative mode already always moves work to a
branch and merges via PR, and never eager-merges locally, so it is unchanged.
