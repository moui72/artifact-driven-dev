---
plan: plan-badge-style-variant-option-2026-07-21-982c.md
generated: 2026-07-21
status: in-progress
---

# Tasks

## Phase 1: shieldcn template
- [x] T001 Create `templates/badge-shieldcn.md` mirroring `templates/badge.md`'s
  three shapes (static, split-version, pair) using shieldcn.dev URLs
  instead of shields.io: static form
  `https://shieldcn.dev/badge/built%20with-ArDD-<labelColor>.svg` (mirror
  this repo's own sponsor badge, `README.md:13`); split-version and pair
  forms use a shieldcn `dynamic/json` endpoint reading `$.message` from
  `.github/badges/ardd-version.json` with `label`/`color` supplied as URL
  query params (dynamic/json can't read them live from the JSON — same gap
  `templates/badge.md`'s existing "Dynamic-JSON readers" renderer-caveat
  note documents) and a pre-encoded base64 `logo` query param built from
  `templates/ardd-icon.svg` via `base64 < templates/ardd-icon.svg`. Use the
  same `<!-- ardd-badge-start/-end -->`, `<!-- ardd-badge-version-start/-end -->`,
  and `<!-- ardd-badge-pair-start/-end -->` marker family as
  `templates/badge.md` so existing marker-family detection in `install.sh`
  needs no change. Default every snippet's `variant`/`theme` query params to
  plain values. Header comment: cross-reference `templates/badge.md` for
  renderer-caveat background, state the default(shieldcn)/fallback(shields.io)
  selection rule, and invite consumers on other badge systems to submit new
  template designs upstream to the ArDD repo.

- [x] T002 [parallel] Update `templates/badge.md`'s header comment to note the
  new shieldcn alternative at `templates/badge-shieldcn.md` and state that
  shieldcn is now the default offer, shields.io the fallback when the
  target README already carries non-ArDD shields.io badges.

## Phase 2: install.sh detection + offer selection
- [ ] T003 In `install.sh`, add an `EXISTING_SHIELDS_IO` detection
  (`true`/`false`) near the existing `BADGE_FAMILY` detection block
  (install.sh:681-696): grep the target README for `img.shields.io`
  outside ArDD's own `<!-- ardd-badge*-start -->`/`<!-- ardd-badge*-end -->`
  marker blocks (strip any lines between those markers before grepping, so
  ArDD's own shields.io-rendered badges never count as "existing"), and set
  `EXISTING_SHIELDS_IO=true` if any match remains.

- [ ] T004 At the `ARDD_VERSION_BADGE=1` print site (install.sh:819-833),
  select the snippet source by `EXISTING_SHIELDS_IO`:
  `EXISTING_SHIELDS_IO=true` → `templates/badge.md` (today's behavior,
  unchanged); otherwise → `templates/badge-shieldcn.md`. Adjust the printed
  advisory text to name which style was offered and why
  (shields.io-detected vs. shieldcn default), and add a one-line invitation
  for the agent to hand-adapt the offered snippet's `variant`/`theme` query
  params to match whatever badge styling is visible in the target README
  (e.g. `variant=secondary&theme=pink`) rather than pasting the shipped
  defaults unexamined. Depends on: T001, T003.

- [ ] T005 [parallel] At the static-only print site (install.sh:849-853),
  apply the same `EXISTING_SHIELDS_IO` selection rule and advisory-text
  adjustment as T004, for the static badge shape only. Depends on: T001, T003.

## Phase 3: docs
- [ ] T006 Update `docs/reference/configuration.md`'s badge section
  (currently states the shields.io endpoint form and brand colour) to
  state shieldcn.dev is now the default install-time badge offer, with
  shields.io offered as the fallback when the target README already
  carries non-ArDD shields.io badges. Add the "submit new template designs
  upstream" pointer alongside it. Depends on: T004, T005.

## Phase 4: regression coverage
- [ ] T007 Extend `scripts/test-install-version-badge.sh`
  with a case: on a target README with no existing shields.io badges,
  `install.sh`'s printed snippet (both the `ARDD_VERSION_BADGE=1` path and
  the static-only path) comes from `templates/badge-shieldcn.md` (assert on
  a shieldcn.dev-specific URL fragment, e.g. `shieldcn.dev/badge`, appearing
  in the captured install output). Depends on: T004, T005.

- [ ] T008 [parallel] Extend `scripts/test-install-version-badge.sh` with a
  case: on a target README pre-seeded with a non-ArDD
  `img.shields.io`-based badge outside any ArDD marker block, `install.sh`'s
  printed snippet still comes from `templates/badge.md` (assert the
  shields.io endpoint URL shape appears, and that `shieldcn.dev` does not).
  Depends on: T004, T005.

- [ ] T009 [parallel] Extend `scripts/test-install-version-badge.sh` with a
  case: the split-version shieldcn snippet's composed URL is well-formed
  (query params present: `url`, a query selector for `$.message`, `label`,
  `color`, and a base64-encoded `logo` value) when run against a target
  with `ARDD_VERSION_BADGE=1` set and no existing shields.io badges.
  Depends on: T004.

## Phase 0: interim caveat (independent of the phases above; ships on its own)
- [ ] T010 [feedback: feedback-badge-style-clash-7db2.md#F001] [parallel]
  Add an interim caveat, in the *current* (pre-shieldcn-default) offer
  text — `skills/ardd-update/SKILL.md`'s badge-offer relay step and/or
  `templates/badge.md`'s printed snippet advisory — noting the offered
  badge is shields.io-styled and may visually clash with a README that
  already uses shieldcn-based badges (rounded/themed look vs. flat
  shields.io square). This is a stopgap: land it independent of Phases
  1-4 above, since it should ship even before the shieldcn-default work
  lands, and stays true (harmlessly redundant) after it does too.
