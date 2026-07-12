---
slug: remote-install-source
status: tasked
logged: 2026-07-12
plan: plan-remote-install-source-2026-07-12.md
tasks: tasks-remote-install-source-18d3.md
---

install.sh and /ardd-update install from GitHub — defaulting to the latest tagged GitHub release (with tip-of-main and an explicit --source/--dev local-checkout escape hatch for dogfooding) — instead of reading a live local checkout, with a release-cutting process (gh release + semver tag) added to this repo so consumers pin stable versions.
Why: consumers reading a live local checkout is the root cause of the primary-stays-on-main mandate (v1.4.0) and the ref-lock collision — remote-by-default makes push/release the deliberate release act and lets that mandate be retired (Principle VII) via constitution amendment once no consumer reads the dev checkout live; releases make 'a version behind' well-defined for ardd-update-check and give stability guarantees tip-of-main can't; ~/.ardd/source already provides the fetch-cache mechanism; Source-Path pointing at a dev checkout becomes a smell.
