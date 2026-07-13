---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: github-pages-docs-site   # the branch inline implementation would use; may never be created (solo no-gate)
created: 2026-07-13
features: [github-pages-docs-site]
surfaced-defects: []
---

# Plan: GitHub Pages docs site (MkDocs Material)

## Goal

Render `docs/` as a navigable, searchable GitHub Pages site (MkDocs
Material) deployed automatically by a paths-filtered GitHub Actions
workflow, with broken-link detection in CI and the site linked from the
README.

## Scope

**In scope:**
- `mkdocs.yml` at the repo root: Material theme, `nav:` transcribed from
  `USAGE.md`'s documentation map, Mermaid rendering (two pages use it:
  `docs/guides/diagrams.md`, `docs/reference/skills/ardd-diagram.md`),
  strict link validation.
- A hand-written `docs/index.md` landing page (site homepage) adapted from
  `USAGE.md`'s map — `README.md`/`USAGE.md` stay at the repo root for
  GitHub browsing and are not pulled into the site.
- Fixing the one link that escapes `docs/` (`../../USAGE.md` in a guide) so
  strict validation passes.
- `.github/workflows/docs.yml`: build (`mkdocs build --strict`) on PRs
  touching docs, build + deploy to Pages (`actions/deploy-pages`) on push
  to `main`.
- Enabling Pages with source = GitHub Actions
  (`gh api repos/moui72/artifact-driven-dev/pages -X POST -f
  build_type=workflow`).
- Publishing `docs/decisions/` as a site section (already public in the
  repo; good reading).
- Linking the site URL (`https://moui72.github.io/artifact-driven-dev/`)
  from `README.md` and `USAGE.md`.

**Out of scope:**
- No custom domain.
- No include/import plugins to render `README.md`/`USAGE.md` inside the
  site (YAGNI — a small hand-written index is enough; see Complexity
  Tracking).
- No versioned docs (mike) — the site tracks `main`; release channels are
  a skills concern, not a docs concern, until proven otherwise.
- No custom link-check script (Principle VIII: `mkdocs build --strict`
  with `validation:` config is the tool's built-in idiom for exactly this).
- No changes to `gen-skill-docs.sh` or the reference-page generation
  pipeline — the site renders the committed files as-is.

## Technical Approach

- **Source-side only (Principle IV).** `mkdocs.yml`, `docs/index.md`, and
  the workflow govern this repository; nothing here is touched by
  `install.sh` or reaches a target project.
- **`docs_dir: docs`**, site homepage = new `docs/index.md`. Existing
  relative `.md` links inside `docs/` convert natively; MkDocs `validation`
  settings (`omitted_files`/`unrecognized_links`/`absolute_links: warn`)
  plus `--strict` turn any dead link into a build failure — this is the
  link-check step, in CI on every docs PR and push.
- **Mermaid** via `pymdownx.superfences` custom fence (Material's
  documented mechanism, no extra plugin).
- **Deploy** with the Pages-native flow: `actions/configure-pages`,
  `mkdocs build --strict`, `actions/upload-pages-artifact`,
  `actions/deploy-pages`. No `gh-pages` branch to maintain (Principle VII —
  no second copy of rendered output living in the repo).
- **Workflow triggers**: `push` to `main` and `pull_request`, both
  path-filtered to `docs/**`, `mkdocs.yml`, root `*.md`, and the workflow
  file itself; deploy job gated on `push` to `main`. Consistent with
  `beta-release.yml` already treating docs-only pushes as non-release
  events.
- **No new deterministic script → no new fixture test (Principle V
  applies to code changes; this adds none).** The only new "check" is the
  off-the-shelf `mkdocs build --strict` CI job. The pre-commit hook's
  glob discovers `scripts/test-*.sh`; nothing new appears there, and
  MkDocs (Python) is deliberately not made a local pre-commit dependency —
  CI owns the docs build.
- `scripts/lint-docs.sh` already scans `docs/` — the new `docs/index.md`
  is automatically covered by the existing skill-name check.

## Phase Breakdown

**Phase 1 — Site scaffold, buildable locally** (feature:
`github-pages-docs-site`)
1. Write `mkdocs.yml` (Material theme, nav from `USAGE.md`'s map including
   a Decisions section, Mermaid superfence, strict validation config).
2. Write `docs/index.md` (landing page: what ARDD is in two sentences,
   then the USAGE-style map).
3. Fix the `../../USAGE.md` escape link (point it at the site-internal
   equivalent, keeping GitHub browsing sensible).
4. Verify: `mkdocs build --strict` passes locally (venv/pipx, not a
   committed dependency); `scripts/lint-docs.sh` still passes.

**Phase 2 — CI deploy** (depends on Phase 1)
5. Write `.github/workflows/docs.yml` (build on PR, build+deploy on push
   to `main`; path-filtered; Pages permissions + concurrency group).
6. Enable Pages via `gh api` (build_type=workflow).
7. Verify: push, watch the workflow deploy, confirm the site serves and
   spot-check nav, search, Mermaid rendering, and deep links.

**Phase 3 — Wire-up** (depends on Phase 2)
8. Add the site link to `README.md` and `USAGE.md`.
9. Confirm `beta-release.yml`'s docs-skip patterns already cover the new
   files as intended (`mkdocs.yml` is top-level but not `*.md` — decide
   whether a docs-config-only push should cut a beta; adjust the skip list
   if not).

## Complexity Tracking

| Deviation | Justification |
|---|---|
| Nav/map duplicated: `USAGE.md` (GitHub) and `mkdocs.yml` + `docs/index.md` (site) | Two rendering surfaces with different link semantics; an include-plugin to unify them adds a dependency to save ~40 duplicated lines that change rarely. Revisit only if they demonstrably drift. |

## Open Questions

- None blocking. Phase 3 task 9 contains the one judgment call
  (`beta-release.yml` skip-list treatment of `mkdocs.yml`), resolvable
  during implementation.
