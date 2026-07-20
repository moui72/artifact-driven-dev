---
status: planned
created: 2026-07-19
plan: plan-dynamic-badge-discoverability-2026-07-19-23cf.md
---

# Feedback

## Bugs
- [x] F001 The ARDD_VERSION_BADGE dynamic-badge feature is undiscoverable: the env-var opt-in is documented nowhere (no mentions in skills/, docs/, README.md, or USAGE.md) and /ardd-update never offers it. Observed in the field: a consuming agent asked to add a version badge hand-rolled a shields.io github/v/release badge — the exact "runs ahead silently" shape the feature was built to prevent — because no visible path led to the endpoint-badge option.
- [x] F002 The printed two-badge snippet (install.sh ARDD_VERSION_BADGE=1 branch) contains literal OWNER/REPO/BRANCH placeholders in the endpoint URL; the explanatory HTML comment telling the reader to replace them sits outside the marker-to-marker block and is never printed. Pasted verbatim, the badge renders "invalid". install.sh can fill these from the target's git remote + branch-info.sh.
- [x] F003 The ARDD_VERSION_BADGE=1 branch reprints the paste-this-snippet suggestion on every run even when the README already contains the markers — the grep guard exists only in the static-badge elif branch.

## UX
- [x] F004 A wrong hand-rolled badge wrapped in ardd-badge-start/end markers (as the observed consuming agent did) permanently suppresses install.sh's static-badge suggestion, so nothing ever corrects the badge inside the markers.
- [x] F005 Nothing warns that the shields.io endpoint badge cannot work for private repos (shields fetches raw.githubusercontent.com unauthenticated) — a private consuming repo gets a badge that can never render.

## Reconsidered
- [x] F006 The env-var gate (ARDD_VERSION_BADGE=1) may be the wrong interface entirely for an agent-mediated workflow — the option needs to be visible in skill prose (/ardd-update, /ardd-init) or in install.sh's default output, not only in a shell environment variable nobody is told about.
