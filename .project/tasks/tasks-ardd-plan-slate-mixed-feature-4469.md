---
plan: plan-ardd-plan-slate-mixed-feature-2026-07-24-a7fb.md
generated: 2026-07-24
status: in-progress
---

# Tasks

## Phase 1: Slate enumeration + Usage prose
- [x] T001 In `skills/ardd-plan/SKILL.md` slate-mode step 1 ("Enumerate the backlog"), add a second enumeration source: glob `.project/feedback/feedback-*.md` and keep files whose frontmatter is `status: open` (same discipline as step 1a in the normal flow). Redefine `N` as the count of backlogged features + open feedback files. Keep the register-direct-read discipline (never trust STATUS.md counts).
- [x] T002 In `skills/ardd-plan/SKILL.md` slate-mode step 2 (N=0/N=1 branch), update the degenerate-case wording so a single open feedback file (N=1) renders a valid single-item recommendation in feedback-filename form (`/ardd-plan feedback-<x>.md`), not only a slug. Keep the "nothing to defrag" N=0 message.
- [x] T003 In `skills/ardd-plan/SKILL.md` Usage `--slate` paragraph, remove the "no feedback load" absolute *as it applies to slate* while preserving the read-only guarantee ("no writes of any kind") and the "takes no scope" rule. Word it so slate now reads both backlogged features and open feedback.

## Phase 2: Grading + pairwise relations for feedback
- [x] T004 In `skills/ardd-plan/SKILL.md` slate-mode step 3 (footprint confidence grading), extend the guidance to feedback items: their footprint is the union of the file's items' artifact bracket-tags plus grep-grounded code refs, and they typically grade `high` because they cite concrete observed behavior (often path+symbol refs). Keep the existing high/medium/low rubric and worked examples intact.
- [x] T005 In `skills/ardd-plan/SKILL.md` slate-mode step 4 (pairwise relations), state that both axes (file-set overlap; ordering dependency) apply to feedback footprints as-is, and add the new dependency-edge heuristic: a `## Reconsidered` feedback item tagged with an artifact that a slated feature would also modify is an ordering edge (the reversal must be negotiated before/with the feature's artifact design) → the pair bundles. Depends on T001.

## Phase 3: Report format + recommendation grammar
- [x] T006 In `skills/ardd-plan/SKILL.md` slate-mode step 5 (classify and present), update the classification prose and the fixed report-format example so buckets can contain feedback filenames: show a mixed Bundle line (`-> /ardd-plan <slug> feedback-<x>.md`) and a feedback-only Defer/solo line (`-> /ardd-plan feedback-<x>.md`), using the already-valid scoped-run grammar. Keep the three fixed headings and the "omit empty heading" rule. Depends on T005.
- [x] T007 In `skills/ardd-plan/SKILL.md` slate-mode "Next-step prompt" subsection, confirm the "top-priority" ordering (bundle > parallel > solo, then first-enumerated) still resolves unambiguously when feedback items are present; adjust the wording only if feedback items introduce a tie the current rule doesn't cover. Depends on T006.

## Phase 4: Doc sync
- [ ] T008 Read `docs/reference/skills/ardd-plan.md`'s hand-written body (below the `generated:end` marker). If it describes `--slate` as backlog/feature-only, update it to reflect the mixed feature+feedback scope; if it doesn't mention slate scope, leave it unchanged. Depends on T006.
- [ ] T009 Add one clarifying sentence to `skills/ardd-feedback/SKILL.md`'s "Consumption by /ardd-plan" section noting that `/ardd-plan --slate` now surfaces open feedback files in its defrag grouping (not only the normal-flow consumption already documented). Depends on T003.
- [ ] T010 Run `scripts/lint-docs.sh` and `scripts/lint-project.sh` and confirm both pass with no new findings introduced by this change. Depends on T008, T009.
