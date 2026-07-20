---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: badge-workflow-branch
created: 2026-07-20
features: []
surfaced-defects: []
---

# Plan: Badge workflow — real default branch in the trigger filter

## Goal

Make install.sh fill the target's real default branch into the written
badge workflow's `on.push.branches:` filter, so the badge sync fires on
repos whose default branch isn't `main`.

## Scope

**In:** the install-time substitution (S9 run `7b1a` finding, feedback
`8110` F001), a red-first `test-install-version-badge.sh` case with a
`master`-default fixture, and the final `/scenario-sweep S9` rerun as
the stable-dispatch gate (coordinator-level, post-merge).

**Out:** any other workflow-template change; multi-branch filters; the
two taste-deferred `7b1a` findings.

## Technical Approach

install.sh's badge section already computes the target's default branch
for the snippet's endpoint URL — reuse that exact value. The workflow
file is written by install.sh, so apply the same coordinate-fill
mechanism the snippet uses: template keeps `branches: [main]` as the
placeholder form; at write time, substitute the real branch (falling
back to leaving `main` + printing the existing replace-instruction shape
only if the branch is genuinely undeterminable, mirroring the snippet's
placeholder fallback). Never-clobber semantics unchanged — an existing
workflow file in the target is left untouched, as today; the fill
applies to the fresh write path.

Red-first: the new test case (fixture repo whose default branch is
`master`) asserts the *written* workflow's `branches:` line carries
`master`, failing against current install.sh before the fix.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

**Phase 1 — Red test.**
- `test-install-version-badge.sh`: master-default fixture case
  asserting the written `.github/workflows/ardd-badge.yml` `branches:`
  filter carries the real branch; confirmed red.

**Phase 2 — Fix (after Phase 1).**
- install.sh badge section: substitute the already-computed default
  branch into the workflow's `branches:` filter on write; suite +
  lint-templates-yaml + lint-docs green.

## Open Questions

- None. (Post-merge, coordinator-level: `/scenario-sweep S9` rerun —
  the user's hard gate before any stable dispatch.)
