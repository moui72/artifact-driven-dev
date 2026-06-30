# /ardd-plan

Generate an implementation plan from the current artifacts and any research
docs. Run `/ardd-analyze` first — do not plan over unresolved conflicts.

## Steps

1. **Check branch.** Get the current branch (`git branch --show-current`) and
   the repo's default branch (`git symbolic-ref refs/remotes/origin/HEAD`
   stripped of `refs/remotes/origin/`, falling back to `main` then `master`
   if no remote is configured).

   If they differ, skip to step 2 and derive `<slug>` from the current branch
   name (lowercase, non-alphanumeric runs → `-`, truncate to ~30 chars).

   If they match, suggest a branch name — a semantic kebab-case slug derived
   from the conversation/artifacts if the topic is clear, otherwise a short
   arbitrary slug (4 hex chars, e.g. `openssl rand -hex 2` → `f2ed`). Ask the
   user:
   - "Yes, create `<suggested-name>`"
   - "Yes, create a branch, but name it: ___"
   - "No, continue on default" (a worktree works too — set one up yourself
     and re-run from there; this gate doesn't automate worktree creation
     since it's environment-specific)

   On yes, run `git checkout -b <name>` and set `<slug>` to `<name>`. On no,
   set `<slug>` to a freshly generated short arbitrary hex token (same
   generation as above) and proceed on the default branch without asking
   again this run.

2. **Discover artifacts** by listing `.project/artifacts/`. Read every `.md`
   file present. If any are `status: draft`, warn the user and ask whether
   to proceed.

3. **Load any research documents** from `.project/plans/research-*.md` relevant
   to the current work.

4. **Check constitution compliance** if `constitution.md` is present. Flag any
   planned patterns that require a Complexity Tracking entry per the simplicity
   principle.

5. **Check for existing approved plans.** List `.project/plans/plan-*.md` and
   read frontmatter. If any have `status: approved`, ask the user whether the
   plan you're about to draft supersedes one of them. Remember the answer for
   step 8.

6. **Draft the plan** covering:
   - **Goal** — what this plan delivers (one sentence)
   - **Scope** — what is and is not included
   - **Technical Approach** — how the system will be built; reference artifact
     decisions rather than repeating them
   - **Phase Breakdown** — ordered phases with dependencies called out; each
     phase produces a testable, demonstrable increment
   - **Complexity Tracking** — table of justified deviations from the simplicity
     principle (if a constitution is present)
   - **Open Questions** — anything that must be resolved before or during
     implementation
   - **Production Annotation Summary** — list of known production shortcuts to
     annotate during implementation

7. **Write the plan** to `.project/plans/plan-<slug>-<YYYY-MM-DD>.md` with
   frontmatter:

   ```yaml
   ---
   status: draft        # draft -> approved -> superseded
   branch: <slug>
   created: YYYY-MM-DD
   ---
   ```

8. **Present a summary** to the user: phases, key decisions, open questions.
   Ask for approval before the plan is considered final. Do not generate tasks
   until the user approves.

   Once approved:
   - Flip this plan's frontmatter `status` to `approved` in place.
   - If step 5 identified a plan this one supersedes, flip that plan's
     `status` to `superseded` in place.
   - Remind the user to run `/ardd-analyze` to update the recommended next
     step in `STATUS.md`.
