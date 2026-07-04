---
status: planned      # open -> planned
created: 2026-07-03
plan: plan-design-review-robustness-2026-07-03.md
---

# Feedback

## UX
- [x] `/ardd-sync` is the most operationally complex skill (idempotent issue creation via body-marker search, a documented GitHub-search colon-parsing workaround, asymmetric push/pull field ownership, indexing-lag races) yet it's the only one with zero test coverage — unlike `lint-project.sh`/`branch-info.sh`/`sibling-tasks-complete.sh`, which all have `test-*.sh` regression tests. It's also the one skill wired for unattended/headless operation (the GitHub Actions cron example in USAGE.md). Extract its idempotency-critical logic (slug-marker search, label-swap decision, divergence detection) into a small testable script layer, the same pattern already used for `branch-info.sh` and `sibling-tasks-complete.sh`, instead of leaving it as untested prose that runs headlessly in CI.
- [x] No concurrency guard exists for two sessions/agents racing on the same `.project/` directory (e.g. two `/ardd-tasks` runs against the same plan, or `/ardd-refine` and `/ardd-plan` racing on the same artifact). Add a lightweight marker (e.g. `.project/.lock` with a timestamp) that any skill about to write multi-file state (plan approval + feature flips, tasks generation) checks and warns on if written in the last few minutes by a different invocation — not full locking, just cheap insurance.

## Reconsidered
- [x] The `status: generating` stale-detection added to `lint-project.sh` only protects tasks-file *content* generation. There's still no rollback/recovery story for the surrounding multi-step bookkeeping a skill like `/ardd-tasks` performs in sequence (plan status flip, feature status flips, tasks file write) if interrupted partway between those steps rather than during content generation itself — worth deciding whether that gap needs its own protection or is acceptable as-is.
- [-] `migrations/*.sh` + `.ardd-applied` only version *skill files* across `install.sh` runs, not target-project *artifact content* — if a template's structure changes between ADD versions, existing artifacts in a target project are never migrated. Worth deciding whether this needs a migration story or is out of scope by design. (Deferred as an Open Question in `plan-design-review-robustness-2026-07-03.md` — no concrete template change has forced this yet; revisit via `/ardd-feature` if a direction is chosen without waiting for one.)
