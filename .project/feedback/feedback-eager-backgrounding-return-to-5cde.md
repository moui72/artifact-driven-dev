---
status: planned      # open -> planned
created: 2026-07-10
plan: plan-eager-backgrounding-2026-07-10.md
---

# Feedback

## Reconsidered
- [x] F001 The solo-mode delegation gate defaults to inline whenever
  `on_default` is false — i.e. whenever the run is already on a feature
  branch or worktree, it skips the "delegate to a background subagent?"
  offer entirely (`skills/ardd-implement/SKILL.md` step 3: "If `on_default`
  is `false`, continue inline at step 4 — the run is already isolated on a
  branch/worktree"; `skills/ardd-converge` mirrors it). Reconsidered: this
  under-uses backgrounding. Being on a branch is not a reason to run in the
  foreground — the system should be *eager* to background long-running work
  and should still offer a background agent in that common case, not treat
  already-on-a-branch as "isolation achieved, run inline." The prior premise
  (a branch already isolates state, so inline is fine) conflates state
  isolation with execution locus: the user wants the focused session freed
  up even when state isolation is already handled.

## UX
- [x] F002 When the user opts to background/delegate from a focused session
  that is sitting on a feature branch or worktree, the coordinator (focused)
  session should return to the default branch (`main`) — so the interactive
  session is left clean and free while the delegated subagent works in its
  own worktree. Today, on the inline path the focused session stays parked on
  the feature branch; pairing the more-eager background offer (F001) with an
  automatic "bring the focused session back to `main`" is the behavior the
  user wants in these situations.
