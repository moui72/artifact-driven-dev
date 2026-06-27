# /tasks

Generate an ordered task list from the current plan. Requires an approved plan
in `.project/plans/`.

## Steps

1. **Load the most recent plan** from `.project/plans/plan-*.md` (latest by date).
   If none exists, tell the user to run `/plan` first.

2. **Generate tasks** ordered by dependency. Each task MUST:
   - Have a unique ID: `T001`, `T002`, etc.
   - State which artifacts must be loaded before execution, e.g.
     `[artifacts: datamodel, infrastructure]`
   - Be atomic enough that an agent can complete it in one focused session
   - Be concrete enough to execute without reading the plan (embed necessary
     context in the task description)
   - Include a test requirement where applicable (per Principle II — test first)

3. **Mark parallelism** with `[parallel]` on tasks that touch different files
   and have no shared dependencies.

4. **Write to `.project/tasks/tasks.md`** using this format:

   ```markdown
   ---
   plan: plan-YYYY-MM-DD.md
   generated: YYYY-MM-DD
   ---

   # Tasks

   ## Phase 1: <Name>
   - [ ] T001 [artifacts: constitution] <description>
   - [ ] T002 [artifacts: datamodel, infrastructure] [parallel] <description>

   ## Phase 2: <Name>
   - [ ] T003 [artifacts: datamodel] <description>
   ```

5. **Report** the total task count and phase breakdown. Note any tasks that
   embed a test requirement.
