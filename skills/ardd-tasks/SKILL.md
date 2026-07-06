---
name: ardd-tasks
tier: core
description: Generate an ordered task list from a plan; selecting a draft plan approves it.
---

# /ardd-tasks

Generate an ordered task list from a plan. Selecting a `status: draft` plan
approves it as part of this — there's no separate approval step in
`/ardd-plan` anymore.

## Steps

1. **Pick a plan.** No branch/worktree gate here, deliberately — unlike
   `/ardd-plan`/`/ardd-implement`/`/ardd-converge`, `/ardd-tasks` always
   operates on whatever branch or worktree it's invoked from. Its own
   actions (plan approval, feature `backlogged→planned`/`planned→tasked`
   flips) are themselves the coarse state update the rest of this workflow
   is trying to get onto the default branch promptly, so there's nothing to
   defer behind a worktree the way there is for the longer-running skills.

   Glob `.project/plans/plan-*.md` and read frontmatter for
   each — list plans regardless of `status` (`draft`, `approved`, or
   `superseded`; skip `superseded` ones, they're historical). Then run
   `.claude/skills/ardd-scripts/tasks-list.sh --all` and match its
   plan-binding column against each plan's filename — note whether one or
   more tasks files already exist for that plan and their statuses.

   Present the list (plan filename, status, and any existing tasks files with
   their status/progress) and ask the user which plan to generate tasks for.
   If only one eligible plan exists, still confirm rather than auto-selecting
   ("Found 1 draft plan: `plan-auth-flow-2026-06-30.md`. Use this one?" —
   selecting it approves it, see step 2).

   If the chosen plan already has a tasks file at `ready`, `in-progress`, or
   `completed`, surface that explicitly and ask for confirmation before
   continuing ("plan-auth-flow already has tasks-auth-flow-9f3c.md at
   in-progress, 4/12 complete — generate a new tasks file for this plan
   anyway?"). This is a deliberate fork, not silent data loss — proceeding
   creates a new file, never overwrites the existing one.

   On confirmation, also ask whether to mark each existing non-`completed`
   tasks file for this plan as `abandoned` (skip any already `completed` —
   that's a more informative terminal state than abandonment, and
   `/ardd-implement`/`/ardd-converge`'s sibling-completion check already
   treats a `completed` sibling as done). For each one the user confirms,
   run `.claude/skills/ardd-scripts/ardd-state.sh tasks-flip <file>
   abandoned`; leave the rest untouched (e.g. still
   legitimately being worked in parallel). This keeps stale forks from
   lingering at `ready`/`in-progress` forever with no way to tell "abandoned"
   from "just not picked up yet."

2. **Approve the plan, if it isn't already.** Run `.claude/skills/ardd-
   scripts/project-lock.sh check ardd-tasks` first — surface any warning to
   the user (another invocation touched `.project/` recently) but proceed
   regardless; this is advisory, never a block. If the chosen plan's
   `status` is `draft`: approve it and advance its features via
   `ardd-state.sh` (all mutations script-performed — constitution
   Principle II; use the copy at `.claude/skills/ardd-scripts/`):

   ```
   ardd-state.sh plan-flip <plan file> approved
   # then, for each slug in the plan's features: frontmatter list:
   ardd-state.sh feature-flip <slug> planned
   ardd-state.sh feature-field <slug> plan <plan filename>
   ```

   — the same mechanics `/ardd-plan` used to perform on explicit
   approval, just triggered by selecting the plan here instead. If the
   chosen plan is already `status: approved` (e.g. from before this
   convention, or a second tasks-file run against the same plan), skip this
   step — nothing to do. Either way, run `... touch ardd-tasks` once this
   step's writes (if any) are done.

3. **Generate tasks** ordered by dependency. Each task MUST:
   - Have a unique ID: `T001`, `T002`, etc.
   - State which artifacts must be loaded before execution, e.g.
     `[artifacts: datamodel, infrastructure]`
   - Be atomic enough that an agent can complete it in one focused session
   - Be concrete enough to execute without reading the plan (embed necessary
     context in the task description)
   - Include a test requirement where applicable, following whatever testing
     paradigm `constitution.md` declares (Quality Standards or Core
     Principles) — TDD, test-after, coverage threshold, or none. Tasks are
     paradigm-agnostic by default; don't assume TDD or any specific
     principle number if the constitution doesn't state one

4. **Mark parallelism** with `[parallel]` on tasks that touch different files
   and have no shared dependencies.

5. **Write the tasks file.** Mint its filename from the chosen plan's
   slug — `.claude/skills/ardd-scripts/ardd-state.sh mint tasks <slug>` —
   minted at write time so the name is always unique even when
   regenerating tasks for the same plan; write to
   `.project/tasks/<that filename>`. Run `.claude/skills/ardd-scripts/project-lock.sh check
   ardd-tasks` before this first write (surface any warning, don't block on
   it). Write the frontmatter immediately, before generating task
   content, with `status: generating` — this is what makes an interrupted
   generation visibly incomplete rather than silently mistaken for `ready`:

   ```yaml
   ---
   plan: plan-<slug>-YYYY-MM-DD.md   # exact filename of the source plan — authoritative binding
   generated: YYYY-MM-DD
   status: generating   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                        # (or -> abandoned, if superseded by a new tasks
                        # file generated for the same plan)
   # worktree_branch: <branch>  — added later by /ardd-implement or
   # /ardd-converge only if this file's work gets delegated to a worktree
   # subagent; not written here at generation time.
   ---

   # Tasks

   ## Phase 1: <Name>
   - [ ] T001 [artifacts: constitution] <description>
   - [ ] T002 [artifacts: datamodel, infrastructure] [parallel] <description>

   ## Phase 2: <Name>
   - [ ] T003 [artifacts: datamodel] <description>
   ```

   Once all tasks are written, flip the file to ready —
   `.claude/skills/ardd-scripts/ardd-state.sh tasks-flip <file> ready` —
   then run `... touch ardd-tasks`.

6. **Flip bound features to `tasked`.** Read the chosen plan's frontmatter
   `features:` list (if any). For each slug:

   ```
   ardd-state.sh feature-flip <slug> tasked
   ardd-state.sh feature-field <slug> tasks <this tasks filename>
   ```

7. **Report** the total task count and phase breakdown. Note any tasks that
   embed a test requirement, which features (if any) were flipped to
   `tasked`, and — if step 2 approved the plan — that it's now `approved`.
   Then run `/ardd-analyze` now to refresh `STATUS.md` — plan approval and
   the feature-backlog flips in steps 2 and 6 leave it stale otherwise.
