---
status: approved
branch: skill-surface-cleanup
created: 2026-07-12
---

# Plan: skill-surface cleanup (pre-v1.0.0 renames, folds, routing)

_Consumes `feedback-critique-design-vetting-gap-0779.md` (F001–F009, all
accepted). Revised after three independent reviews (UX/DevX, architecture,
release-engineering — all approve-with-changes; their findings are folded in
below). **Hard sequencing constraint: this entire plan lands before
`tasks-remote-install-source-18d3.md` T008 cuts `v1.0.0`.** T008–T010
resume after this plan completes._

## Goal

The skill catalog's public surface is finalized for `v1.0.0`: 17 skills
become 13 with names that state each skill's question or object, misrouting
is guarded at the argument level, the transition is tombstoned for existing
users, and the naming system itself is codified.

## Scope

**In (by feedback item):**
- **F001** Report-owner renames: `critique→audit` (+`critique.md→audit.md`),
  `analyze→status`, `verify→defects` (DEFECTS.md keeps its name),
  `sync→tracker` (+`SYNC.md→TRACKER.md`).
- **F002** Capture/action renames: `feature→backlog` (command only),
  `render→diagram`.
- **F003** Fold `converge` into `implement` (offered reconcile; see prompt
  shape below); **F004** fold `add-artifact` into `refine`; **F005** merge
  `bootstrap`+`codify` into `init`.
- **F006** `research` proposal-vetting mode; **F007** naming system codified
  + all descriptions rewritten; **F008** argument guards on audit/defects;
  **F009** feedback/backlog cross-routing.
- **Transition/tombstone work** (review finding): rename-aware prune output,
  old→new table for README + release notes, "(formerly ardd-X)" description
  suffixes for one release cycle.

**Out:**
- Stores and scripts keep their names: `.project/features/`, `ardd-state.sh
  feature-*`, DEFECTS.md, `defects-unsurfaced.sh`, `completion-flip-check.sh`.
- No feedback/backlog store merge (F009 records the rejection).
- No new skills.
- **Immutable history — the sweep's stopping rule:** `docs/decisions/*.md`,
  completed `.project/plans/*` and `.project/tasks/*`, `.project/features/*`
  bodies, and past DEFECTS.md entries are never rewritten to new names.
- Target constitutions carrying `/ardd-critique` from the old template:
  user-owned content, not migrated (template itself is updated).
- Report-file casing stays as-is (`audit.md` lowercase beside uppercase
  STATUS/DEFECTS/TRACKER — matches the critique.md precedent; decided, not
  overlooked).
- T008–T010 of the remote-install-source plan (resume after this).

## Technical Approach

**Atomicity is the governing constraint (review blocker).** All five
consumers currently update from this live checkout, so any intermediate
merge to `main` is instantly consumer-visible; and a skill rename split from
its report-file migration opens a data-loss window (a fresh `/ardd-audit`
with no `audit.md` regenerates and orphans the open `critique.md`
checklist — real open items exist in two consumers and this repo). Therefore:
**the whole plan rides one delegated worktree branch and merges to `main`
exactly once, at completion** — a deliberate, stated exception to solo
mode's eager-merge default, which the single-background-run delegation shape
satisfies naturally. Belt-and-suspenders, `/ardd-audit` and `/ardd-tracker`
each carry a two-line legacy-adoption step ("owned file absent but legacy
name present → rename/adopt before proceeding"), making every
ordering/rollback edge self-healing.

**Rollback:** before Phase 1, cut a signed annotated pre-cleanup tag (plain
`git tag`, pushed; not a gh release) as the known-good ref. Migrations are a
ratchet (`.ardd-applied` never unrecords), so rollback recovery is
"pin to the tag + re-install"; the legacy-adoption step doubles as
roll-forward repair.

**Verification net gets fixed before it's leaned on** (resolves old Open
Question 1 affirmatively): `lint-docs.sh`'s scan extends to
`skills/*/SKILL.md` and `templates/*.md` (not `.sh` files — comment
false-positives; scripts are swept manually), plus a frontmatter
`name:`==dirname check. Owned-filename literals (`critique.md`, `SYNC.md`)
get a one-off grep gate since lint-docs checks command tokens only.

Renames are `git mv` + frontmatter `name:` updates; `install.sh` prune
converges consumers (regression-tested). Folds follow Principle VII.
Constitution body verified clean of renamed names — **no amendment or bump
needed** (`/ardd-update` and `/ardd-plan` are its only live skill mentions).
CLAUDE.md's single-writer list and architecture-section names update in
Phase 1 with the renames; only the new naming-conventions section waits for
Phase 5 (resolves a reviewer-caught contradiction).

## Phase Breakdown

_All phases on one worktree branch; each task's commit green under the full
pre-commit suite; single merge after Phase 5._

### Phase 0 — Net and tag
1. Signed annotated pre-cleanup tag. Extend `lint-docs.sh` (skill bodies +
   templates in DOCS; `name:`==dirname check) with fixture-based tests,
   test-first; add the owned-filename grep gate.

### Phase 1 — Renames (per-rename tasks, each independently green)
2. One task per rename — `critique→audit`, `analyze→status`,
   `verify→defects`, `sync→tracker`, `feature→backlog`, `render→diagram`:
   `git mv`, frontmatter `name:`, every reference to that one name across
   skills/docs/workflows, "(formerly ardd-X)" description suffix. The
   `audit` and `tracker` tasks also switch owned-file names in prose AND
   ship their migrations in the same commit (co-atomicity):
   `migrations/0006-critique-to-audit.sh`, `0007-sync-to-tracker.sh`
   (numbering corrected per review — 0004/0005 exist) — idempotent,
   never-clobber-destination when both files exist (warn + skip; pinned in
   fixture tests, test-first), plus the legacy-adoption prose step.
3. Edit `gen-skill-docs.sh` itself (ORDER lists + embedded boilerplate name
   old skills — it silently degrades ordering otherwise), regenerate
   `templates/WORKFLOW.md`. Sweep the functional stragglers the reviews
   enumerated: `install.sh` next-steps echo, `new.sh` analyze-handoff arm,
   `templates/constitution-suggestions.md`, `templates/artifacts/
   constitution.md` (critique ref), `smoke.yml` (`/ardd-feature` scenario,
   `/ardd-tasks` residue, `SYNC.md` absence assertions), `lint-project.sh`
   not-validated comment, script header comments (cheap sweep).

### Phase 2 — Folds
4. Converge→implement: reconcile offer **as a branch of the pick-list
   confirmation, not a separate gate** (review-pinned shape: chosen file
   in-progress + unclaimed → one prompt, "reconcile first (recommended
   after an interruption) or continue from next task?"; delegation gate
   follows as today) + explicit `--reconcile <file>` opt-in; delete
   converge; update delegation-knob prose + CLAUDE.md worktree sections.
5. Add-artifact→refine (absorb create-path extras; delete add-artifact).
6. Bootstrap+codify→init: mode detection + confirmation question (no
   flags — resolved); F007-formula description written at creation, with
   redirect clause for the harness's built-in `/init` ("seeds .project/
   artifacts, not CLAUDE.md"); delete both; update `new.sh` handoff
   prompts/messaging + `test-new.sh` (handoff-string cases AND the
   `ardd-bootstrap/SKILL.md` existence assertion at line ~101), test-first.

### Phase 3 — Routing behavior
7. Research proposal mode (lens list by reference, usage example, closing
   recommendation section).
8. Argument guards on audit + defects (early step, explicit redirects to
   research/feedback).
9. Feedback/backlog cross-routing with **batched confirmation** (one
   grouped prompt listing all re-file candidates, per-item accept/decline
   inside it — never N sequential prompts); mutual "instead" description
   clauses.

### Phase 4 — Docs (structural rewrites, named — not token sweeps)
10. USAGE: core-loop renumbering (step 5 "resume after interruption"
    dissolves into implement's step), "seed your artifacts" section merged
    for init. README: Philosophy verb list rewritten to the new surface,
    Concurrency section's report-file names, "Renamed in v1.0.0" old→new
    table (doubles as T008's `--notes-file` input — note added for that
    task). `guides/greenfield.md` + `guides/existing-project.md` reframed
    around `init` (31 old-name references are framing, not tokens).
11. `install.sh` prune output learns the rename map: `✗ ardd-analyze
    (renamed — now /ardd-status)` for the six renames and `(folded into
    /ardd-X)` for the four deletions; regression-covered in the prune test.
12. `migrations/0008-workflow-table.sh`: upsert the skills table in a
    target's existing `.project/WORKFLOW.md` from the shipped template
    (via `upsert-section.sh`), so consumers don't carry a table of dead
    commands; fixture-tested, test-first.

### Phase 5 — Codify + close out
13. CLAUDE.md naming-conventions section; `ardd-status` description signals
    full-pass cost; re-run `./install.sh .` (self-install — verify this
    repo's 5 open critique.md items survive the self-migration into
    audit.md); regenerate this repo's `.project/WORKFLOW.md`; full suite +
    extended lint green. Merge to `main` (the single merge); then the
    in-flight release plan's T008–T010 may resume.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| Six renames in one release | The non-breaking window closes at v1.0.0; one consumer-visible discontinuity instead of six. |
| Single deferred merge (exception to solo eager-merge) | Five consumers read this checkout live; per-phase merges expose half-renamed states and a report-file data-loss window. One branch, one merge is the atomicity the transition requires. |
| Three new migrations (0006–0008) | Each is a pure file-state function (mv-if-exists ×2, table upsert) following the established numbered pattern with fixture tests. |

## Open Questions

None — both prior questions were resolved by review (lint-docs extension:
yes, scoped to markdown; init: detection + confirmation, no flags).
