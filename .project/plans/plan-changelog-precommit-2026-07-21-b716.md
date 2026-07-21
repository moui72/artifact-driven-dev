---
status: approved
branch: changelog-precommit
created: 2026-07-21
features: [changelog-from-github-releases, pre-commit-hook-scoping-expans]
surfaced-defects: []
---

# Plan: release-notes generation, pre-commit scoping expansion, and three follow-up fixes

## Goal

Generate `docs/release-notes.md` from real GitHub releases via a
fetch-and-commit script, extend `hooks/pre-commit`'s staged-path scoping to
give workflow-YAML/test-fixture/no-check-subject commits a fast path (and
wire `lint-templates-yaml.sh` into the hook), and land three small follow-up
fixes surfaced as feedback: the shieldcn badge logo placeholder, this repo's
own `.worktreeinclude` gap for `.agents/skills/scenario-sweep/`, and
`/ardd-implement`'s missing `core.hooksPath` restoration after delegated
worktree creation.

## Scope

**In scope:**
- A new source-side script, `scripts/release-notes.sh`, that regenerates
  `docs/release-notes.md` from `gh release list` / `gh api` release data,
  alongside the other release-ops scripts.
- Wiring that script into `stable-release.yml` right after a release is cut,
  so the page stays current without a manual step, plus a regression test
  (`scripts/test-release-notes.sh`) and a CI lint job, matching this repo's
  "every deterministic script gets a fixture-based test in the same commit"
  rule.
- Extending `hooks/pre-commit`'s `check_needed`/staged-path-scoping table:
  add `lint-templates-yaml.sh` to the check loop with `.github/workflows/` +
  `templates/` as its subjects; map `tests/fixtures/` to
  `test-lint-project.sh` + `test-hook-lint-on-write.sh`; recognize
  `CLAUDE.md`, `dev-notes/*`, `tests/scenarios/*`, `mkdocs.yml`,
  `.gitignore`, `.worktreeinclude` as no-check paths.
- Fixture cases added to `scripts/test-hooks-pre-commit.sh` pinning each new
  mapping, in the same commit.
- `templates/badge-shieldcn.md`: confirm shieldcn.dev's `dynamic/json` logo
  param shape, then replace the `PLACEHOLDER` token in the split/pair
  snippets with the real base64-encoded `templates/ardd-icon.svg` value and
  drop the header-comment caveat.
- This repo's own `.worktreeinclude`: add an entry covering
  `.agents/skills/scenario-sweep/`, mirroring the existing
  `.claude/skills/ardd-*/` line.
- `skills/ardd-implement/SKILL.md` step 3's post-delegation coordinator
  check: alongside the existing `core.bare` check, also check
  `git config --get core.hooksPath` and restore the repo-standard value
  (`hooks`) when it reads `/dev/null`, reporting the restoration the same
  way as the `core.bare` fix. Mention the paired side effect in
  `CLAUDE.md`'s architecture note and in
  `docs/decisions/0001-branch-identity-and-worktree-native-state.md`'s
  side-effect list.

**Out of scope:**
- A build-time fetch of release data in `docs.yml`'s GitHub Pages build —
  explicitly rejected in the feature register entry (new network/auth
  dependency, rate-limit failure mode, no benefit over fetch-and-commit).
- Splitting `test-install-version-badge.sh` or `test-new.sh`, or narrowing
  the `skills/*` → install-family test fan-out, or mapping `.claude/`,
  `.agents/`, `site/` in the pre-commit hook — all explicitly rejected by
  the dispatched research pass behind this feature (rarely committed, leave
  on fail-safe; or every case already exercises its one mapped subject).
- Verifying shieldcn.dev's logo param against any badge type other than
  `dynamic/json` — out of scope for this fix.
- Any change to how `install.sh` manages a *target* project's
  `.worktreeinclude` — the scenario-sweep gap is this source repo's own dev
  file, not something `install.sh` writes for consumers (scenario-sweep is
  explicitly source-side-only, never installed).

## Technical Approach

**Release notes.** `scripts/release-notes.sh` follows the shape of
`scripts/next-version.sh`/`scripts/source-resolve.sh`: POSIX `sh`,
source-side only, not installed. It runs `gh release list` /
`gh api repos/:owner/:repo/releases` to fetch every release (tag, name,
body, published date), sorts newest-first, and renders
`docs/release-notes.md` in the shape the mkdocs "Release notes" nav page
already expects — one section per release, tag as heading, body as-is. The
regenerated file stays git-tracked (a plain regenerate-and-commit, not a
runtime fetch). `stable-release.yml` runs it immediately after
`gh release create` publishes the new release, then commits the updated
file — consistent with that workflow already being the one that computes
and tags versions via `next-version.sh`.

**Pre-commit scoping.** All changes are inside `hooks/pre-commit`'s existing
`case` pattern-table and `check_needed()` function — no new control-flow
shape, just new table entries following the same "every branch fails safe
to run-all" discipline already documented in the hook's own comments.
`lint-templates-yaml.sh` is a new check invocation (it isn't currently in
the `for check in ...` loop at all), so it needs both the loop addition and
a `check_needed` case.

**Badge logo param.** Verify shieldcn.dev's `dynamic/json` logo param
directly (docs or a test render) before touching the template — this is a
verification step, not a design decision (the icon and encoding recipe are
already decided per the feedback item).

**Worktreeinclude / hooksPath fixes.** Both are narrow, single-line-class
edits to existing files following an established pattern each already
demonstrates elsewhere in the same file (the `.claude/skills/ardd-*/` line;
the `core.bare` check block).

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is tracked
in the linked tasks file.

- **Phase 1: Release notes generation** — write `scripts/release-notes.sh`
  and `scripts/test-release-notes.sh`, wire the CI lint job, wire the
  script into `stable-release.yml`. No dependency on other phases.
- **Phase 2: Pre-commit scoping expansion** — extend `hooks/pre-commit`'s
  pattern table and `check_needed()`, add the new fixture cases to
  `scripts/test-hooks-pre-commit.sh`. No dependency on other phases.
- **Phase 3: Follow-up fixes** — the three feedback-sourced fixes (badge
  logo param, `.worktreeinclude` scenario-sweep entry, `core.hooksPath`
  restoration + doc mentions). Independent of Phase 1 and 2 and of each
  other; grouped here because each is small enough not to warrant its own
  phase.

## Open Questions

- Does shieldcn.dev's `dynamic/json` badge type actually accept a base64
  `data:image/svg+xml;base64,...` logo URI the way shields.io's `/endpoint`
  does? Must be confirmed against real docs/source (or a test render)
  before the `PLACEHOLDER` token can be replaced — if it turns out
  unsupported, the split/pair shieldcn shapes stay caveated rather than
  silently shipping a broken logo param.
- Should `scripts/release-notes.sh` re-render the full history every run
  (idempotent, simplest) or only append the newest release since the last
  regeneration? Full re-render is the default assumption (matches
  "regenerates from release bodies/tags" in the feature register entry)
  unless the release history turns out too large for that to stay cheap.
