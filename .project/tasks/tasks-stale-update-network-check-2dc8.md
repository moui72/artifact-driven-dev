---
plan: plan-stale-update-network-check-2026-07-13-cc79.md
generated: 2026-07-13
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: plumbing (field exists and validates)

- [ ] T001 [parallel] (stale-update-network-check) Add
  `update_check_max_age_days` to `scripts/ardd-state.sh`'s `stamp` key
  allowlist, accepting only positive integers (refuse `0`, negatives,
  non-numeric — nonzero exit, same refusal style as the other stamp keys).
  Add cases to `scripts/test-ardd-state.sh` in the same commit: set,
  replace, no-duplicate-keys, and at least two refused junk values.
- [ ] T002 [parallel] (stale-update-network-check) Validate
  `update_check_max_age_days` in `scripts/lint-project.sh`'s
  constitution-frontmatter checks: when present it must be a positive
  integer (message names the field and the allowed shape, carrying the
  version-skew hint like other enum findings). Add good/bad cases to
  `scripts/test-lint-project.sh` (and the bad-project fixture if that's
  where bad cases live) in the same commit.

## Phase 2: the fetch (test-first, then implement)

- [ ] T003 (stale-update-network-check; after T001) Extend
  `scripts/test-ardd-update-check.sh` with local-fixture-remote cases (no
  real network — same fixture-repo pattern the file already uses):
  (a) field set + FETCH_HEAD older than N days (or absent) + a new tag on
  the fixture remote → the check fetches and reports `behind` against the
  new tag; (b) field set + fresh FETCH_HEAD → no fetch (new remote tag
  stays invisible); (c) field absent → no fetch ever (default unchanged);
  (d) field set + unreachable remote → `note=fetch-failed` token and the
  comparison proceeds against local state, exit 0; (e) dev-mode and
  self-hosted sources never fetch regardless of the field. Expect these
  to fail until T004.
- [ ] T004 (stale-update-network-check; after T003) Implement the
  conditional fetch in `scripts/ardd-update-check.sh`: read
  `update_check_max_age_days` from `.project/artifacts/constitution.md`
  frontmatter (absent/invalid → skip, preserving current behavior); only
  when the source resolves to the release channel (never dev-mode, never
  self-hosted) and the mtime of `<src>/.git/FETCH_HEAD` (missing file =
  stale) is older than N days, run `git -C <src> fetch --tags --quiet`;
  on fetch failure emit `note=fetch-failed` and continue against local
  tags. POSIX sh only. Update the script's header comment ("LOCAL git
  only — no fetch") to describe the opt-in exception. All T003 cases and
  the full existing suite must pass.

## Phase 3: docs

- [ ] T005 (stale-update-network-check; after T004) Document the knob in
  `docs/reference/configuration.md` (name, positive-integer value, absent
  = never fetch, stamped via `ardd-state.sh stamp`, not asked by
  /ardd-init or /ardd-update, when and what it fetches, the
  `note=fetch-failed` fallback) and update the one-line descriptions in
  `docs/reference/scripts.md`'s ardd-update-check entry,
  `docs/reference/skills/ardd-status.md`'s update-check bullet, and
  `docs/reference/skills/ardd-update.md` if it states the no-fetch
  division of labor. Verify `scripts/lint-docs.sh` and
  `scripts/gen-skill-docs.sh --check` stay green.
