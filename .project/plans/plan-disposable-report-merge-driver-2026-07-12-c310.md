---
status: approved
branch: disposable-report-merge-driver
created: 2026-07-12
features: [disposable-report-merge-driver]
surfaced-defects: [7efff3a5]
---

# Plan: disposable-report merge driver (+ smoke-tier expansion)

## Goal

The take-either-side rule for the four single-writer report files becomes
git mechanism instead of prose — parallel branch merges never conflict on
generated reports — and the behavioral smoke tier catches up to the
14-skill surface (accepted defect `7efff3a5`).

## Scope

**In:**
- `.project/.gitattributes` shipped/maintained by `install.sh` (idempotent,
  like `.worktreeinclude`): `STATUS.md`, `DEFECTS.md`, `TRACKER.md`,
  `audit.md` marked `merge=ours`.
- Per-clone opt-in `git config merge.ours.driver true` — the
  `core.hooksPath` precedent: install.sh *suggests* and *checks* (warns
  when the attributes file exists but the driver is unconfigured), never
  mutates the user's git config.
- Graceful degradation documented and tested: an unconfigured driver falls
  back to git's normal text merge (a conflict, handled by today's
  interactive disposable rule — nothing gets worse).
- Skill/doc prose updates: `/ardd-implement`'s `merge_policy: auto`
  conflict note ("not even the disposable report files … until the
  merge-driver feature lands" — it has landed), README's Concurrency
  section, CLAUDE.md's single-writer notes.
- Dogfood: this repo gets the attributes + driver config; live-verify with
  a real two-branch report conflict.
- **[defect: 7efff3a5]** Smoke scenarios extended to the new surface:
  Reconcile mode and `/ardd-init` (both modes) at minimum, tracker/
  cross-routing if the scenario harness makes them cheap; scenarios stay
  secret-gated and path-filtered; the unprovisioned `ANTHROPIC_API_KEY`
  remains a documented manual step (called out in the workflow README),
  not something this plan can provision.

**Out:**
- `worktree-reap-and-fanout` (next feature; this plan is its dependency).
- Any change to `worktree-align.sh`/`fold-to-main.sh` — they are
  fast-forward-only by design and never merge, so the driver doesn't
  apply to them.
- Union/theirs driver variants — `ours` is the whole rule ("take either
  side without deliberation"; deterministically picking ours *is* that).
- Constitution changes (confirmed at design time — mechanism for an
  existing convention, hooksPath-style opt-in).

## Technical Approach

Git's attribute-driven merge drivers are the tool's own idiom for exactly
this file class (Principle VIII — checked before building anything custom):
`merge=ours` with `merge.ours.driver true` keeps the current branch's
version on conflict, which implements "take either side without
deliberation" deterministically; the owning skill regenerates from disk
afterward, exactly as the convention already prescribes. The attributes
live in `.project/.gitattributes` (scoped to the directory ARDD owns —
never the target's root `.gitattributes`, mirroring the gitignore-ceiling
discipline of Principle III). install.sh's handling is idempotent
create-or-append, regression-tested like its `.worktreeinclude` handling.
The config check is a pure function of repo state
(`git config --get merge.ours.driver` + file presence) — a deterministic
warning, not prose reliance. Smoke expansion reuses the existing
scenario/smoke-assert pattern; scenarios are additive to `smoke.yml`.

## Phase Breakdown

### Phase 1 — Driver mechanism (test-first)
1. install.sh ships/maintains `.project/.gitattributes` (create if absent,
   append missing entries, never duplicate, preserve user lines) + the
   driver-unconfigured warning; regression tests for all cases.
2. End-to-end behavior test in a throwaway repo: with driver configured, a
   two-branch STATUS.md conflict merges clean keeping ours; without it, a
   normal conflict (degradation pinned).
3. Dogfood: attributes + driver config in this repo; live two-branch
   verification.

### Phase 2 — Prose catch-up
4. `/ardd-implement` merge_policy prose, README Concurrency section,
   CLAUDE.md single-writer notes: the rule is now mechanized, interactive
   handling is the unconfigured-driver fallback. lint-docs green.

### Phase 3 — Smoke-tier expansion [defect: 7efff3a5]
5. New smoke scenarios: Reconcile mode (seed an interrupted in-progress
   file, assert reconciliation outcome) and `/ardd-init` (greenfield
   interview path with a scripted prompt; existing-code path against a
   minimal fixture). Assertions via smoke-assert.sh. Keep secret-gated;
   README/workflow note states the key remains deliberately unprovisioned
   and how to provision it when ready.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| Per-clone config opt-in (driver can't ship enabled) | Git deliberately doesn't honor repo-committed merge-driver definitions (arbitrary command execution); the hooksPath precedent already establishes the suggest-and-check pattern for exactly this constraint. |

## Open Questions

None — attributes location (`.project/.gitattributes`), driver semantics
(`ours`), and the defect's scope were all settled at design time.
