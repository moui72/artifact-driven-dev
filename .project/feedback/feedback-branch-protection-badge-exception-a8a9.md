---
status: planned
created: 2026-07-23
plan: plan-chore-feedback-status-readines-2026-07-23-659e.md
---

# Feedback

## Bugs
- [x] F001 The "ArDD version badge sync" workflow can no longer push its badge-refresh commit directly to `main` — commit `0a4d52a` ("switch to collaborative workflow mode, add branch protection + CodeRabbit") added a `main` branch protection rule requiring changes via PR (1 approving review), and the workflow's `git push` now fails with `GH006: Protected branch update failed for refs/heads/main — Changes must be made through a pull request.` (observed run: `gh run view 30040967764`). Needs an exception so the badge-sync automation keeps working: either a bypass allowance for the workflow's actor (e.g. `github-actions[bot]`) on the `main` branch protection ruleset, or reworking the workflow to open/auto-merge a small PR instead of pushing directly. Not release-blocking (only the version badge goes stale), but should be fixed so it doesn't silently keep failing on every future push to `main`.
