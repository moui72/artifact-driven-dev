---
plan: plan-disposable-report-merge-driver-2026-07-12-c310.md
generated: 2026-07-12
status: in-progress
---

# Tasks

## Phase 1: Driver mechanism (test-first)

- [x] T001 Extend `install.sh` to ship/maintain `.project/.gitattributes`
  in the target: entries `STATUS.md merge=ours`, `DEFECTS.md merge=ours`,
  `TRACKER.md merge=ours`, `audit.md merge=ours` (paths relative to
  `.project/` — the attributes file lives inside the directory ARDD owns,
  never the target's root, mirroring the gitignore-ceiling discipline).
  Create-if-absent, append missing entries, never duplicate, preserve
  user-added lines — the `.worktreeinclude` handling is the pattern to
  copy, including its regression-test shape. Also add a deterministic
  post-install check: if `.project/.gitattributes` contains a `merge=ours`
  entry but `git config --get merge.ours.driver` is empty in the target,
  print the one-time opt-in suggestion (`git config merge.ours.driver
  true`) — suggest-and-check like the hooksPath convention, never mutate
  the user's config. Test-first: extend the install fixture tests (create,
  idempotent re-run, user-line preserved, warning printed when driver
  unset, silent when set) — red before implementation.

- [ ] T002 End-to-end behavior regression test
  (`scripts/test-merge-driver.sh` + CI job in the same commit): in a
  throwaway repo with the attributes file and `merge.ours.driver true`,
  two branches editing `.project/STATUS.md` divergently merge cleanly with
  the current branch's version kept (assert content); the same setup
  WITHOUT the driver config produces a normal conflict (degradation
  pinned — assert conflict markers/exit code). Wire into CI
  (`.github/workflows/lint.yml`); `hooks/pre-commit` picks it up by glob
  automatically.

- [ ] T003 Dogfood: run `./install.sh .` so this repo gets
  `.project/.gitattributes`; set `git config merge.ours.driver true` here
  (our clone, our opt-in); live-verify with a real throwaway two-branch
  STATUS.md conflict in this repo (create branch, divergent edits, merge,
  confirm clean + ours; delete the branch). Commit the attributes file.

## Phase 2: Prose catch-up

- [ ] T004 [parallel] Update the prose that says the rule is
  interactive-only: `skills/ardd-implement/SKILL.md`'s `merge_policy: auto`
  conflict note ("never auto-resolve, not even the disposable report files
  … until the merge-driver feature lands" → with the driver configured,
  report-file conflicts no longer occur; the interactive take-either-side
  rule remains as the unconfigured-driver fallback); README's
  "Concurrency and `.project/` merge conflicts" section; CLAUDE.md's
  single-writer/disposable notes. `lint-docs.sh` + pre-commit green.

## Phase 3: Smoke-tier expansion [defect: 7efff3a5]

- [ ] T005 [defect: 7efff3a5] Add smoke scenarios for the surfaces the
  sixth/seventh-pass defect names, following the existing
  scenario + `smoke-assert.sh` pattern in `.github/workflows/smoke.yml`:
  (a) Reconcile mode — seed the fixture project with an `in-progress`
  tasks file whose codebase work is ahead of its checkboxes, run
  `claude -p "/ardd-implement --reconcile <file>"`, assert checkboxes
  advanced and status legal; (b) `/ardd-init` greenfield — scripted
  design-conversation prompt, assert `.project/artifacts/constitution.md`
  exists with valid frontmatter and STATUS.md was seeded; (c) `/ardd-init`
  existing-code mode against a minimal fixture codebase, assert artifacts
  reverse-engineered. Scenarios stay secret-gated and path-filtered
  exactly as the existing two.

- [ ] T006 [defect: 7efff3a5] Document the smoke tier's standing state
  where contributors will see it: a short note in the workflow README (or
  `.github/workflows/smoke.yml` header comment + README) stating the
  `ANTHROPIC_API_KEY` secret is deliberately unprovisioned, what
  provisioning it enables, and that scenarios must be kept current with
  state-mutating skill paths (constitution Quality Standards). No
  constitution change — this documents reality at the point of contact.
