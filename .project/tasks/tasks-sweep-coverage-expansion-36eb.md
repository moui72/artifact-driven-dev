---
plan: plan-sweep-coverage-expansion-2026-07-20-d493.md
generated: 2026-07-20
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Scenario-brief extensions

- [x] T001 [parallel] Extend `tests/prerelease/scenarios/S1.md` with
  dynamic-badge steps (F001), written against the merged fixed behavior
  (commit 09abad7): in the scratch target, `git remote add origin
  https://github.com/example-owner/example-repo.git` (never push), then
  re-run install with `ARDD_VERSION_BADGE=1` and verify (a) the printed
  two-badge snippet contains `example-owner/example-repo` and the
  target's current branch — no literal `OWNER/REPO/BRANCH`; (b) with
  `<!-- ardd-badge-version-start -->` markers pasted into the README, a
  re-run does NOT reprint the snippet; (c) the default (env unset)
  install output mentions the `ARDD_VERSION_BADGE=1` opt-in; (d) a
  hand-planted `img.shields.io/github/v/release/...artifact-driven-dev`
  badge inside markers draws the printed advisory. Match the brief's
  existing step style/numbering; each step states its expected
  observation. Keep in smoke tier unless the added wall-clock plainly
  threatens S1's budget (plan's open question — leaning smoke).

- [x] T002 [parallel] Extend `tests/prerelease/scenarios/S5.md` (F003):
  with two `backlogged` features present in the scratch project, a bare
  `/ardd-plan` must present the multi-select plannable-inputs picker
  (backlogged slugs + any open feedback); scripted answer: select one
  and confirm the run proceeds scoped to it. One added step in the
  brief's existing style.

- [x] T003 [parallel] Extend `tests/prerelease/scenarios/S7.md` (F004 +
  F005): add (a) a smoke-tier step running `/ardd-status --view` —
  verify the printed summary/in-flight/next-step output AND that
  `STATUS.md` content is byte-identical afterward (capture a checksum
  before/after; single-writer discipline in a read-only mode is the
  regression risk); (b) a full-tier-only step running `/ardd-refine
  constitution --review` against the consumer's real constitution —
  judge that trim proposals are grounded in the project (not a generic
  rubric), batched for confirmation, and never auto-applied. Check the
  brief's existing tier-annotation convention first; if steps aren't
  individually tier-marked, gate (b) with an explicit "full tier only"
  note in prose.

- [x] T004 [parallel] Extend `tests/prerelease/scenarios/S8.md` (F002):
  before the delegation step (S8 already sets up two `ready` tasks
  files), run `/ardd-status` and verify the Work Queue section shows
  pairwise verdicts — `independent` for the disjoint pair, and a plan
  with `features: []` reading `none` (never `unknown`); verify the
  fan-out multi-select picker displays the matrix annotations; during
  flight, verify the ready-vs-worktree-claim pair for the same file
  reads `claimed` (reported as "claimed by in-flight worktree").

## Phase 2: Graduation mechanism

- [ ] T005 Edit `.claude/skills/prerelease-sweep/SKILL.md` per the
  plan's design-of-record (the 2026-07-19 audit proposal — its drafted
  prose, adjusted to the file's current wording): (a) step 3
  (dispatch): while deriving S3's recent-features list from `git log`
  since the last stable tag, grep-and-judge each surface against
  `tests/prerelease/scenarios/*.md` (briefs don't name register slugs
  verbatim — judge, don't slug-match); record any consumer-facing
  surface with no brief line that survived a prior sweep as
  `never-graduated:` lines in RUN.md. (b) step 6 (triage): add a
  mandatory `graduate ∈ yes / no / n-a` column to the TRIAGE.md
  disposition table, plus a Graduation paragraph: accepted findings on
  dispatcher-stressed surfaces (and `never-graduated:` carry-ins) mark
  `yes` and produce a brief-coverage item in the consolidated
  /ardd-feedback capture naming the target scenario and the 1-3-line
  step to add (extend an existing S<n> whose setup provides the
  precondition; new S-file only when no scenario's axes fit); brief
  edits land via the fix plan and are validated by the regression
  rerun — never edit tests/prerelease/ during the sweep. Criteria:
  consumer-facing accepted findings only; taste-defers, harness
  artifacts, source-side surfaces never graduate; smoke-tier additions
  respect the ~1 hr budget (costly steps go full-tier). (c) add the
  one-line mirror to `tests/prerelease/README.md`'s Maintenance rules
  pointing at the skill's step 6. No new script (explicit design
  decision — detection fails the deterministic bar). Run
  `./scripts/lint-docs.sh` green before completion.
