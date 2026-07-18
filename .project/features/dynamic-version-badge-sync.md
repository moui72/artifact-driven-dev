---
slug: dynamic-version-badge-sync
status: tasked
logged: 2026-07-18
plan: plan-dynamic-version-badge-sync-2026-07-18-35aa.md
tasks: tasks-dynamic-version-badge-sync-4553.md
---

install.sh (or a migration) offers to install a dynamic 'ArDD version' README badge for a target project: a shields.io endpoint-badge JSON file + a GitHub Action that watches .project/ardd-version.md (or fires off /ardd-update's own commit) and regenerates the JSON with the current Source-Ref, plus a two-badge README snippet (static 'built with ArDD' + dynamic version badge) replacing the current single static-only badge suggestion.
Why: the existing badge suggestion (templates/badge.md, offered by install.sh) is static with no version in it, and structurally can't have one — the template is copied verbatim to every target with no way to know that project's installed version at suggestion time. A consumer (assisted-review) already hand-built this exact plumbing (.github/badges/ardd-version.json + .github/workflows/ardd-badge.yml) from scratch; every other target project reinventing it is the signal this should be an ArDD-provided capability instead. Open question carried into design: should the sync workflow fire directly off /ardd-update's commit instead of (or in addition to) watching ardd-version.md via a separate Action, to remove the extra CI hop for projects that run /ardd-update locally and push.
