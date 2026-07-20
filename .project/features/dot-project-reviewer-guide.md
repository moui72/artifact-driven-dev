---
slug: dot-project-reviewer-guide
status: backlogged
logged: 2026-07-20
---

A short 'how to read .project/' orientation note installed into consumer repos (or linked from ardd-version.md) that downstream AI reviewer configs (CodeRabbit etc.) can be pointed at — explaining which files are generated vs authored, which look live but are static historical records, and the single-writer/disposable-report conventions — so .project/ artifacts stop producing false-positive review noise on consumer PRs. Motivated by CodeRabbit findings on moui72/assisted-review#105.
