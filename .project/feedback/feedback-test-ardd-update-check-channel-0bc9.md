---
status: planned
created: 2026-07-23
plan: plan-chore-feedback-status-readines-2026-07-23-659e.md
---

# Feedback

## Bugs
- [x] F001 `scripts/test-ardd-update-check.sh`'s "install.sh records Channel: stable by default" assertion (~line 238) is silently order/timing-dependent, not a stable channel-inference bug. It runs `install.sh` directly against this repo's own checkout and expects the SOURCE_REF-inference fallback to land on `stable`. But `beta-release.yml` tags every push to `main`, so that assumption only holds in the brief window before the beta tag lands — `lint.yml` checks out before `beta-release.yml` has a chance to tag, so CI stays green, but a local re-run after tags catch up fails deterministically (observed: reported `beta` instead of `stable`). Not a functional bug in `install.sh` itself — real installs always go through `new.sh`, which explicitly sets `$ARDD_CHANNEL` and never hits this fallback path. Fix should stop the test from relying on this repo's live tag state for that assertion (e.g. pin/mock the reachable tags instead of using the real checkout).
