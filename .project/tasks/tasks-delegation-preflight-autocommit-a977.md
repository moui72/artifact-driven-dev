---
plan: plan-delegation-preflight-autocommit-2026-07-16-0ca8.md
generated: 2026-07-16
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Audit existing pre-flight mechanics
- [x] T001 [artifacts: constitution] Manually verify `skills/ardd-implement/SKILL.md`
  step 3's pre-flight check (currently: read the chosen tasks file's
  `plan:` frontmatter to resolve its bound plan filename, then run
  `git status --short <plan-file> <tasks-file>`) against three scenarios:
  (1) an untracked plan file, (2) a tracked-but-modified tasks file, and
  (3) a tasks file whose `plan:` frontmatter names a plan file that
  doesn't exist on disk. For each, confirm whether the check correctly
  surfaces the gap or silently misses it. Record the findings as a short
  note in this task's completion (which of the three scenarios pass/fail,
  and why) — no separate artifact file is needed. [defect: n/a] [feedback: F001]

  **Findings (scratch-repo audit):** (1) untracked plan file — `git status
  --short` correctly reports `?? <path>`, check passes. (2)
  tracked-but-modified tasks file — correctly reports ` M <path>`, check
  passes. (3) `plan:` frontmatter naming a plan file that doesn't exist on
  disk — `git status --short <nonexistent-path>` prints **nothing** (exit
  0, silent) because git status only reports paths that exist as
  untracked/modified; a genuinely missing file is indistinguishable from
  "clean." This is a real scope-miss: the pre-flight check never verifies
  the resolved plan filename actually exists before running `git status`
  against it, so a stale/typo'd `plan:` reference silently passes and
  delegation proceeds referencing a plan the subagent can't read. Fixed in
  T004.

## Phase 2: Auto-commit in solo mode
- [ ] T002 [artifacts: constitution] Edit `skills/ardd-implement/SKILL.md`
  step 3's pre-flight paragraph: when `workflow_mode` (grepped from
  `.project/artifacts/constitution.md` frontmatter, same as elsewhere in
  this skill) is absent or `solo`, and `git status --short <plan-file>
  <tasks-file>` shows either path as untracked or modified, replace the
  "offer to commit them now, or block delegation" behavior with a direct
  auto-commit: `git add <plan-file> <tasks-file>` (exact paths only, never
  a sweep), then a signed commit per this repo's `CLAUDE.md` signing
  convention (the on-disk `~/.ssh/id_claude_signing` key), with a message
  naming the tasks file's slug (e.g. `chore(delegation): auto-commit
  <slug> plan/tasks before delegating`). After committing, print the
  committed paths and the resulting `git rev-parse --short HEAD` so the
  action is visible, not silent. Collaborative mode's existing
  ask-or-block behavior is unchanged — this branch of the check only
  applies in solo mode. [feedback: F001]
- [ ] T003 [artifacts: constitution] [parallel] In the same file, move the
  (now auto-committing) pre-flight paragraph so it runs *before* the
  `on_default: false` → `fold-to-main.sh` step (SKILL.md, the block
  around "If `on_default` is `false`... run
  `.claude/skills/ardd-scripts/fold-to-main.sh`"), so an uncommitted
  plan/tasks file is committed before the fold's dirty-tree check runs
  against it and no longer causes a spurious `reason=dirty` refusal.
  [feedback: F001]

## Phase 3: Fix any mechanics gap found in Phase 1 (conditional)
- [ ] T004 [artifacts: constitution] If T001 found a real scope-miss in
  the pre-flight check's frontmatter resolution or `git status --short`
  path scope, fix the prose in `skills/ardd-implement/SKILL.md` step 3 to
  close it. If T001 found no defect, skip this task and record that
  outcome in its completion note instead of leaving it half-done.
  [feedback: F001]
