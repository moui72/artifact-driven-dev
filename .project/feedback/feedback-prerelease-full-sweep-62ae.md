---
status: open      # open -> planned
created: 2026-07-17
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Bugs
- [ ] F001 `install.sh` only *mentions* gitignoring `.project/.lock`
  (`project-lock.sh`'s transient concurrency marker) in its printed
  ACTION NEEDED text — it never adds the pattern to `.gitignore` itself,
  and never proactively checks whether `.lock` already exists. A user
  who follows the printed instructions literally still commits the
  stray lock file the first time any lock-touching skill runs (e.g.
  `/ardd-backlog`'s `project-lock.sh touch` call), before they think to
  add the pattern by hand. Especially sharp in `workflow_mode:
  collaborative`, where every commit is more visible (goes through a
  PR). Fix direction: `install.sh` should add `.project/.lock` to the
  generated/suggested `.gitignore` block unconditionally, or detect a
  pre-existing `.project/.lock` and gitignore it immediately rather than
  only printing a conditional reminder. Found by `/prerelease-sweep
  full` (S4-F001, run 2026-07-17-fab5).

## UX
- [ ] F002 `/ardd-init`'s existing-codebase path (step 7, feature
  register extraction) calls git-log `feat:` commits and PR merge
  titles the "most reliable" signal for extracting shipped features,
  but never instructs verifying the commit's actual diff before trusting
  its message. On a real repo with misleadingly-titled commits (e.g. a
  `feat: add GitHub OAuth authentication with session management and
  user registration` commit whose diff only touches `.env.example`,
  +8/-6 lines, zero code), a less careful run would extract a false
  "implemented" register entry for a capability that was never actually
  built. Fix direction: step 7's git-log guidance should note that a
  commit's message is not proof of its diff, and instruct verifying the
  diff (or at minimum cross-referencing against the step-2 code survey)
  before treating a `feat:` commit as evidence a capability is actually
  implemented and shipped, not just proposed or documented. Found by
  `/prerelease-sweep full` (S2-F001, run 2026-07-17-fab5).
