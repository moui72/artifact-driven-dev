---
status: approved
branch: v1-0-0-pre-cut-testing-finding
created: 2026-07-15
features: []
surfaced-defects: []
---

# Plan: fix v1.0.0 pre-cut testing findings

## Goal

Fix the 13 issues (4 bugs, 9 UX) surfaced by the v1.0.0 pre-cut dry-run
testing pass across two feedback batches:
`feedback-v1-0-0-pre-cut-testing-findings-0344.md` (F001–F006, the
original 4-scenario pass) and
`feedback-v1-0-0-pre-cut-testing-redrive-findings-695b.md` (F001–F007,
the redrive of the 3 scenarios that lost their reports to a spend-limit
outage). Folded into one plan since both batches came from the same
testing effort and several items touch overlapping surfaces
(`/ardd-init`, `/ardd-update`, the reporting skills).

**A note on the shared `F00N` numbering across the two feedback files**:
this plan's Phase Breakdown below disambiguates by feedback filename
where both batches use the same ID (e.g. two different "F001"s) —
always read the filename prefix, not the bare ID, when tracing a task
back to its source.

## Scope

**In scope, from `feedback-...-0344.md` (original batch):** F001
(`worktree-align.sh` silent non-worktree collapse), F002 (`/ardd-init`
reverse-engineering entity-completeness gap), F003 (gitignore suggestion
visibility — scoped narrower than the feedback's literal ask, see below),
F004 (constitution-suggestion catalog scale sensitivity), F005
(`/ardd-defects` nudge after brownfield init), F006 (`/ardd-update`
resolution diagnostics).

**In scope, from `feedback-...-695b.md` (redrive batch):** F001
(`lint-project.sh` Sync Impact Report arrow parsing), F002 (`/ardd-defects`
staleness signal — scoped narrower than the feedback's literal ask, see
below), F003 (`/ardd-implement` collaborative-mode `gh pr create` failure
path undocumented), F004 (`/ardd-plan` task-phrasing assumes existing
code), F005 (`ardd-update-check.sh`/SKILL.md field-name mismatch), F006
(`/ardd-diagram` silent README creation), F007 (workflow-field
stamped-vs-inline documentation clarity).

**Out of scope, with reasoning:**
- **F003 as literally proposed** ("self-apply the `.gitignore` pattern
  the way `.worktreeinclude` does") conflicts with a deliberate, standing
  decision: install.sh never modifies a target's `.gitignore` — only
  suggests — precisely because `.gitignore` is content the user owns and
  controls, unlike `.worktreeinclude`, which is a harness-internal
  mechanism with no user-authorship expectation (CLAUDE.md's gitignore
  ceiling discipline, install.sh's own comments around its suggestion
  block). This plan does NOT add auto-editing of `.gitignore`. Instead it
  scopes F003 to what the underlying complaint actually needs: making the
  existing suggestion harder to miss (a distinct, clearly-marked block
  rather than one line among many), not auto-applying it.
- Re-running any further untested scenarios — none remain; both feedback
  batches together cover all 7 original test scenarios.
- **Redrive F002 as literally proposed** ("record something like a commit
  SHA each `DEFECTS.md` claim was checked against, so staleness is
  detectable without a full re-run") is a real feature, not a small fix —
  it needs schema design (per-claim vs whole-report staleness marker,
  how `/ardd-status` would surface it, whether `lint-project.sh` needs a
  new enum) disproportionate to a cleanup plan built from dry-run
  findings. This plan scopes it down to what's cheap and unambiguous: a
  one-line caveat in `DEFECTS.md`'s own template/header noting it's a
  point-in-time snapshot that can go stale immediately, not a build-out
  of staleness tracking. If per-claim staleness detection is wanted
  later, that's a `/ardd-backlog` entry, not squeezed into this plan.

## Technical Approach

Thirteen independent fixes across ten files, none touching
`.project/artifacts/` (no artifact declares any of this behavior — it's
all skill-prose, script logic, and one template). Grouped into 5 phases by
which surface they touch: worktree/delegation machinery (original F001),
`/ardd-init` (original F002/F004/F005), install/update reporting
(original F003/F006), deterministic-script fixes from the redrive batch
(redrive F001/F002/F005), and skill-prose fixes from the redrive batch
(redrive F003/F004/F006/F007). No shared dependencies between phases;
within a phase, tasks touch different files and are independent.

## Phase Breakdown

### Phase 1: delegation machinery — F001

- [ ] T001 [artifacts: none] Fix `scripts/worktree-align.sh` to positively
  verify it's running in a genuine linked worktree, not the primary
  checkout. A linked worktree's `.git` is a regular *file* (pointing at
  the real gitdir); the primary checkout's `.git` is a *directory*. Add a
  check early (after the existing `is-inside-work-tree` check, before the
  dirty check) that `[ -f .git ]` — i.e. `.git` at the repo root is a
  file, not a directory — and if not, print `aligned=false` /
  `reason=not-a-worktree` and exit 1, mirroring the existing
  reason-code output format exactly. Update the script's header comment
  block to document the new failure mode alongside the existing four.
  Test-first (constitution Principle V, deterministic-check paradigm):
  add a case to `scripts/test-worktree-align.sh` that runs the script
  from the **primary checkout itself** (not a linked worktree) against a
  fixture repo and asserts `aligned=false reason=not-a-worktree` exit 1 —
  confirm this fixture fails before the fix, passes after. [feedback: findings-0344/F001]

### Phase 2: `/ardd-init` — F002, F004, F005

- [ ] T002 [artifacts: none] In `skills/ardd-init/SKILL.md`'s
  existing-codebase reverse-engineering steps: strengthen the entity/schema
  discovery instruction so it doesn't rely on a single structural
  convention (e.g. "every entity has a colocated Zod schema") to enumerate
  entities. Add explicit guidance to cross-check entity completeness using
  at least two independent signals where the codebase offers them (e.g.
  ORM/schema files AND database migration files AND route handlers AND
  type definitions — whichever the detected stack actually has), and to
  flag in the generated artifact's `[OPEN: ...]` items any entity the
  survey found via only one signal, as a lower-confidence claim worth a
  human second look. Documentation-only change — no test task (Constitution
  Principle V's documentation-only exception). [feedback: findings-0344/F002]
- [ ] T003 [artifacts: none] [parallel] In `skills/ardd-init/SKILL.md`:
  add project-scale sensitivity to the constitution-suggestion catalog
  step. Alongside the existing stack-signal detection, detect a
  "trivial project" signal (e.g. fewer than some small file-count
  threshold, no dependency manifest, or a single source file) and when
  present, default to offering only the catalog's "Always" tier rather
  than the full stack-matched set — with a note the user can ask to see
  the full catalog if they want it. Keep the existing full-catalog
  behavior unchanged for anything not detected as trivial.
  Documentation-only change — no test task. [feedback: findings-0344/F004]
- [ ] T004 [artifacts: none] [parallel] In `skills/ardd-init/SKILL.md`:
  at the end of the existing-codebase (brownfield reverse-engineering)
  path's final report step, add an explicit recommendation to run
  `/ardd-defects` next, in the same session, before treating the
  reverse-engineered artifacts as ready to plan against — with one
  sentence on why (freshly-reverse-engineered artifacts are exactly the
  case where a code-vs-artifact drift check is most likely to catch a
  survey mistake). If this project's `next_step_prompt: true`, this
  recommendation should be eligible for the existing next-step-prompt
  mechanism the same way `/ardd-status` and `/ardd-plan` already offer
  one — check whether `/ardd-init`'s SKILL.md already participates in
  that convention before adding a new one; if it doesn't, a plain-text
  recommendation is sufficient here (don't widen the two-skill
  next-step-prompt scope as a side effect of this task — CLAUDE.md notes
  that scope is deliberately narrow). Documentation-only change — no test
  task. [feedback: findings-0344/F005]

### Phase 3: install/update reporting — F003, F006

- [ ] T005 [artifacts: none] In `install.sh`'s `.gitignore` suggestion
  block (near the `.claude/skills/ardd-*/` guidance): make the suggestion
  visually distinct from the surrounding output — a clearly bounded
  block (e.g. a `---` separator or an all-caps `ACTION NEEDED` marker,
  matching whatever the script's existing warning-block convention is, if
  it has one) rather than one line among general install output — so it
  survives being read in a long transcript. Do NOT add any code that
  writes to the target's `.gitignore` — this stays suggestion-only per
  the standing ceiling decision (see Scope). Add/update a case in
  `scripts/test-install.sh` asserting the suggestion block's distinct
  marker text appears in output when `.gitignore` doesn't cover
  `.claude/skills/ardd-*/`. [feedback: findings-0344/F003]
- [ ] T006 [artifacts: none] [parallel] In `scripts/source-resolve.sh`:
  when resolution completes but the resulting ref is NOT the newest tag
  the remote actually has (i.e. a fetch happened, tags were seen, but an
  older tag was selected than what's technically available — the
  propagation-lag scenario F006 hit), emit a diagnostic line distinguishing
  "resolved to the newest tag we could see" from cases where something
  prevented seeing a newer one (e.g. `note=fetch-skipped-fresh-cache` when
  the offline-tolerant fetch skip logic applied, vs. no note when the
  fetch genuinely ran and this really is the newest available tag).
  Relay this note through `/ardd-update`'s step-1 reporting in
  `skills/ardd-update/SKILL.md` (it already relays `warning=offline` and
  `warning=no-tags` the same way — extend that existing relay list, don't
  invent a new mechanism). Add a case to
  `scripts/test-source-resolve.sh` covering the fresh-cache-skip note.
  [feedback: findings-0344/F006]

### Phase 4: deterministic-script fixes — redrive F001, F002, F005

- [ ] T007 [artifacts: none] Fix `scripts/lint-project.sh`'s Sync Impact
  Report version-arrow parsing (around line 199, the
  `sed -E 's/.*→[[:space:]]*([0-9.]+).*/\1/'` extraction of `sir_ver` from
  a `Version change:` line). It currently matches only the literal Unicode
  arrow `→`; an ASCII `->` (or `-->`) silently fails to extract anything,
  leaving `sir_ver` empty and producing the misleading "Sync Impact Report
  targets version '' but footer says 'X'" error instead of a message that
  actually names the problem. Extend the pattern to match `→`, `->`, and
  `-->` equivalently. Test-first (Constitution Principle V): add a case to
  `scripts/test-lint-project.sh`'s fixtures using an ASCII `->` arrow in a
  `Version change:` line and assert it's accepted identically to the `→`
  case — confirm the fixture fails before the fix, passes after.
  [feedback: redrive-695b/F001]
- [ ] T008 [artifacts: none] [parallel] In `skills/ardd-defects/SKILL.md`,
  add a one-line caveat near the `_Last verified: YYYY-MM-DD_` footer
  template (both occurrences) noting that `DEFECTS.md` is a point-in-time
  snapshot against the codebase as of that date/commit — any claim in it
  can be invalidated by a subsequent commit, and a stale-looking report is
  expected, not a bug, until the next `/ardd-defects` run. Documentation-only
  change — no test task. (Full per-claim staleness tracking is explicitly
  out of scope for this plan — see Scope section.) [feedback:
  redrive-695b/F002]
- [ ] T009 [artifacts: none] [parallel] Align the field-name mismatch
  between `scripts/ardd-update-check.sh`'s actual output (`latest-release=<tag>`
  in the common "behind" case; `source-tip=<y> note=no-releases` only in
  the no-releases fallback — see the script's own header comment, lines
  26–28) and `skills/ardd-status/SKILL.md`'s doc example (which shows only
  `behind installed=<x> source-tip=<y>`, implying that's always the field
  name). Update the SKILL.md line to show both cases distinctly: the
  common `behind installed=<x> latest-release=<y>` and the no-releases
  fallback `behind installed=<x> source-tip=<y> note=no-releases`,
  matching what the script actually emits. Documentation-only change — no
  test task (the script's own behavior is correct and already covered by
  its existing tests; only the doc was wrong). [feedback:
  redrive-695b/F005]

### Phase 5: skill-prose fixes — redrive F003, F004, F006, F007

Depends on nothing in Phase 4; independent surfaces, can run in parallel
with it.

- [ ] T010 [artifacts: none] [parallel] In `skills/ardd-implement/SKILL.md`'s
  collaborative-mode paragraph (the one describing offering to push and
  open a draft PR after the first commit): add one sentence covering what
  to do when `gh pr create` fails (no GitHub remote, no `gh` auth, etc.) —
  report the `gh` error verbatim, note the push already succeeded so the
  branch and its state are safe, and let the user open the PR by hand or
  retry once `gh` is usable. Documentation-only change — no test task.
  [feedback: redrive-695b/F003]
- [ ] T011 [artifacts: none] [parallel] In `skills/ardd-plan/SKILL.md`'s
  task-generation step (step 12, the task-quality bullet list): add
  guidance that a task touching a file/function for the first time in a
  project (nothing to modify yet) should be phrased as creating it, not
  extending/modifying it — greenfield's very first feature is the common
  case this bites. Documentation-only change — no test task. [feedback:
  redrive-695b/F004]
- [ ] T012 [artifacts: none] [parallel] In `skills/ardd-diagram/SKILL.md`'s
  upsert step: when the configured destination file (default `README.md`)
  doesn't exist yet, add an explicit one-line note to the skill's own
  report output — e.g. "creating README.md (none existed)" — instead of
  silently originating it via the existing upsert-section.sh append path.
  Documentation-only change — no test task. [feedback: redrive-695b/F006]
- [ ] T013 [artifacts: none] [parallel] In `skills/ardd-init/SKILL.md`
  and `skills/ardd-update/SKILL.md`, wherever `workflow_mode`,
  `next_step_prompt`, `delegation`, and `merge_policy` are introduced
  together: add a short clarifying clause that `workflow_mode` alone is
  written inline during artifact authoring (by `/ardd-init` directly),
  while the other three are written via `ardd-state.sh stamp` — mirroring
  the distinction `docs/reference/configuration.md`'s intro paragraph
  already states (`workflow_mode` "is written into the frontmatter by
  `/ardd-init` directly"), which the SKILL.md-level phrasing doesn't
  currently make obvious to someone reading only the skill files.
  Documentation-only change — no test task. [feedback: redrive-695b/F007]

## Open Questions

None — each task is independently scoped and testable; nothing here
depends on a design decision not already made in this plan.

## Summary of decisions made this run

- Original-batch F003 accepted with narrowed scope: visibility/prominence
  fix, not auto-editing `.gitignore` — the literal ask conflicts with a
  standing, deliberate ceiling decision documented in CLAUDE.md and would
  need its own explicit reversal decision, not a side effect of this
  cleanup plan.
- Redrive-batch F002 accepted with narrowed scope: a one-line staleness
  caveat, not a per-claim staleness-tracking mechanism — that's
  disproportionate scope for a dry-run-findings cleanup plan and belongs
  in `/ardd-backlog` if wanted later.
- Both feedback batches folded into this single plan (rather than a
  second separate plan) since they came from the same testing effort and
  several items touch overlapping files.
- No artifact changes: nothing here is a `.project/artifacts/*.md`-level
  decision: all thirteen fixes are skill-prose or deterministic-script
  behavior.
