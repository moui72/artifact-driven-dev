---
plan: plan-changelog-precommit-2026-07-21-b716.md
generated: 2026-07-21
status: in-progress
---

# Tasks

## Phase 1: Release notes generation
- [x] T001 [feature: changelog-from-github-releases] Create
  `scripts/release-notes.sh`: a POSIX `sh`, source-side-only script
  (follow the header-comment style of `scripts/next-version.sh` and
  `scripts/source-resolve.sh` — purpose, usage, source-side-only note)
  that runs `gh release list --limit 1000` (or paginated `gh api
  repos/:owner/:repo/releases`) to fetch every GitHub release for this
  repo, sorts newest-first, and writes `docs/release-notes.md` with one
  Markdown section per release (tag as `## <tag>` heading, publish date,
  release body verbatim below it) — full re-render every run
  (idempotent), matching the existing single-release page's overall
  shape (`# ArDD release notes` top-level title, then one heading per
  release). Print nothing but the regenerated file's path on success;
  exit non-zero with a clear message on `gh` auth/rate-limit failure.
  Test requirement: none in this task — its regression test is T002.
- [x] T002 [feature: changelog-from-github-releases] [parallel] Create
  `scripts/test-release-notes.sh`: a fixture-based regression test for
  `scripts/release-notes.sh`, following the pattern of
  `scripts/test-next-version.sh` / `scripts/test-source-resolve.sh`
  (hermetic — stub `gh` with a fixture script/fixture JSON payload
  rather than hitting the real GitHub API; use a `mktemp -d` fixture
  repo so it never touches this repo's own `docs/release-notes.md`).
  Pin: multiple releases render newest-first; a release body containing
  Markdown table/list content passes through unescaped; zero releases
  produces a valid (near-empty) file rather than erroring.
- [x] T003 Add a `lint-release-notes` (or similarly
  named) CI job to `.github/workflows/lint.yml` running
  `./scripts/test-release-notes.sh`, following the existing
  `lint-templates-yaml`/`lint-templates-yaml-test` job pair's shape (a
  small `run:` step under `runs-on: ubuntu-latest`).
- [x] T004 [feature: changelog-from-github-releases] Wire
  `scripts/release-notes.sh` into `.github/workflows/stable-release.yml`:
  add a step after "Publish the release (API-created tag)" that runs
  `sh scripts/release-notes.sh`, then commits and pushes
  `docs/release-notes.md` if it changed (guard with `git diff --quiet --
  docs/release-notes.md || (git add docs/release-notes.md && git commit
  -m "docs: regenerate release-notes.md" && git push origin
  "$GITHUB_SHA:refs/heads/release" — mirroring the existing "Fast-forward
  main into the release branch" step's push target). Update the
  workflow's own header comment (mirroring its existing numbered-steps
  list) to mention the new step.

## Phase 2: Pre-commit scoping expansion
- [x] T005 [feature: pre-commit-hook-scoping-expans] In `hooks/pre-commit`,
  add `scripts/lint-templates-yaml.sh` to the `for check in scripts/lint-docs.sh
  scripts/lint-project.sh scripts/test-*.sh` loop (it currently only
  matches `test-*.sh` and the two named lints, so `lint-templates-yaml.sh`
  needs an explicit new entry in that `for` list), and add a
  `check_needed()` case for it: `staged_matches .github/workflows/
  templates/ "scripts/$check_base"`.
- [x] T006 [feature: pre-commit-hook-scoping-expans] [parallel] In
  `hooks/pre-commit`'s `check_needed()`, add a case mapping
  `test-lint-project.sh` and `test-hook-lint-on-write.sh` to also run
  when `tests/fixtures/` is staged (in addition to their existing
  subjects) — extend their `staged_matches` calls to include
  `tests/fixtures/`.
- [x] T007 [feature: pre-commit-hook-scoping-expans] In `hooks/pre-commit`'s
  top-level staged-path `case` statement (the `RUN_ALL` fail-safe loop),
  add `CLAUDE.md`, `dev-notes/*`, `tests/scenarios/*`, `mkdocs.yml`,
  `.gitignore`, and `.worktreeinclude` as recognized no-check paths
  (matched but producing no action, same as the existing `.project/*)
  ;;` branch) — so a commit touching only these paths no longer falls
  through to the `RUN_ALL=1` catch-all.
- [x] T008 [feature: pre-commit-hook-scoping-expans] In
  `scripts/test-hooks-pre-commit.sh`, add fixture cases pinning each new
  mapping from T005–T007: (a) staging a `.github/workflows/*.yml` or
  `templates/*` path runs `lint-templates-yaml.sh` but not the full
  suite; (b) staging a `tests/fixtures/*` path runs
  `test-lint-project.sh` and `test-hook-lint-on-write.sh` but not the
  full suite; (c) staging only `CLAUDE.md`, `dev-notes/*`,
  `tests/scenarios/*`, `mkdocs.yml`, `.gitignore`, or `.worktreeinclude`
  runs no checks at all (fast exit); (d) staging an unmapped path still
  triggers `RUN_ALL=1` (regression guard for the fail-safe default).
  Follow the existing stub-script-plus-staged-fixture-repo pattern
  already used for cases 5–9 in this file.

## Phase 3: Follow-up fixes
- [x] T009 Verify shieldcn.dev's `dynamic/json` badge
  type's `logo` query parameter against shieldcn.dev's own docs or a
  live test render: confirm whether it accepts a base64
  `data:image/svg+xml;base64,...` URI the way shields.io's `/endpoint`
  does. Record the confirmed answer directly in this task's commit
  message or in `templates/badge-shieldcn.md`'s own comments — T010
  depends on the outcome. [feedback: F001,
  feedback-badge-style-variant-followups-dbff.md]
- [x] T010 In `templates/badge-shieldcn.md`, once T009
  confirms the param shape: replace the `PLACEHOLDER` token in both the
  split and pair snippets (currently at the two
  `logo=data:image/svg+xml;base64,PLACEHOLDER` occurrences) with the
  real base64-encoded `templates/ardd-icon.svg` value — generate it via
  `base64 < templates/ardd-icon.svg` (same recipe already used for the
  shields.io form elsewhere in this repo) — and remove the
  header-comment caveat about the logo param being unverified. If T009
  finds the param unsupported, instead update the header comment to
  state that finding explicitly and leave `PLACEHOLDER` in place with an
  explanatory note (do not silently ship a broken param). [feedback:
  F001, feedback-badge-style-variant-followups-dbff.md]
- [ ] T011 [parallel] In this repo's own
  `.worktreeinclude` (repo root, not a target project's — this is
  source-side dev tooling), add a line covering
  `.agents/skills/scenario-sweep/`, mirroring the existing
  `.claude/skills/ardd-*/` line and its header comment style. [feedback:
  F002, feedback-badge-style-variant-followups-dbff.md]
- [ ] T012 [parallel] In `skills/ardd-implement/SKILL.md`
  step 3 (the "When the subagent reports back" coordinator checklist,
  immediately after the existing `git config --get core.bare` check),
  add an equivalent check: run `git config --get core.hooksPath` in the
  primary checkout; if it prints `/dev/null`, run
  `git config core.hooksPath hooks` (this repo's standard value; for a
  target project installed elsewhere, restore to unset or whatever the
  pre-run value was) and tell the user, the same way the `core.bare`
  restoration is reported. [feedback: F001,
  feedback-hookspath-side-effect-c707.md]
- [ ] T013 [parallel] Mention the `core.hooksPath`
  side effect and its restoration alongside the existing `core.bare`
  mentions in `CLAUDE.md`'s architecture note (the paragraph beginning
  "back, the coordinator checks the primary checkout for the `core.bare
  = true`") and in
  `docs/decisions/0001-branch-identity-and-worktree-native-state.md`'s
  side-effect list (near its existing `core.bare` mentions), so the pair
  travels together as the feedback item requests. [feedback: F001,
  feedback-hookspath-side-effect-c707.md]
