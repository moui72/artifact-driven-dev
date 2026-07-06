---
status: planned   # open -> planned
created: 2026-07-06
plan: plan-ardd-state-determinism-2026-07-06.md
---

# Feedback — repo critique, part 1 of 2: structural / determinism

Source: full-repo critique session 2026-07-06, revised same day after a
second-agent review. Originally one file; split into two (this one and
`feedback-repo-critique-docs-ca1d.md`) because a feedback file has a
single `plan:` field and these two groups should feed *separate* plans.
This file is the structural/determinism plan's input; all items here are
scriptwork plus the constitution amendments that legitimize it.
Compound items from the first draft are split per ardd-feedback's own
rule, so each can be accepted/declined independently.

## Bugs

None.

## UX

None in this file — see part 2 for docs/UX items.

## Reconsidered

- [x] (P1, decide FIRST — before ardd-state.sh is designed) features.md's
  `· `-separated single-line metadata format is hand-rolled and parsed by
  prose rules duplicated across ardd-feature step 4, ardd-tasks steps 2/6,
  and ardd-sync push step 2. The state script below must embed a
  parser/writer for whichever format wins, so the decision — keep the
  current format, or move to per-feature files with real frontmatter
  (`.project/features/<slug>.md`) — has to be made before that parser is
  built, not after tooling ossifies it. Either outcome is fine; if the
  current format is kept, record it as an explicit decision so it stops
  resurfacing.
- [x] (P1) [artifacts: constitution] Amend constitution Principle II to
  cover state *mutations*, not just checks: deterministic transitions
  that are pure functions of file state get scripts, with prose reserved
  for deciding *when* to invoke them. This is the governing decision the
  build items below implement — confirm or decline it on its own.
- [x] (P1, after the format decision; the concrete deliverable of the
  Principle II amendment) Build `ardd-state.sh` (target-side, installed
  by install.sh) with subcommands that perform each transition atomically
  and validate before writing. Scope, consolidated from the determinism
  audit: (a) plan `draft→approved→superseded` flips; (b) tasks-file
  status flips, checkbox flips, and the next-uncompleted-task locator
  (ardd-implement step 4); (c) feedback bookkeeping — `[x]`/`[-]` item
  marks, `status: planned` flip, `plan:` stamping (ardd-plan step 4);
  (d) feature `Status:` flips plus the features.md parse/append/
  field-edit used by ardd-feature/ardd-tasks/ardd-sync (`· Plan:`,
  `· Tasks:`, `· GH:` appends); (e) frontmatter stamping (`last_updated`,
  `diagram_status`); (f) slug sanitization + hex/filename minting — the
  same kebab/~30-char/`openssl rand -hex 2` rules currently repeated in
  prose across seven skills (ardd-plan 1, ardd-feature 2, ardd-feedback
  4, ardd-tasks 5, ardd-featurize 4, ardd-sync pull 1, ardd-research 4);
  naming stays judgment, sanitizing doesn't. Skills then shrink to
  deciding *when*; several lint-project.sh after-the-fact checks
  (interrupted flip sequences, stuck `generating`) become
  impossible-by-construction. Per Principle V each subcommand ships with
  fixture tests + CI in the same commit.
- [x] (P1) Build `defects-unsurfaced.sh` (target-side): ardd-plan step 5
  currently has the LLM shasum each DEFECTS.md description, glob all
  plans, union their `surfaced-defects:` lists, and set-subtract — pure
  set arithmetic with silent failure modes in both directions (re-prompt
  forever, or never prompt). Sibling to completion-flip-check.sh; the
  skill keeps only the ask-the-user half.
- [x] (P1) [artifacts: constitution] Amend constitution Quality Standards
  to name a behavioral-test tier for skills: fixture-project smoke
  scenarios asserting on file outcomes. Separate decision from the build
  item below — confirm or decline independently.
- [x] (P1, soft dependency: drafting can start anytime, but assertions
  should target ardd-state.sh-driven file state once it lands) Build at
  least one CI smoke scenario: headless `claude -p "/ardd-<skill>"` runs
  against a fixture project, asserting on file outcomes (plan flipped,
  tasks file created with valid frontmatter, features flipped,
  single-writer files untouched).
- [x] (P2 riders — independent scripts, each with its own fixture test +
  CI job per Principle V; parallelizable with everything above except
  where noted) From the determinism audit:
  - `tasks-list.sh`: the tasks-file pick-list (glob, status, exclude
    `abandoned`, x/y checkbox progress, `plan:` bindings) re-described in
    prose in ardd-implement step 1, ardd-converge step 1, ardd-tasks
    step 1.
  - `upsert-section.sh`: ardd-render step 6's find-header/
    replace-until-next-`##`/append README surgery, where an LLM slip can
    eat README content; Mermaid generation itself stays prose.
  - Constitution governance-consistency check added to lint-project.sh:
    footer `Version`/`Last Amended` vs frontmatter `last_updated` vs Sync
    Impact Report version — /ardd-verify already caught exactly this
    drift once (the v1.1.0 defects).
- [x] (P2 rider, independent — skill edit, no script) `/ardd-plan` has no
  way to scope which feedback files a run consumes: step 4 globs every
  `status: open` file and loads them all, so feeding two open feedback
  files into two separate plans relies on the user/LLM carefully leaving
  one file's items unresolved rather than marking them `[-]` (declined),
  which would flip that file to `planned` bound to the wrong plan.
  Discovered while splitting this very critique into two files. Add an
  optional feedback-file argument (mirroring the existing feature-slug
  arguments) that scopes step 4 to the named file(s); unnamed open files
  are neither presented nor marked.
- [x] (P3, explicit non-goals — record so they stop resurfacing) Audited
  and deliberately NOT mechanized per Principle VI: critique.md staleness
  date-compare (advisory, low blast radius), STATUS.md count assembly
  (becomes a byproduct of the scripts above), ardd-sync's remaining `gh`
  glue (error handling needs judgment), the post-delegation `core.bare`
  check (a one-liner), and all genuine-judgment steps (Mermaid content,
  feature naming, converge gap identification).
