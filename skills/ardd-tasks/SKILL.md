# /ardd-tasks

Generate an ordered task list from an approved plan.

## Steps

1. **Check branch.** Get the current branch (`git branch --show-current`) and
   the repo's default branch (`git symbolic-ref refs/remotes/origin/HEAD`
   stripped of `refs/remotes/origin/`, falling back to `main` then `master`
   if no remote is configured). If they differ, skip to step 2.

   If they match, suggest a branch name — a semantic kebab-case slug derived
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
   each. Filter out `status: draft` (if only drafts exist, warn the user the
   same way the artifact draft-warning does, and stop). For each remaining
   plan, also glob `.project/tasks/tasks-*.md` and check each file's `plan:`
   frontmatter for an exact match against the plan's filename — note whether
   one or more tasks files already exist for that plan and their statuses.

   Present the list (plan filename, status, and any existing tasks files with
   their status/progress) and ask the user which plan to generate tasks for.
   If only one eligible plan exists, still confirm rather than auto-selecting
   ("Found 1 approved plan: `plan-auth-flow-2026-06-30.md`. Use this one?").

   If the chosen plan already has a tasks file at `ready`, `in-progress`, or
   `completed`, surface that explicitly and ask for confirmation before
   continuing ("plan-auth-flow already has tasks-auth-flow-9f3c.md at
   in-progress, 4/12 complete — generate a new tasks file for this plan
   anyway?"). This is a deliberate fork, not silent data loss — proceeding
   creates a new file, never overwrites the existing one.

3. **Generate tasks** ordered by dependency. Each task MUST:
   - Have a unique ID: `T001`, `T002`, etc.
   - State which artifacts must be loaded before execution, e.g.
     `[artifacts: datamodel, infrastructure]`
   - Be atomic enough that an agent can complete it in one focused session
   - Be concrete enough to execute without reading the plan (embed necessary
     context in the task description)
   - Include a test requirement where applicable (per Principle II — test first)

4. **Mark parallelism** with `[parallel]` on tasks that touch different files
   and have no shared dependencies.

5. **Write to `.project/tasks/tasks-<slug>-<hex>.md`**, where `<slug>` is
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

6. **Report** the total task count and phase breakdown. Note any tasks that
   embed a test requirement.
