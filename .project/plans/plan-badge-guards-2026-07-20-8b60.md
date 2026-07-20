---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: badge-guards
created: 2026-07-20
features: []
surfaced-defects: []
---

# Plan: Badge guards — marker-family awareness

## Goal

Make install.sh's two badge guards recognize all three marker families
(`ardd-badge-start`, `ardd-badge-version-start`, `ardd-badge-pair-start`)
as "already badged" — naming which form was found — and make the
no-README pointer acknowledge an already-set `ARDD_VERSION_BADGE=1`.

## Scope

**In:** the two guard fixes and the pointer wording (S9 findings
F001–F003, feedback `b8b6`), extended red-first cases in
`scripts/test-install-version-badge.sh`, and the `/scenario-sweep S9`
regression rerun as the closing validation.

**Out:** any badge template/JSON/workflow change (all just shipped and
S9-verified); any new marker family or consolidation of the three.

## Technical Approach

One shared helper shape inside install.sh's badge section: detect which
marker family (if any) the README carries, then both guards branch on
"any family present" instead of their single hardcoded marker —
- env-unset static-suggestion path (~line 588): any family present →
  suppress the static suggestion; print a one-line acknowledgment
  naming the found form instead (matters doubly because `/ardd-update`
  runs install.sh env-unset and relays verbatim).
- `ARDD_VERSION_BADGE=1` snippet path (~line 555): `version` markers →
  current behavior (no reprint, files-exist notices); `pair` or
  `static` markers → still write/refresh supporting files as designed,
  but replace the full paste-block with a short "already badged via
  <form> markers" note pointing at `templates/badge.md`'s shapes for
  anyone wanting to switch — never duplication-inviting output.
- no-README pointer: branch on `ARDD_VERSION_BADGE` being set — "flag
  is set; create a README and re-run" vs. today's wording.

Test-first (constitution's deterministic-gates paradigm as this repo
practices it): new `test-install-version-badge.sh` cases go red against
current behavior before the fix lands. Closing validation is the
change-triggered scenario doing its job: `/scenario-sweep S9` rerun
re-verifying F001–F003 live (run after tasks complete — release-ops
style note, not a task an agent executes inside the tasks file).

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

**Phase 1 — Red tests.**
- Extend `test-install-version-badge.sh`: env-unset over a
  version-badged README (no static re-suggestion), env-set over a
  pair-badged README (no full paste block; acknowledgment names the
  form), env-set no-README pointer acknowledges the flag. Confirm red.

**Phase 2 — Fix (after Phase 1).**
- Marker-family detection + both guard branches + pointer wording in
  install.sh's badge section; suite green.

## Open Questions

- None. (Post-merge: rerun `/scenario-sweep S9` as the regression gate
  before the next stable dispatch.)
