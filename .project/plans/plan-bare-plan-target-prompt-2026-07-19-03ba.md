---
status: approved
branch: bare-plan-target-prompt
created: 2026-07-19
features: []
---

# Plan: Bare /ardd-plan target prompt

## Goal

Make a bare `/ardd-plan` (no scope arguments) open by offering the
plannable items it actually found — backlogged slugs, open feedback,
unsurfaced defects — as a picker, and end with prose guidance plus
concrete next steps when truly nothing is plannable, instead of
complaining about missing feedback input.

## Scope

**In scope** (consumes `feedback-bare-plan-target-prompt-dc5f.md`, F001 +
F002 both accepted):
- A new early "target pick" step in `skills/ardd-plan/SKILL.md`, active
  only for the bare invocation (no slug, no feedback/defect scope, no
  `--list`/`--from`/`--slate`).
- The empty-case behavior: prose + suggestions (`/ardd-backlog`,
  `/ardd-feedback`, `/ardd-implement` when a `ready` tasks file exists).
- Matching update to `docs/reference/skills/ardd-plan.md`'s hand-written
  body.

**Out of scope:**
- Any new script — enumeration already exists (`feature-list.sh`,
  `defects-unsurfaced.sh`, `tasks-list.sh`); this is presentation prose.
- Scoped invocations (`/ardd-plan <slug>`, feedback/defect scopes) —
  unchanged; the picker only fires when the user gave no scope.
- `--slate` — remains the deeper read-only grouping mode; the picker is a
  lightweight complement, not a replacement, and the prose should
  cross-point to `--slate` when the backlog is large.

## Technical Approach

Insert a **step 1a (bare-invocation target pick)** into
`skills/ardd-plan/SKILL.md`, between the branch check (step 1) and
artifact discovery (step 2), firing only when no scope argument of any
kind was passed:

- Enumerate plannable inputs deterministically: `feature-list.sh`
  (backlogged slugs), a glob of `status: open` feedback files,
  `defects-unsurfaced.sh` (count of never-surfaced defect entries).
- **Something found** (F001): present ONE AskUserQuestion (multiSelect
  on) listing each backlogged slug, each open feedback file, and — if
  any — a "surfaced defects" option, and continue the run scoped to the
  selection exactly as if those arguments had been passed (slugs → step
  3, feedback files → step 4's scope, defects → step 5's explicit
  mode). Selecting nothing = proceed as today (artifacts/feedback-only
  drafting). This respects the one-prompt-per-turn-end convention: it is
  a mid-run gate, not a terminal prompt, same class as the approval
  checkpoint, and fires regardless of `next_step_prompt`.
- **Nothing found** (F002): report in prose — no plannable inputs
  (empty backlog, no open feedback, no unsurfaced defects) — and
  suggest concrete next steps: `/ardd-backlog <idea>` or
  `/ardd-feedback <observation>` to create something plannable, and
  `/ardd-implement` when `tasks-list.sh` shows a `ready`/`in-progress`
  file. Then stop; never draft a plan against nothing. Never prompt in
  this branch (there is nothing to pick) — plain text, like `--list`'s
  degenerate cases.

The side doors (`--list`, `--slate`, `--from`) are untouched and still
bypass this step; the new prose cross-references `--slate` as the richer
alternative when many backlogged items exist.

## Phase Breakdown

### Phase 1: Skill prose — no dependencies
- Add step 1a to `skills/ardd-plan/SKILL.md` per the Technical Approach
  (bare-detection rule, picker, empty-case prose, scope-forwarding
  semantics), and adjust the Usage paragraph's "plans from
  artifacts/feedback only" wording to mention the target pick.
  Addresses F001 + F002.

### Phase 2: Docs — depends on Phase 1
- Update `docs/reference/skills/ardd-plan.md`'s hand-written body (below
  the `generated:end` marker); `./scripts/lint-docs.sh` stays green.

## Open Questions

- None. (One decision made here rather than left open: selecting nothing
  in the picker proceeds with today's artifacts/feedback-only behavior
  rather than stopping — the picker adds options, it doesn't remove the
  existing path.)
