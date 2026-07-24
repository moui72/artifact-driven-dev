---
slug: ci-status-refresh-on-main-coll
status: backlogged
logged: 2026-07-24
---

A CI job on the default branch regenerates STATUS.md post-merge in collaborative mode, so feature branches don't need to commit regenerated report files (PR noise).
Why: collaborative mode makes committed STATUS.md churn in every PR; merge=ours mitigates conflicts but not diff noise — post-merge CI regeneration keeps main's report fresh without branch commits.
