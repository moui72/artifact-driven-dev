---
status: draft        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: self-update-from-consumer
created: 2026-07-06
features: [self-update-from-consumer]
surfaced-defects: []
---

# Plan: self-update from a consuming repo + pending-update visibility

## Goal

Let a consuming repo update its ARDD install without knowing where the
source checkout lives, and surface "you're behind" before it bites.

## Scope

**In:** the `self-update-from-consumer` feature (no artifact changes —
user-confirmed 2026-07-06): source-path recording at install time, a
deterministic update-check script, an `/ardd-update` skill, analyze
visibility, and doc alignment.

**Out:** network-based update checks against the GitHub remote (v1
compares against the local source checkout only — no fetch, no network;
a `--fetch` flag is a possible later extension, noted, not built);
automatic updates (every update remains user-initiated).

## Technical Approach

The consumer's only durable link to the source is
`.project/ardd-version.md`; today it records the commit but not the
path. Add a machine-readable source-path line at install time, then
everything else reads it: `ardd-update-check.sh` (target-side, shipped)
compares the installed commit against the source checkout's tip —
pure local git, deterministic, testable; `/ardd-update` (new extension
skill) re-runs the source's install.sh against the current repo, with
user confirmation before any `git pull` of the source. A side benefit
that motivated this feature's timing: install-time suggestions (badge,
gitignore) print to whoever runs install.sh — running it via
`/ardd-update` *in the consumer's own session* means the consumer
actually sees them (today's badge offer was invisible because the
source-side coordinator ran the installs).

Scripts are test-first with fixtures + CI (Principle V); the new skill
registers in gen-skill-docs' extension ordering and regenerates the
docs tables (drift check enforces).

## Phase Breakdown

### Phase 1 — record the source path

- T-A install.sh writes a machine-readable source-path line into
  `.project/ardd-version.md` (exact format decided in-task — must
  survive the file's prose and be greppable, e.g. a `Source-Path:`
  line; absolute path of the source checkout). Idempotent across
  reinstalls (updates the line, never duplicates). Extend the install
  fixture test first (red: line absent).

### Phase 2 — deterministic update check

- T-B `scripts/ardd-update-check.sh [target-dir]` (target-side,
  shipped via install.sh + chmod + .worktreeinclude coverage): parses
  ardd-version.md for source path + installed commit; prints exactly
  one machine-readable line — `up-to-date commit=<x>`,
  `behind installed=<x> source-tip=<y>`, `source-missing path=<p>`, or
  `no-version-file`. Local comparison only (`git -C <source> rev-parse
  HEAD`), no network. Fixture tests first (all four outcomes, using
  throwaway git repos), CI job, same commit.
- T-C Wire visibility: `/ardd-analyze` runs the check (present-or-
  fallback path rule) and, when `behind`, adds an "ARDD update
  available" line to its report and STATUS.md (analyze already owns
  STATUS.md); `/ardd-lint`'s skill prose mentions the check exists but
  lint-project.sh itself stays offline-pure (no cross-repo reads in
  the validator). Prose edits only beyond T-B's script.

### Phase 3 — /ardd-update skill

- T-D New extension skill `skills/ardd-update/SKILL.md` (frontmatter:
  name/tier: extension/description): reads the source path from
  ardd-version.md (if missing/stale, asks the user for the checkout
  path and proceeds — the reinstall re-records it via T-A); runs
  `ardd-update-check.sh` and reports standing; offers — never assumes —
  `git -C <source> pull` when the source has a remote (never push, and
  skip the offer entirely on a dirty source tree: surface it instead);
  then runs `<source>/install.sh <target>` and relays its full output —
  migrations applied and suggestions (badge/gitignore) now reach the
  consumer's own session, closing the invisible-offer gap; terminal
  handoff to /ardd-analyze. Register in gen-skill-docs ORDER_extension,
  regenerate README/WORKFLOW tables (drift check green), lint-docs
  green (it validates skill-name references).
- T-E Doc alignment: guides/continuing.md's hygiene bullet says
  `/ardd-update` (instead of "re-run install.sh"); README's Install
  section gains one line on updating from inside a consumer. Doc-only.

## Complexity Tracking

| Deviation | Justification (Principle VI) |
|---|---|
| (none) | One recorded path, one comparison script, one skill that shells out to the existing installer |

## Open Questions

- [OPEN: T-A source-path line format — decided in-task; constraint:
  greppable single line, idempotent rewrite]
- [OPEN: T-B behavior when the source checkout has moved (recorded
  path exists but isn't the ARDD repo) — likely `source-missing` with
  a distinct reason; decide in-task]

## Production Annotation Summary

- None anticipated. (v1's no-network limitation is documented Scope,
  not a shortcut.)
