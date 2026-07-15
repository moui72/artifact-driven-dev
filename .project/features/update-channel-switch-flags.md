---
slug: update-channel-switch-flags
status: implemented
logged: 2026-07-15
plan: plan-update-channel-switch-flags-2026-07-15-f22c.md
tasks: tasks-update-channel-switch-flags-c066.md
---

/ardd-update accepts --local, --beta, or --stable to switch the install to the latest from the named channel, overriding the recorded Channel: for that run (and re-recording it going forward).
Why: today the channel is fixed at install-record time (Channel: stable|beta, dev-mode via Source-Path); switching requires hand-editing ardd-version.md or reinstalling. --local = dev-mode against the recorded/available live checkout; interacts with source-resolve.sh's per-channel tag selection and the dev-mode warn-and-ask path.
