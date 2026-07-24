---
status: approved
branch: chore-feedback-status-readines
created: 2026-07-23
features: []
surfaced-defects: []
---

# Plan: ardd-state.sh stamp arg-safety + delegation pre-flight artifact-gap fix

## Goal

Make `ardd-state.sh stamp` reject unexpected trailing arguments instead of
silently dropping them, and extend `/ardd-implement`'s delegation pre-flight
to cover every path a plan run may have edited (artifacts, feature-register
flips, feedback marks), not just the plan and tasks files.

## Scope

In scope:
- `.claude/skills/ardd-scripts/ardd-state.sh`'s `cmd_stamp` — reject a
  non-empty 4th positional argument.
- `.claude/skills/ardd-implement/SKILL.md`'s delegation pre-flight step —
  widen its dirty-check/auto-commit path list beyond `<plan-file>
  <tasks-file>`.

Out of scope:
- Multi-pair stamping (`stamp <file> key1 val1 key2 val2 ...` applying all
  pairs) — the feedback flagged this as an alternative direction, but no
  caller today needs it and every existing call site passes exactly one
  pair; rejecting extras is the smaller, sufficient fix.
- Any other `ardd-state.sh` subcommand's argument handling — only `stamp`
  was flagged.

## Technical Approach

**`stamp` arg-safety (F001, `feedback-ardd-state-stamp-silent-extra-args-1625.md`).**
`cmd_stamp` (`ardd-state.sh:330-332`) reads only `$1 $2 $3` into
`file`/`key`/`val` and never inspects `$4` onward, so
`stamp <file> key1 val1 key2 val2` silently applies only `key1`/`val1` and
drops the rest with no error. The fix adds one guard at the top of
`cmd_stamp`: after the existing `need <file> <key> <value>` check, `shift 3`
and check `[ "$#" -eq 0 ]` — if anything remains, `dieu` with a message
naming the unexpected extra argument(s). A positional-count check, not a
value/`-z` check, so an explicitly empty trailing argument is rejected too
(a value check would wrongly treat an empty string as "no argument" —
caught by CodeRabbit review on PR #15, after this plan's initial draft
proposed the value-based form). Every existing caller across the
skill prose passes exactly one `key val` pair, so this is a pure
tightening — no existing call site regresses.

**Delegation pre-flight artifact-gap (F001, `feedback-delegation-preflight-artifact-gap-44dc.md`).**
`/ardd-implement`'s pre-flight (`ardd-implement/SKILL.md:161-195`) resolves
the tasks file's bound plan via its `plan:` frontmatter, then runs
`git status --short <plan-file> <tasks-file>` and (in solo mode) `git add`s
only those two exact paths. But a single `/ardd-plan` run that targeted
feature slugs, resolved feedback, or surfaced defects also touches
`.project/artifacts/*.md` (step 3d), `.project/features/<slug>.md` (step
3d's register write, step 11's `feature-flip`/`feature-field`, step 14's
`tasked` flip), and `.project/feedback/feedback-*.md` (step 4's
`feedback-mark`/`feedback-planned`) — none of those paths are covered by
the pre-flight's fixed two-file list. Since a delegated worktree only sees
state that has reached local `<default>` (via `worktree-align.sh`'s
fast-forward), any uncommitted sibling edit stays invisible to the
subagent the same way an uncommitted plan/tasks file would. The fix widens
the pre-flight's path list, computed the same way the plan's own
frontmatter already ties these files together:
- The plan's `features:` frontmatter list resolves directly to
  `.project/features/<slug>.md` for each slug — always readable, already
  the field this pre-flight has to open to resolve the bound plan anyway.
- The consuming feedback files are discoverable by globbing
  `.project/feedback/feedback-*.md` and keeping any whose `plan:`
  frontmatter names this plan's filename.
- `.project/artifacts/*.md` files a plan may have edited have no
  frontmatter back-reference to the plan, so the pre-flight instead checks
  `git status --short .project/artifacts/` as a whole and detects any
  dirty/untracked artifact file it finds — coarser than the other two
  (which are exact matches), but the only mechanically available signal
  here.

  The `git status --short <paths...>` check takes this widened path list
  (plan, tasks, resolved feature files, resolved feedback files, and the
  artifacts directory) instead of the fixed two paths. **Auto-commit is
  narrower than detection, though**: solo mode's no-prompt `git add` covers
  only the plan/tasks/feature/feedback set — every one an exact match
  provably tied to this plan. `.project/artifacts/` is deliberately
  excluded from that automatic step even in solo mode: since an artifact
  carries no back-reference, blindly `git add`-ing the whole directory
  risks silently committing an unrelated, still-in-progress edit the user
  never intended to commit yet (raised by CodeRabbit review on PR #14/#16
  after this plan's initial draft proposed including it unconditionally).
  If the artifacts check finds anything dirty, ask the user whether to
  include it in a second commit before delegating — a narrow, deliberate
  exception to solo mode's normal no-prompt default. Collaborative mode's
  existing "surface to the user / block" behavior already covered this
  safely and is unchanged in shape, just now covering the same widened
  list.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is tracked
in the linked tasks file.

**Phase 1: `ardd-state.sh stamp` rejects unexpected trailing args**
- Add a trailing-argument guard to `cmd_stamp` in
  `.claude/skills/ardd-scripts/ardd-state.sh`: after validating
  `<file> <key> <value>` are all present, `shift 3` and `dieu` if any
  argument remains. [feedback:
  feedback-ardd-state-stamp-silent-extra-args-1625.md F001]
- Add regression cases to `scripts/test-ardd-state.sh`'s existing `stamp`
  section (~line 463 onward): a red-first case confirming
  `stamp <file> key val extra` currently exits non-zero for the wrong
  reason (or succeeds silently) before the fix, then a green case
  confirming it now exits with a usage error (`dieu`'s exit code) and a
  message naming the unexpected argument, without disturbing any existing
  passing `stamp` case in the same section. [feedback:
  feedback-ardd-state-stamp-silent-extra-args-1625.md F001]

**Phase 2: Widen the delegation pre-flight's committed-path coverage**
- In `.claude/skills/ardd-implement/SKILL.md`'s pre-flight step
  (currently lines 161-195), after resolving the bound plan file, add
  steps to also resolve: (a) `.project/features/<slug>.md` for each slug
  in the plan's `features:` frontmatter list; (b) every
  `.project/feedback/feedback-*.md` whose `plan:` frontmatter names this
  plan's filename; (c) any dirty/untracked file under
  `.project/artifacts/` (detection only — see below). Fold the plan file,
  tasks file, and paths (a)/(b) into the same `git status --short` check
  and (solo mode) `git add` list, and extend collaborative mode's
  uncommitted-file message to name every affected path, not just the
  plan/tasks pair. `.project/artifacts/` is checked in the same
  `git status --short` pass but is deliberately **excluded** from the
  automatic `git add` even in solo mode — an artifact carries no
  back-reference proving it belongs to this plan, so a blind
  `git add .project/artifacts/` risks silently committing an unrelated,
  still-in-progress edit; if it's dirty, ask the user before including it
  in a second commit, a narrow exception to solo mode's normal no-prompt
  default. [feedback: feedback-delegation-preflight-artifact-gap-44dc.md
  F001]
- Manually verify the widened pre-flight prose against a worked example:
  trace through a hypothetical plan run that targeted one feature slug and
  one feedback file, confirm the described resolution steps correctly
  identify `.project/features/<that-slug>.md` and the feedback file as
  additional paths, and confirm the collaborative-mode message text would
  name all of them. This is prose-only skill behavior with no
  `scripts/test-*.sh` harness to run against it (same class of
  verification the plan/tasks pre-flight text itself already relies on
  today). [feedback: feedback-delegation-preflight-artifact-gap-44dc.md
  F001]

## Open Questions

- Is the artifacts-directory coverage (a whole-directory `git status`
  check rather than an exact-match resolution like the feature/feedback
  cases) precise enough, or does it risk pulling in an unrelated
  in-progress artifact edit that happens to be dirty for a different
  reason at delegation time? The Technical Approach section argues this
  is safe either way (any dirty artifact is state a delegated worktree
  genuinely can't see), but it's worth confirming during Phase 2's manual
  verification that this doesn't produce confusing "committed on your
  behalf" surprises in solo mode when an unrelated artifact edit is
  mid-flight.
