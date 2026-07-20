---
plan: plan-s1-badge-followups-2026-07-20-9667.md
generated: 2026-07-20
status: ready   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Test-first

- [ ] T001 Extend `scripts/test-install-version-badge.sh` with red-first
  cases (run the script and confirm both new cases fail before T002):
  (a) a target fixture with NO README.md, env unset → install.sh output
  contains a one-line `ARDD_VERSION_BADGE=1` opt-in pointer (a pointer,
  not a snippet — assert the two-badge snippet is NOT printed); (b) a
  README whose `ardd-badge-version-start`/`-end` markers contain a
  misdirected `img.shields.io/github/v/release/...artifact-driven-dev`
  badge, run with `ARDD_VERSION_BADGE=1` → the advisory text names the
  replace-the-badge-inside-the-markers remedy (grep for wording along
  the lines of "replace the badge inside the markers") and does NOT
  present a bare `ARDD_VERSION_BADGE=1` re-run as the sole remedy.
  POSIX sh, same fixture/harness style as the file's existing cases;
  keep all existing cases green except the two new red ones.

## Phase 2: Implement

- [ ] T002 Implement both output-text fixes in `install.sh`'s badge
  section, turning T001 green: (1) F001 — print the one-line opt-in
  pointer when the target has no README.md (currently the mention lives
  only inside the `[ -f "$TARGET/README.md" ]`-gated static-suggestion
  branch), e.g. "once this project has a README, re-run install with
  ARDD_VERSION_BADGE=1 to add a dynamic version badge"; never print
  the snippet itself in the no-README case. (2) F002 — rewrite the
  misdirected-badge advisory's remedy text to be self-sufficient:
  state that the badge inside the ardd-badge-version markers should be
  replaced with the shields.io endpoint form pointing at the project's
  own `.github/badges/ardd-version.json`, instead of instructing a
  re-run the reprint guard would silence. Do not change the reprint
  guard, coordinate fill, or any non-advisory output; README-present
  paths stay byte-stable except where T001 asserts the new text. Full
  `./scripts/test-install-version-badge.sh` green before completion.
