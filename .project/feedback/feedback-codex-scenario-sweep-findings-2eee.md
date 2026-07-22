---
status: planned
created: 2026-07-22
plan: plan-plan-preview-editor-option-2026-07-22-3276.md
---

# Feedback

## Bugs
- [-] F001 Codex `$ardd-update` pre-harness guard warns that an old installer would regenerate "Claude-oriented `.agents/skills` output"; the warning should name `.claude/skills` or use harness-neutral wording. Source: `dev-notes/scenario-runs/2026-07-22-c0de/S3-report.md` S3-F001; path: `skills/ardd-update/SKILL.md`.
- [-] F002 `$ardd-defects` drops still-open known defects when regenerating `DEFECTS.md`, then makes `STATUS.md` under-report unresolved defects. Source: `dev-notes/scenario-runs/2026-07-22-c0de/S7-report.md` S7-F002; paths: `skills/ardd-defects/SKILL.md`, `skills/ardd-status/SKILL.md`.

## UX
- [-] F003 `$ardd-status` compresses lived-in `STATUS.md` too aggressively, dropping durable re-entry chronology while preserving only the current summary. Source: `dev-notes/scenario-runs/2026-07-22-c0de/S7-report.md` S7-F001; path: `skills/ardd-status/SKILL.md`.

## Reconsidered
