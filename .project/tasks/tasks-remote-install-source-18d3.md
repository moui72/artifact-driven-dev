---
plan: plan-remote-install-source-2026-07-12.md
generated: 2026-07-12
status: in-progress
---

# Tasks

## Phase 1: Release mechanics (source-side)

- [x] T001 [artifacts: constitution] Create `scripts/release.sh <vX.Y.Z>`
  (POSIX sh): refuse unless the working tree is clean, HEAD is on the
  default branch (use `branch-info.sh`), the version argument matches
  `^v[0-9]+\.[0-9]+\.[0-9]+$`, the tag doesn't already exist, and the full
  pre-commit suite passes; then create an annotated tag, push it, and run
  `gh release create <tag> --generate-notes`. Test-first: write
  `scripts/test-release.sh` exercising every refusal against throwaway
  repos (dirty tree, off-default, bad format, duplicate tag) with the
  tag/push/gh block stubbed or gated (e.g. `--dry-run` flag that stops
  after validation — the network steps stay thin and untested by design);
  confirm refusals fail before implementation completes them. Add the CI
  job to `.github/workflows/lint.yml` in the same commit. Ask the user
  whether tags should be SSH-signed (plan Open Question 4) before
  finalizing the tag command.

## Phase 2: Resolution + update-check (target-side)

- [x] T002 [artifacts: constitution] Create `scripts/source-resolve.sh`
  (POSIX sh, installed to `ardd-scripts` by install.sh — add it to the
  install list): given the recorded `Source-Path` (argument or read from
  `.project/ardd-version.md`), if the path is the tooling-owned
  `~/.ardd/source` (or `$ARDD_HOME/source`), `git fetch --tags` it
  (offline-tolerant: on fetch failure print `warning=offline` and continue
  with existing state), select the latest semver tag — prefer `git tag
  --sort=v:refname` if fixture tests prove its ordering (plan Complexity
  Tracking; fall back to a small portable compare only if they don't) —
  check it out, and print `resolved=<path> ref=<tag> channel=release`; for
  any other existing path print `resolved=<path> channel=dev` without
  mutating it (a user's checkout is read, never mutated); missing path →
  `resolved=false reason=...`, exit 1. Test-first:
  `scripts/test-source-resolve.sh` against local fixture remotes in temp
  dirs (latest-tag selection incl. `v1.10.0 > v1.9.0`, offline fallback,
  dev path untouched, detached-at-tag re-resolve, no-tags repo →
  `ref=<default-branch>` with `warning=no-tags`). CI job same commit.

- [x] T003 Rework `scripts/ardd-update-check.sh` to compare the installed
  commit against the source's latest release tag: `behind` now means "the
  installed commit is not the latest release's commit," printing
  `behind installed=<x> latest-release=<tag>`; keep `self-hosted`,
  `no-version-file`, `no-source-path`, `source-missing` outcomes unchanged;
  a source with no tags yet falls back to the current tip comparison and
  appends `note=no-releases`. Update `scripts/test-ardd-update-check.sh`
  cases accordingly (behind-release, at-release, no-tags fallback,
  self-hosted unchanged) — extend fixtures first, confirm red, then
  implement.

- [x] T004 Extend `install.sh` to record `Source-Ref: <tag>` in the target's
  `.project/ardd-version.md` when the source checkout's HEAD is exactly at
  a semver tag (`git describe --exact-match --tags`, filtered to `v*`),
  omitting the line otherwise; keep `Source-Path` as-is. Extend the
  install-fixture regression coverage (the version-file cases in
  `scripts/test-new.sh` or the install checks wherever they live —
  follow the existing pattern) with an at-tag and a not-at-tag case,
  test-first.

## Phase 3: Acquisition routes

- [ ] T005 [artifacts: constitution] Update `new.sh`: after cloning or
  refreshing the `~/.ardd/source` checkout it owns, fetch tags and check
  out the latest release tag (same selection rule as T002 — but new.sh
  runs with no checkout of its own, so the logic must be inline or
  duplicated minimally, NOT sourced from ardd-scripts; keep it a few
  lines); offline refresh failure warns and proceeds with existing state;
  a source with no tags stays on the default branch with a note.
  `--source`/`$ARDD_SOURCE` paths are used exactly as given (dev-mode,
  never mutated — preserve the existing never-mutate rule and its
  hermetic-test guarantee). Extend `scripts/test-new.sh` with fixture-tag
  cases (installs from latest tag; no-tags fallback; --source untouched),
  test-first, keeping every branch under the timeout guard per the
  existing test discipline.

- [ ] T006 [artifacts: constitution] Update `skills/ardd-update/SKILL.md`:
  its source-standing step now runs `source-resolve.sh` (worktree
  copy/absolute-path fallback rule as with other ardd-scripts); on
  `channel=release` proceed and report the resolved tag; on `channel=dev`
  surface an explicit dev-mode warning (live checkout, may hold unreleased
  state) and ask the user before proceeding; on `resolved=false` relay the
  reason (existing source-missing flow). The offered "pull the source"
  step becomes "fetch tags + move to latest release" for the owned
  checkout, delegated to the script — the skill decides, the script
  writes. Keep the new-workflow-field backfill behavior intact.

## Phase 4: Docs

- [ ] T007 [parallel] Update README.md and USAGE.md acquisition/update
  sections and CLAUDE.md (commands block: add `release.sh`,
  `source-resolve.sh`, their tests; architecture notes: the release
  channel, dev-mode escape, and that the primary-stays-on-main section is
  slated for retirement at Phase 6) to describe releases as the stable
  channel. `./scripts/lint-docs.sh` and the pre-commit hook green.

## Phase 5: First release + consumer repoint

- [ ] T008 Cut the first release: confirm the version with the user (plan
  Open Question 1 — proposed `v1.0.0`), run the full suite, then
  `scripts/release.sh <version>` for real (this is the one deliberate
  network step; it requires the session to push — get explicit user
  confirmation per the push convention).

- [ ] T009 Repoint sweep: confirm with the user which of the five consumers
  move to the release channel (plan Open Question 3 — default all:
  atelier, yet-another-rank-games, yet-another-rank-games-2,
  assisted-review, sync-tab-scroll); for each, refresh `~/.ardd/source` to
  the new release and run its `install.sh` into the consumer so
  `Source-Path` records `~/.ardd/source` and `ardd-version.md` records the
  tag; commit each consumer's ARDD record signed (no push). Verify
  `ardd-update-check.sh` reports at-release in each. Note
  yet-another-rank-games-2 has never committed its ARDD files — surface,
  don't force.

## Phase 6: Retire the mandate

- [ ] T010 [artifacts: constitution] Only after T009 is verified: amend the
  constitution to retire the primary-stays-on-main standing decision
  (replace the paragraph + its retirement note with a brief pointer to the
  release-channel decision and the decision record; new SIR; version bump
  magnitude per plan Open Question 2 — ask the user), stamp
  `last_updated`, remove CLAUDE.md's "the primary checkout stays on main"
  section, and write `docs/decisions/0006-release-channel.md` recording
  the arc (live-checkout hazard → v1.4.0 mandate → release channel →
  retirement). `lint-project.sh` + `lint-docs.sh` + pre-commit green.
