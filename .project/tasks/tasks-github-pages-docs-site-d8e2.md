---
plan: plan-github-pages-docs-site-2026-07-13-3fb8.md
generated: 2026-07-13
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                     # (or -> abandoned, if superseded by a new tasks
                     # file generated for the same plan)
                     # completed is terminal — post-completion failures
                     # become new feedback (/ardd-feedback), never a
                     # status edit.
---

# Tasks

Feature: `github-pages-docs-site`. All work is source-side (Constitution
Principle IV) — nothing here is installed into target projects. No new
`scripts/*.sh` is added, so no new fixture test is owed under Principle V;
the docs build itself (`mkdocs build --strict`) is the new CI check and is
off-the-shelf (Principle VIII).

## Phase 1: Site scaffold, buildable locally

- [ ] T001 Write `mkdocs.yml` at the repo root: `site_name` (artifact-driven-dev / ARDD), `site_url: https://moui72.github.io/artifact-driven-dev/`, `repo_url: https://github.com/moui72/artifact-driven-dev`, `docs_dir: docs`, `theme: material` (enable navigation + search features; light/dark palette toggle), `markdown_extensions:` incl. `pymdownx.superfences` with the documented Mermaid custom fence and `admonition`/`toc(permalink)`, `validation:` set so omitted files, unrecognized links, and absolute links fail under `--strict`, and a `nav:` transcribed from `USAGE.md`'s documentation map — Home (index.md), Concepts, Example, Install, Guides (greenfield, existing-project, core-loop, from-spec-kit, parallel-work, checking, tracker-sync, diagrams), Reference (skills/ incl. its README as section index, scripts, configuration, project-files), Decisions (docs/decisions/*, README first), Release notes (release-notes-v1.md). Every file under `docs/` must be reachable in nav or deliberately excluded — `--strict` flags omissions.
- [ ] T002 [parallel] Write `docs/index.md`: landing page with a two-sentence statement of what ARDD is (adapt README's pitch, don't copy it wholesale), then the "New to ARDD?" reading order and situation→guide table adapted from `USAGE.md` with site-relative links (no `docs/` prefix, no links escaping `docs/`). Note in the page footer that the repo's README/USAGE hold the GitHub-facing equivalents.
- [ ] T003 Fix the link(s) escaping `docs/` so strict validation can pass: `grep -rn '\.\./\.\./USAGE\.md\|\.\./\.\./README\.md' docs/` and repoint each at the site-internal equivalent (e.g. `../../USAGE.md` → the new `index.md`), keeping the anchor text sensible for GitHub browsing too. Re-grep to confirm zero remaining escapes.
- [ ] T004 Verify Phase 1: in a throwaway venv or via pipx/uvx (never a committed dependency, no requirements file), run `mkdocs build --strict` from the repo root and fix anything it flags until it exits 0; then run `./scripts/lint-docs.sh` (the new `docs/index.md` is inside its scan surface) and the full pre-commit suite via a normal commit. Commit Phase 1 as `feat: add MkDocs site scaffold (mkdocs.yml, docs/index.md)` (signed, per global instructions).

## Phase 2: CI deploy

- [ ] T005 Write `.github/workflows/docs.yml`: triggers `push` (branch `main`) and `pull_request`, both path-filtered to `docs/**`, `mkdocs.yml`, `README.md`, `USAGE.md`, and `.github/workflows/docs.yml`; a `build` job (checkout, `actions/setup-python`, `pip install mkdocs-material`, `mkdocs build --strict`, `actions/upload-pages-artifact` with `site/`) and a `deploy` job (needs build, `if: github.event_name == 'push'`, `environment: github-pages`, `actions/deploy-pages`) with `permissions: pages: write, id-token: read` and a `concurrency: pages` group. The PR-triggered build (no deploy) is the plan's link-check step.
- [ ] T006 Enable Pages with source = GitHub Actions: `gh api repos/moui72/artifact-driven-dev/pages -X POST -f build_type=workflow` (if it 409s because Pages already exists, `-X PUT` with the same field). Confirm with `gh api repos/moui72/artifact-driven-dev/pages` showing `"build_type": "workflow"`.
- [ ] T007 Verify Phase 2 end-to-end: commit `docs.yml` (`feat: deploy docs site to GitHub Pages via Actions`), push `main` (note: push also publishes the ~16 pending commits as the next beta — expected, flag it in the report), watch `gh run watch` for the docs workflow, then confirm `https://moui72.github.io/artifact-driven-dev/` serves: spot-check sidebar nav, search, a deep link into `docs/reference/skills/`, a decisions page, and Mermaid rendering on the diagrams guide.

## Phase 3: Wire-up

- [ ] T008 Add the live site link near the top of `README.md` and `USAGE.md` ("Browse these docs as a website: https://moui72.github.io/artifact-driven-dev/"), keeping `lint-docs.sh` green.
- [ ] T009 Decide `beta-release.yml`'s treatment of the new files: its skip patterns (`.project/**`, `docs/**`, top-level `*.md`) already cover everything here except `mkdocs.yml` and `.github/workflows/docs.yml`. Judgment call per the plan: a docs-config-only push shouldn't cut a beta — add `mkdocs.yml` (and `.github/workflows/docs.yml` if consistent with how other workflow files are treated there — check first) to the skip list if the workflow's structure supports it, or record explicitly (commit body) why it's left alone. Commit Phase 3 as `docs: link the rendered docs site; adjust beta skip list`.
