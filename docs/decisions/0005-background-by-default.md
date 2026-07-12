# 0005 — Background by default

_2026-07-12. Extends 0004: the solo flow stops authoring the branch
`fold-to-main.sh` existed to undo, and two constitution workflow knobs
(`delegation`, `merge_policy`) remove the two always-yes prompts from
`/ardd-implement`/`/ardd-converge`._

## What changed relative to 0004

0004 made backgrounding offered eagerly regardless of `on_default`, and
built `fold-to-main.sh` to make that possible from a feature branch: the
common case at the time was that every run *was* on a feature branch,
because `/ardd-plan`'s branch gate created one at the top of every chain.
So the common path was: plan creates a branch → implement folds that branch
straight back into local `<default>` → delegate. The fold existed almost
entirely to undo a branch whose only fate was to be fast-forward-folded
back — ceremony, not isolation.

This record removes the ceremony at its source and the prompts that
remained:

1. **Solo `/ardd-plan` no longer has a branch gate.** The run proceeds on
   the current branch (normally the default branch) and commits plan+tasks
   there. A `ready` tasks file on the default branch is planned truth,
   already accepted there — the same reasoning 0004 used to justify the
   fold's effect, now reached without the round-trip. Collaborative mode
   keeps the gate unchanged (nothing may be committed to the local default
   branch in that mode).
2. **`delegation: eager | ask | inline`** (constitution frontmatter,
   absent = `ask`): `eager` delegates to a background worktree subagent
   without prompting, `ask` is the 0004-era offer, `inline` never offers.
3. **`merge_policy: auto | ask`** (absent = `ask`): `auto` merges the
   subagent-reported branch into the local default branch on completion
   when the merge fast-forwards or completes without conflicts; on any
   conflict it aborts, surfaces, and falls back to asking — never
   auto-resolving. Consulted in solo mode only.

With `delegation: eager` + `merge_policy: auto`, the solo happy path is
fully unattended between the plan-approval checkpoint and completion:
plan+tasks land on `<default>`, the subagent worktree branches from it,
and the merge lands code and state together.

## Why fold-to-main demotes to a recovery path rather than being deleted

Principle VII (subtract before adding) was checked deliberately:
`fold-to-main.sh` still serves runs that find themselves on a feature
branch — a run resumed from before this change, a branch made by hand, a
collaborative-style branch in a solo project. The delegation gate still
runs it in exactly that case; only the *framing* changed (recovery path,
no longer the common-path step). The script, its tests, and its
refuse-don't-resolve discipline are untouched. Deleting it would strand
every on-a-branch run with no deterministic way to background.

## Why absent = `ask` for both knobs

Absent-means-today's-behavior is the same compatibility rule
`workflow_mode` (absent = `solo`) and `next_step_prompt` (absent =
`false`) established: existing installs see zero behavior change until
they opt in, so no migration script is needed and `/ardd-update`'s
backfill-ask is a courtesy, not a requirement. A default of `eager`/`auto`
would have silently changed every installed project's consent model on
upgrade.

## Why `merge_policy` is solo-only

Collaborative mode never merges locally — its merge is the PR, its
in-flight channel the pushed draft PR, and its local default branch is
never committed to. An auto-local-merge knob would contradict all three,
so the knob is simply not consulted there (and `/ardd-bootstrap` doesn't
ask it in collaborative mode — asking would imply an effect it doesn't
have).

## Consequences worth stating

- The plan's `branch:` frontmatter now names a branch that may never be
  created (the branch inline implementation *would* use).
  `completion-flip-check.sh` treats a nonexistent ref as not-merged and
  stays silent — verified with a regression case in
  `scripts/test-completion-flip-check.sh`.
- `merge_policy: auto` never auto-resolves conflicts — including the
  disposable single-writer report files. Their take-either-side rule stays
  interactive prose until the `.gitattributes` merge-driver feature
  (`disposable-report-merge-driver`) lands.
