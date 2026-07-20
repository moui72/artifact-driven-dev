---
status: planned      # open -> planned
created: 2026-07-19
plan: plan-stamp-workflow-mode-2026-07-19-ac2b.md
---

# Feedback

Source: regression sweep run 2026-07-19-51a7 (S3), verified against
source: `cmd_stamp`'s key enum omits `workflow_mode`.

## Bugs

- [x] F001 `skills/ardd-update/SKILL.md` step 5 (`--reconfigure`)
  instructs stamping changed fields via `ardd-state.sh stamp`, but
  `cmd_stamp` rejects `workflow_mode` (not in its key enum) — an agent
  following the prose literally errors when the user changes that
  field. Fix: add `workflow_mode <solo|collaborative>` to the stamp
  enum (usage text + `cmd_stamp` case) with a regression case in
  `scripts/test-ardd-state.sh` — keeps the mutation script-performed
  per constitution Principle II, rather than rerouting prose to a
  hand edit.
