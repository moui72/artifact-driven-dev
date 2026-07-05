---
status: approved
branch: delegation-smoketest
created: 2026-07-05
features: []
---

# Plan: delegation smoke test

## Goal

Throwaway plan to exercise a real delegated `/ardd-implement` run (Agent tool,
`isolation: "worktree"`) and observe what actually happens to the tasks
file's `worktree_branch:` frontmatter across a merge. Not a real feature —
delete after use.

## Scope

One trivial task: create a scratch file. Nothing else.

## Technical Approach

N/A — this plan exists only to drive one delegated task through
`/ardd-implement`.

## Phase Breakdown

### Phase 1
- T001: create `.project/scratch/delegation-smoketest.txt` containing the
  text `delegated ok`.

## Complexity Tracking

None.

## Open Questions

None.

## Production Annotation Summary

None.
