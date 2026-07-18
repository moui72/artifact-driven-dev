---
plan: plan-backlog-assign-epics-automated-2026-07-18-3d8f.md
generated: 2026-07-18
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: `epic` write path (test-first)
- [x] T001 (test-first) Add a regression case to
  `scripts/test-ardd-state.sh` covering `feature-field <slug> epic
  <value>`: set on a feature with no `epic` field, replace on one that
  already has a value, and confirm an unrecognized key (e.g. `bogus`) is
  still refused — mirror the existing `plan`/`tasks`/`gh_issue` test
  blocks' structure exactly. Confirm the new `epic` set/replace cases
  fail against current `scripts/ardd-state.sh` first (red — `epic` isn't
  in the valid-key case statement yet; the unknown-key-refused case
  should already pass, since `epic` is currently indistinguishable from
  any other unrecognized key). Apply the test framework's
  expected-failure marker on this red commit per the constitution's
  full-suite pre-commit hook convention (this repo has no language-level
  xfail marker for its POSIX-sh test scripts — use `--no-verify` with
  the emergency documented in the commit body, per existing precedent in
  this repo's history). [feature: backlog-assign-epics-automated]
- [x] T002 Add `epic` to `scripts/ardd-state.sh`'s `feature-field`
  valid-key case statement (`plan|tasks|gh_issue` becomes
  `plan|tasks|gh_issue|epic`), and update its usage/help text (the
  `feature-field <slug> <plan|tasks|gh_issue> <value>` line) to include
  `epic`. T001's cases go green — remove the expected-failure marker.
  [feature: backlog-assign-epics-automated]

## Phase 2: `--assign-epics` sweep mode (depends on Phase 1 — calls its write path)
- [x] T003 Add `--assign-epics` to `skills/ardd-backlog/SKILL.md`'s
  Usage section (alongside the existing `--from-artifacts` mention) and
  write a new `## --assign-epics mode` section, structured exactly like
  the existing `## --from-artifacts mode` section (same
  numbered-steps-instead-of-1–2 dispatch pattern). Its step 1: walk
  every feature register entry (`.claude/skills/ardd-scripts/feature-list.sh
  --all`, installed copy; fall back to the source repo path
  `scripts/feature-list.sh --all` if absent) and filter to those whose
  `epic` column (5th tab-separated field) is empty. For each, read its
  description and `Why:` line (already present in `feature-list.sh
  --all`'s output — no extra file reads needed beyond what the script
  already returns, though re-reading the full `.project/features/<slug>.md`
  file is fine if more context is needed for judgment). Propose thematic
  groupings by agent judgment, grounded in the actual description/`Why:`
  text — never invent a grouping the text doesn't support. A feature
  with no clear fit to any other feature is proposed as its own
  standalone group (not forced into an unrelated bucket) — mirror the
  atelier dry-run precedent (`plan-time-defrag-slate-analysi`'s
  research inputs) that explicitly left a speculative, non-clustering
  item unbundled rather than forcing it in. If there are no candidates
  (every feature already has `epic` set, or the register is empty),
  report that and stop. [feature: backlog-assign-epics-automated]
- [x] T004 [parallel] In the same new section, write the confirmation
  step (step 2, mirroring `--from-artifacts`'s step 2 exactly): present
  all proposed groups in ONE grouped `AskUserQuestion` prompt
  (`multiSelect` on) with per-group accept/decline — never N sequential
  prompts. Show each group's member slugs and a one-line rationale for
  the grouping. [feature: backlog-assign-epics-automated]
- [x] T005 In the same new section, write the apply step (step 3,
  mirroring `--from-artifacts`'s step 3's `project-lock.sh check`/
  `touch` discipline): before writing, run
  `.claude/skills/ardd-scripts/project-lock.sh check ardd-backlog`
  (surface any warning, never block); for each accepted group, call
  `.claude/skills/ardd-scripts/ardd-state.sh feature-field <slug> epic
  <value>` (from T002) for every member slug; declined groups are
  dropped, not recorded, matching `--from-artifacts`'s existing
  "the user's judgment is final for this run" framing. After writing,
  run `.claude/skills/ardd-scripts/project-lock.sh touch ardd-backlog`.
  Write step 4 (mirroring `--from-artifacts`'s step 4): report the
  applied group names + slugs and the declined count, then continue
  with the skill's existing step 6 (`/ardd-status` handoff) — no new
  handoff logic needed, since `/ardd-status`'s by-epic breakdown already
  exists from `epics-grouping-in-feature-regi`. No test task —
  prose-only skill-file change; the write calls themselves are already
  covered by T001's regression test. [feature: backlog-assign-epics-automated]
- [ ] T006 Update `docs/reference/skills/ardd-backlog.md`'s hand-written
  body to document `--assign-epics`, mirroring how `--from-artifacts` is
  already documented there (a short paragraph: what it does, the
  batched-confirmation discipline, a pointer to what `epic:` values are
  used for). [feature: backlog-assign-epics-automated]
