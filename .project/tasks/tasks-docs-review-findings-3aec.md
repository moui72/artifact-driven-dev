---
plan: plan-docs-review-findings-2026-07-13-1cf4.md
generated: 2026-07-13
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: skill-prose fixes (F001–F003)

- [ ] T001 [parallel] (F001) In `skills/ardd-feedback/SKILL.md`, rewrite the
  "Consumption by /ardd-plan" section's final paragraph: consumed feedback
  files are marked (`feedback-mark`) and flipped to `status: planned` with
  the `plan:` stamp (`feedback-planned`) at /ardd-plan's step-4 negotiation
  time — before the approval checkpoint — not "once the plan is approved."
  Keep the surrounding 3-state checkbox prose intact; note that a file with
  unresolved items stays `open` for a later run (matching /ardd-plan step 4).
- [ ] T002 [parallel] (F002, F003) In `skills/ardd-status/SKILL.md`: fix the
  doubled word "Delegated Delegated" in the run-only-from-primary paragraph,
  and collapse the auto-run list's duplicated `/ardd-refine` mention
  ("/ardd-refine, ... /ardd-refine's create path (when relevant)") into a
  single entry that covers the create path. Touch nothing else in the
  canonical list.

## Phase 2: document `retired` (F004)

- [ ] T003 [parallel] (F004) Document `retired`'s semantics — "shipped, then
  deliberately removed"; entered only from `implemented`; terminal; flipped
  manually via `ardd-state.sh feature-flip <slug> retired` because no skill
  automates removal decisions — in `docs/reference/project-files.md` (as a
  note under the status-enums table, next to the existing who-advances
  paragraph) and as a one-line comment beside `FEATURE_STATUS_ENUM` in
  `scripts/lint-project.sh`. Comment/prose only — no validator behavior
  change (Principle V untriggered).

## Phase 3: drop the "(formerly ardd-X)" suffixes (F005)

- [ ] T004 (F005) Remove the trailing "(formerly ardd-*)" clause from the
  `description:` frontmatter of `skills/ardd-audit`, `ardd-backlog`,
  `ardd-defects`, `ardd-diagram`, `ardd-status`, and `ardd-tracker`. Keep
  each description's object → data-flow → redirect structure and the
  quoted-value colon rule intact; do not touch the "(absorbs ...)" clauses
  in `ardd-implement`/`ardd-refine` (fold routing, not rename history).
- [ ] T005 (F005; after T004) Run `scripts/gen-skill-docs.sh` to regenerate
  the README Skills table, `docs/reference/skills/*` headers + index, and
  `templates/WORKFLOW.md`; then verify `scripts/gen-skill-docs.sh --check`,
  `scripts/lint-docs.sh`, and the full `scripts/test-*.sh` suite pass.
  Grep the non-generated docs for any now-orphaned "formerly ardd-"
  references and update them (docs/guides/from-spec-kit.md's mapping table
  keeps the old→new routing and stays).

## Phase 4: wrap-up

- [ ] T006 Update CLAUDE.md's naming-convention bullet (the "Renamed skills
  carry '(formerly ardd-X)' for one release cycle..." sentence) to record
  that the suffixes were dropped in this change, so the convention text
  stops prescribing an already-completed action.
