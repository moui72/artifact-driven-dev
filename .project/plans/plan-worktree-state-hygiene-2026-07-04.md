---
status: approved        # draft -> approved -> superseded
branch: worktree-state-hygiene
created: 2026-07-04
features: []
---

# Plan: worktree-state-hygiene

## Goal

Change ARDD's git-hygiene model so long-running work (`/ardd-plan` when it
does real design work, `/ardd-implement`, `/ardd-converge`) happens in a
delegated worktree subagent, while coarse-grained state fields
(`features.md` `Status`, plan/tasks frontmatter `status`) land on local
`main` immediately — before the worktree is even created — so other
sessions/people see "what's started" without waiting for a merge.

## Scope

**In scope:**
- `/ardd-tasks` drops its branch/worktree gate entirely — always runs on
  whatever branch it's invoked on (normally `main`); its core action (plan
  approval + feature `backlogged→planned`) already **is** the state update,
  so there's nothing to defer.
- `/ardd-plan`'s existing branch-gate step starts recommending a worktree +
  subagent delegation by default when it's about to do real design work
  (one or more feature slugs targeted in step 3), and stays lightweight
  (plain branch, no delegation) when it's just touching feedback/artifacts
  without a targeted feature.
- `/ardd-implement` and `/ardd-converge`'s branch-gate steps default to
  "yes" and, on acceptance, create a worktree and delegate the actual
  execution to a subagent (`Agent` tool, `isolation: "worktree"`) instead of
  running inline in the coordinating conversation.
- **State-commit-before-branch spine**: any coarse status flip that would
  otherwise happen at the start of delegated work (tasks `ready→in-progress`,
  plan `draft→approved` + feature `backlogged→planned` on selection,
  feature `planned→tasked` on tasks generation) commits to local `main`
  first; the worktree is then cut from that commit.
- **Completion-side flips move to a post-merge, main-side step**: feature
  `tasked→implemented` and a tasks file's own `→completed` flip no longer
  happen inside the worktree. The subagent's last action is a report, not a
  `features.md` write; the coordinating conversation performs the
  completion flip on `main` once it confirms the worktree branch is merged.
- **Coordination check**: before `/ardd-plan`, `/ardd-implement`, or
  `/ardd-converge` starts new delegated work, check for an already-running
  subagent (harness `TaskList`) touching this repo and warn the user before
  proceeding if one is still active.
- New shared script `scripts/worktree-info.sh` (sibling to
  `branch-info.sh`) for the deterministic half: create-or-locate a worktree
  for a given slug, branched from current `main` HEAD. Plus a regression
  test, `scripts/test-worktree-info.sh`.
- Incorporates `feedback-plan-defects-check-4cdb.md`: `/ardd-plan` gains a
  step that reads `.project/DEFECTS.md`, presents listed defects to the
  user, and includes an accepted defect as a fix task — with a tracking
  mechanism so already-surfaced defects aren't re-prompted every run.
- Docs: `README.md`, `USAGE.md`, and `CLAUDE.md`'s Architecture section
  updated to describe the new worktree/state-commit philosophy.

**Out of scope (explicit, per user decision this run):**
- Auto-pushing state commits to `origin/main`. Commits land on **local**
  `main` only; pushing stays a manual, explicit step, consistent with this
  repo's existing confirm-before-push posture and the global
  unsigned-commit-when-1Password-is-locked convention.
- Automating merge-back of a worktree branch into `main`. Still a manual
  step (PR or local merge) the user performs; this plan only changes what
  happens *around* that step (state timing, delegation), not the merge
  itself.
- `/ardd-sync` and its tracker-facing mechanics — untouched.
- Cleanup/removal of worktrees after merge — left to the user, same as
  today's "set one up yourself" carve-out for the deterministic half.

## Technical Approach

**Worktree location convention.** `scripts/worktree-info.sh create <slug>
[project-dir]` creates (or, if it already exists, locates) a worktree at
`../<repo-basename>-wt-<slug>` relative to `project-dir` (default `.`),
branched from the *current tip of the default branch* (reusing
`branch-info.sh`'s `default` detection) — not from whatever branch happened
to be checked out when the script ran, since the state-commit-first spine
guarantees the default branch's tip already has the just-written state
flip. Prints the worktree's absolute path on success. Idempotent: if a
worktree for that slug already exists, print its existing path instead of
erroring or duplicating it (mirrors `branch-info.sh`'s "detect, don't
assume" style and `project-lock.sh`'s idempotent `touch`).

**State-commit-before-branch sequencing**, concretely:
1. The coordinating conversation (not a subagent) performs the coarse
   status flip — e.g. tasks `ready→in-progress`, or plan
   `draft→approved`/feature `backlogged→planned` in `/ardd-tasks`'s
   approval step — and commits it directly on `main`.
2. Only then does it run `worktree-info.sh create <slug>` and delegate the
   substantive work to a subagent pointed at that worktree.
3. Per-task checkbox progress inside a tasks file, and any artifact edits
   from `/ardd-plan` step 3d, stay in the worktree and only reach `main`
   when that branch is merged — this is deliberately fine-grained-vs-coarse
   scoping, not an oversight: syncing every single task checkbox to `main`
   in real time would eliminate the isolation the worktree exists to
   provide, and the coarse start/completion flips are what
   `STATUS.md`/`features.md` actually report on.

**Completion-flip relocation.** `/ardd-implement` step 7 and
`/ardd-converge` step 6 stop performing the `tasked→implemented` flip (and
tasks-file `→completed` flip) themselves when running inside a delegated
worktree. Instead:
- The subagent's final action is a structured report (tasks file path,
  whether all tasks are complete, which features would flip) — no
  `features.md` write.
- The coordinating conversation, on receiving that report, checks whether
  the worktree branch is already merged into `main`
  (`git merge-base --is-ancestor <branch> main`). If yes, it performs the
  completion flip on `main` immediately. If not yet merged, it tells the
  user the flip is pending merge and does not write it — avoiding a
  `features.md` state that claims "implemented" before the code actually
  landed on `main`.
- If the user declined delegation (ran inline, no subagent), behavior is
  unchanged from today — the flip happens wherever the work happened, same
  as before this plan.

**Implementation-time refinement (confirmed with the user during T009):**
only the `features.md` flip is actually relocated to post-merge. The
tasks-file's own `→completed` frontmatter flip stays immediate, in-worktree,
same as its per-task checkboxes — it's plan-specific (no other branch edits
the same tasks file concurrently), so it carries none of the cross-branch
conflict risk `features.md` has, and it travels to `main` with the rest of
the code on merge regardless. Relocating it too would only add latency with
no corresponding benefit.

**Coordination check.** `TaskList` is a harness tool, not something a POSIX
script can wrap (per Constitution Principle II, this stays prose/judgment,
not a deterministic check) — added as a preamble in `/ardd-plan` (when
about to delegate), `/ardd-implement`, and `/ardd-converge`: list in-flight
background tasks, and if one touches this repo/`.project/`, surface it and
ask whether to wait before proceeding. `project-lock.sh` is unchanged and
keeps its narrower existing job (warn on a recent `.project/` write by a
different label) — it is not repurposed as an in-flight tracker, since its
5-minute staleness window is wrong for work that can run much longer than
that (this is a deliberate two-mechanism split, not redundant).

**`/ardd-plan` DEFECTS.md ingestion** (the incorporated feedback item): add
a step after the existing feedback-loading step that reads
`.project/DEFECTS.md` (if present), presents each listed defect, and on
confirmation adds a fix task to the plan. Tracking mechanism to avoid
re-prompting: record surfaced-and-declined/deferred defects by a stable
identifier (defect description hash, or line-number-independent slug) in
the plan's own frontmatter or a small sidecar list — exact mechanism is an
implementation-time decision (see Open Questions), not fixed here.

## Phase Breakdown

### Phase 1: Deterministic worktree helper (foundation)
- [ ] Write `scripts/test-worktree-info.sh` first (fixture-based, mirrors
  `test-branch-info.sh`'s style) covering: create-from-scratch, idempotent
  re-run against an existing worktree, and the default-branch-tip sourcing
  behavior. Confirm it fails against no implementation yet.
- [ ] Implement `scripts/worktree-info.sh create <slug> [project-dir]` per
  the Technical Approach above until the test passes.

### Phase 2: `/ardd-tasks` — drop the worktree gate
- [ ] Remove `/ardd-tasks` step 1 (branch/worktree gate) entirely; it now
  always operates on the invoking branch with no gate, since its own
  actions are the state update. Update any step numbering that follows.

### Phase 3: `/ardd-plan` — worktree/subagent bias + DEFECTS.md ingestion
- [ ] Update `/ardd-plan` step 1: when one or more feature slugs are passed
  (step 3 will do real design work), default the suggestion to worktree +
  subagent delegation via `worktree-info.sh`; when invoked with no feature
  slugs, keep today's lightweight plain-branch behavior.
- [ ] Add the coordination check (in-flight `TaskList` scan) before
  delegating.
- [ ] Add the DEFECTS.md-ingestion step (after the existing feedback-load
  step), including the re-prompt-avoidance tracking mechanism.
- [ ] Update `feedback-plan-defects-check-4cdb.md`: mark its Bugs item
  `[x]`, flip `status` to `planned`, set `plan:` to this plan's filename
  (done as part of this plan's own write-up, per step 5's bookkeeping
  rule — not deferred to this phase).

### Phase 4: `/ardd-implement` — delegation + completion-flip relocation
- [ ] Update step 1 to default to worktree creation + subagent delegation
  on "yes", per the Technical Approach.
- [ ] Add the coordination check before delegating.
- [ ] Relocate the `tasked→implemented` (and tasks-file `→completed`) flip
  out of step 7 into a new main-side step the coordinating conversation
  performs after receiving the subagent's completion report, gated on
  `git merge-base --is-ancestor`.

### Phase 5: `/ardd-converge` — same relocation
- [ ] Apply the same completion-flip relocation to `/ardd-converge` step 6
  (it performs the identical flip via the same `sibling-tasks-complete.sh`
  check as `/ardd-implement`).
- [ ] Add the coordination check before delegating (converge can also be
  long-running).

### Phase 6: Docs
- [ ] Update `README.md` and `USAGE.md` wherever they describe the
  branch/worktree gate or the implement/converge completion flow.
- [ ] Update `CLAUDE.md`'s Architecture section: add this plan's spine
  (state-commit-before-branch, coarse-vs-fine-grained state scoping,
  worktree delegation) alongside the existing branch-info.sh description,
  since it's the same "shared deterministic half, judgment stays in prose"
  pattern this repo already documents.

## Complexity Tracking

None — this plan adds one new script (paralleling the existing
`branch-info.sh` pattern) and relocates existing write logic; it doesn't
introduce a new abstraction layer or a mechanism beyond what three-plus
call sites (plan/implement/converge) already justify.

## Open Questions

- Exact tracking mechanism for "already-surfaced" `DEFECTS.md` items in
  `/ardd-plan` (frontmatter list vs. sidecar file) — decide during Phase 3
  implementation, not here; the feedback item itself deferred this
  decision explicitly.
- Whether `worktree-info.sh` needs a `cleanup`/`remove` subcommand now or
  can wait until it's actually requested (current lean: wait — YAGNI per
  Constitution VI, since merge-back and worktree removal are already a
  manual step the user performs).

## Production Annotation Summary

N/A — this repository has no runtime application or production shortcuts
concept (per `constitution.md`'s Project Scope & Intent); the "product" is
the skill prose and scripts themselves.
