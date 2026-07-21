---
status: open      # open -> planned
created: 2026-07-21
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Bugs
- [ ] F001 Second harness worktree side effect (observed 2026-07-21,
  after the delegated multi-harness run): alongside the known
  `core.bare=true` flip, `Agent` worktree creation left the primary
  checkout's repo config with `core.hooksPath=/dev/null`, silently
  disabling the pre-commit hook — the next two primary-checkout commits
  (a merge and a `.project/`-only status commit) ran no checks at all,
  detected only because the commit finished in 0.03s. Fix direction:
  `/ardd-implement`'s post-delegation coordinator step (the
  `core.bare` check in `skills/ardd-implement/SKILL.md` step 3) should
  also check `git config --get core.hooksPath` and restore the
  repo-standard value (`hooks` for this repo; for targets, unset or the
  pre-run value) when it reads `/dev/null`, reporting the restoration
  like the `core.bare` one. Mention it wherever the `core.bare` side
  effect is documented (CLAUDE.md architecture note, decision record
  0001's side-effect list) so the pair travels together.
