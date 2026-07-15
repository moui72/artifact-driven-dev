---
slug: epics-grouping-in-feature-regi
status: backlogged
logged: 2026-07-15
---

Epics: declared, semantic, durable grouping at the register level for bundling clearly related work into release-cadence-sized chunks. Minimal version: an optional epic: frontmatter slug on feature files (lint-project.sh enum/schema updated in the same commit), /ardd-plan's pick list groups by it and can offer 'plan this epic' as a session-sized unit, /ardd-status counts by it, /ardd-tracker maps it to GitHub milestones or labels. Deliberately stops short of epic files with their own lifecycle (a second register to keep consistent) until flat-slug grouping proves insufficient. Distinct from the computed/ephemeral 'defrag' footprint analysis (separate, pending research prototype in sync-tab-scroll).
