---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: dynamic-badge-discoverability
created: 2026-07-19
features: []
surfaced-defects: []
---

# Plan: dynamic-badge-discoverability

## Goal

Make the `ARDD_VERSION_BADGE` dynamic-badge feature actually reachable and
correct for consumers: surface the opt-in in skill prose and install.sh's
default output, print a snippet that works as pasted (real repo
coordinates, not `OWNER/REPO/BRANCH` placeholders), stop reprinting it
when already adopted, warn about the wrong hand-rolled badge shape and
the private-repo limitation.

## Scope

**In scope** (consumes `feedback-dynamic-badge-discoverability-a123.md`,
all six items accepted):
- F001/F006 — discoverability: mention the `ARDD_VERSION_BADGE=1` opt-in
  in install.sh's *default* (unset) output alongside the static-badge
  suggestion; have `/ardd-update` offer the dynamic badge explicitly
  (setting the env var on the install.sh re-run when the user opts in);
  document the feature in the docs site + USAGE.md. The env var stays
  the mechanism (scriptable, mirrors `ARDD_CHANNEL`, already
  regression-tested); skills and printed output become the interface —
  this resolves F006 without a new CLI flag parser.
- F002 — install.sh fills `OWNER/REPO/BRANCH` in the printed two-badge
  snippet from the target's own git coordinates (`git -C "$TARGET"
  remote get-url origin` parsed to `owner/repo`, default branch via the
  same fallback chain `branch-info.sh` uses); when no GitHub remote is
  resolvable, keep the placeholders but *print* the replace-these
  instruction that today lives only in an unprinted template comment.
- F003 — the `ARDD_VERSION_BADGE=1` branch skips the paste-this-snippet
  print when the README already contains `ardd-badge-version-start`
  (mirror of the static branch's existing `ardd-badge-start` grep
  guard); supporting-file writes still run.
- F004 — advisory only (install.sh never edits a README): when the
  README contains an ArDD badge that tracks *latest release*
  (`img.shields.io/github/v/release/…artifact-driven-dev`), print a
  warning that it advertises ArDD's newest release, not the installed
  version, and point at the endpoint-badge snippet as the replacement.
- F005 — a printed one-line caveat with the snippet (and a comment in
  `templates/badge.md` / the workflow template): the endpoint badge only
  renders for public repos, since shields.io fetches
  `raw.githubusercontent.com` unauthenticated.

**Out of scope:**
- install.sh rewriting README marker blocks in place (would break the
  "suggestion only, never a README edit" standing posture — decision
  record 0002's spirit; revisit only with new evidence).
- `/ardd-init` offering the badge (init runs before a first release
  exists in most greenfield targets; `/ardd-update` is where version
  currency is already the topic). Can be added later if wanted.
- Any change to the sync workflow's push mechanics (branch protection /
  Actions-permissions failure modes) — real but unobserved; not in this
  feedback batch.

## Technical Approach

All install.sh changes live in the existing badge section
(`install.sh:427-486`), extending `scripts/test-install-version-badge.sh`
red-first per this repo's shell-test convention. Coordinate derivation is
POSIX sh: parse `git -C "$TARGET" remote get-url origin` for the
`github.com[:/]owner/repo(.git)` shapes; branch from `git -C "$TARGET"
symbolic-ref --short HEAD` falling back to `main` (same spirit as
`branch-info.sh`, which isn't guaranteed present in `$TARGET`). The
snippet substitution is a `sed` over `templates/badge.md`'s printed
block, same style as the existing seed-JSON `sed`. Skill prose changes go
to `skills/ardd-update/SKILL.md` (offer step) with the matching reference
page + USAGE.md rows; `docs-sweep`'s lint (`lint-docs.sh`) keeps names
honest.

## Phase Breakdown

**Phase 1 — install.sh mechanics (test-first)** (no dependencies)
1. Extend `test-install-version-badge.sh` with red cases: filled
   coordinates in printed snippet; placeholder+instruction fallback with
   no remote; no reprint when `ardd-badge-version-start` present;
   latest-release-badge advisory; private-repo caveat line. (F002-F005)
2. Implement: coordinate fill, reprint guard, wrong-badge advisory,
   caveat line, default-output discoverability mention. (F001-F005)

**Phase 2 — skill prose** (depends on Phase 1 for accurate wording)
3. `/ardd-update` offers the dynamic badge when the target hasn't
   adopted it, passing `ARDD_VERSION_BADGE=1` into the install.sh re-run
   on acceptance. (F001/F006)

**Phase 3 — docs** (depends on Phases 1-2)
4. Document the feature: USAGE.md routing, `/ardd-update` reference
   page body, template comments (private-repo caveat). (F001/F005)

## Open Questions

- Should the F004 latest-release-badge advisory also fire in the
  *default* (env var unset) path, or only under `ARDD_VERSION_BADGE=1`?
  Leaning: both — the warning is cheap, correct, and the default path is
  where the drifted consumers are.
- Exact `/ardd-update` offer placement: step 4's suggestion-relay point
  seems natural (where install.sh output is already surfaced), to be
  confirmed against the current SKILL.md structure while editing.
