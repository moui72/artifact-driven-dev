---
slug: stale-update-network-check
status: backlogged
logged: 2026-07-13
---

Opt-in: /ardd-status's update check may use the network to look for a new release on the recorded channel when the source checkout's tags are older than N days, instead of staying local-git-only.
Why: ardd-update-check.sh is deliberately no-fetch (source-resolve.sh owns fetching), so a machine where no project has run /ardd-update since a release never sees the update-available nudge; an age-gated fetch bounds staleness without making every status run touch the network.
