---
status: open      # open -> planned
created: 2026-07-20
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## UX
- [ ] F001 `templates/badge.md` implies the badge JSON drives the badge's
  appearance, which is only true for endpoint-style renderers. Document
  the distinction: shields.io's `/endpoint` consumes `label`, `message`,
  and `color` from `.github/badges/ardd-version.json`, but
  dynamic-JSON-style renderers (e.g. shieldcn's `dynamic/json`) read only
  the query-selected field — label and colour must be set in the URL, and
  the JSON's channel-aware colouring never shows. Found adopting the
  badge guidance in moui72/assisted-review (PRs #107/#108), where badges
  render through shieldcn to match the repo's badge row and the channel
  colouring silently never appears. A short renderer-caveat note in the
  template (near the snippet) resolves the wrong implication.
