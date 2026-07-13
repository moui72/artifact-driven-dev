---
plan: plan-worktree-reap-and-fanout-2026-07-12-c560.md
generated: 2026-07-12
status: in-progress
---

# Tasks

## Phase 1: Reap script (test-first)

- [x] T001 Create `scripts/worktree-reap.sh` (POSIX sh, target-side —
  installed to `ardd-scripts`): enumerate every worktree of the repo except
  the primary and the current one (`git worktree list --porcelain`); for
  each, a reap candidate iff its branch is fully merged into the local
  default branch (`git merge-base --is-ancestor <branch> <default>`,
  default from `branch-info.sh` alongside) AND its tree is clean
  (`git -C <path> status --porcelain` empty); reap = `git worktree remove
  <path>` + `git branch -d <branch>` (never `-D`, never `--force` on a
  dirty tree — `branch -d`'s own unmerged refusal is the second net);
  per-worktree output `reaped=true path=<p> branch=<b>` or
  `reaped=false path=<p> branch=<b> reason=unmerged|dirty|detached|
  remove-failed`; `--dry-run` prints `candidate=` lines and mutates
  nothing; exit 0 when everything eligible was reaped or nothing existed,
  exit 1 only on a reap attempt that failed. Test-first:
  `scripts/test-worktree-reap.sh` against throwaway repos with real
  worktrees — merged+clean reaped (worktree gone, branch gone); unmerged
  kept with reason; dirty kept with reason; detached kept; primary and
  cwd never candidates (run the script FROM a worktree to pin the
  cwd rule); `--dry-run` leaves everything intact. Red before
  implementation. CI job in `.github/workflows/lint.yml` same commit;
  `install.sh` ships it to `ardd-scripts` + installed-and-executable
  assertion in the install tests.

## Phase 2: Wiring

- [x] T002 Wire the reap into `skills/ardd-implement/SKILL.md`'s
  post-delegation coordinator steps: after a successful merge (either
  `merge_policy` path), run `worktree-reap.sh` (installed copy at
  `.claude/skills/ardd-scripts/worktree-reap.sh`, coordinator
  absolute-path fallback — the standard present-or-fallback rule) and
  include its output in the completion report; on `reaped=false` surface
  the reason verbatim, never force. Replace the prose that currently
  implies manual `git worktree remove`/`branch -d`. Also update
  `skills/ardd-status/SKILL.md`: the in-flight step additionally runs
  `worktree-reap.sh --dry-run` and lists any `candidate=` lines in the
  In Flight section as "merged, reapable" (visibility only — status never
  mutates worktrees).

- [x] T003 Dogfood verification: in this repo, create a throwaway branch +
  worktree, commit a trivial change there, merge it to the default branch,
  then run `worktree-reap.sh` from the primary and confirm it reaps
  exactly that worktree (and nothing else); confirm `--dry-run` had listed
  it as candidate first. Clean state after. This is a live check, not a
  new test file (T001's fixtures already pin behavior).

## Phase 3: Fan-out

- [ ] T004 Update `skills/ardd-implement/SKILL.md`'s pick/delegation flow
  for fan-out: when `tasks-list.sh` shows more than one `ready` file (and
  `delegation` is `eager` or the user answers yes), offer multi-select
  delegation — one `Agent` worktree subagent per selected file, launched
  in parallel, each with the standard align-first preamble; the
  coordinator handles each report-back independently as it arrives
  (core.bare check, `merge_policy` merge, reap — merges serialize
  naturally). Reword the "another worktree is mid-run — ask whether to
  wait" caution to informational ("N runs in flight" — parallel runs are
  a supported mode; report-file conflicts are prevented by the merge
  driver, code conflicts still abort-and-ask per `merge_policy`). The
  same-file claim check stays a hard exclusion from the pick list.

- [ ] T005 [parallel] Docs: CLAUDE.md commands block gains
  `worktree-reap.sh`/`test-worktree-reap.sh`; its worktree-native-state
  notes gain the reap step and fan-out mode (and drop any "nothing removes
  a merged worktree" phrasing); README/USAGE delegation narratives
  updated. `lint-docs.sh` + full pre-commit suite green.
