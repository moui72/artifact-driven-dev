---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: eager-backgrounding
created: 2026-07-10
features: []
surfaced-defects: []
---

# Plan — eager background delegation + return-to-main

## Goal

Make `/ardd-implement` and `/ardd-converge` eager to offer background
delegation even when the run is already on a feature branch/worktree, folding
that branch into local `main` and returning the focused session to `main` so
the delegated subagent can see the run's state and the interactive session is
freed.

## Scope

**Included**
- Rewrite the solo-mode delegation gate in `skills/ardd-implement/SKILL.md`
  (step 3) and `skills/ardd-converge/SKILL.md` (step 2): offer background
  delegation **regardless of `on_default`**, not only when `on_default` is
  `true` (F001).
- A preparatory "fold current branch into local `main`, then checkout
  `main`" step, run when the user accepts backgrounding while on a
  non-default branch — deterministic, fast-forward-only, refusing (with a
  reason) on a dirty tree or non-FF divergence rather than resolving (F002).
- Keep inline as an explicit opt-out ("No, continue on the current branch").
- Keep the two skills in lockstep and update the CLAUDE.md / decision-record
  prose that explains *why* inline-on-a-branch was the old default.

**Not included**
- `/ardd-plan`'s branch gate — it deliberately never delegates (the draft
  plan file is the state `/ardd-tasks` must see); unchanged.
- Any change to `worktree-align.sh` or to the harness `Agent` worktree base
  behavior — this plan works *with* them (fold onto local `main`, which
  align already fast-forwards into the worktree).
- Collaborative mode's PR-based flow (it already always moves work to a
  branch and never eager-merges locally); see Open Question 3.

Addresses feedback F001 + F002
(`feedback-eager-backgrounding-return-to-5cde.md`).

## Technical Approach

**The obstacle that made inline the old default.** `Agent isolation:
"worktree"` creates its own branch from `origin/<default>` (fresh base), and
`worktree-align.sh` fast-forwards *local `main`* into it. There is no way to
branch a delegated worktree from the current feature branch. So a delegated
run can only see state that lives on (local) `main`. When you're mid-run on a
feature branch, the tasks file and its progress live on *that branch*, not
`main` — which is exactly why the current gate says "on a branch → continue
inline."

**Resolution — fold to `main`, then delegate.** To background from a feature
branch, first fold that branch into local `main` (fast-forward) and checkout
`main`; `worktree-align.sh` then carries the now-on-`main` state into the
subagent's worktree, and the focused session is left clean on `main` (F002).
This ties F001 and F002 into one operation: *return-to-main is the mechanism
that makes eager backgrounding possible on a branch.*

This is cleanest at **run start** — when the branch carries only planning
artifacts (an approved plan + a `ready` tasks file). That's "planned truth,"
which sits naturally on `main`; the in-flight truth (the `→in-progress` flip,
checkboxes, `→completed`, the register flip) then rides the subagent's
worktree exactly as today. See Open Question 1 for the mid-run case.

**Deterministic half is a script, judgment half is prose** — matching the
`worktree-align.sh` / `branch-info.sh` precedent. A new
`scripts/fold-to-main.sh` (installed to `.claude/skills/ardd-scripts/` via
`install.sh`) does the git-state work: fast-forward-only merge of the current
branch into the local default branch, checkout default, and **refuse** (print
`folded=false reason=dirty|diverged|...`) rather than resolve anything
non-trivial. The gate prose owns the judgment (offer, decide, on refusal stop
and surface). `git merge --ff-only` is the built-in idiom here (Principle
VIII); the script wraps it with the repo's standard refuse-don't-resolve
discipline.

## Phase Breakdown

**Phase 1 — `fold-to-main.sh` + regression test (deterministic, test-first).**
- New `scripts/fold-to-main.sh`: FF-only fold of the current branch into the
  local default branch (default resolved via the same fallback chain
  `branch-info.sh` uses), checkout default, emit `folded=true` or
  `folded=false reason=...`; refuse on dirty tree or non-FF divergence.
- New `scripts/test-fold-to-main.sh`: fixture test over throwaway repos
  (clean FF case → folded=true on default; dirty → refused; diverged →
  refused), asserted red-then-green per Principle V.
- Add a CI job; the pre-commit hook glob-discovers the new `test-*.sh`
  automatically. Source-side (governs this repo's script), but installed to
  targets like other ardd-scripts. (F002)

**Phase 2 — rewrite the delegation gates (depends on Phase 1).**
- `skills/ardd-implement/SKILL.md` step 3 and `skills/ardd-converge/SKILL.md`
  step 2: replace "`on_default` false → continue inline" with an eager offer
  presented regardless of `on_default`. On accept while on a non-default
  branch, run `fold-to-main.sh`; on `folded=true` proceed to delegate from
  `main`; on `folded=false` stop and surface the reason (never resolve).
  Preserve the inline opt-out and the in-flight-worktrees check. Keep both
  skills' gate prose identical (the deliberate residual duplication). (F001,
  F002)

**Phase 3 — doc/consistency sweep (depends on Phase 2).**
- Update `CLAUDE.md`'s worktree-native-state / delegation description and add
  a decision-record note (extend `0001` or add `0004`) capturing why
  fold-to-main replaces inline-on-a-branch, so the rationale isn't lost.
- Update `USAGE.md` if it describes the delegation flow.
- Verify `lint-docs.sh` stays green. (F001)

## Complexity Tracking

| Deviation | Justification |
|---|---|
| New `fold-to-main.sh` script | A git-state operation with refuse-don't-resolve semantics, directly matching the `worktree-align.sh`/`branch-info.sh` precedent for the deterministic half of a branch operation. `git merge --ff-only` is the checked built-in idiom (Principle VIII); the script only adds the standard refusal discipline and default-branch resolution. Prose keeps all judgment. |

## Open Questions

1. **Does folding onto `main` violate "default branch = merged truth"?**
   Folding at run start (a `ready` tasks file, no task checked) puts only
   "planned truth" on `main` and keeps in-flight truth on the worktree —
   arguably fine. Folding *mid-run* (some tasks completed inline, then
   background the rest) would put in-progress state + partial task commits on
   `main` until the subagent's branch merges. Decide: restrict the eager
   offer to run start (cleanest), or allow mid-run folds and accept a brief
   in-progress-on-`main` window? **Recommendation:** offer eagerly at run
   start; for mid-run, still allow but note the transient in-progress state
   on `main`.
2. **Auto-delete the folded branch?** After an FF fold it is identical to
   `main` (a stale merged branch). Delete it in `fold-to-main.sh`, or leave
   it for the user?
3. **Scope — solo only?** Collaborative mode already always moves work to a
   branch and merges via PR, never eager-locally. Does "eager background +
   return to `main`" apply there, or is this a solo-mode change with
   collaborative left as-is? **Recommendation:** solo-mode only; state that
   explicitly in the gate.
4. **Script vs. prose for the fold.** Confirm a dedicated `fold-to-main.sh`
   is warranted over two inline git commands in the gate. **Recommendation:**
   script, per the refusal semantics and the `worktree-align` precedent.

## Production Annotation Summary

None — no production shortcuts introduced.
