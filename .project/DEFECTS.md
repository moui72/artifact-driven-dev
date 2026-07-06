# Defects

_Last verified: 2026-07-06 (third pass)_

## constitution.md

- **Claim:** Behavioral smoke tests are required for state-mutating skill paths
  **Actual:** two scenarios now exist (`.github/workflows/smoke.yml`:
  feature→plan, tasks→implement — scenario 2 added by
  plan-repo-critique-docs T010 per the user's expand-don't-soften
  decision), but the `/ardd-converge`, `/ardd-feedback`, `/ardd-refine`,
  and `/ardd-sync` state-mutating paths still have none, and no scenario
  has ever executed (the `ANTHROPIC_API_KEY` secret is deliberately
  unprovisioned; jobs skip). Reduced-scope residue of an already-surfaced
  defect (identifier 970d935b is in
  plan-repo-critique-docs-2026-07-06.md's `surfaced-defects:`, so
  /ardd-plan will not re-prompt) — expand scenarios as the harness
  matures, starting when the key is provisioned and the existing two are
  proven to run.
  **Location:** .github/workflows/smoke.yml:1
  **Severity:** drift (reduced scope; tracked, not re-promptable)

Cleared since the previous run: the BSD-only `sed -i ''` in migrations
0001/0002 (58bd7dd2) — replaced with the portable `sed -i.bak` pattern,
with backfilled fixture tests running in ubuntu CI (only a historical
comment in test-migrations-legacy.sh mentions the old form).

All other spot-checks passed: POSIX-clean scripts throughout (21 test
scripts, every deterministic check covered — including both legacy
migrations now); pre-commit glob rule upheld; per-feature register
matches the standing decision; governance footer/frontmatter/SIR
consistent at v1.2.1 (lint-enforced); skill docs single-sourced and
`gen-skill-docs.sh --check` in sync; no vendored dependencies.
