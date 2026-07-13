---
status: approved
branch: worktree-reap-and-fanout
created: 2026-07-12
features: [worktree-reap-and-fanout]
---

# Plan: worktree reap + delegation fan-out

## Goal

Merged delegated worktrees are reaped deterministically so the
worktrees-equal-in-flight-truth signal stays honest, and the delegation
gate can fan out one background run per independent ready tasks file —
completing the parallel-agent flow the merge driver made safe.

## Scope

**In:**
- `scripts/worktree-reap.sh` (target-side, installed to `ardd-scripts`;
  added to install.sh's list): enumerate every non-primary worktree; a
  candidate is one whose branch is fully merged into the local default
  branch (`git merge-base --is-ancestor`) AND whose tree is clean; remove
  the worktree and delete its branch; per-worktree `key=value` output
  (`reaped=true path=… branch=…` / `reaped=false reason=dirty|unmerged|…`);
  refuse-never-resolve — a dirty or unmerged worktree is reported and
  skipped, never forced; `--dry-run` lists candidates without acting; the
  primary worktree and the current worktree are never candidates.
- Wiring: `/ardd-implement`'s post-merge coordinator step runs the reap
  after a successful merge (replacing the manual
  `git worktree remove`/`branch -d` sequence); its completion report
  includes what was reaped. `/ardd-status`'s in-flight section notes
  reap candidates when `--dry-run` finds any (visibility, no mutation —
  status never reaps).
- Fan-out: `/ardd-implement`'s pick/delegation flow — when multiple
  `ready` tasks files exist, offer multi-select delegation (one worktree
  subagent per file, launched in parallel); the "another worktree is
  mid-run — wait?" caution becomes informational (parallel runs are now a
  supported mode, not a hazard) while the same-file claim check stays a
  hard exclusion. Merges serialize naturally as each subagent reports
  back; report-file conflicts are gone (merge driver), and any *code*
  conflict still aborts and asks per `merge_policy`.
- Docs: CLAUDE.md (commands block, worktree-native state notes,
  mechanization list), README/USAGE where the delegation flow is narrated.

**Out:**
- No constitution changes (confirmed at design time).
- No automatic reaping outside the post-merge step (no cron, no hook —
  the coordinator moment is when a worktree becomes reapable).
- No change to `inflight-worktrees.sh` (it keeps reporting whatever exists;
  reap is what keeps its output honest).
- No fan-out of *phases within one tasks file* — the unit of parallelism
  is the tasks file, as designed.

## Technical Approach

Reap-candidacy is a pure function of git state, so it's a script, not
prose (Principle II), following the house key=value/refuse-never-resolve
conventions (`worktree-align.sh` is the pattern). Principle VIII check:
git has no built-in "remove merged worktrees" command — `git worktree
remove` + `git branch -d` are the idioms and the script only sequences
them behind the safety predicate (`branch -d` itself refuses unmerged
branches — a second net). Fan-out is prose-only in `/ardd-implement`: the
Agent-tool delegation shape is unchanged, just issued N times; the
coordinator handles each report-back exactly as today (core.bare check,
`merge_policy`, now reap). Fixture tests build throwaway repos with real
worktrees (merged+clean → reaped; unmerged → kept with reason; dirty →
kept with reason; primary and cwd never candidates; `--dry-run` mutates
nothing).

## Phase Breakdown

### Phase 1 — Reap script (test-first)
1. `scripts/worktree-reap.sh` + `scripts/test-worktree-reap.sh` (red
   first) + CI job, install.sh ships it to `ardd-scripts` (+ the
   installed-and-executable assertion).

### Phase 2 — Wiring
2. `/ardd-implement` post-merge step invokes the reap (installed copy,
   absolute-path fallback) and reports; `/ardd-status` in-flight section
   surfaces `--dry-run` candidates.
3. Dogfood check: run the reap on this repo (expect a no-op — recent
   runs cleaned up manually) and verify against a deliberately-left
   merged test worktree.

### Phase 3 — Fan-out
4. `/ardd-implement` gate: multi-select delegation across independent
   `ready` files; caution → informational; same-file claim stays a hard
   exclusion; note that each completion merges on arrival (serialized by
   the coordinator).
5. Docs: CLAUDE.md/README/USAGE delegation narratives; lint green.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| — | None: two existing-idiom git commands behind a tested predicate, plus prose. No custom mechanism beyond the sequencing script the mechanization audit pattern already blesses. |

## Open Questions

None — candidacy predicate, never-reap set (primary + cwd), and the
fan-out unit (tasks file) settled at design time.
