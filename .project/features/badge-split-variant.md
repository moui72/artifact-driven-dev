---
slug: badge-split-variant
status: backlogged
logged: 2026-07-20
---

A third templates/badge.md shape: a single split badge — 'built with ArDD │ vX.Y.Z' — fed by the existing .github/badges/ardd-version.json (sync workflow unchanged; only the README snippet differs); consider making it the default, keeping the two-badge pair for those who want the marks separated. Why: adopting the pair in moui72/assisted-review (PRs #107/#108) showed it is one idea rendered as two images with drifting styles (branded next to secondary). Related: badge-brand-color-in-json, badge-icon-logosvg — all three ride the same generated JSON.
