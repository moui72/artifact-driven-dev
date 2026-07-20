---
plan: plan-dynamic-badge-discoverability-2026-07-19-23cf.md
generated: 2026-07-19
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: install.sh badge mechanics (test-first)

- [ ] T001 Extend `scripts/test-install-version-badge.sh` with red-first
  cases for the five install.sh badge fixes (run it, confirm the new
  cases fail before T002): (a) a target fixture with a GitHub `origin`
  remote (`https://github.com/acme/widget.git`) run with
  `ARDD_VERSION_BADGE=1` → the printed two-badge snippet contains
  `acme/widget` and the fixture's current branch, and no literal
  `OWNER/REPO/BRANCH`; (b) a target with no remote → placeholders remain
  AND the output prints an explicit "replace OWNER/REPO/BRANCH with your
  repo's coordinates" instruction; (c) a README already containing
  `<!-- ardd-badge-version-start -->` → the snippet is NOT reprinted
  (supporting-file writes still checked); (d) a README containing a
  latest-release badge (`img.shields.io/github/v/release/` +
  `artifact-driven-dev`) → an advisory warning is printed, in BOTH the
  env-var-unset default path and the `ARDD_VERSION_BADGE=1` path;
  (e) snippet output includes a private-repo caveat line; (f) the
  default (unset) path's static-badge suggestion mentions
  `ARDD_VERSION_BADGE=1` as the dynamic upgrade. Also cover: SSH-form
  remote `git@github.com:acme/widget.git` parses to `acme/widget`.
  POSIX sh, fixture repos in a temp dir, same harness style as the
  file's existing cases.

- [ ] T002 Implement the five fixes in `install.sh`'s badge section
  (currently lines ~427-486), turning T001 green: (1) derive
  `owner/repo` from `git -C "$TARGET" remote get-url origin` (handle
  `https://github.com/o/r(.git)` and `git@github.com:o/r(.git)` shapes)
  and branch from `git -C "$TARGET" symbolic-ref --short HEAD`
  (fallback `main`), then `sed`-substitute `OWNER/REPO/BRANCH` in the
  printed snippet — on any parse failure keep placeholders and print
  the replace-these instruction; (2) guard the `ARDD_VERSION_BADGE=1`
  snippet print with `grep -q 'ardd-badge-version-start'
  "$TARGET/README.md"` (mirror of the static branch's existing guard);
  (3) print a one-line advisory when the README matches
  `img.shields.io/github/v/release/.*artifact-driven-dev` (it tracks
  ArDD's latest release, not the installed version — point at the
  endpoint-badge snippet), firing in both the default and opted-in
  paths; (4) print the private-repo caveat line with the snippet
  (shields.io fetches raw.githubusercontent.com unauthenticated, so the
  endpoint badge renders only for public repos); (5) in the default
  (unset) path's static-badge suggestion, add one line noting the
  dynamic version-badge option via `ARDD_VERSION_BADGE=1
  ./install.sh …`. POSIX sh only; default path stays otherwise
  byte-compatible.

## Phase 2: skill prose

- [ ] T003 Edit `skills/ardd-update/SKILL.md`: at the step where
  install.sh output/suggestions are relayed to the user (step 4's
  suggestion-relay point — confirm against the file's current
  structure), add an offer: when the target's README lacks
  `ardd-badge-version-start` markers (and a README exists), ask the
  user whether to adopt the dynamic ArDD version badge; on yes, re-run
  the same `install.sh` invocation with `ARDD_VERSION_BADGE=1` set (env
  var is the mechanism, this prose is the interface — plan's F006
  resolution) and relay the printed snippet + caveats. Never edit the
  target README; never offer when markers are already present. Keep the
  offer out of delegated/scripted contexts per the skill's existing
  prompt conventions.

## Phase 3: docs and templates

- [ ] T004 Documentation pass: (a) update
  `templates/badge.md`'s comment block and
  `templates/ardd-badge-workflow.yml`'s header comment to state the
  public-repo-only limitation; (b) add the dynamic badge to `USAGE.md`
  (a "How do I…?" row routing to `/ardd-update` / `ARDD_VERSION_BADGE`);
  (c) document the offer in `docs/reference/skills/ardd-update.md`'s
  hand-written body. Run `./scripts/lint-docs.sh` and the full badge
  test (`./scripts/test-install-version-badge.sh`) green before
  completion.
