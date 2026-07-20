---
status: approved
branch: stamp-workflow-mode
created: 2026-07-19
features: []
---

# Plan: stamp accepts workflow_mode

## Goal

Make `ardd-state.sh stamp` accept `workflow_mode <solo|collaborative>`
so `ardd-update --reconfigure`'s prose (which already routes the field
through stamp) works when the user changes it.

## Scope

**In scope** (consumes `feedback-stamp-workflow-mode-ca7d.md`, F001):
- `scripts/ardd-state.sh`: add `workflow_mode` to `cmd_stamp`'s key
  enum with value validation `solo|collaborative`, and the matching
  usage line.
- Regression cases in `scripts/test-ardd-state.sh`: valid stamp of
  both values; invalid value refused with a usage-style error.

**Out of scope:** any `ardd-update` prose change — the prose is
already correct once stamp accepts the key. No lint-project.sh change
(its `workflow_mode` enum already validates the frontmatter on read).

## Technical Approach

Mirror the existing `delegation`/`merge_policy` stamp cases exactly —
same case-arm shape, same `dieu` error format. Test-first per the
constitution: red cases before the fix.

## Phase Breakdown

### Phase 1: fix (test-first) — no dependencies
- Red regression cases in `test-ardd-state.sh`, then the `cmd_stamp`
  case-arm + usage line; all green.

## Open Questions

- None.
