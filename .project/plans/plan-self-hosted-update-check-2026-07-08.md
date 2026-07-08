---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: self-hosted-update-check
created: 2026-07-08
features: []
surfaced-defects: []
---

# Plan: distinct self-hosted outcome for ardd-update-check

## Goal

Stop the perpetual "behind by the version-bump commit" reading when a
repo is both ARDD's source and its own consumer.

## Scope

**In:** feedback-self-hosted-update-check-7531.md F001, exactly as
specified: a `self-hosted commit=<x>` outcome, silent in analyze.

**Out:** anything else about the check (network, N-commit deltas —
"behind by N" was considered and rejected in the feedback item).

## Technical Approach

Detect self-hosting by comparing resolved git toplevels — `git -C
<source> rev-parse --show-toplevel` vs `git -C <target> rev-parse
--show-toplevel` — never string paths (symlinks/relative paths would
fool a string compare). When equal, print `self-hosted commit=<x>`
before any tip comparison. Test-first per Principle V; analyze's
outcome table gains one silent case.

## Phase Breakdown

### Phase 1

- T-A `ardd-update-check.sh`: add the self-hosted branch (toplevel
  comparison; outcome line `self-hosted commit=<installed>`).
  Test-first: new fixture case in test-ardd-update-check.sh — a target
  whose recorded Source-Path is the target repo itself (and a symlink
  variant to prove the toplevel comparison) — red, then green; all
  existing outcome cases stay green.
- T-B `skills/ardd-analyze/SKILL.md`: add `self-hosted` to the silent
  outcomes list (alongside `no-version-file`, `no-source-path`,
  `up-to-date`). Doc-only; lint-docs green.
- T-C Verify live: run the installed check against this repo — it
  should print `self-hosted commit=<x>` instead of `behind` (requires
  reinstall to refresh the installed copy first; the source copy
  suffices for the pre-merge check).

## Complexity Tracking

| Deviation | Justification (Principle VI) |
|---|---|
| (none) | One guard clause, one fixture case, one prose line |

## Open Questions

None.

## Production Annotation Summary

- None.
