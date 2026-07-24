---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: chore-status-and-devx-feedback
created: 2026-07-23
features: []
surfaced-defects: []
---

# Plan: collaborative-mode delegation alignment fix + STATUS.md legacy tail cleanup

## Goal

Fix `/ardd-implement`'s collaborative-mode delegation preamble to align a
delegated worktree against the current feature branch instead of forcing a
fold-to-main + push + draft-PR sequence before delegation can start, and
clean up `STATUS.md`'s stale, unmaintained legacy `## Recent Releases` /
`## Feature Backlog` tail section.

## Scope

**In scope:**
- `.claude/skills/ardd-implement/SKILL.md` step 3's collaborative-mode
  delegation branch: replace the fold-to-main requirement with
  `worktree-align.sh <branch-info.sh's current-or-default ref>`, make the
  push + draft PR offer visibility-only (no longer a delegation
  prerequisite), and document the cross-branch visibility caveat.
- `STATUS.md`'s legacy `## Recent Releases` / `## Feature Backlog` section
  (lines ~1894-1930): delete it, since its content is redundant with the
  `_Updated:` log's newest entry and it is not touched by any current
  `/ardd-status` run.
- Marking both consumed feedback files (`F76c4`, `F87b6`) incorporated —
  already done in step 4 of this run.

**Out of scope:**
- Solo mode's delegation path (unaffected — keeps `worktree-align.sh`'s
  default-argument, local-default-branch behavior and `fold-to-main.sh` for
  its own on-a-branch eager-background case, per decision record 0004).
- `feedback-delegation-preflight-artifact-gap-44dc.md`'s narrower
  plan+tasks+features+feedback+artifacts preflight fix — already planned
  separately; this plan's ref-alignment approach is a superset fix for the
  general artifact-gap class but doesn't touch that plan's own scope.
- Any change to `/ardd-status`'s current `_Updated:`-log generation logic —
  only the dead legacy tail is removed, not the live log format.

## Technical Approach

**Delegation alignment (F76c4).** `worktree-align.sh` already accepts an
optional `<ref>` argument and only defaults to the local default branch
when the argument is omitted (confirmed by reading the script) — nothing
about it is main-specific. `/ardd-implement` step 3's collaborative-mode
branch currently has no explicit alignment instruction of its own beyond
"same align-first subagent preamble ... as solo mode," which in solo mode
resolves to the no-argument (default-branch) call. The fix makes the
collaborative-mode subagent preamble pass an explicit ref: `branch-info.sh`'s
`current` (or `default`, when `on_default` is already true — the case where
there's nothing to align beyond default anyway). Because git worktrees
share local branch refs, this fast-forwards the feature branch's own
commits — plan, tasks, artifacts, feedback, anything else the plan run
touched — straight into the fresh worktree, with no `fold-to-main.sh` step
and no local-`main`-touching at all. This also means the "work *must* move
to a branch before step 4" requirement in step 3's collaborative-mode intro
is satisfied by a plain `git checkout -b` exactly as today; only the
subsequent align-ref changes.

The push + draft PR offer no longer gates delegation — it becomes a
visibility offer only, made any time after the branch exists (as today),
since ref-alignment doesn't depend on anything having reached `origin`.

Edge cases to encode directly in the SKILL.md prose (per the feedback's
design-consult scope list):
1. On `aligned=false reason=diverged` (or any other reason), stop and
   surface verbatim — same refuse-don't-resolve discipline the fold path
   already has, not a new failure mode.
2. Solo mode is unaffected — no change to its no-argument alignment call or
   its `fold-to-main.sh` eager-background case.
3. Document that a worktree aligned to feature-branch A can't see
   uncommitted work still sitting only on unrelated feature-branch B — this
   is acceptable (the same-file claim check already serializes same-plan
   work, and a fan-out from one plan aligns every subagent to the same
   branch) but must be stated, not silently assumed.
4. Note that once a delegated branch's PR (now carrying the plan/tasks
   commits too) merges, an earlier plan-only draft PR opened before
   delegation becomes redundant/closable/absorbable — state this in the
   prose so a future run doesn't leave two open PRs unexplained.

**STATUS.md legacy tail cleanup (F87b6).** The `## Recent Releases` /
`## Feature Backlog` section reports frozen, stale counts (confirmed via
direct read: it still names `codex-second-harness-support` and
`plan-preview-editor-option` as backlogged, both now `implemented`) and
predates the current pure prepend-and-preserve `_Updated:` log convention.
Since `/ardd-status` is this file's single writer and its current
generation logic never touches this legacy tail, the fix is a one-time
manual removal of the section (not a `/ardd-status` code change) — the
next `/ardd-status` run continues its normal prepend-only behavior
unaffected.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is tracked
in the linked tasks file.

**Phase 1: Delegation alignment fix (F76c4)** — no dependencies
- Update `.claude/skills/ardd-implement/SKILL.md` step 3's
  collaborative-mode delegation branch: replace the implicit
  fold-to-main-shaped alignment with an explicit
  `worktree-align.sh <current-or-default ref>` call, sourced from
  `branch-info.sh`'s `current`/`on_default` output already read in step 2.
  `[artifacts: none]` [F76c4]
- Add the `aligned=false` stop-and-surface, cross-branch-visibility caveat,
  and redundant-draft-PR notes to the same SKILL.md section. [F76c4]

**Phase 2: STATUS.md legacy tail removal (F87b6)** — no dependencies,
parallel with Phase 1 (different file)
- Delete the `## Recent Releases` / `## Feature Backlog` section from
  `.project/STATUS.md` (currently lines ~1894-1930), leaving the
  `_Updated:` log as the file's sole content below its header.
  `[artifacts: none]` [parallel] [F87b6]

## Open Questions

- None — both feedback items were single-fix, no open design questions
  raised during step 4's review.

## Production Annotation Summary

(Omitted — the constitution does not declare a production-annotations
principle.)
