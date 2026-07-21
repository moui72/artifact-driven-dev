---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: badge-style-variant-option       # the branch inline implementation would use; may never be created (see step 1)
created: 2026-07-21
features: [badge-style-variant-option]
surfaced-defects: []
---

# Plan: badge-style-variant-option

## Goal

Make shieldcn.dev the default install-time badge style offer (matching
this repo's own README badge language), falling back to the existing
shields.io endpoint style when the target repo's README already carries
shields.io-styled badges, so a consumer's generated ArDD badge always
matches the visual language already present in their README.

## Scope

**In scope:**
- A new shieldcn-styled badge template (static, split-version, and pair
  shapes, mirroring `templates/badge.md`'s three shapes) shipped under
  `templates/`.
- Detection logic in `install.sh`: does the target README already contain
  non-ArDD `img.shields.io` badges? If so, offer the shields.io snippet
  (today's behavior); otherwise offer the new shieldcn snippet by default.
- Advisory text (both the ARDD_VERSION_BADGE=1 path and the static-only
  path) naming the detected style and, per the feature's request, giving
  the agent explicit leeway to hand-adapt the offered snippet's
  `variant`/`theme` query params to match whatever badge styling is
  actually visible in the target README, rather than always pasting the
  shipped defaults verbatim.
- Doc updates: `templates/badge.md`'s header comment gains a pointer to
  the new shieldcn template and the default/fallback rule;
  `docs/reference/configuration.md`'s badge section states the new
  default.
- A pointer, in both the new template's header and the offer text, inviting
  consumers on other badge systems to submit new template designs upstream.

**Out of scope:**
- Changing what data the seed JSON (`.github/badges/ardd-version.json`)
  carries — it already carries everything a shieldcn `dynamic/json` badge
  needs (message, color, labelColor, logoSvg); this plan only changes
  which *renderer URL* gets offered and how it's built.
- Any change to the badge sync workflow (`.github/workflows/ardd-badge.yml`
  / `templates/ardd-badge-workflow.yml`) — it writes the JSON only, not a
  renderer-specific URL.
- Retrofitting already-installed consumer repos — this only changes what
  a future `install.sh` run offers.

## Technical Approach

`install.sh` already computes `BADGE_FAMILY` (which `ardd-badge-*` marker
family, if any, the target README carries — install.sh:681-696) and prints
snippets sourced from `templates/badge.md` at two sites: the
`ARDD_VERSION_BADGE=1` path (install.sh:819-833, prints the
`ardd-badge-version-start` block) and the static-only path
(install.sh:849-853, prints the `ardd-badge-start` block). Neither site
currently looks at the README's *non-ArDD* badge styling — only at whether
an ArDD marker is already present.

Add one more piece of detection, independent of `BADGE_FAMILY`: whether
the README contains any `img.shields.io` badge reference outside ArDD's
own markers (reuse the existing marker-bounded grep pattern shape at
install.sh:689-696 to exclude ArDD's own snippet from the check, then grep
the remainder for `img.shields.io`). Call this `EXISTING_SHIELDS_IO`
(`true`/`false`).

Selection rule, applied at both print sites:
- `EXISTING_SHIELDS_IO=true` → offer the shields.io snippet from
  `templates/badge.md` (today's behavior, unchanged).
- otherwise (including `false`, and including a bare README with no
  badges at all) → offer the new shieldcn snippet from
  `templates/badge-shieldcn.md`.

Both templates carry the same three shapes (static / split-version /
pair) and the same `<!-- ardd-badge*-start/-end -->` marker family, so the
existing marker-detection logic (`BADGE_FAMILY`) needs no change — a
consumer's README stays taggable regardless of which renderer style
produced the markers inside it.

New template `templates/badge-shieldcn.md` mirrors `templates/badge.md`'s
structure:
- **Static**: `https://shieldcn.dev/badge/built%20with-ArDD-<labelColor>.svg`
  (mirrors this repo's own sponsor badge shape, README.md:13).
- **Split-version**: a shieldcn `dynamic/json` endpoint reading `$.message`
  from `.github/badges/ardd-version.json`, with `label`, `color` (from the
  JSON's channel-aware `color` field, since dynamic/json can't read it
  live — this plan's renderer caveat already documents that gap per
  `templates/badge.md`'s existing "Dynamic-JSON readers" note), and the
  pre-encoded base64 `logo` query param built from
  `templates/ardd-icon.svg` (same recipe `templates/badge.md` already
  documents: `base64 < templates/ardd-icon.svg`).
- **Pair**: static shieldcn badge + shieldcn `dynamic/json` version badge,
  same shape as `templates/badge.md`'s pair variant.

Every shieldcn snippet carries `variant`/`theme` query params defaulted to
plain values, with a one-line install-time advisory (not a script — this
is judgment, not mechanizable) inviting the agent to match whatever
`variant`/`theme` the target README's own badges already use (the
feature's `variant=secondary&theme=pink` example) rather than pasting the
shipped defaults unexamined.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

**Phase 1: shieldcn template**
Depends on: none.
- Write `templates/badge-shieldcn.md` with the three shapes described
  above, marker families identical to `templates/badge.md`, and a header
  comment cross-referencing `templates/badge.md` for the renderer-caveat
  background and stating the default/fallback selection rule.
- Update `templates/badge.md`'s own header comment to note the shieldcn
  alternative and point at the new file.

**Phase 2: install.sh detection + offer selection**
Depends on: Phase 1 (needs the new template file to point at).
- Add the `EXISTING_SHIELDS_IO` detection (marker-excluded grep for
  `img.shields.io`) near the existing `BADGE_FAMILY` detection block
  (install.sh:681-696).
- At both print sites (install.sh:819-833 and :849-853), select
  `templates/badge-shieldcn.md` or `templates/badge.md` per the rule above,
  and adjust the printed advisory text to name which style was offered and
  why (existing-shields.io-detected vs. default), plus the
  variant/theme-matching invitation.
- Ship the pre-encoded base64 icon needed for the shieldcn split-version
  snippet the same way the shields.io endpoint form's logo guidance already
  documents it (no new mechanism — reuse the existing recipe).

**Phase 3: docs**
Depends on: Phase 2.
- Update `docs/reference/configuration.md`'s badge section to state
  shieldcn is now the default offer, shields.io the detected-fallback.
- Add the "submit new template designs upstream" pointer to both the new
  template's header and `docs/reference/configuration.md`.

**Phase 4: regression coverage**
Depends on: Phase 2.
- Extend `scripts/test-install-version-badge.sh` with cases covering:
  default shieldcn offer on a README with no existing shields.io badges;
  shields.io fallback offer on a README carrying a non-ArDD
  `img.shields.io` badge; the split-version shieldcn snippet composing a
  valid URL with the base64 logo query param.

## Complexity Tracking

| Deviation | Why needed | Simpler alternative rejected because |
|---|---|---|
| New detection branch (`EXISTING_SHIELDS_IO`) alongside existing `BADGE_FAMILY` detection | Feature explicitly requires matching the target's existing visual language, not just always defaulting to one style | Always offering shieldcn (no detection) would reintroduce the exact clash this feature was filed to fix for repos that already standardized on shields.io |

## Open Questions

- Exact shieldcn.dev `dynamic/json` query-string syntax (parameter names
  for `url`, `query`, `label`, `color`, `logo`) should be verified against
  shieldcn.dev's own docs/source during Phase 1 — this plan grounds the
  static-badge shape in this repo's own working example
  (`README.md:13`) but the dynamic/json shape is inferred from the
  shields.io analog documented in `templates/badge.md`'s existing
  renderer caveat, not independently verified against shieldcn.dev.
- Whether `EXISTING_SHIELDS_IO` detection should also treat a
  pre-existing *shieldcn* badge elsewhere in the README as a positive
  signal to prefer shieldcn even more strongly (currently: shieldcn is
  already the default, so this only matters for the inverse — no action
  needed unless review surfaces a reason to special-case it).
