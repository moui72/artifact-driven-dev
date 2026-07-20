---
status: planned      # open -> planned
created: 2026-07-20
plan: plan-badge-guards-2026-07-20-8b60.md
---

# Feedback

From `/scenario-sweep S9` run `2026-07-20-4f1a` (badge matrix, first
run — overall PASS; full report
`dev-notes/scenario-runs/2026-07-20-4f1a/S9-report.md`). Common root of
F001/F002: install.sh's two badge guards should each treat any of the
three marker families (`ardd-badge-start`, `ardd-badge-version-start`,
`ardd-badge-pair-start`) as "already badged" and say which form was
found.

## UX
- [x] F001 install.sh's static-suggestion guard (the badge section's
  env-unset path, ~line 588) greps only `ardd-badge-start`, which does
  not match `ardd-badge-version-start` — so every env-unset install,
  including every `/ardd-update` (which runs install.sh env-unset and
  relays output verbatim), re-suggests the static badge to a repo
  already carrying the correct dynamic version badge, inviting a
  duplicate paste.
- [x] F002 install.sh's version-snippet reprint guard
  (`ARDD_VERSION_BADGE=1` path, ~line 555) greps only
  `ardd-badge-version-start` — a pair-badged repo
  (`ardd-badge-pair-start` markers) gets the full "paste this snippet"
  block with no acknowledgment it is already badged.
- [x] F003 Minor: on a README-less repo with `ARDD_VERSION_BADGE=1`
  already set, the no-README pointer says "re-run with
  `ARDD_VERSION_BADGE=1`" without acknowledging the flag is already
  set — reads as if the flag was ignored. Branch the message on the env
  var being present.

Regression validation for the fixes: extend
`scripts/test-install-version-badge.sh` cases (cross-marker-family
guard behavior), then rerun `/scenario-sweep S9`.
