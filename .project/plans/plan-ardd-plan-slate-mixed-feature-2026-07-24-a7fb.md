---
status: approved
branch: chore-docs-sweep-feedback
created: 2026-07-24
features: [ardd-plan-slate-mixed-feature]
surfaced-defects: []
---

# Plan: mixed feature+feedback slates for `/ardd-plan --slate`

## Goal

Extend `/ardd-plan --slate`'s read-only defrag analysis to span open feedback
files alongside backlogged features, so its grouping and fan-out
recommendations reflect the full plannable surface instead of features only.

## Scope

**In scope**
- Widen slate-mode enumeration to include open `.project/feedback/*.md` files
  as first-class slate items (one item per *file*).
- Extend footprint grading and the two-axis pairwise relation model to feedback
  items, including the key new dependency heuristic: a `## Reconsidered`
  feedback item tagged with an artifact a slated feature also modifies is a
  dependency edge → bundle them.
- Emit mixed recommendations using the already-valid scoped-run grammar
  (`/ardd-plan <slug> feedback-x.md`), including feedback-only groups.
- Update the Usage `--slate` paragraph (drop the "no feedback load" absolute
  for slate; keep the read-only guarantee) and the slate report-format example.
- Doc-sync: verify/update `docs/reference/skills/ardd-plan.md`'s hand-written
  body; add one clarifying sentence to `ardd-feedback`'s "Consumption by
  /ardd-plan" section.

**Out of scope**
- Any change to the normal (non-slate) plan flow — mixed *planning* already
  works today (a normal run accepts a feature slug + a `feedback-*.md`
  argument, and the bare picker already spans features + feedback + defects).
- Per-`F###`-item slating — the feedback *file* is the slate unit (the scoped-run
  grammar has no `feedback-file#F002` form).
- Any script or `lint-project.sh` enum change — slate stays read-only and writes
  nothing, so no new state machinery. All state flips remain in the normal run.
- Defects in the slate (features + feedback only, per the stated request).

## Technical Approach

Slate mode is a self-contained procedure at the end of `skills/ardd-plan/SKILL.md`
("Slate mode (`--slate`)"), read-only by construction. The change is prose-only
and confined to that procedure plus the Usage entry:

- **Enumeration (slate step 1):** in addition to
  `feature-list.sh --status backlogged`, glob `.project/feedback/feedback-*.md`
  and keep `status: open` files — the same discipline step 1a already uses in
  the normal flow. `N` = backlogged features + open feedback files.
- **Item granularity:** each feedback *file* is one slate item; its footprint is
  the union of its items' `[artifacts: ...]` tags plus grep-grounded code refs.
- **Grading (slate step 3):** feedback items usually grade `high` (they cite
  concrete observed behavior, often with path+symbol refs). The existing
  high/medium/low rubric applies unchanged.
- **Relations (slate step 4):** the two independent axes (file-set overlap;
  ordering dependency) apply to feedback items as-is, plus one new dependency
  heuristic — a `## Reconsidered` item tagged with an artifact a slated feature
  would also modify is an ordering edge (negotiate the reversal before/with the
  feature's artifact design), so the pair bundles.
- **Output (slate step 5):** bundles/parallel/solo may now contain feedback
  filenames; recommendations use the existing scoped grammar. Feedback-only solo
  groups read `-> /ardd-plan feedback-<x>.md`.

Reference the feature's research notes in
`.project/features/ardd-plan-slate-mixed-feature.md` for the grounding of each
of these points.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is tracked in
the linked tasks file.

**Phase 1 — Slate enumeration + Usage prose**
- Widen slate step 1 to also enumerate open feedback files; redefine `N` to
  count both kinds; update the N=0/N=1 degenerate-branch wording so a lone
  feedback file renders a valid single-item recommendation.
- Update the Usage `--slate` paragraph: remove the "no feedback load" absolute
  *for slate*, keep "read-only … no writes of any kind." Preserve the
  "takes no scope" rule.

**Phase 2 — Grading + pairwise relations for feedback (depends on Phase 1)**
- Extend slate step 3 grading guidance to feedback items (worked note: feedback
  typically grades `high`).
- Extend slate step 4's two-axis model to feedback footprints and add the
  `## Reconsidered`-vs-slated-feature dependency-edge heuristic.

**Phase 3 — Report format + recommendation grammar (depends on Phase 2)**
- Update slate step 5 classification prose and the fixed report-format example
  to show a mixed bundle (`/ardd-plan <slug> feedback-<x>.md`) and a
  feedback-only solo line. Confirm the next-step-prompt "top-priority" ordering
  still resolves with feedback items present.

**Phase 4 — Doc sync (depends on Phase 3)**
- Update `docs/reference/skills/ardd-plan.md` hand-written body if it describes
  slate as backlog-only.
- Add one sentence to `skills/ardd-feedback/SKILL.md` "Consumption by
  /ardd-plan" noting `--slate` now surfaces open feedback.
- Run `scripts/lint-docs.sh` and `scripts/lint-project.sh` to confirm nothing
  regressed.

## Open Questions

- Should the plan frontmatter gain a `feedback:` list mirroring `features:` for
  reverse-linkage, or is the feedback file's own `plan:` pointer (stamped by
  `feedback-planned`) sufficient? Research recommends the existing pointer is
  enough — leave plan frontmatter untouched unless a concrete need appears.
- The `docs/reference/skills/ardd-plan.md` body wasn't inspected this pass;
  Phase 4 verifies whether it actually mentions slate scope before editing.
