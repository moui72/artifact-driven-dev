---
status: open      # open -> planned
created: 2026-07-11
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Bugs
- [ ] F001 During the 2026-07-11 npx-scrap implementation, a T005 commit
  failed with a ref-lock error (`cannot lock ref 'HEAD': is at <main> but
  expected <branch>`). Root cause: the primary checkout was on the
  `scrap-npx-channel` feature branch, and a **consumer's `ardd-update`
  flow** (some other local project whose `.project/ardd-version.md` records
  `Source-Path: /Users/tylerpeckenpaugh/dev/artifact-driven-dev`) read this
  source checkout, found it off `main`, and to obtain a clean source
  **stashed the branch WIP and checked out `main`** mid-commit
  (stash message: `ardd-update: park scrap-npx-channel WIP while switching to
  main`). Work was recovered from the stash, but this is a real collision
  class, not a fluke.

## Reconsidered
- [ ] F002 The primary/default worktree of THIS repo must **never leave
  `main`**. [artifacts: constitution] This repo is the local *source* other
  consumer projects install and update from — `install.sh`/`/ardd-update`
  read this checkout (via a recorded `Source-Path` or `~/.ardd/source`) and
  install from whatever branch is checked out. A checked-out feature branch
  therefore serves *unmerged, possibly-broken* skills to every consumer that
  updates while it is checked out, and (per F001) provokes consumer update
  flows into forcibly re-checking-out `main` underneath in-flight work. The
  reversed decision: our own `/ardd-plan` and `/ardd-implement` branch-gate,
  in this repo, used the inline `git checkout -b` path that moves the primary
  checkout's HEAD off `main` (that is how `consolidate-setup-skills` and
  `scrap-npx-channel` were worked). That path must not be used here.
- [ ] F003 All feature work in this repo happens in a **separate git
  worktree** — which branches without moving the primary checkout's HEAD —
  never an inline branch checkout in the primary. This is what the skills'
  `isolation: "worktree"` delegation already does; the discipline is to
  *always* take it (or create a worktree by hand and work there), and the
  primary checkout stays parked on `main` as the stable source consumers see.
  Encode the invariant as a constitution standing decision and reflect it in
  `CLAUDE.md`'s workflow guidance. [artifacts: constitution]
- [ ] F004 Possible generalization (decide during planning, do not assume):
  this "primary checkout is a live source others read, so it must stay on the
  default branch" property could be a reusable workflow mode/field for any
  target project that is itself an install source — e.g. a constitution
  frontmatter flag that makes the branch-gate *require* a worktree rather than
  offering inline `checkout -b`. Whether to build that generic feature, or
  keep the rule as a this-repo-only standing decision, is a plan-scope
  question. An enforcement angle also exists (a check/hook that refuses if the
  primary worktree is off `main`) — weigh it against Principle VI.
