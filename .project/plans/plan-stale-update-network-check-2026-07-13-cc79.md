---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: stale-update-network-check
created: 2026-07-13
features: [stale-update-network-check]
surfaced-defects: []
---

# Plan: stale-update-network-check

## Goal

Give `/ardd-status`'s update check an opt-in, age-gated network fetch so a
machine that never runs `/ardd-update` still learns about new releases —
without making any default status run touch the network.

## Scope

- **In:** a new constitution frontmatter workflow field
  (`update_check_max_age_days`), the conditional fetch inside
  `ardd-update-check.sh`, `ardd-state.sh stamp` support,
  `lint-project.sh` validation, fixture-based regression tests for all of
  it, and the documentation updates (configuration.md, scripts.md, the
  ardd-status and ardd-update reference pages).
- **Out:** any change to default behavior (field absent = today's
  local-git-only check); any new `/ardd-init` or `/ardd-update` question
  (the knob is stamped manually, documented in configuration.md); any
  change to `source-resolve.sh` (it keeps owning the update-time fetch);
  artifact content changes (none needed — the standing decision doesn't
  pin the check as no-fetch).

## Technical Approach

The knob follows the established workflow-field pattern
(`workflow_mode`/`next_step_prompt`/`delegation`/`merge_policy`):
constitution frontmatter, not constitution content — no Sync Impact
Report entry, no version bump, absent = safe default (never fetch), so
existing projects need no migration. `ardd-update-check.sh` reads the
field itself from `.project/artifacts/constitution.md` (a pure function
of disk state — Principle II) and fetches only when **all** of: the field
is a positive integer; the source resolves to the release channel (never
dev-mode, never `self-hosted`); and the owned checkout's last-fetch
signal — the mtime of `<src>/.git/FETCH_HEAD`, with a missing file
counting as stale (git-native signal, Principle VIII) — is older than N
days. The fetch is `git -C <src> fetch --tags --quiet` with failure
tolerated: on error, print a `note=fetch-failed` token and continue
against local state — the constitution's "resolution never blocks
offline" discipline applied to the check. Deterministic changes ship with
fixture tests in the same commit (Principle V): `test-ardd-update-check.sh`
gains local-fixture-remote cases (no real network), and the stamp and
lint enums get cases in their existing tests.

## Phase Breakdown

### Phase 1: plumbing (field exists and validates)

- Add `update_check_max_age_days` to `ardd-state.sh stamp`'s key
  allowlist (positive-integer validation, refusing junk) + test cases.
- Add the field to `lint-project.sh`'s constitution-frontmatter checks
  (positive integer when present) + `test-lint-project.sh` cases.

### Phase 2: the fetch (behavior, test-first)

- Extend `test-ardd-update-check.sh` with fixture-remote cases: fetches
  when opted-in and stale (new remote tag becomes visible → `behind`);
  skips when fresh; skips when the field is absent (default unchanged);
  tolerates a dead remote (`note=fetch-failed`, local fallback); never
  fetches dev-mode or self-hosted sources.
- Implement the conditional fetch in `ardd-update-check.sh` per the
  approach above.

### Phase 3: docs

- `docs/reference/configuration.md`: document the knob (name, values,
  default, how to stamp it, when it fetches).
- `docs/reference/scripts.md` (update-check entry),
  `docs/reference/skills/ardd-status.md` and `ardd-update.md`: one-line
  updates reflecting the opt-in fetch.

## Complexity Tracking

No deviations — one frontmatter field, one guarded fetch inside an
existing script, no new files or mechanisms (Principle VI).

## Open Questions

None.
