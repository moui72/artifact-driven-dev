---
plan: plan-status-conflicts-disposable-2026-07-08.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-08
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                     # completed is terminal — post-completion failures
                     # become new feedback (/ardd-feedback), never a
                     # status edit.
---

# Tasks

All three tasks are doc-only (the stated Principle V exception). The
canonical sentence, inserted verbatim (adjust only surrounding
connective prose):

> Single-writer report files (STATUS.md, DEFECTS.md, SYNC.md,
> critique.md) are disposable at merge/rebase: take either side without
> deliberation — never hand-reconcile, never re-apply — and let the
> owning skill regenerate from disk. Conflict markers in a generated
> report are noise, not data loss.

## Phase 1: The rule at every point of action

- [x] T001 Insert the canonical sentence into
  `skills/ardd-implement/SKILL.md` — in step 3's
  when-the-subagent-reports-back merge bullet (where the coordinator
  merges the worktree branch) — and into
  `skills/ardd-converge/SKILL.md`'s matching merge bullet in its step 2.
  lint-docs + gen-skill-docs --check green.
- [ ] T002 Insert it into `skills/ardd-plan/SKILL.md`'s branch-gate
  (step 1) — covering the observed failure: a plan run discovering its
  branch is stale and merging/rebasing the default branch in before
  proceeding. lint-docs green.
- [ ] T003 Insert a one-sentence version + pointer to README's
  concurrency section into CLAUDE.md's single-writer ownership section;
  read README's "Concurrency and .project/ merge conflicts" section and
  align its wording with the canonical sentence's meaning if drifted
  (align, don't duplicate the full sentence twice in one file).
  lint-docs green.
