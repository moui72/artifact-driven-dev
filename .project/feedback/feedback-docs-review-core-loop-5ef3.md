---
status: open      # open -> planned
created: 2026-07-06
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

Source: user-requested review of USAGE.md, README.md, CLAUDE.md, and
guides/ (2026-07-06), prompted by the user's observation that they use
`/ardd-feature` and `/ardd-feedback` constantly despite both being
classified as "extensions."

## Bugs

- [ ] F001 USAGE step 1 misdescribes `/ardd-bootstrap`: says it writes
  infrastructure/datamodel/ui and to run `/ardd-refine constitution` "if
  you want a constitution" — bootstrap has created the constitution
  (suggestion catalog, `workflow_mode` question) for a while, and the
  artifact set is judgment-driven, not fixed. Rewrite the step to match
  ardd-bootstrap's actual behavior.
- [ ] F002 guides/greenfield.md claims research outputs are "available
  to `/ardd-plan` automatically" — false; nothing reads research docs
  back (USAGE states this correctly, and ardd-plan has no
  research-loading step). Also says "review and approve the phased
  plan" — the separate approval step no longer exists (selecting the
  plan in `/ardd-tasks` approves it). Fix both.
- [ ] F003 The name "ArDD" survives in 7 places across guides/ (T001's
  rename matched the token ADD but not ArDD) — apply ARDD there too.
- [ ] F004 Stale single-file-register and fixed-set references:
  guides/existing-project.md says features land in `features.md`
  (register is per-feature files now); README line ~6 still says
  "four-plus living documents"; USAGE line ~97 says "reads all four
  artifacts"; CLAUDE.md retains ~7 `features.md` mentions including the
  lint-enum description that no longer matches lint-project.sh's
  per-feature schema. Sweep and fix all.
- [ ] F005 gen-skill-docs.sh emits the core-loop table in glob
  (alphabetical) order — implement appears before plan, defeating the
  loop presentation. Add an explicit ordering (e.g. an `order:`
  frontmatter field or a per-tier ordered list in the generator), with
  the fixture test extended to assert order. [artifacts: constitution]
  is NOT needed — generator-only change.

## UX

- [ ] F006 README's "Future directions" (and Credits) sit as sections
  2–3, before Philosophy — a reader hits speculative roadmap before
  learning what the system is. Move both to the bottom of README.
- [ ] F007 The one-time "Recovering from a rewritten main" note
  (2026-07-04 event) permanently occupies README space — move to
  docs/decisions/ with a one-line pointer, or drop entirely.
- [ ] F008 Add guides/continuing.md — "Working an established project,"
  the missing third guide for steady-state use: log ideas the moment
  you have them (`/ardd-feature`), capture observations from using the
  built thing (`/ardd-feedback`), targeted plans by slug,
  feedback-scoped plans (the two-open-files-two-plans pattern), when to
  run `/ardd-converge`, and a `/ardd-verify`//`/ardd-critique` cadence.
  Fold in the "Adding features after..." tail sections both existing
  guides currently bolt on (each ends with a pointer to the new guide
  instead), and give USAGE's workflow a step or pointer for
  `/ardd-feedback`, which currently appears nowhere in it.

## Reconsidered

- [ ] F009 The two-tier core-loop framing (T002/F001 of the docs plan)
  misclassifies the system's steady state: bootstrap/codify/refine are
  really *setup* (run once, or rarely), while `/ardd-feature` and
  `/ardd-feedback` are the intake side of the *recurring* delivery loop
  (feature/feedback → targeted plan → tasks → implement → merge) — the
  user uses both constantly, and this repo's own history shows every
  plan was feedback- or feature-driven. Reverse to a three-tier
  presentation: **Getting started** (bootstrap, codify, featurize),
  **The core loop** (feature, feedback, refine, plan, tasks,
  implement), **Extensions** (everything else). Mechanically: re-tier
  the `tier:` frontmatter values, teach gen-skill-docs.sh (and its
  fixture test) a third tier, regenerate README tables + WORKFLOW.md,
  and align USAGE's numbered steps to the delivery loop (research moves
  out of the numbered steps to Extensions, matching README).
