---
slug: changelog-from-github-releases
status: implemented
logged: 2026-07-21
---

Auto-generate docs/release-notes.md (the GitHub Pages docs site's changelog page, mkdocs.yml nav "Release notes") from actual GitHub releases via a fetch-and-commit script (gh api / gh release list), rather than the current hand-written single-release page frozen at v0.9.0.
Why: observed 2026-07-21 -- the docs site's changelog reads as very incomplete against the real release history (41 real releases through v1.0.4 exist, but the page only covers v0.9.0). Design direction (user-confirmed): a source-side script, alongside scripts/next-version.sh and the other release-ops scripts, regenerates docs/release-notes.md from release bodies/tags -- run on-demand or wired into stable-release.yml right after a release is cut, so the page stays current without a separate manual step. The regenerated file stays git-tracked; deliberately NOT a build-time fetch in docs.yml's GitHub Pages build (that was considered and rejected -- it would add a new network/auth dependency and rate-limit failure mode to the docs pipeline for no real benefit over fetch-and-commit).
