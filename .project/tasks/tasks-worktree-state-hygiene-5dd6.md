---
plan: plan-worktree-state-hygiene-2026-07-04.md
generated: 2026-07-04
status: completed     # generating -> ready -> in-progress -> completed
                     # (or -> abandoned, if superseded by a new tasks
                     # file generated for the same plan)
---

# Tasks

## Phase 1: Deterministic worktree helper (foundation)
- [x] T001 [artifacts: constitution] Write `scripts/test-worktree-info.sh`
  (fixture-based, mirroring `test-branch-info.sh`'s style) covering: (a)
  creating a worktree from scratch for a new slug, (b) idempotent re-run
  against a slug that already has a worktree (must return the existing path,
  not error or duplicate), and (c) that the new worktree branches from the
  *current tip of the default branch* rather than whatever branch happened
  to be checked out when the script ran. Run it and confirm it fails (no
  `worktree-info.sh` implementation exists yet) — per Constitution Principle
  V, this precedes T002.
- [x] T002 [artifacts: constitution] Implement `scripts/worktree-info.sh
  create <slug> [project-dir]` (default `project-dir` is `.`, same
  convention as `lint-project.sh`/`project-lock.sh`): resolves the default
  branch via the same detection `branch-info.sh` uses, creates (or, if one
  already exists for `<slug>`, locates) a worktree at
  `../<repo-basename>-wt-<slug>` relative to `project-dir`, branched from the
  default branch's current tip, and prints the worktree's absolute path on
  success. Iterate until T001 passes.

## Phase 2: `/ardd-tasks` — drop the worktree gate
- [x] T003 [artifacts: constitution] [parallel] In
  `skills/ardd-tasks/SKILL.md`, remove step 1 (the branch/worktree check)
  entirely — `/ardd-tasks` now always operates on whatever branch/worktree
  it's invoked from, with no gate, since its own actions (plan approval,
  feature `backlogged→planned`/`planned→tasked` flips) already are the state
  update this whole plan is trying to get onto `main` promptly. Renumber the
  remaining steps (old step 2 becomes step 1, etc.) and fix any internal
  cross-references to step numbers within the file.

## Phase 3: `/ardd-plan` — worktree/subagent bias + DEFECTS.md ingestion
- [x] T004 [artifacts: constitution] In `skills/ardd-plan/SKILL.md` step 1
  (branch check), change the suggestion logic: if one or more feature slugs
  were passed as arguments (step 3 will do real artifact-design work),
  default the suggested answer to creating a worktree via
  `.claude/skills/ardd-scripts/worktree-info.sh create <slug>` and delegating
  steps 2 onward to a subagent (`Agent` tool, `isolation: "worktree"`,
  pointed at the printed path) rather than a plain `git checkout -b`. If
  invoked with no feature slugs, keep today's plain-branch behavior
  unchanged — no delegation bias for lightweight feedback/artifact-only
  runs. Depends on T002 (references `worktree-info.sh`).
- [x] T005 [artifacts: constitution] In `skills/ardd-plan/SKILL.md`,
  add a coordination-check step immediately before the delegation introduced
  in T004: list in-flight background subagents (harness `TaskList`) and, if
  any is touching this repo/`.project/`, surface it to the user and ask
  whether to wait before proceeding. Depends on T004 (shares the same step).
- [x] T006 [artifacts: constitution] In `skills/ardd-plan/SKILL.md`, add a
  new step after the existing feedback-loading step that reads
  `.project/DEFECTS.md` (if present), presents each listed defect to the
  user, and on confirmation adds a corresponding fix task to the drafted
  plan. Include a concrete tracking mechanism to avoid re-prompting the same
  defect on a later run (e.g. a `surfaced-defects:` frontmatter list on the
  plan, keyed by a stable per-defect identifier) — this closes out
  `feedback-plan-defects-check-4cdb.md` (already marked `[x]` /
  `status: planned` against this plan as of the planning step; no further
  feedback-file bookkeeping needed here).

## Phase 4: `/ardd-implement` — delegation + completion-flip relocation
- [x] T007 [artifacts: constitution] In `skills/ardd-implement/SKILL.md` step
  1, change the branch-gate default to "yes" and, on acceptance, create a
  worktree via `worktree-info.sh` and delegate step 2 onward to a subagent
  (`Agent` tool, `isolation: "worktree"`) instead of running inline. Depends
  on T002.
- [x] T008 [artifacts: constitution] In
  `skills/ardd-implement/SKILL.md`, add the same coordination-check pattern
  as T005 before delegating. Depends on T007.
- [x] T009 [artifacts: constitution] In `skills/ardd-implement/SKILL.md`,
  relocate the `tasked→implemented` feature flip out of step 7 (which
  currently performs it unconditionally) into a new step 10 the
  *coordinating* conversation performs only after receiving the delegated
  subagent's completion report: check `git merge-base --is-ancestor
  <branch> main`; if true, perform the flip on `main` immediately; if
  false, tell the user the flip is pending merge and do not write it. When
  the user declined delegation (ran inline, no subagent), behavior is
  unchanged from today. Depends on T007. **Refined during implementation**
  (user-confirmed): the tasks-file's own `→completed` flip is *not*
  relocated — it stays immediate/in-worktree, since it's plan-specific with
  no cross-branch conflict risk, unlike `features.md`; see the plan's
  Technical Approach note.

## Phase 5: `/ardd-converge` — same relocation
- [x] T010 [artifacts: constitution] [parallel] Apply the same change as
  T007 to `skills/ardd-converge/SKILL.md`'s branch/delegation handling (it
  currently has no explicit branch-gate step of its own — add one
  equivalent to `/ardd-implement`'s, biased to worktree+subagent delegation
  by default). Depends on T002.
- [x] T011 [artifacts: constitution] Apply the same
  coordination-check pattern (T005/T008) to `skills/ardd-converge/SKILL.md`
  before delegating. Depends on T010.
- [x] T012 [artifacts: constitution] Apply the same completion-flip
  relocation as T009 to `skills/ardd-converge/SKILL.md` step 7 (it performs
  the identical `tasked→implemented` flip via the same
  `sibling-tasks-complete.sh` check `/ardd-implement` uses). Depends on
  T010. Same refinement as T009: only the `features.md` flip is relocated,
  not the tasks-file's own `→completed` flip.

## Phase 6: Docs
- [x] T013 [artifacts: constitution] Update `README.md` and `USAGE.md`
  wherever they describe the branch/worktree gate or the
  implement/converge completion flow, to match the behavior from T003–T012.
  Depends on T003, T004, T007, T010. Also fixed a real gap found while
  writing this: `install.sh` never copied `worktree-info.sh` into a target
  project's `.claude/skills/ardd-scripts/`, which would have made the new
  skill behavior non-functional outside this repo — added the copy,
  `chmod +x`, and inline comment alongside `branch-info.sh`'s.
- [x] T014 [artifacts: constitution] [parallel] Update `CLAUDE.md`'s
  Architecture section: document the state-commit-before-branch spine, the
  coarse-vs-fine-grained state scoping rationale, and the worktree
  delegation pattern (new `worktree-info.sh`, sibling to `branch-info.sh`,
  same "shared deterministic half, judgment stays in prose" convention this
  file already documents for branch detection). Depends on T003, T004, T007,
  T010.
