---
status: planned
created: 2026-07-15
plan: plan-v1-0-0-pre-cut-testing-finding-2026-07-15-b89e.md
---

# Feedback

Source: 7 parallel dry-run test scenarios of the ArDD skill pack ahead of
a v1.0.0 cut (fresh new.sh quickstart, brownfield reverse-engineer init,
consumer upgrade + `--reconfigure`, collaborative-mode lifecycle, solo
inline core loop, delegated-worktree execution, peripheral-skills sweep).
An account-wide API spend-limit outage killed 3 of the 7 subagents
mid-run and wiped their session-scoped scratchpad before their reports
could be recovered, so only 4 scenarios (new.sh/greenfield init,
brownfield reverse-engineer, consumer upgrade, delegated worktree)
produced full findings; the other 3 (collaborative mode, solo inline core
loop, peripheral-skills sweep) reportedly completed execution cleanly but
left no captured detail and should be considered untested for UX
purposes.

## Bugs

- [x] F001 `worktree-align.sh` has no positive check that it's actually
  running in a distinct git worktree. In a nested-delegation test (a
  worktree subagent itself spawning a further `isolation: "worktree"`
  sub-subagent), the "worktree" ended up coinciding with the primary
  checkout — commits landed directly on `main`, `core.bare` never
  flipped, `git worktree list` never showed a second entry, and
  `worktree-reap.sh` had nothing to reap. `worktree-align.sh` still
  printed `aligned=true` throughout, masking the collapse rather than
  catching it. Root cause is ambiguous (possibly a harness limitation on
  nested worktree isolation specifically, not necessarily an ArDD script
  bug) but the fix is cheap either way: add a check that the worktree
  path actually differs from the primary checkout's (e.g. compare against
  `git worktree list` or `git rev-parse --show-toplevel` from both sides)
  and fail loud (`aligned=false reason=not-a-worktree`) instead of
  silently succeeding.
- [x] F002 `/ardd-init`'s existing-codebase reverse-engineering survey is
  under-specified for completeness when entities aren't uniformly
  structured. On a real ~101-file app, it missed an entire `Practice`
  entity in the generated `datamodel.md` because — unlike its sibling
  entities — it had no colocated Zod schema to key off of; this was only
  caught because the test brief explicitly demanded a spot-check against
  real source files. A real user without that prompt could end up
  planning against a confidently-wrong `datamodel.md` with no signal
  anything was missed.

## UX

- [x] F003 `install.sh`'s `.gitignore` suggestion for
  `.claude/skills/ardd-*/` is print-only advice, easy to miss in a long
  install transcript — inconsistent with the neighboring
  `.worktreeinclude` handling, which self-applies (creates/appends the
  pattern) instead of just telling the user to do it by hand. Worth
  considering whether the gitignore suggestion should also self-apply (or
  offer to), same as `.worktreeinclude` already does, rather than being
  the one remaining "please do this yourself" step in an otherwise
  automated install.
- [x] F004 `/ardd-init`'s constitution-suggestion catalog offered ~11
  principles (7 "Always" entries plus several signal-matched ones like
  Deterministic Gates and Bootstrap/Entry Files) for a genuinely trivial
  one-file "Hello, name!" CLI test project. Functionally fine — nothing
  wrong was suggested — but it feels over-built for the project's actual
  size, because the filter logic keys off detected stack signals rather
  than any notion of project scale. Worth considering whether a
  detected-as-trivial project (very few files, no dependencies) should
  see a shorter default suggestion list.
- [x] F005 Running `/ardd-defects` immediately after a brownfield
  `/ardd-init` reverse-engineering pass caught genuine drift in an
  artifact `/ardd-init` had *just* written in the same session (a
  `GET /patients` endpoint shape claim, marked `[OPEN: ...]` in the
  artifact but actually just factually wrong, not merely underspecified).
  This is a strong signal that `/ardd-defects` earns its keep right after
  a reverse-engineering init specifically — worth having `/ardd-init`'s
  own SKILL.md (or its final report) explicitly suggest running
  `/ardd-defects` as a same-session follow-up on the existing-codebase
  path, rather than leaving it to be discovered as a periodic-only tool.
- [x] F006 When stress-testing the brand-new `/ardd-update --reconfigure`
  flag against a real consumer clone on the day it was published, the
  tester could not straightforwardly reach the new code through
  `/ardd-update`'s documented real resolution path (fetching the latest
  tag from the consumer's recorded `Source-Path`/real GitHub remote) and
  had to fall back to reinstalling from a local dev checkout instead. It's
  unclear whether this is expected propagation lag, a caching quirk in
  `source-resolve.sh`, or something else — but there's currently no easy
  way for a user in this situation to tell *why* `/ardd-update` isn't
  seeing content that was just published. Worth considering whether
  `/ardd-update`'s standing report (or `source-resolve.sh`'s output)
  could surface more diagnostic detail when a resolution doesn't land on
  the expected tag.
