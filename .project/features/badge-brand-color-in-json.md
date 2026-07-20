---
slug: badge-brand-color-in-json
status: backlogged
logged: 2026-07-20
---

Publish a canonical ArDD brand colour (one hex, stated in the docs) and have the badge sync workflow write it into .github/badges/ardd-version.json as labelColor, keeping the channel signal in color — brand-on-left, status-on-right. Why: badge.md hardcodes blue and the workflow picks blue/yellow by channel, so every downstream repo invents its own answer; emitting it from the workflow propagates brand changes to every ArDD repo with no README edits (npm's #CB3837 precedent). From assisted-review PRs #107/#108. Related: badge-split-variant, badge-icon-logosvg.
