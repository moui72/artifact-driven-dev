---
plan: plan-update-channel-switch-flags-2026-07-15-f22c.md
generated: 2026-07-15
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: `/ardd-update` channel flags [feature: update-channel-switch-flags]

- [x] T001 Rewrite `skills/ardd-update/SKILL.md`'s Usage
  section to add `--local`, `--beta`, `--stable` alongside the existing
  bare form and `--reconfigure`. Rewrite step 1 to branch on the flag
  before doing the existing recorded-channel read:
  - `--stable`/`--beta`: skip reading `Channel:` from
    `.project/ardd-version.md`; run
    `.claude/skills/ardd-scripts/source-resolve.sh --channel
    stable|beta` directly against the owned checkout and set
    `ARDD_CHANNEL=stable|beta` for step 4's `install.sh` invocation so
    it gets re-recorded.
  - `--local`: resolve the dev-mode checkout — if the recorded
    `Source-Path` already resolves `channel=dev` via
    `source-resolve.sh`, use it; otherwise prompt the user for a live
    checkout path exactly like step 1's existing `resolved=false`
    handling (never guess or search the filesystem). Reinstall from
    that checkout's own `install.sh` in step 4, without setting
    `ARDD_CHANNEL` (dev-mode ignores it).
  - Bare form (no flag): unchanged, resolves on the recorded channel.
  - More than one flag given at once is a usage error, reported before
    step 1 proceeds further.
  No test task — prose-only change (constitution Principle V's
  documentation-only exception).

- [x] T002 [parallel] Update
  `docs/reference/skills/ardd-update.md`'s Usage and "What a run does"
  sections to match T001: document the three new flags, their
  precedence over the recorded channel, and the dev-mode prompt
  behavior for `--local`.

## Phase 2: `/ardd-plan` browser-preview offer [feature: plan-approval-browser-preview]

- [x] T003 Add a browser-preview offer to
  `skills/ardd-plan/SKILL.md` step 10, immediately before the existing
  Approve/Revise/Stop `AskUserQuestion`: a one-time preliminary
  question asking whether to view the plan in the browser first. On
  yes, publish the plan file (`.project/plans/plan-<slug>-...md`) via
  the `Artifact` tool, open it, and display the resulting URL, then
  proceed to the existing three-way question unchanged. On no, proceed
  straight to the three-way question. Note in the prose that this offer
  re-fires each time a Revise loop returns to step 10 — a later
  redeploy of the same plan file targets the same artifact URL. No test
  task — prose-only change (Principle V documentation-only exception).

- [ ] T004 [parallel] Update
  `docs/reference/skills/ardd-plan.md` to document the browser-preview
  offer at the approval checkpoint, matching T003.
