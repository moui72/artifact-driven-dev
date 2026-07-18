---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: channel-source-ref-consistency
created: 2026-07-18
features: [channel-source-ref-consistency]
surfaced-defects: []
---

# Plan: channel-source-ref-consistency

## Goal

Add a `lint-project.sh` check that flags a `.project/ardd-version.md`
whose `Channel:` and `Source-Ref:` fields are mutually inconsistent
(e.g. `Channel: stable` paired with a prerelease `Source-Ref:` tag),
closing the gap that let exactly this drift ship undetected in a real
consumer project.

## Scope

**In scope:**
- A new check in `scripts/lint-project.sh` that parses
  `.project/ardd-version.md`'s `Channel:` and `Source-Ref:` lines (when
  both are present — `Source-Ref:` is optional, per `install.sh`'s own
  "omitted when source HEAD isn't at a release tag" rule) and flags
  `Channel: stable` paired with a `Source-Ref:` matching the prerelease
  tag shape (`vX.Y.Z-beta.N` or similar `-` suffixed prerelease
  pattern) — the exact mismatch class the atelier consumer hit.
- Regression fixtures: extend `tests/fixtures/good-project` with a
  consistent `.project/ardd-version.md` (`Channel: stable` + a plain
  `vX.Y.Z` `Source-Ref:`, or no `Source-Ref:` at all) and
  `tests/fixtures/bad-project` with the atelier-shaped mismatch
  (`Channel: stable` + a `-beta.N` `Source-Ref:`), bumping
  `bad-project`'s expected finding count in
  `scripts/test-lint-project.sh` by one. Also a standalone temp-dir
  case (matching the existing targeted-message-quality case style) to
  assert the exact error wording.

**Out of scope:**
- `Channel: beta` paired with any `Source-Ref:` — a beta channel is
  legitimately expected to carry a prerelease tag; there's no
  inconsistency to flag there. Only `stable` + prerelease is a
  contradiction (a beta tag under a channel that's supposed to mean
  "strict releases only").
- `install.sh`'s own writing logic — it already writes `Channel:` and
  `Source-Ref:` correctly and consistently (confirmed by reading
  `install.sh:371-388`); the gap this plan closes is *detecting* a
  drift that predates or bypasses a normal `install.sh` write (e.g. the
  atelier case's file was committed from an earlier, separately-flagged
  session), not fixing a bug in the writer itself.
- Any change to `ardd-update-check.sh` — its `dev-ahead`/`behind`
  comparison logic already reads these fields correctly for its own
  purpose; this is a separate, static consistency check, not a
  comparison-logic change.

## Technical Approach

`.project/ardd-version.md` is plain key:value lines (`Source-Path:`,
`Source-Commit:`, optionally `Source-Ref:`, `Channel:`), not YAML
frontmatter — `lint-project.sh`'s existing `fm_field`-style frontmatter
helpers don't apply to it. The new check reads the file directly with
`sed`/`grep` (the same discipline `install.sh` and `ardd-update-check.sh`
already use to read this exact file), extracts `Channel:` and
`Source-Ref:` if both lines are present, and applies one rule:
`Channel: stable` + a `Source-Ref:` value matching a prerelease shape
(a `-` followed by an identifier after the `vX.Y.Z` core — reuse
whatever tag-shape recognition `scripts/next-version.sh` or
`source-resolve.sh` already codifies, rather than re-deriving a regex
from scratch, per Principle VIII) is a violation. This is a pure,
deterministic function of two lines of file content — squarely
mechanizable per Principle II.

## Phase Breakdown

### Phase 1: the lint-project.sh check (test-first)
- T001 (test-first) Add fixtures and a regression case to
  `scripts/test-lint-project.sh`: `tests/fixtures/good-project`'s
  `.project/ardd-version.md` gets a consistent `Channel: stable` +
  plain-tag `Source-Ref:`; `tests/fixtures/bad-project`'s gets the
  atelier-shaped mismatch (`Channel: stable` + a `-beta.N`
  `Source-Ref:`), bumping the fixture's expected total finding count by
  one; a standalone temp-dir case asserts the exact violation message
  names the file, both field values, and the nature of the mismatch.
  Confirm the new cases fail against current `lint-project.sh` first
  (red — no such check exists yet).
- T002 Add the `Channel:`/`Source-Ref:` consistency check to
  `scripts/lint-project.sh`, reusing existing tag-shape recognition
  (check `next-version.sh`/`source-resolve.sh` for a reusable pattern
  before writing a new one). T001's cases go green.

## Open Questions

- Whether `Source-Ref:` absent (the common "HEAD isn't at a tag" case)
  should ever be flagged against `Channel: stable` — leaning no, since
  `install.sh`'s own documented rule already treats that combination as
  normal (dev-mode-adjacent, not a drift), and the atelier finding was
  specifically about a *present* mismatched tag, not an absent one.
