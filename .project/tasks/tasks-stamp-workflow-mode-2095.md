---
plan: plan-stamp-workflow-mode-2026-07-19-ac2b.md
generated: 2026-07-19
status: completed
---

# Tasks

## Phase 1: fix (test-first)

- [x] T001 Add red regression cases to `scripts/test-ardd-state.sh`:
  `stamp <constitution-fixture> workflow_mode solo` and `...
  collaborative` succeed and write the frontmatter field;
  `... workflow_mode bogus` is refused with a usage-style error
  naming the legal values. Confirm the success cases fail against the
  current script (stamp rejects the key) before T002.

- [x] T002 Add `workflow_mode` to `cmd_stamp` in
  `scripts/ardd-state.sh`: a case-arm validating
  `solo|collaborative` (mirror the `delegation` arm's shape and
  `dieu` error format exactly) plus the matching usage line
  (`stamp <file> workflow_mode <solo|collaborative>`). All
  `test-ardd-state.sh` cases green. Fixes
  feedback-stamp-workflow-mode-ca7d F001; no `ardd-update` prose
  change needed.
