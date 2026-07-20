---
plan: plan-badge-workflow-branch-2026-07-20-abf3.md
generated: 2026-07-20
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Red test

- [ ] T001 Add a case to `scripts/test-install-version-badge.sh`: a
  fixture repo whose default branch is `master` (git init with
  `-b master` or rename), fake `example-owner/example-repo` remote,
  README present, `ARDD_VERSION_BADGE=1` install — assert the *written*
  `.github/workflows/ardd-badge.yml`'s `on.push.branches:` filter
  carries `master`, not `main` (and, cheaply alongside, that the
  printed snippet's endpoint URL carries `master` — already-passing
  context assertion). Run and confirm the new case FAILS against
  current install.sh (the workflow is copied with the template's
  hardcoded `[main]`). Commit red-first per the repo's documented
  convention (mirror the prior red-first commits' handling of the
  full-suite pre-commit hook, documenting in the commit body).

## Phase 2: Fix

- [ ] T002 In install.sh's badge section, substitute the target's real
  default branch — the same already-computed value the printed
  snippet's endpoint URL uses — into the workflow file's
  `on.push.branches:` filter at write time (template keeps
  `branches: [main]` as the placeholder form; when the branch is
  genuinely undeterminable, mirror the snippet's existing
  placeholder-plus-printed-replace-instruction fallback). Never-clobber
  semantics unchanged: an existing workflow file in the target is left
  untouched; the fill applies to the fresh write path only. Verify via
  `git diff` on install.sh; then the full
  `test-install-version-badge.sh` suite (including T001's case),
  `scripts/lint-templates-yaml.sh`, and `scripts/lint-docs.sh` all
  green. (Post-merge, coordinator-level, not a task: `/scenario-sweep
  S9` rerun — the user's hard gate before any stable dispatch.)
