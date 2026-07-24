---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: fix-badge-icon-monochrome
created: 2026-07-24
features: []
surfaced-defects: []
---

# Plan: badge correctness — consumer audit fixes (F001–F008)

## Goal

Make the badge pipeline honest end to end: installs/updates refresh or report drifted badge assets, record channel-correct Source-Refs, offer only what install.sh can deliver, detect orphaned flips even after branch deletion, and ship templates whose colors, icons, and caveats match what the renderers actually do.

## Scope

**In:** the eight accepted items of
`feedback-badge-audit-assisted-review-ff0b.md` — install.sh badge-asset
refresh/drift-report (F001), template/workflow brand-color consistency
(F002), channel-aware Source-Ref tag selection (F003),
`completion-flip-check.sh` missing-ref reporting (F004), aligning
`/ardd-update`'s badge offer with install.sh's guard (F005), the shieldcn
data-URI caveat rewrite + real base64 icon (F006), documenting the inert
`mode=` param (F007), and resolving the inert per-channel color (F008).

**Out:** any redesign of the badge mark itself (landed earlier on this
branch), the shields.io template's overall structure, and any new badge
variants. No new constitution principles.

## Technical Approach

- **F003 (highest blast radius):** in install.sh's `ALL_REFS_AT_HEAD`
  block, replace the channel-blind non-beta preference + plain `sort -V`
  with: filter tags to the channel being recorded (beta channel admits
  prereleases; stable admits only strict `vX.Y.Z`), then pick the highest
  under `versionsort.suffix=-beta.` ordering — the same convention
  `next-version.sh`/`source-resolve.sh` pin. Extend the existing
  install-channel regression test with the dual-tag case (v1.2.0 +
  v1.2.1-beta.1 at HEAD, Channel: beta → records the beta tag).
- **F004:** `completion-flip-check.sh` distinguishes "ref missing" from
  "not merged": when the resolved branch doesn't exist, emit an explicit
  `branch-missing` line naming the branch and still-`tasked` slugs
  (loud, never exit-0-silent). Test case added to
  `test-completion-flip-check.sh` (deleted-branch fixture). Per
  Principle VI we do not chase squash-merge-commit archaeology — the
  loud report is the fix; the user confirms the flip via `/ardd-status`
  as today.
- **F001:** install.sh treats `.github/badges/ardd-icon.svg` as a
  *managed* asset: when it exists but differs from the current template,
  refresh it in place and say so (it is declared verbatim-inlined source
  of truth; consumer customization is not supported for it). The badge
  *workflow* file stays never-clobber but gains a drift *report* line
  ("differs from current template — review manually"). Covered by a new
  fixture case in the install badge tests.
- **F005:** make `/ardd-update`'s step-4 offer test the same condition as
  install.sh's `BADGE_FAMILY` guard (README classified static blocks the
  version-badge emit): the skill checks for *any* ArDD badge marker
  family the guard would refuse, not just `ardd-badge-version-start`.
  Prose-only edit to `skills/ardd-update/SKILL.md`, mirroring the guard's
  documented priority order.
- **F002 + F006 + F007 (template truth):** `templates/badge-shieldcn.md` —
  swap `color=7C3AED` → the brand `2F4858` (matching
  `ardd-badge-workflow.yml`/`ardd-badge.json`), rewrite the two stale
  caveats to the 2026-07-24 verification (data-URI logos render;
  satori drops strokes/transforms/per-element fills → monochrome
  filled-path icons only), replace `PLACEHOLDER` with the real base64 of
  `templates/ardd-icon.svg` (regeneration command documented alongside),
  and add the one-line `mode=` note (byte-identical output; don't wrap in
  `<picture>` theme markup). `lint-docs.sh` must stay green.
- **F008:** keep shieldcn as the default offer but document the manual
  mirroring honestly: the workflow's computed JSON color is consumed by
  shields.io `/endpoint` renders only; the shieldcn snippets carry the
  color as a static URL param, so the template states that channel-color
  changes require editing the URL (or using the shields.io form). No new
  mechanism (Principle VI) — documentation resolves the "silently does
  nothing" half; the computed JSON color stays, since the shields.io
  fallback template consumes it.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

- **Phase 1 — Source-Ref channel correctness (F003).** Fix the tag
  selection in install.sh; extend the channel regression test with the
  dual-tag beta case. Independent of everything else; first because it
  publishes wrong version strings today.
- **Phase 2 — completion-flip-check missing-ref reporting (F004).**
  Loud `branch-missing` output + fixture test. Independent.
- **Phase 3 — install badge-asset refresh + offer alignment (F001,
  F005).** Managed-icon refresh, workflow drift report, and the
  `/ardd-update` guard alignment, with fixture coverage. Depends on
  Phase 1 only for clean sequencing in install.sh (same file), not
  logically.
- **Phase 4 — template truth (F002, F006, F007, F008).** The
  badge-shieldcn.md color/caveat/PLACEHOLDER/mode edits and the F008
  color-mirroring documentation; `lint-docs.sh` green. Independent of
  Phases 1–3.

## Complexity Tracking

No justified deviations — every fix is the simplest mechanism that
resolves its item (Principle VI is invoked twice above to *decline*
mechanism: no merge-commit archaeology in F004, no color-sync automation
in F008).

## Open Questions

- F001: is in-place refresh of a consumer's existing `ardd-icon.svg`
  acceptable, or should install.sh only report drift and require a flag
  (e.g. `ARDD_REFRESH_BADGES=1`) to overwrite? The plan assumes in-place
  refresh for the icon (declared source of truth) and report-only for the
  workflow; flip to report-only-for-both at approval if that feels too
  aggressive.
- F008: if shieldcn later adds a JSON-color read (as it did for data-URI
  logos), the mirroring note becomes stale — acceptable, same
  re-verify-then-update loop as F006.
