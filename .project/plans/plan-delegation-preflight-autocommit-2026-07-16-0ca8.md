---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: delegation-preflight-autocommit
created: 2026-07-16
features: []
surfaced-defects: []
---

# Plan: Delegation pre-flight auto-commit (solo mode) + mechanics audit

## Goal

Make `/ardd-implement`'s delegation pre-flight check auto-commit an
uncommitted plan/tasks file in solo mode instead of asking, and confirm
(or fix) that the check's existing frontmatter-resolution and
`git status --short` scoping actually catch every uncommitted-file case
it's supposed to.

## Scope

**In scope:**
- `skills/ardd-implement/SKILL.md` step 3's pre-flight check: in solo
  mode, on the current (usually default) branch, auto-commit the
  uncommitted plan and/or tasks file(s) rather than asking — scoped
  `git add` to exactly those paths, never a sweep — and announce what was
  committed (paths + short hash).
- Reordering: when `on_default` is `false`, this auto-commit must run
  *before* the `fold-to-main.sh` dirty-tree check (SKILL.md ~line 130-144),
  since an uncommitted plan/tasks file is exactly what would make that
  fold refuse with `reason=dirty`.
- Collaborative mode keeps the existing ask-or-block behavior — this
  item is solo-mode-only per the feedback's own scoping.
- Auditing the pre-flight's existing mechanics (`plan:` frontmatter
  resolution on the tasks file, `git status --short <plan-file>
  <tasks-file>` path scope) against realistic scenarios — untracked
  files, modified-but-tracked files, a tasks file whose `plan:`
  frontmatter doesn't resolve — to rule out a silent scope-miss as an
  independent bug from the ask-vs-auto-commit UX question.

**Out of scope:**
- Pushing to a remote (a separately-owned decision, per the feedback).
- Collaborative mode's behavior.
- Any change to `fold-to-main.sh` itself unless the audit finds a real
  defect in it (none is currently confirmed).

## Technical Approach

`skills/ardd-implement/SKILL.md` step 3 currently reads `plan:`
frontmatter off the chosen tasks file to resolve the bound plan's
filename, then runs `git status --short <plan-file> <tasks-file>` and,
on any output, offers to commit or blocks. This plan changes that
prose: in solo mode (`workflow_mode` absent or `solo`, grepped the same
way step elsewhere in the same skill already does), on a dirty result,
commit both paths directly (`git add <plan-file> <tasks-file>` — exact
paths only — then a signed commit per this repo's own signing
convention, `chore(delegation): auto-commit plan/tasks before
delegating` or similar) and print what was committed (paths + `git rev-parse
--short HEAD`), then proceed. Collaborative mode is untouched: still ask
or block.

The reordering (auto-commit before the `on_default: false` fold) is a
straight move of the pre-flight paragraph earlier in step 3's prose,
ahead of the `fold-to-main.sh` invocation — no script changes, since
both are already prose-driven steps in the same skill file.

The mechanics audit is manual verification, not a script: walk the three
scenarios above by hand (or with a throwaway scratch repo) against the
current prose and current `branch-info.sh`/`git status --short`
behavior, and fix the prose if a gap is found. No new deterministic
script is expected — Principle II already puts this check's actual
mutation (`git add`/`git commit`) in scripted territory (a plain `git`
invocation is already deterministic), but the *decision* of what counts
as "the chosen tasks file's bound plan" stays prose-resolved, matching
how the rest of this skill already interleaves prose judgment with
scripted state changes.

## Phase Breakdown

### Phase 1: Audit existing pre-flight mechanics
- T001 [artifacts: constitution] Manually verify `skills/ardd-implement/SKILL.md`
  step 3's pre-flight check against three scenarios: an untracked plan
  file, a tracked-but-modified tasks file, and a tasks file whose `plan:`
  frontmatter names a plan file that doesn't exist on disk. Record
  findings inline as this task's completion note (no separate artifact
  needed — this is a one-time verification, not a durable design
  decision). [feedback: F001]

### Phase 2: Auto-commit in solo mode (depends on Phase 1 confirming no blocking defect)
- T002 [artifacts: constitution] Edit `skills/ardd-implement/SKILL.md`
  step 3: in solo mode, replace the "offer to commit them now, or block
  delegation" pre-flight behavior with a direct, scoped auto-commit
  (`git add <plan-file> <tasks-file>` — exact paths only, followed by a
  signed commit per this repo's `CLAUDE.md` signing convention) that
  announces the committed paths and resulting short hash. Collaborative
  mode's ask-or-block behavior is unchanged. [feedback: F001]
- T003 [artifacts: constitution] [parallel] In the same file, move the
  (now auto-committing) pre-flight paragraph ahead of the `on_default:
  false` → `fold-to-main.sh` step, so an uncommitted plan/tasks file is
  committed before the fold's dirty-tree check runs against it.
  [feedback: F001]

### Phase 3: Fix any mechanics gap found in Phase 1 (conditional)
- T004 [artifacts: constitution] If Phase 1 found a real scope-miss (e.g.
  frontmatter resolution failing silently, or `git status --short`
  missing a case), fix the pre-flight prose to close it. Skip this task
  entirely if Phase 1 finds no defect — record that outcome instead of
  leaving this task half-done. [feedback: F001]

## Open Questions

- Should the auto-commit message be a fixed string or should it embed
  the tasks file's slug/plan name for traceability? (Leaning: embed the
  slug — cheap and matches this repo's existing commit-message
  conventions of naming what changed.)
- Phase 1's audit may find nothing wrong, in which case Phase 3 is
  skipped — this is written as a conditional phase deliberately, per the
  feedback's explicit request not to assume the ask-vs-auto-commit
  framing is the whole story.
