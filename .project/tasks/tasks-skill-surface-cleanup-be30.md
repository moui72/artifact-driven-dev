---
plan: plan-skill-surface-cleanup-2026-07-12.md
generated: 2026-07-12
status: in-progress
---

# Tasks

_Execution constraint (plan Technical Approach): all tasks on ONE worktree
branch, each commit green under the full pre-commit suite, a SINGLE merge to
`main` after T018 — no per-phase merges (five consumers read this checkout
live). Read the plan before starting; it carries the review findings these
tasks encode._

## Phase 0: Net and tag

- [x] T001 Cut the rollback ref and fix the verification net first. (a)
  Create a signed annotated pre-cleanup tag `pre-surface-cleanup` on current
  main (plain `git tag -s`, no gh release; do NOT push — the coordinator
  pushes on merge). (b) Test-first, extend `scripts/lint-docs.sh`: add
  `skills/*/SKILL.md` and `templates/*.md` to its scanned set (command-token
  check only; never scan `.sh` files), and add a check that each
  `skills/*/SKILL.md` frontmatter `name:` equals its directory name. Extend
  its fixture/self tests with a deliberately-bad case each, confirmed red
  first. (c) Add a grep gate for owned-report-filename literals: after the
  renames, `critique.md` and `SYNC.md` must not appear in `skills/`,
  `scripts/`, `install.sh`, `new.sh`, README, USAGE, or templates (history
  dirs excluded) — simplest as lines in `lint-docs.sh` guarded to this
  repo's source side.

## Phase 1: Renames (each task independently green)

- [x] T002 Rename `ardd-critique` → `ardd-audit` (co-atomic with its
  migration): `git mv skills/ardd-critique skills/ardd-audit`; frontmatter
  `name: ardd-audit`; description rewritten per the plan's F007 formula
  ending "(formerly ardd-critique)"; every prose reference to
  `/ardd-critique` and `critique.md` across skills/docs/templates updated
  (immutable-history rule: never touch docs/decisions/, completed
  plans/tasks, feature bodies, past DEFECTS entries); owned file becomes
  `audit.md` with a legacy-adoption step ("if audit.md absent and
  critique.md exists, rename it and continue"); ship
  `migrations/0006-critique-to-audit.sh` in the SAME commit — idempotent
  mv-if-exists, never clobber an existing audit.md (warn + skip), fixture
  regression test added to the migrations test in the same commit,
  test-first. Update CLAUDE.md's single-writer list entry.

- [x] T003 Rename `ardd-sync` → `ardd-tracker` (co-atomic with its
  migration): same recipe as T002 — dir, `name:`, F007 description
  "(formerly ardd-sync)", all `/ardd-sync` and `SYNC.md` references,
  owned file `TRACKER.md` + legacy-adoption step,
  `migrations/0007-sync-to-tracker.sh` (same never-clobber semantics +
  fixture test, test-first), CLAUDE.md single-writer entry. Also rename the
  `sync-*.sh` script header comments' references (scripts keep their
  filenames — out of scope per plan).

- [x] T004 Rename `ardd-analyze` → `ardd-status`: dir, `name:`, F007
  description leading with "full cross-artifact consistency check" (cost
  signal) and ending "(formerly ardd-analyze)"; sweep the terminal-handoff
  references in every skill that names `/ardd-analyze` (the canonical list
  lives in the analyze/status SKILL.md intro), plus CLAUDE.md architecture
  mentions, `new.sh`'s analyze-handoff arm, and the `next_step_prompt`
  scope prose (CLAUDE.md + skill bodies). STATUS.md keeps its name; the
  single-writer entry updates to `/ardd-status`.

- [x] T005 Rename `ardd-verify` → `ardd-defects`: dir, `name:`, F007
  description ending "(formerly ardd-verify)"; DEFECTS.md keeps its name;
  sweep `/ardd-verify` references (skills bodies, CLAUDE.md, README/USAGE);
  single-writer entry updates.

- [x] T006 Rename `ardd-feature` → `ardd-backlog`: dir, `name:`, F007
  description ending "(formerly ardd-feature)" with the F009 "instead"
  clause ("bugs and UX problems with existing behavior belong in
  /ardd-feedback instead"); command references sweep. Explicitly out:
  `.project/features/` and `ardd-state.sh feature-*` keep their names.

- [x] T007 Rename `ardd-render` → `ardd-diagram`: dir, `name:`, F007
  description ending "(formerly ardd-render)"; sweep references
  (`render_target`/`render_section` frontmatter fields keep their names —
  data schema, not command surface).

- [x] T008 Edit `scripts/gen-skill-docs.sh` itself: ORDER_setup/core/
  extension lists and its embedded boilerplate prose to the new names
  (drop folded skills — converge/add-artifact/bootstrap/codify leave the
  lists in Phase 2 tasks; coordinate: this task may run after T011 or
  update the lists twice); regenerate `templates/WORKFLOW.md`; sweep the
  remaining functional stragglers: `install.sh` next-steps echo block,
  `templates/constitution-suggestions.md`, `templates/artifacts/
  constitution.md` critique reference, `.github/workflows/smoke.yml`
  (`/ardd-feature` invocation, stale `/ardd-tasks` residue, `SYNC.md`
  absence assertions → TRACKER.md and SYNC.md both), `scripts/
  lint-project.sh` "deliberately NOT validated" comment, cheap script
  header-comment sweep. Full suite green.

## Phase 2: Folds

- [x] T009 Fold converge into implement, delete `skills/ardd-converge/`:
  implement's pick-list step gains the reconcile branch — when the chosen
  file is `in-progress` and no live worktree claims it
  (`inflight-worktrees.sh`), the pick confirmation becomes ONE prompt with
  two outcomes ("reconcile against the codebase first (recommended after an
  interruption), or continue from the next task?"); never a separate
  stacked gate. Migrate converge's reconcile/gap-identification prose and
  add `--reconcile <file>` explicit usage (works on `ready` files too, for
  hotfix-added never-tasked work). Document the pre-existing plain-branch
  blind spot. Update every converge mention: CLAUDE.md (worktree-native
  state sections, commands block), delegation-knob prose in implement,
  README/USAGE, `ardd-status`'s auto-run list, `gen-skill-docs.sh` lists +
  regenerate. Lint + suite green (T001's extended lint now guards skill
  bodies).

- [x] T010 Fold add-artifact into refine, delete `skills/ardd-add-artifact/`:
  absorb its unique lines (conflict check, WORKFLOW.md row note, CLAUDE.md
  registration note) into refine's existing create path; update references
  (README/USAGE tables regenerate via gen-skill-docs.sh).

- [x] T011 Merge bootstrap+codify into new `skills/ardd-init/`, delete both:
  mode detection (existing source files → codify's reverse-engineering
  path; greenfield → interview path) + one confirmation question, no flags;
  F007-formula description written fresh (no "formerly" — two ancestors)
  including the built-in-`/init` redirect clause ("seeds .project/
  artifacts, not CLAUDE.md — for CLAUDE.md use the built-in /init");
  deduplicate the shared steps (constitution suggestions, workflow-field
  questions, WORKFLOW.md, STATUS.md seed, report). Update `new.sh` handoff
  prompts/messaging (both kickoff arms) and `scripts/test-new.sh`:
  handoff-string cases AND the `ardd-bootstrap/SKILL.md` existence
  assertion (~line 101) — extend the tests first, red, then implement.
  Update USAGE "seed your artifacts" merge, guides references (full guide
  reframe is T015), gen-skill-docs lists + regenerate.

## Phase 3: Routing behavior

- [x] T012 Widen `ardd-research` with the proposal-vetting mode: usage line
  and an explicit proposal-vetting example invocation; steps for the
  proposal object (load current artifacts, apply `ardd-audit`'s lens list
  BY REFERENCE — name the section, don't duplicate the list — and answer
  goals / challenges / which committed decisions it reverses /
  is-it-worth-it); output stays a one-off `.project/plans/` doc whose
  closing section recommends `/ardd-backlog <slug>`, `/ardd-plan`, or
  drop. Add the one-sentence routing hint to `ardd-backlog` and
  `ardd-plan` ("substantial or decision-reversing ideas: vet with
  /ardd-research first").

- [x] T013 Argument guards, mirroring `/ardd-plan`'s disambiguation, as an
  explicit early step: `ardd-audit` rejects any argument that isn't an
  existing `.project/artifacts/*.md` name with redirect text pointing to
  `/ardd-research <proposal>`; `ardd-defects` rejects freeform arguments
  with redirect text pointing to `/ardd-feedback`. Both descriptions carry
  the "takes no proposal/observation input" clause.

- [x] T014 Feedback/backlog cross-routing: `ardd-feedback`'s classification
  step gains the fourth outcome (item is a new capability → candidate for
  the register) with BATCHED confirmation — one grouped prompt listing all
  re-file candidates, per-item accept/decline within it, never N sequential
  prompts; on accept, `ardd-state.sh slug` + `feature-create` and omit from
  the feedback file. `ardd-backlog` step 1 gains the mirror check
  (complaint about existing behavior → offer to capture as feedback).
  Feedback's description gains its "instead" clause ("new-capability ideas
  belong in /ardd-backlog instead").

## Phase 4: Docs (structural rewrites — not token sweeps)

- [ ] T015 Rewrite, don't sweep: USAGE core loop renumbered (the "resume
  after interruption" step dissolves into implement's step; init replaces
  the bootstrap/codify pair in "seed your artifacts"); README Philosophy
  verb list rewritten to the new surface; README Concurrency section's
  report-file names; `guides/greenfield.md` + `guides/existing-project.md`
  reframed around `/ardd-init` (their whole framing is bootstrap-vs-codify);
  add a "Renamed in v1.0.0" old→new table to README (six renames + four
  fold destinations) and save the same table as `docs/release-notes-v1.md`
  for T008 of the remote-install-source plan to pass via
  `gh release create --notes-file` (add that pointer to this repo's
  STATUS-visible close-out report, not by editing the other tasks file).
  `lint-docs.sh` (extended) green.

- [ ] T016 `install.sh` prune output learns the rename map: renamed skills
  print `✗ ardd-analyze (renamed — now /ardd-status)` (six entries), folded
  skills print `✗ ardd-converge (folded into /ardd-implement)` (four
  entries), unknown stale dirs keep today's message. Extend the prune
  regression test with a renamed-dir and folded-dir case, test-first.

- [ ] T017 `migrations/0008-workflow-table.sh`: if a target has
  `.project/WORKFLOW.md`, upsert its skills table section from the shipped
  template via `scripts/upsert-section.sh` (consumers must not carry a
  table of dead commands); no-op when absent; idempotent; fixture
  regression test, test-first.

## Phase 5: Codify + close out

- [ ] T018 CLAUDE.md gains the naming-system conventions section
  (report-owners = nouns named for their file; lifecycle actions =
  imperative verbs; capture skills = named for what you hand them; the
  description formula: object → data-flow → redirect clause) and its
  architecture/commands text reflects the final 13-skill surface. Re-run
  `./install.sh .` (self-install: prune renames the six + removes the four
  here too; verify this repo's 5 open critique.md items survive migration
  0006 into audit.md with checkboxes intact); regenerate this repo's
  `.project/WORKFLOW.md`; run the FULL suite + extended lint-docs +
  lint-project against live `.project/`. Do NOT merge, push, or run any
  status/analyze skill — report back to the coordinator, who performs the
  single merge and the post-merge steps.
