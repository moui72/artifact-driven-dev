---
slug: docs-sweep
status: tasked
logged: 2026-07-18
plan: plan-docs-sweep-2026-07-18-b6ef.md
tasks: tasks-docs-sweep-e6c1.md
---

A local-only, source-side-only skill (docs-sweep, never installed to consumers — same placement/pattern as prerelease-sweep) that judges whether human-facing documentation (README.md, USAGE.md, docs/concepts.md, docs/guides/*, docs/reference/skills/*.md hand-written bodies — everything that renders on the MkDocs docs site) is current and complete against each skill's actual current SKILL.md behavior, then triages findings to /ardd-feedback.
Why: reference-page headers are already kept in sync by gen-skill-docs.sh/lint-docs.sh --check, but nothing catches drift in hand-written prose bodies, USAGE.md's routing, or docs/concepts.md's mental model as new skill capabilities ship — e.g. epics (/ardd-status's by-epic breakdown, /ardd-tracker's milestone mapping) and /ardd-plan --slate are currently undocumented on the site. Run manually at release cadence, specifically before dispatching the stable-release workflow. See research-docs-freshness-human-facing-2026-07-18.md for the full investigation and concrete drift evidence.
