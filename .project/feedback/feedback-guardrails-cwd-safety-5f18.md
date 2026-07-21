---
status: planned      # open -> planned
created: 2026-07-21
plan: plan-multi-harness-2026-07-21-76ba.md
---

# Feedback

## Bugs
- [x] F001 Real isolation incident (2026-07-21): the primary ArDD
  checkout's git `origin` remote disappeared during the day's S9
  scenario-sweep runs — discovered when `git rev-list
  origin/main..main` failed after run `2026-07-21-b788`; restored by
  hand from the known URL. Likely culprit (unproven): a scenario
  subagent executing `tests/scenarios/GUARDRAILS.md` rule 2's cleanup
  (`git remote remove origin` after cloning a real repo from its local
  path) with its cwd outside `$SCRATCH`, mutating the real checkout
  instead of a scratch clone; the concurrent codex-port session is the
  alternative candidate. Root gap regardless of attribution: the
  guardrails prescribe git state mutations but carry no
  cwd-verification requirement, so one mis-executed step can damage a
  real checkout. Harden GUARDRAILS.md: before ANY guardrails-prescribed
  git mutation (`git remote remove origin`, `git init`, adding the fake
  origin), the subagent must verify its cwd is inside `$SCRATCH`
  (e.g. `case "$PWD" in "$SCRATCH"/*) ;; *) stop and report ;; esac`),
  and prefer structural `-C`/absolute-path forms
  (`git -C "$SCRATCH/..." remote remove origin`) over cwd-dependent
  invocations so safety doesn't rely on the agent remembering. Also
  state explicitly: any damage to a path outside `$SCRATCH` must be
  reported immediately as an incident, never silently fixed.
