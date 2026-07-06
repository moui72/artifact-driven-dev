---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: repo-critique-docs
created: 2026-07-06
features: []
surfaced-defects: [58bd7dd2, 970d935b]
---

# Plan: docs/positioning overhaul + verify-run defect fixes

## Goal

Make the documentation present ADD as it actually is — a small core loop
with opt-in extensions, a declared artifact set, one name, and no shipped
archaeology — and fix the two defects the 2026-07-06 `/ardd-verify` run
recorded.

## Scope

**In:** all six items of `feedback-repo-critique-docs-ca1d.md`
(F001–F006), plus fix tasks for both `DEFECTS.md` entries (58bd7dd2 sed
portability; 970d935b smoke-scenario coverage — user chose expanding
scenarios over softening the constitution's wording).

**Out:** any skill *behavior* change beyond what the docs items require
(the structural work shipped in plan-ardd-state-determinism); provisioning
the smoke API key.

## Technical Approach

Constraint from the second-agent review, honored in phase structure:
F001/F002/F005 (and F003) all edit README.md/USAGE.md, so they are
**sequential tasks on this one branch** — only F004 (CLAUDE.md + skill
prose) and F006 (SKILL.md frontmatter + generators) are textually
parallel-safe, and F006's final table-regeneration lands after the
README restructure to generate from the settled text. Doc tasks are the
testing-paradigm exception (Principle V) except where a deterministic
generator/check is added (F006's lint-docs drift check; the migration
fixture tests; smoke scenarios) — those are test-first as usual.

## Phase Breakdown

### Phase 1 — README/USAGE restructure (sequential, shared files)

- T-A **Name decision + apply (F002)**: pick ADD or ARDD once (user
  confirms at execution; recommendation: ARDD — matches every skill
  name, avoids the ADHD-adjacent collision) and apply it across
  README.md, USAGE.md, guides/, CLAUDE.md prose, and
  constitution.md's Project Scope wording. Pure rename; no file or
  skill-name changes.
- T-B **Tier the docs (F001)**: README/USAGE restructured around the
  core loop (bootstrap/codify → refine → plan → tasks → implement, with
  analyze auto-running) presented as *the* workflow; sync/render/
  critique/verify/featurize/converge/feedback/lint/research/add-artifact
  documented under an "Extensions" section as opt-in. No skill behavior
  change.
- T-C **Demote the four-artifact set (F005)**: README/USAGE stop
  defining the system as "four living documents" — "a declared set of
  living artifacts, typically constitution + the concerns your project
  actually has," with the four as suggested defaults per project shape;
  align ardd-bootstrap step 2's framing (it already uses judgment).
- T-D **Document inline-on-a-branch as the blessed delegation fallback
  (F003)**: a short README/USAGE note — the worktree model depends on
  regressing harness behavior; a harness regression degrades to plain
  `git checkout -b` + inline run, not a workflow outage.

### Phase 2 — archaeology strip (parallel-safe vs Phase 1)

- T-E **(F004)** Move development history out of shipped prose: create
  `docs/decisions/` (source-repo-only); relocate CLAUDE.md war stories
  (bugs #1–3 detail, removed-design narratives) and the History
  notes/smoke-test dates embedded in ardd-implement/ardd-converge/
  ardd-plan to decision records; leave one-line pointers. Target ≥25%
  token reduction across the touched SKILL.md files, zero behavior
  change — land after T-K's expanded smoke scenarios exist if the key
  is provisioned by then, else on prose review alone (Production
  Annotation below).

### Phase 3 — single-source skill descriptions (after Phase 1 merges textually)

- T-F **(F006a)** Add YAML frontmatter (`name:`, `description:`) to every
  `skills/*/SKILL.md`; verify Claude Code still loads them (frontmatter
  is the standard skill format).
- T-G **(F006b)** Generate the README skill table and WORKFLOW.md from
  that frontmatter: a `scripts/gen-skill-docs.sh` (source-side) plus a
  lint-docs.sh drift check (test-first, fixture-based) so descriptions
  can't diverge again; ship WORKFLOW.md as a static file installed by
  install.sh instead of bootstrap/codify transcribing an embedded
  template.

### Phase 4 — verify-run defects

- T-H `[defect: 58bd7dd2]` **Fix BSD-only sed in migrations 0001/0002**:
  replace `sed -i ''` with the portable `sed -i.bak`+rm pattern 0003
  uses; backfill fixture tests for both migrations (test-first: run
  against a pre-0001/0002-shaped fixture, red under GNU-sed semantics
  today via CI, green after) + CI jobs.
- T-K `[defect: 970d935b]` **Expand smoke scenarios** (user decision
  2026-07-06: add scenarios rather than soften the constitution): extend
  `.github/workflows/smoke.yml` with a second scenario covering the
  tasks→implement mutation path (`/ardd-tasks` selecting the plan, then
  a short `/ardd-implement` run against a 1-task file), asserting via
  `smoke-assert.sh` (plan flipped approved, tasks file completed,
  feature flipped implemented, single-writer files untouched). Same
  key-gate + `continue-on-error`; scenarios remain unexecutable until
  the `ANTHROPIC_API_KEY` secret is provisioned.

## Complexity Tracking

| Deviation | Justification (Principle VI) |
|---|---|
| A doc-generation script (`gen-skill-docs.sh`) | Descriptions currently drift across four hand-maintained copies — the duplication threshold is met, and lint-docs already exists to host the drift check |

## Open Questions

- [OPEN: T-A name choice — ADD vs ARDD; user confirms at execution
  (recommendation on record: ARDD)]

## Production Annotation Summary

- T-K's scenarios land key-gated and `continue-on-error`, same as the
  existing smoke job — promotion condition unchanged (provision secret,
  drop continue-on-error).
- T-E lands on prose review alone if the smoke harness still can't
  execute — annotate the decision-record commit if so.
