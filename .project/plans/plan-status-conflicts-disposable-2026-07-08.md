---
status: draft        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: status-conflicts-disposable
created: 2026-07-08
features: []
surfaced-defects: []
---

# Plan: single-writer reports are disposable at merge — say so at the point of action

## Goal

Stop agents from hand-reconciling STATUS.md (and sibling report) merge
conflicts by stating the disposable-regenerate rule everywhere an agent
actually encounters a merge or rebase.

## Scope

**In:** feedback-status-conflicts-disposable-56a9.md F001, prose-only
(user decision 2026-07-08: no merge-driver machinery — a merge=ours
driver needs per-clone git config .gitattributes can't provide, and
"ours" inverts under rebase; Principle VI).

**Out:** any git configuration, hooks, or install.sh changes.

## Technical Approach

One canonical sentence, repeated verbatim at every point of action so
it's in context exactly when the conflict appears:

> Single-writer report files (STATUS.md, DEFECTS.md, SYNC.md,
> critique.md) are disposable at merge/rebase: take either side without
> deliberation — never hand-reconcile, never re-apply — and let the
> owning skill regenerate from disk. Conflict markers in a generated
> report are noise, not data loss.

Placed in: ardd-implement's eager-merge step (where the coordinator
merges a worktree branch), ardd-converge's equivalent, ardd-plan's
branch gate (the stale-branch discovery case the user hit), and
CLAUDE.md's single-writer ownership section. README's concurrency
section already states it — it stays the long-form home and gains
nothing. Doc-only plan; no tests (the stated Principle V exception),
but lint-docs and gen-skill-docs --check must stay green.

## Phase Breakdown

### Phase 1 — the rule at every point of action

- T-A Add the canonical sentence to `skills/ardd-implement/SKILL.md`
  (step 3's when-the-subagent-reports-back merge bullet) and
  `skills/ardd-converge/SKILL.md` (same spot in its step 2).
- T-B Add it to `skills/ardd-plan/SKILL.md`'s branch-gate step (step
  1) — the observed failure case: a plan run discovering its branch is
  stale and merging/rebasing before proceeding.
- T-C Add it to CLAUDE.md's single-writer ownership section (one
  sentence + pointer to README's fuller treatment); confirm README's
  concurrency section wording matches the canonical sentence's meaning
  (align phrasing if drifted, don't duplicate).

## Complexity Tracking

| Deviation | Justification (Principle VI) |
|---|---|
| (none) | Four prose insertions of one sentence |

## Open Questions

None.

## Production Annotation Summary

- None.
