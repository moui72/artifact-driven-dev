---
plan: plan-v1-0-0-pre-cut-testing-finding-2026-07-15-b89e.md
generated: 2026-07-15
status: in-progress
---

# Tasks

## Phase 1: delegation machinery — findings-0344 F001

- [ ] T001 Fix `scripts/worktree-align.sh` to positively
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
  confirm this fixture fails before the fix, passes after. [feedback:
  findings-0344/F001]

## Phase 2: `/ardd-init` — findings-0344 F002, F004, F005

- [ ] T002 In `skills/ardd-init/SKILL.md`'s
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
  Principle V's documentation-only exception). [feedback:
  findings-0344/F002]
- [ ] T003 [parallel] In `skills/ardd-init/SKILL.md`:
  add project-scale sensitivity to the constitution-suggestion catalog
  step. Alongside the existing stack-signal detection, detect a
  "trivial project" signal (e.g. fewer than some small file-count
  threshold, no dependency manifest, or a single source file) and when
  present, default to offering only the catalog's "Always" tier rather
  than the full stack-matched set — with a note the user can ask to see
  the full catalog if they want it. Keep the existing full-catalog
  behavior unchanged for anything not detected as trivial.
  Documentation-only change — no test task. [feedback: findings-0344/F004]
- [ ] T004 [parallel] In `skills/ardd-init/SKILL.md`:
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

## Phase 3: install/update reporting — findings-0344 F003, F006

- [ ] T005 In `install.sh`'s `.gitignore` suggestion
  block (near the `.claude/skills/ardd-*/` guidance): make the suggestion
  visually distinct from the surrounding output — a clearly bounded
  block (e.g. a `---` separator or an all-caps `ACTION NEEDED` marker,
  matching whatever the script's existing warning-block convention is, if
  it has one) rather than one line among general install output — so it
  survives being read in a long transcript. Do NOT add any code that
  writes to the target's `.gitignore` — this stays suggestion-only per
  the standing ceiling decision. Add/update a case in
  `scripts/test-install.sh` asserting the suggestion block's distinct
  marker text appears in output when `.gitignore` doesn't cover
  `.claude/skills/ardd-*/`. [feedback: findings-0344/F003]
- [ ] T006 [parallel] In `scripts/source-resolve.sh`:
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

## Phase 4: deterministic-script fixes — redrive-695b F001, F002, F005

- [ ] T007 Fix `scripts/lint-project.sh`'s Sync Impact
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
- [ ] T008 [parallel] In `skills/ardd-defects/SKILL.md`,
  add a one-line caveat near the `_Last verified: YYYY-MM-DD_` footer
  template (both occurrences) noting that `DEFECTS.md` is a point-in-time
  snapshot against the codebase as of that date/commit — any claim in it
  can be invalidated by a subsequent commit, and a stale-looking report is
  expected, not a bug, until the next `/ardd-defects` run. Documentation-only
  change — no test task. (Full per-claim staleness tracking is explicitly
  out of scope for this plan.) [feedback: redrive-695b/F002]
- [ ] T009 [parallel] Align the field-name mismatch
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

## Phase 5: skill-prose fixes — redrive-695b F003, F004, F006, F007

- [ ] T010 [parallel] In `skills/ardd-implement/SKILL.md`'s
  collaborative-mode paragraph (the one describing offering to push and
  open a draft PR after the first commit): add one sentence covering what
  to do when `gh pr create` fails (no GitHub remote, no `gh` auth, etc.) —
  report the `gh` error verbatim, note the push already succeeded so the
  branch and its state are safe, and let the user open the PR by hand or
  retry once `gh` is usable. Documentation-only change — no test task.
  [feedback: redrive-695b/F003]
- [ ] T011 [parallel] In `skills/ardd-plan/SKILL.md`'s
  task-generation step (step 12, the task-quality bullet list): add
  guidance that a task touching a file/function for the first time in a
  project (nothing to modify yet) should be phrased as creating it, not
  extending/modifying it — greenfield's very first feature is the common
  case this bites. Documentation-only change — no test task. [feedback:
  redrive-695b/F004]
- [ ] T012 [parallel] In `skills/ardd-diagram/SKILL.md`'s
  upsert step: when the configured destination file (default `README.md`)
  doesn't exist yet, add an explicit one-line note to the skill's own
  report output — e.g. "creating README.md (none existed)" — instead of
  silently originating it via the existing upsert-section.sh append path.
  Documentation-only change — no test task. [feedback: redrive-695b/F006]
- [ ] T013 [parallel] In `skills/ardd-init/SKILL.md`
  and `skills/ardd-update/SKILL.md`, wherever `workflow_mode`,
  `next_step_prompt`, `delegation`, and `merge_policy` are introduced
  together: add a short clarifying clause that `workflow_mode` alone is
  written inline during artifact authoring (by `/ardd-init` directly),
  while the other three are written via `ardd-state.sh stamp` — mirroring
  the distinction `docs/reference/configuration.md`'s intro paragraph
  already states. Documentation-only change — no test task. [feedback:
  redrive-695b/F007]
