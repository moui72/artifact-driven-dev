---
status: open      # open -> planned
created: 2026-07-21
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## UX
- [ ] F001 The dynamic version badge offered by `/ardd-update` (the
  `ardd-badge-version-start` snippet) renders via the classic shields.io
  endpoint style; in a README that already uses shieldcn.dev badges
  (observed in yet-another-rank-games: a shieldcn sponsor badge with
  `variant=secondary&theme=pink` sits directly below it) the two visual
  languages clash — flat shields.io square next to shieldcn's
  rounded/themed look. Until the style/variant option ships (re-filed to
  the register as `badge-style-variant-option`), document the caveat in
  the badge offer itself: the offer prompt (skills/ardd-update SKILL
  badge-offer text and/or `templates/badge.md`) should state the badge
  is shields.io-styled and may visually clash with shieldcn-based
  badges, so users can decide before adopting.
