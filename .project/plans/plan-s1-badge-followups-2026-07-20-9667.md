---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: s1-badge-followups
created: 2026-07-20
features: []
surfaced-defects: []
---

# Plan: s1-badge-followups

## Goal

Close the two badge-output gaps the targeted S1 sweep found: the
`ARDD_VERSION_BADGE=1` opt-in mention must reach projects with no README
yet, and the misdirected-badge advisory must give a remedy that actually
works when markers are already present.

## Scope

**In scope** (consumes `feedback-s1-badge-followups-5e84.md`, both
items accepted):
- F001 — the default-path opt-in mention currently lives inside the
  `[ -f "$TARGET/README.md" ]`-gated static-badge suggestion, so a
  greenfield `new.sh` project (no README yet) never sees it. Fix: print
  the one-line opt-in pointer in the no-README case too (a pointer
  line, never the snippet — there's no README to paste into yet), e.g.
  "once this project has a README, re-run with ARDD_VERSION_BADGE=1 for
  a version badge".
- F002 — the misdirected-badge advisory tells the user to re-run with
  `ARDD_VERSION_BADGE=1`, but with markers present the reprint guard
  makes that re-run print nothing. Fix: make the advisory
  self-sufficient — state that the badge inside the
  `ardd-badge-version-start` markers should be replaced with the
  endpoint snippet, and where that snippet comes from (the seed JSON /
  `.github/badges/ardd-version.json` endpoint form). Keep the reprint
  guard itself unchanged (it's correct); only the advisory's remedy
  text changes.

**Out of scope:**
- Having `new.sh` or `/ardd-init` surface the badge opt-in themselves
  (a bigger interface question; the printed pointer covers the gap the
  sweep observed).
- Any change to snippet generation, coordinate fill, or the reprint
  guard logic — all verified working by the same sweep.

## Technical Approach

Both are output-text changes in install.sh's badge section, with
red-first cases added to `scripts/test-install-version-badge.sh` (the
existing harness already has fixtures for no-README and
markers-present paths). F001 adds a small `else`/no-README branch (or
un-gates the pointer line) — take care to keep the existing README
paths byte-stable except where the tests assert the new lines. F002
rewrites the advisory string only. POSIX sh throughout.

## Phase Breakdown

**Phase 1 — test-first** (no dependencies)
1. Red cases: (a) no-README target, env unset → output contains the
   opt-in pointer; (b) markers-present + misdirected badge → advisory
   text names the replace-inside-markers remedy and does NOT instruct a
   bare `ARDD_VERSION_BADGE=1` re-run as the sole remedy. Confirm red.

**Phase 2 — implement** (depends on Phase 1)
2. install.sh: no-README opt-in pointer (F001) + rewritten advisory
   remedy text (F002); full badge test green.

## Open Questions

- None — both fixes are narrow output-text changes with the remedy
  shapes settled at triage.
