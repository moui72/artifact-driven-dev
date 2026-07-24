---
plan: plan-chore-docs-sweep-feedback-2026-07-24-8c58.md
generated: 2026-07-24
status: in-progress
---

# Tasks

## Phase 1: Fix stale reference-page passages

- [x] T001 [parallel] Edit `docs/reference/skills/ardd-defects.md` (hand-written body, below the `generated:end` marker): find the passage describing a fixed defect "silently drops out" on the next `/ardd-defects` run and add a clause noting the pre-drop reconciliation spot-check `skills/ardd-defects/SKILL.md:80-89` performs first (it checks whether a claim present in the prior `DEFECTS.md` but missing from a fresh survey is genuinely resolved before letting it drop). [feedback: feedback-ardd-defects-reconciliation-docs-4cbd F001]
- [x] T002 [parallel] Edit `docs/reference/skills/ardd-implement.md` (hand-written body): rewrite the Pre-flight bullet (currently only mentioning "the chosen tasks file and its bound plan must be committed") to name all four resolved-path kinds `skills/ardd-implement/SKILL.md:176-225` actually covers — the tasks file, its bound plan, the plan's bound feature-register files, and feedback files whose `plan:` frontmatter names this plan (all auto-committed together per the mode's existing rule) — plus the separate `.project/artifacts/` directory check, which always asks before committing in both solo and collaborative mode (never auto-commits silently). [feedback: feedback-ardd-implement-pre-flight-docs-e370 F001]
- [x] T003 [parallel] Edit `docs/reference/skills/ardd-init.md` (hand-written body): add a clause to the "Never invents decisions" bullet distinguishing "never guesses" (the existing claim) from "never overclaims observed-vs-universal coverage" — the new guard at `skills/ardd-init/SKILL.md:192-200` that avoids confident universal-coverage claims (e.g. "all routes validate input") on the existing-codebase reverse-engineer path. [feedback: feedback-ardd-init-overclaim-docs-fb81 F001]
- [x] T004 [parallel] Edit `docs/reference/skills/ardd-plan.md` (hand-written body): add a sentence, alongside the existing `plan_preview` browser-preview description at lines 79-85, covering `plan_preview_editor` — a distinct, independently-configurable open-in-editor checkpoint option that substitutes the plan file's absolute path into a `{path}` template and runs it — and how it composes with (offers alongside, never replaces) `plan_preview` per `skills/ardd-plan/SKILL.md`'s approval-checkpoint step. [feedback: feedback-ardd-plan-preview-editor-docs-2301 F001]
- [x] T005 [parallel] Edit `docs/reference/skills/ardd-update.md` (hand-written body): add a sentence to the guard description at lines 82-94 distinguishing the two harnesses' behavior against a pre-`--harness` source — Codex refuses and asks, while Claude (`HARNESS=claude`) is instead treated as safe and proceeds (omitting `--harness claude`) — per `skills/ardd-update/SKILL.md:105-129`. [feedback: feedback-ardd-update-harness-docs-15a4 F001]
- [x] T006 Run `./scripts/lint-docs.sh` to confirm the edited reference pages still only reference real skill names and pass the doc lint after T001-T005 land.
