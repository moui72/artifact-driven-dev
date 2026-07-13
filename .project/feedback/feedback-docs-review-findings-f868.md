---
status: planned
created: 2026-07-13
plan: plan-docs-review-findings-2026-07-13-1cf4.md
---

# Feedback

Source: four-agent documentation review, 2026-07-13 (naive adopter,
Spec Kit veteran, task-driven user, fact-checker). Doc-side fixes landed
directly in the docs rewrite; these are the system-level items.

## Bugs

- [x] F001 skills/ardd-feedback/SKILL.md's "Consumption by /ardd-plan"
  section says consumed feedback files flip to `planned` "once the plan is
  approved," but skills/ardd-plan/SKILL.md step 4 deliberately performs
  the feedback-mark/feedback-planned bookkeeping at negotiation time,
  before approval — the feedback skill's prose describes the old timing
  and should be aligned with plan's.
- [x] F002 skills/ardd-status/SKILL.md (~line 30) has a doubled word:
  "Delegated Delegated /ardd-implement subagents".
- [x] F003 skills/ardd-status/SKILL.md's canonical auto-run list names
  /ardd-refine twice ("/ardd-refine, ... /ardd-refine's create path") —
  reads as an editing leftover; collapse to one entry that mentions the
  create path.

## UX

- [x] F004 The feature register's `retired` status value exists in
  lint-project.sh's FEATURE_STATUS_ENUM but no skill prose or user doc
  explains what puts a feature there or what it means — either document
  its semantics (which skill writes it, from which states) or drop it
  from the enum.

## Reconsidered

- [x] F005 The "(formerly ardd-X)" suffixes in skill description
  frontmatter were to be dropped "in the release after next" following
  v1.0.0 (naming convention, CLAUDE.md Conventions) — at v1.8.0 they are
  overdue by that policy, and reviewers found them noisy in the generated
  README table. Decide: drop them now (a frontmatter edit + doc
  regeneration per skill), or explicitly extend the policy.
