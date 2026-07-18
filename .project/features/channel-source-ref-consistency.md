---
slug: channel-source-ref-consistency
status: tasked
logged: 2026-07-17
plan: plan-channel-source-ref-consistency-2026-07-18-461b.md
tasks: tasks-channel-source-ref-consistency-824e.md
---

Validate that a project's ardd-version.md Channel: and Source-Ref: fields are mutually consistent (e.g. flag a Channel: stable paired with a beta prerelease tag as Source-Ref:). Why: found in a real consumer's committed history (atelier, 2026-07-15) with nothing in /ardd-status, /ardd-lint, or ardd-update-check.sh currently detecting the mismatch — discovered during the 2026-07-17 prerelease smoke sweep (S7-F002).
