# /ardd-tasks

Generate an ordered task list from a plan. Selecting a `status: draft` plan
approves it as part of this — there's no separate approval step in
`/ardd-plan` anymore.

## Steps

1. **Check branch.** Run `.claude/skills/ardd-scripts/branch-info.sh` for
   `current`, `default`, and `on_default`. If `on_default` is `false`, skip to
   step 2.

   If `on_default` is `true`, suggest a branch name — a semantic kebab-case slug derived
   from the conversation/artifacts if the topic is clear, otherwise a short
   arbitrary slug (4 hex chars, e.g. `openssl rand -hex 2` → `f2ed`). Ask the
   user:
   - "Yes, create `<suggested-name>`"
   - "Yes, create a branch, but name it: ___"
   - "No, continue on default" (a worktree works too — set one up yourself
     and re-run from there; this gate doesn't automate worktree creation
     since it's environment-specific)

   On yes, run `git checkout -b <name>`. On no, proceed on the default branch
   without asking again this run.

2. **Pick a plan.** Glob `.project/plans/plan-*.md` and read frontmatter for
   each — list plans regardless of `status` (`draft`, `approved`, or
   `superseded`; skip `superseded` ones, they're historical). For each
   remaining plan, also glob `.project/tasks/tasks-*.md` and check each
   file's `plan:` frontmatter for an exact match against the plan's
   filename — note whether one or more tasks files already exist for that
   plan and their statuses.

   Present the list (plan filename, status, and any existing tasks files with
   their status/progress) and ask the user which plan to generate tasks for.
   If only one eligible plan exists, still confirm rather than auto-selecting
   ("Found 1 draft plan: `plan-auth-flow-2026-06-30.md`. Use this one?" —
   selecting it approves it, see step 3).

   If the chosen plan already has a tasks file at `ready`, `in-progress`, or
   `completed`, surface that explicitly and ask for confirmation before
   continuing ("plan-auth-flow already has tasks-auth-flow-9f3c.md at
   in-progress, 4/12 complete — generate a new tasks file for this plan
   anyway?"). This is a deliberate fork, not silent data loss — proceeding
   creates a new file, never overwrites the existing one.

3. **Approve the plan, if it isn't already.** If the chosen plan's `status`
   is `draft`: flip it to `approved` in place, then read its `features:`
   frontmatter list (if any) and for each slug flip that entry in
   `.project/artifacts/features.md` from `Status: backlogged` to
   `Status: planned`, adding `· Plan: <plan filename>` to its metadata
   line — the same mechanics `/ardd-plan` used to perform on explicit
   approval, just triggered by selecting the plan here instead. If the
   chosen plan is already `status: approved` (e.g. from before this
   convention, or a second tasks-file run against the same plan), skip this
   step — nothing to do.

4. **Generate tasks** ordered by dependency. Each task MUST:
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

5. **Mark parallelism** with `[parallel]` on tasks that touch different files
   and have no shared dependencies.

6. **Write to `.project/tasks/tasks-<slug>-<hex>.md`**, where `<slug>` is
   taken from the chosen plan's filename and `<hex>` is a freshly generated
   4-char token (same generation as the branch-gate step), minted at write
   time so the filename is always unique even when regenerating tasks for the
   same plan. Write the frontmatter immediately, before generating task
   content, with `status: generating` — this is what makes an interrupted
   generation visibly incomplete rather than silently mistaken for `ready`:

   ```yaml
   ---
   plan: plan-<slug>-YYYY-MM-DD.md   # exact filename of the source plan — authoritative binding
   generated: YYYY-MM-DD
   status: generating   # generating -> ready -> in-progress -> completed
   ---

   # Tasks

   ## Phase 1: <Name>
   - [ ] T001 [artifacts: constitution] <description>
   - [ ] T002 [artifacts: datamodel, infrastructure] [parallel] <description>

   ## Phase 2: <Name>
   - [ ] T003 [artifacts: datamodel] <description>
   ```

   Once all tasks are written, flip `status` to `ready`.

7. **Flip bound features to `tasked`.** Read the chosen plan's frontmatter
   `features:` list (if any). For each slug, flip its entry in
   `.project/artifacts/features.md` from `Status: planned` to `Status: tasked`
   and add `· Tasks: tasks-<slug>-<hex>.md` (this file's own filename) to its
   metadata line.

8. **Report** the total task count and phase breakdown. Note any tasks that
   embed a test requirement, which features (if any) were flipped to
   `tasked`, and — if step 3 approved the plan — that it's now `approved`.
   Then run `/ardd-analyze` now to refresh `STATUS.md` — plan approval and
   the feature-backlog flips in steps 3 and 7 leave it stale otherwise.
