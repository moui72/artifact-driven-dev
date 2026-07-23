---
plan: plan-codex-scenario-sweep-fixes-2026-07-22-220d.md
generated: 2026-07-22
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                     # (or -> abandoned, if superseded by a new tasks
                     # file generated for the same plan)
                     # completed is terminal — post-completion failures
                     # become new feedback (/ardd-feedback), never a
                     # status edit.
---

# Tasks

## Phase 1: /ardd-defects reconciliation step

- [x] T001 In `skills/ardd-defects/SKILL.md` step 5 ("Write
  `.project/DEFECTS.md`"), add a reconciliation sub-step before the
  full-overwrite write: read the current on-disk `.project/DEFECTS.md`
  (if present) and extract its claims; compute the set of claims present
  there but not produced by this run's fresh survey (step 2/3); for each
  such claim, spot-check it directly — re-read the specific artifact
  claim and the specific code location the old entry cited — before
  deciding whether to drop it. A claim confirmed still genuinely true on
  spot-check is carried forward into the new `DEFECTS.md` even though the
  general survey pass missed it this run; a claim confirmed fixed (the
  code now matches the artifact) drops, same as today. State explicitly
  that this closes the gap where an incomplete general survey silently
  loses a still-valid finding, while keeping the "full regenerate, no
  manual removal needed" design intact — the fix mechanism stays the
  actual code check, never a human remembering to preserve an entry.
  [feedback: F002] No test requirement — documentation/prose-only change
  (constitution Principle V's exception).

## Phase 2: /ardd-status prepend-and-preserve rule

- [x] T002 In `skills/ardd-status/SKILL.md` step 6 ("Write
  `.project/STATUS.md`"), add an explicit rule, right after the existing
  bullet list and before the closing "STATUS.md is the single re-entry
  point..." paragraph: a new run's `_Updated:` entry is *prepended* as a
  new top block, and every prior `_Updated:` block already in the file is
  preserved verbatim below it — never summarized away, condensed, or
  replaced with just a fresh top-level summary. Add one clarifying
  sentence noting this is why `STATUS.md` grows over time by design: its
  history is durable re-entry chronology, not a point-in-time snapshot —
  matching the file's own existing self-description in the same
  paragraph ("the single re-entry point after any interruption").
  [feedback: F003] No test requirement — documentation/prose-only change
  (constitution Principle V's exception).
