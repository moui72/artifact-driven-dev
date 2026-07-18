---
plan: plan-dynamic-version-badge-sync-2026-07-18-35aa.md
generated: 2026-07-18
status: in-progress
---

# Tasks

## Phase 1: Workflow + seed JSON templates
- [x] T001 Create `templates/ardd-badge-workflow.yml` — a GitHub Actions
  workflow: triggers on push, `paths: ['.project/ardd-version.md']`;
  parses `Source-Ref:` (preferred) falling back to a short
  `Source-Commit:` prefix when no tag is recorded, and `Channel:`, from
  `.project/ardd-version.md` using the same `sed`-based read style
  `install.sh`/`ardd-update-check.sh`/`source-resolve.sh` already use for
  that file; regenerates `.github/badges/ardd-version.json` in shields.io
  endpoint-badge JSON schema (`schemaVersion`, `label`, `message`,
  optionally `color`); commits the change only if the JSON actually
  differs from what's on disk (never an empty commit).
- [x] T002 Create `templates/ardd-badge.json` — the seed JSON template
  with a placeholder shape (schemaVersion/label/message fields)
  `install.sh` fills in with the current install's actual
  `Source-Ref`/`Source-Commit` and `Channel` at write time (per T004).
- [x] T003 [parallel] Update `templates/badge.md` — add a two-badge
  variant (static "built with ArDD" badge + dynamic version badge
  reading `.github/badges/ardd-version.json` via a shields.io
  `dynamic/json` badge URL) as an alternate snippet alongside the
  existing single static badge, clearly labeled as the version that
  accompanies the `ARDD_VERSION_BADGE=1` opt-in.

## Phase 2: `install.sh` wiring
- [x] T004 Add `ARDD_VERSION_BADGE` env-var validation to `install.sh`
  (valid values: unset, `0`, `1` — any other value is a refusal with a
  clear error message, mirroring the existing `ARDD_CHANNEL` validation
  block near the top of the script). Extend the existing "built with
  ArDD badge" suggestion section: when `ARDD_VERSION_BADGE=1` and
  `.github/workflows/ardd-badge.yml` / `.github/badges/ardd-version.json`
  don't already exist in the target, write both files (workflow from
  T001's template verbatim; JSON from T002's template with this run's
  actual `Source-Ref`/`Source-Commit`/`Channel` substituted in), then
  print the two-badge snippet (T003) instead of the single static one.
  When `ARDD_VERSION_BADGE` is unset (the default), behavior must be
  byte-for-byte unchanged from before this task.
- [x] T005 Manually verify: an `ARDD_VERSION_BADGE=1 ./install.sh
  <fixture-target>` run writes both new files with content matching that
  fixture's actual recorded version; a plain `./install.sh
  <fixture-target>` (unset) writes neither file and prints the unchanged
  static-only snippet. Record both outcomes as this task's completion
  note.

## Phase 3: Regression test
- [ ] T006 Create `scripts/test-install-version-badge.sh` — a new
  narrow fixture-based regression test mirroring this repo's existing
  per-concern install test pattern (`test-install-gitattributes.sh`,
  `test-install-manifest-complete.sh`, `test-install-prune.sh`,
  `test-install-worktreeinclude.sh`). Assert: (a) an
  `ARDD_VERSION_BADGE=1` install case creates both new files with the
  fixture's actual version baked into the JSON; (b) a re-install case
  confirms a hand-edited `ardd-version.json`/`ardd-badge.yml` is left
  untouched (idempotent, never clobbered); (c) the default (unset)
  path's existing badge-suggestion behavior is unchanged byte-for-byte
  from before this plan. Add its CI job to `.github/workflows/lint.yml`
  in this same commit — this repo's stated rule that a new deterministic
  check ships with both its regression test and CI wiring together in
  one commit, the exact convention `feedback-ci-migration-tests-unwired-37ee.md`
  caught a violation of.
