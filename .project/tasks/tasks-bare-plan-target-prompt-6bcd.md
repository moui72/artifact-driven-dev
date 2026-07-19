---
plan: plan-bare-plan-target-prompt-2026-07-19-03ba.md
generated: 2026-07-19
status: ready
---

# Tasks

## Phase 1: Skill prose

- [ ] T001 Add a **step 1a (bare-invocation target pick)** to
  `skills/ardd-plan/SKILL.md`, between step 1 (branch check) and step 2
  (artifact discovery), firing ONLY when the run received no scope
  argument of any kind (no feature slug, no `feedback-*.md`, no
  `defect:`/`defects`, and not `--list`/`--from`/`--slate`). The step:
  (1) enumerates plannable inputs deterministically —
  `.claude/skills/ardd-scripts/feature-list.sh` (backlogged slugs; source
  fallback `scripts/feature-list.sh`), glob of `status: open`
  `.project/feedback/feedback-*.md` files, and
  `defects-unsurfaced.sh` output (never-surfaced defect entries);
  (2) if anything was found, presents ONE AskUserQuestion (multiSelect
  on) listing each backlogged slug, each open feedback file, and — when
  any exist — a "surfaced defects" option, then continues the run scoped
  to the selection exactly as if those arguments had been passed (slugs
  → step 3, feedback files → step 4's feedback scope, defects → step 5's
  explicit-selection mode); selecting nothing proceeds with today's
  artifacts/feedback-only drafting; note this is a mid-run gate (same
  class as the approval checkpoint), fires regardless of
  `next_step_prompt`, and cross-point to `--slate` as the richer
  read-only grouping when the backlog is large;
  (3) if nothing was found (F002), reports in prose — no plannable
  inputs — suggesting `/ardd-backlog <idea>` or `/ardd-feedback
  <observation>` to create something plannable and `/ardd-implement`
  when `tasks-list.sh` shows a `ready`/`in-progress` file, then stops
  without drafting a plan and without prompting (plain text, like
  `--list`'s degenerate cases). Also adjust the Usage paragraph's
  "`/ardd-plan` plans from artifacts/feedback only" wording to mention
  the target pick. Addresses F001 + F002 of
  `feedback-bare-plan-target-prompt-dc5f.md`. Verify: `./scripts/
  lint-docs.sh` green (skill names unchanged); prose consistent with the
  side-door paragraphs it sits between.

## Phase 2: Docs

- [ ] T002 Update the hand-written body (below the `generated:end`
  marker) of `docs/reference/skills/ardd-plan.md` to describe the bare
  invocation's target pick and empty-case guidance, mirroring T001's
  semantics (picker only on a truly bare run; empty selection keeps
  today's behavior; empty inputs → prose + next steps, no plan drafted).
  Verify: `./scripts/lint-docs.sh` green.
