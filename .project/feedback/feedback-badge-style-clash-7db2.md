---
status: open      # open -> planned
created: 2026-07-21
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## UX
- [ ] F001 The dynamic version badge offered by `/ardd-update` (the
  `ardd-badge-version-start` snippet) currently renders only via the
  classic shields.io endpoint style — a default the user has since
  reconsidered. The ArDD repo itself uses shieldcn.dev badges, and in a
  README that already uses shieldcn (observed in yet-another-rank-games:
  a shieldcn sponsor badge with `variant=secondary&theme=pink` sits
  directly below the ArDD badge) the two visual languages clash — flat
  shields.io square next to shieldcn's rounded/themed look. The decision
  now recorded in the register entry `badge-style-variant-option` flips
  the default: shieldcn becomes the primary badge offer, with shields.io
  offered as the fallback when pre-existing shields.io badges are
  detected in the consuming README. Until that feature ships, an interim
  caveat in the current offer text (skills/ardd-update SKILL badge-offer
  text and/or `templates/badge.md`) — noting the badge is
  shields.io-styled and may clash with shieldcn-based badges — may still
  be worth adding, but the main point is the default-flip decision, not
  the caveat.
