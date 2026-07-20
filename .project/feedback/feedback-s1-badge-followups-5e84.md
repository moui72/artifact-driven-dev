---
status: open      # open -> planned
created: 2026-07-20
plan: null
---

# Feedback

Source: scenario-sweep run 2026-07-20-a7d7 (targeted S1, first exercise
of the new badge brief steps, against v1.0.2-beta.1). Both accepted at
triage; graduation n-a — the surface already has standing brief
coverage (S1 steps 6-9 are what caught these).

## UX
- [ ] F001 install.sh's default-path mention of the ARDD_VERSION_BADGE=1 opt-in is gated on `[ -f README.md ]`, so a greenfield new.sh project (which has no README yet) never learns the feature exists — the same discoverability failure class the dynamic-badge-discoverability plan just fixed, one gap over. Print the opt-in pointer (or an equivalent hint) even when no README exists, or have new.sh/init surface it.
- [ ] F002 The misdirected-badge advisory (README carries a github/v/release badge inside ardd-badge markers) tells the user to re-run with ARDD_VERSION_BADGE=1 — but with markers already present that re-run prints no snippet (the reprint guard), making the suggested remedy circular. The advisory should instead tell the user to replace the badge inside the markers with the endpoint snippet (and where to get it), or the ARDD_VERSION_BADGE=1 path should reprint the snippet when the advisory fires.
