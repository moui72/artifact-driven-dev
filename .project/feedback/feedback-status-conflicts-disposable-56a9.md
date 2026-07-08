---
status: open      # open -> planned
created: 2026-07-07
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

Source: user observation across sessions (2026-07-07) — agent behavior
at STATUS.md merge/rebase conflicts is inconsistent.

## Bugs

None.

## UX

- [ ] F001 Agents over-deliberate STATUS.md conflicts. The
  disposable-regenerate rule exists (README's concurrency section:
  single-writer report files — STATUS.md, DEFECTS.md, SYNC.md,
  critique.md — take either side and re-run the owning skill), and
  sometimes an agent correctly just picks a side and moves on; but
  sometimes — e.g. a plan run discovering it started on a stale branch —
  the agent agonizes over reapplying STATUS.md changes after a rebase
  or merge, treating a generated report as if it held unrecoverable
  content. Fix: state the rule at the point of action, not just in the
  README — one line in the skills whose flows hit merges/rebases
  (ardd-implement's eager-merge step, ardd-converge's equivalent,
  ardd-plan's branch gate) and in CLAUDE.md's single-writer section:
  "STATUS.md (and the other single-writer reports) are DISPOSABLE at
  merge/rebase: take either side without deliberation — never
  hand-reconcile, never rebase-reapply; the next /ardd-analyze
  regenerates it from disk. Conflict markers in a generated report are
  noise, not data loss." Optionally: a .gitattributes suggestion in
  install.sh (`.project/STATUS.md merge=ours`-style driver) was
  considered — decide during planning whether that's worth the setup
  cost per Principle VI, or whether prose-at-point-of-action suffices.

## Reconsidered

None.
