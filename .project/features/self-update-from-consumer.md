---
slug: self-update-from-consumer
status: tasked
logged: 2026-07-06
plan: plan-self-update-from-consumer-2026-07-06.md
tasks: tasks-self-update-from-consumer-0399.md
---

From inside a consuming repo, update ARDD without knowing the source checkout's path (e.g. an /ardd-update skill or installed script that finds/pulls the source and re-runs install.sh), and get notified when installed skills are behind the source (e.g. /ardd-analyze or lint comparing .project/ardd-version.md against the source repo's tip).
Why: today updating requires remembering where artifact-driven-dev is cloned and running its install.sh by hand from there; consumers silently fall behind (both downstream repos were a full release behind before today's manual sweep).
