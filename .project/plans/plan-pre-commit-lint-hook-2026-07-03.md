---
status: approved
branch: pre-commit-lint-hook
created: 2026-07-03
features: [pre-commit-lint-hook]
---

# Plan: Pre-commit lint enforcement

## Goal

Implement the constitution's already-stated Pre-commit Enforcement standard:
a local git hook blocks a commit unless `scripts/lint-docs.sh`,
`scripts/test-lint-project.sh`, `scripts/test-branch-info.sh`, and
`scripts/test-hook-lint-on-write.sh` all pass.

## Scope

**In scope:** the hook script itself, its own regression test, CI wiring for
that test, and documenting the one-time per-clone opt-in step.

**Not in scope:** no artifact changes. This feature implements an existing
constitution principle rather than introducing a new one — the
artifact-affected table (constitution/datamodel/infrastructure/adapters/
api/ui) was checked in `/ardd-plan` step 3b and none apply. `constitution.md`
already states the standard this plan fulfills.

## Technical Approach

Git provides `core.hooksPath` as the built-in, idiomatic way to point at a
tracked hooks directory instead of the untracked `.git/hooks/` (Principle
VIII: check tool idioms before building a custom mechanism — this avoids a
symlink-into-`.git/hooks` script of our own). A tracked `hooks/pre-commit`
POSIX-sh script runs the four check scripts in sequence, aborting on the
first non-zero exit with a message naming which one failed — mirroring how
CI already runs them unconditionally on every push, with no path-filtering
(Principle VI: no speculative optimization without evidence it's needed).

Git cannot auto-enable a tracked hooks directory on clone (a deliberate
security property of git, not a gap in this design) — each contributor
opts in once with `git config core.hooksPath hooks`. That's documented,
not engineered around.

The hook script's own aggregation/short-circuit logic gets a dedicated
regression test (Principle V — deterministic checks are test-first) using
stub pass/fail scripts rather than a full sandboxed repo clone, since the
four underlying scripts already have their own regression tests; this test
only needs to prove the hook stops at the first failure and names it.

## Phase Breakdown

### Phase 1 — Hook script and its test
- [artifacts: none] Add `hooks/pre-commit`: runs the four check scripts in
  order, aborts with a clear per-script failure message on first non-zero
  exit, succeeds silently otherwise.
- [artifacts: none] Add `scripts/test-hooks-pre-commit.sh`: verifies the
  hook passes when all four scripts pass, and that it stops at (and names)
  the first failing script, using temporary stub scripts standing in for
  the real four.
- [artifacts: none] [parallel] Wire the new test into
  `.github/workflows/lint.yml` as its own job.

This phase is a testable, demonstrable increment on its own: the hook
script exists, is proven correct in isolation, and CI covers it — even
before anyone opts in locally.

### Phase 2 — Document the opt-in step
- [artifacts: none] Add the one-time `git config core.hooksPath hooks`
  step to `CLAUDE.md`'s Commands section, and a short note in `README.md`
  (this repo's own contributor-facing setup, not `install.sh`'s target-
  project install — Principle IV: keep the two install targets separate).

## Complexity Tracking

None. `core.hooksPath` is git's own idiomatic mechanism; no deviation from
the simplicity principle to justify.

## Open Questions

None.

## Production Annotation Summary

None. ADD's constitution did not adopt the Production Annotations
principle for its own development (declined at bootstrap).
