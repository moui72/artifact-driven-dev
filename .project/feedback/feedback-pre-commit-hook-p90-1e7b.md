---
status: planned      # open -> planned
created: 2026-07-21
plan: plan-multi-harness-2026-07-21-76ba.md
---

# Feedback

## UX
- [x] F001 `hooks/pre-commit` runs both lints plus every `scripts/test-*.sh`
  unconditionally and serially on every commit (~46 scripts, ~117s warm,
  >2m under load/sandboxed shells) — a `.project/`-only commit pays ~60s
  of `install.sh`/`new.sh` fixture-repo tests it cannot affect. Measured
  top costs: `test-new.sh` ~21s, `test-install-version-badge.sh` ~14s,
  `test-install-worktreeinclude.sh` ~8s, `lint-project.sh` ~8s,
  `test-lint-docs.sh` ~8s, `lint-docs.sh` ~7s (top 9 ≈ 80s). Fix
  direction (investigated 2026-07-21): staged-path scoping inside the
  hook's existing check loop — a small pattern table for the special
  cases (`lint-docs.sh`, `lint-project.sh`, `test-new.sh`, the
  `test-install-*`/merge-driver/update-check family, `test-hooks-pre-commit.sh`),
  a generic `test-X.sh` guards `scripts/X.sh` rule for the rest,
  run-all fallbacks for empty staged lists and unmapped paths
  (fail-safe), and an `ARDD_HOOK_ALL=1` full-run override; extend
  `scripts/test-hooks-pre-commit.sh` with marker-file-stub routing cases
  (`.project/`-only → lint-project only; one script → its test only;
  unmapped path → all). Slow worst case (touching `install.sh`) stays
  acceptable; the P90 target is `.project/`/doc/skill commits at ~7–10s.
