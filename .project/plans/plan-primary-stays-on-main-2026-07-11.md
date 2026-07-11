---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: primary-stays-on-main
created: 2026-07-11
features: []
surfaced-defects: []
---

# Plan — Primary worktree stays on main (source-for-consumers invariant)

## Goal

Encode as a governing invariant that this repo's primary/default worktree
never leaves `main`, so the source other local projects install/update from
always serves merged, stable skills — and all feature work is isolated in
separate worktrees.

## Scope

**In:**
- A new `constitution.md` standing decision stating the invariant and why
  (F002/F003). [artifacts: constitution]
- A `CLAUDE.md` workflow note reflecting it: in this repo, use a separate
  worktree for feature work; never the branch-gate's inline `git checkout -b`
  on the primary checkout.

**Out (defaults; the open questions below can pull them back in):**
- A generic reusable "source-repo" workflow field in the *installed* skills
  (F004 generalization). Default: don't build it — this is a single-repo need
  today, and speculative generality is a Principle VI (YAGNI) cost.
- A deterministic enforcement check/hook. Default: don't build one — the
  failure ("primary is on a branch when a consumer reads it") isn't cleanly
  mechanizable from this repo's side, so the honest fix is prose discipline,
  not a guard with poor leverage.

## Technical Approach

This is a governance/documentation change, not code. The invariant lives in
`constitution.md` (this repo's source of truth) and is operationalized in
`CLAUDE.md`'s workflow guidance. The mechanism it relies on already exists:
`git worktree add` (or the skills' `isolation: "worktree"` delegation)
branches without moving the primary checkout's HEAD — this very plan is being
worked that way as the first exercise of the rule. No skill prose changes:
the branch-gate's inline `checkout -b` path stays valid for *ordinary
consumer projects* (which are not sources others read); the constraint is
specific to this repo and belongs in its constitution, not in the installed
skills.

## Phase Breakdown

### Phase 1 — Constitution standing decision (artifact-first)
`[artifacts: constitution]` (F002, F003). Depends on: nothing.
- Add a standing decision to `constitution.md`'s Project Scope & Intent
  (adjacent to the acquisition/`new.sh` material, since it is about this repo
  being a live source): the primary/default worktree never leaves `main`
  because consumers' `install.sh`/`/ardd-update` read this checkout and
  install from whatever branch is out; feature work happens in separate
  worktrees. Cite the 2026-07-11 ref-lock anomaly (F001) as the concrete
  failure the rule prevents. Amendment process: Sync Impact Report + version
  bump (magnitude is an open question — a new standing decision, like the
  npx-scrap one which was MINOR). Prefer routing through `/ardd-refine
  constitution` for correct versioning. Verify `lint-project.sh` green.
- Demonstrable increment: constitution states the invariant; lint green.

### Phase 2 — CLAUDE.md workflow note
Depends on: Phase 1 (so the note can cite the constitution).
- Add a short workflow note to `CLAUDE.md` (near the Commands / worktree
  material): when doing feature work *in this repo*, create a worktree and
  keep the primary checkout on `main`; do not take `/ardd-plan`/
  `/ardd-implement`'s inline `git checkout -b` branch-gate option here. One
  line on the recovery move if the primary is ever found off `main`
  (`git checkout main`; unmerged work is safe on its branch/worktree).
- Demonstrable increment: `CLAUDE.md` gives the operational rule;
  `lint-docs.sh` green.

### Phase 3 — Verify
Depends on: 1–2.
- `lint-docs.sh`, `lint-project.sh`, and the doc generators' `--check` green.
  Confirm the constitution version bookkeeping (SIR/footer/frontmatter) is
  internally consistent (the write-time hook already guards this).

## Open Questions

- **Version-bump magnitude:** new standing decision — MINOR (material
  governance addition) or PATCH? Resolve when performing Phase 1 (as with the
  npx-scrap bump).
- **F004 generalization:** should this become a reusable workflow field for
  any install-source project, rather than a this-repo standing decision? Lean:
  no (YAGNI — one repo needs it now). Decide at the approval checkpoint.
- **F004 enforcement:** is there a worthwhile deterministic guard (a check
  that flags the primary worktree being off `main`)? Lean: no — not cleanly
  mechanizable from this side, low leverage, Principle VI. Decide with the
  above.
