---
status: approved
branch: background-by-default-flow
created: 2026-07-12
features: [background-by-default-flow]
---

# Plan: background-by-default flow

## Goal

Make background delegation the frictionless default of the solo git flow:
`/ardd-plan` commits plan+tasks straight to the local default branch, and two
new constitution workflow knobs (`delegation`, `merge_policy`) remove the two
always-yes prompts from `/ardd-implement`/`/ardd-converge`, demoting
`fold-to-main.sh` to a recovery path.

## Scope

**In:**
- `lint-project.sh` schema for two new optional constitution frontmatter
  fields: `delegation: eager | ask | inline` and `merge_policy: auto | ask`
  (absent = `ask` for both — today's behavior, so no migration is needed).
- `/ardd-plan` step 1: in solo mode, drop the branch-gate prompt — proceed on
  the current branch (normally the default branch) and commit plan+tasks
  there. Collaborative mode keeps the gate unchanged.
- `/ardd-implement` + `/ardd-converge`: the delegation gate honors
  `delegation` (`eager` = delegate without prompting; `ask` = today;
  `inline` = never offer), and the post-delegation completion step honors
  `merge_policy` (`auto` = merge when fast-forward or conflict-free, surface
  and stop otherwise; `ask` = today). `merge_policy` is consulted in solo
  mode only — collaborative mode never eager-merges locally.
- Ask-once wiring per the `next_step_prompt` precedent: `/ardd-bootstrap`
  asks both questions; `/ardd-update` backfills installs whose constitution
  lacks the fields; values stamped via `ardd-state.sh stamp`, never
  hand-edited.
- Docs: CLAUDE.md (the "ardd-plan is the branch-gate exception" and
  two-operating-modes sections), README/USAGE sweep, decision record for the
  default change (amends/extends 0004).
- Dogfood: stamp this repo's own constitution with chosen values.

**Out:**
- The `.gitattributes` merge driver for disposable report files
  (`disposable-report-merge-driver` — separate backlog entry; until it lands,
  `merge_policy: auto` stops on any conflict and the prose disposable rule
  handles it interactively).
- Worktree reaping and multi-tasks-file fan-out (`worktree-reap-and-fanout`).
- Any constitution *body* change — the knobs are workflow frontmatter fields
  (confirmed at design time: `workflow_mode`/`next_step_prompt` precedent, no
  SIR, no version bump).
- Collaborative-mode behavior changes (its gate, push-confirmation, and
  draft-PR flow are untouched).

## Technical Approach

The knobs follow the established workflow-field pattern end to end: enum
block in `lint-project.sh` (schema-of-record, same commit as first writer),
`ardd-state.sh stamp` for mutation, bootstrap/update ask-once, absent =
today's behavior so existing installs are unaffected without action.

The plan-to-default change is prose-only in `ardd-plan`'s step 1: solo mode
proceeds where it stands (deriving the plan-name slug from the feature slug
or a hex token as today), while collaborative mode retains the full gate.
Decision 0004's reasoning is extended, not reversed: a `ready` tasks file on
the default branch is planned truth, already accepted there — this plan just
stops authoring a branch whose only fate was to be fast-forward-folded back.
`fold-to-main.sh` and its tests remain untouched; only the skills' framing
changes (recovery path for runs that find themselves on a branch, no longer
the common-path step).

The delegation/merge gate edits touch the deliberately-duplicated
interactive halves of `ardd-implement` and `ardd-converge` — both need the
same edit (per CLAUDE.md's note on the shared-script/interactive split); the
deterministic scripts they call are unchanged.

## Phase Breakdown

### Phase 1 — Schema of record (test-first)
1. Add `delegation` (`eager|ask|inline`) and `merge_policy` (`auto|ask`)
   to `lint-project.sh`'s constitution-frontmatter validation: optional
   fields, enum-checked when present. Extend `tests/fixtures/good-project`
   (valid values) and `tests/fixtures/bad-project` (invalid value each) and
   `test-lint-project.sh` — bad fixtures confirmed failing before the
   validator change is complete (Principle V).

### Phase 2 — Solo plan commits to default
2. Rewrite `/ardd-plan` step 1: solo = no branch-gate prompt, proceed on the
   current branch; collaborative = gate unchanged; keep the
   stale-branch/disposable-reports note and the worktree escape hatch as
   prose. Clarify the plan `branch:` field's meaning in the no-branch flow
   (see Open Questions #2).
3. Update CLAUDE.md (branch-gate-exception paragraph, two-modes section) and
   USAGE/README where they narrate the plan gate; `lint-docs.sh` green.

### Phase 3 — Knob consumption in implement/converge
4. `/ardd-implement` step 3 and `/ardd-converge`'s equivalent: read
   `delegation` from constitution frontmatter (grep, absent = `ask`) and
   branch the gate accordingly; same edit in both skills.
5. Same two skills, completion step: read `merge_policy`; on `auto`, merge
   the reported subagent branch when fast-forward or conflict-free and run
   the existing post-merge steps (core.bare check unchanged); on any
   conflict, stop and surface — never auto-resolve. Reword `fold-to-main.sh`
   references to recovery-path framing.
6. Record the decision: new `docs/decisions/0005-background-by-default.md`
   (what changed relative to 0004, why fold demotes, why absent = ask).

### Phase 4 — Ask-once wiring
7. `/ardd-bootstrap`: add the two questions (delegation in both modes;
   `merge_policy` asked only in solo — see Open Questions #3), stamped via
   `ardd-state.sh stamp`.
8. `/ardd-update`: backfill-ask for installs whose constitution lacks either
   field, exactly mirroring the `next_step_prompt` backfill; field presence
   (either value) suppresses re-asking.

### Phase 5 — Dogfood and closeout
9. Stamp this repo's constitution with the chosen values (Open Questions #4)
   and verify `lint-project.sh` passes against the live `.project/`.
10. Full docs sweep + pre-commit hook run; confirm `completion-flip-check.sh`
    degrades gracefully when a plan's `branch:` names a never-created branch
    (Open Questions #2) — add a regression case if its behavior needed a fix.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| Two knobs instead of one combined "autonomy" field | Delegation locus and merge consent are independent decisions — auto-delegate with manual merge is a legitimate combination (e.g. while the disposable-report merge driver hasn't landed). A single enum would need 6 values to cover the same space. |

## Open Questions

1. **Knob names.** `delegation` and `merge_policy` proposed. `merge` alone is
   too vague as a frontmatter key; `delegation_policy` felt redundant.
   Confirm or rename before Phase 1 locks the enum block.
2. **`completion-flip-check.sh` vs the no-branch flow.** Its fallback reads
   the plan's `branch:` field and runs `git merge-base --is-ancestor`. In
   the solo no-branch flow that branch may never exist. Verify during Phase 5
   that a missing ref degrades silently (expected) rather than erroring, and
   decide whether the plan `branch:` field should be omitted entirely when no
   branch is created.
3. **Should `/ardd-bootstrap` ask `merge_policy` in collaborative mode?**
   Proposed: no — the field is only consulted in solo, so asking would imply
   effect it doesn't have. It can still be stamped later if the project
   switches modes.
4. **Dogfood values for this repo.** `delegation: eager` + `merge_policy:
   auto` exercises the full feature; `ask` values are safer while the
   feature is fresh. Decide at Phase 5.
