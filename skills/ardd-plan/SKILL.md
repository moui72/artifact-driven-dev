# /ardd-plan

Generate an implementation plan from the current artifacts, any research
docs, and any open feedback (`/ardd-feedback`). Run `/ardd-analyze` first —
do not plan over unresolved conflicts.

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

4. **Load open feedback.** Glob `.project/feedback/feedback-*.md` and read
   frontmatter. Load every file with `status: open` as planning input —
   these came from the user manually inspecting the implementation (bugs,
   UX issues, reconsidered decisions). For each `## Reconsidered` item tagged
   with an artifact, diff it against that artifact's current text and surface
   the specific discrepancy to the user (what the artifact says vs. what the
   feedback says), asking them to confirm the override before proceeding —
   this is a decision reversal, not a routine update, so don't assume intent
   silently. On confirmation, the feedback wins and the plan includes a task
   to bring the artifact back in line; if the user declines, drop that item
   from the plan and leave the artifact and feedback item as-is (still
   `status: open` — it wasn't resolved). Remember which files/items were
   loaded and confirmed; you'll mark the consumed files in step 9.

5. **Check constitution compliance** if `constitution.md` is present. Flag any
   planned patterns that require a Complexity Tracking entry per the simplicity
   principle.

6. **Check for existing approved plans.** List `.project/plans/plan-*.md` and
   read frontmatter. If any have `status: approved`, ask the user whether the
   plan you're about to draft supersedes one of them. Remember the answer for
   step 9.

7. **Draft the plan** covering:
   - **Goal** — what this plan delivers (one sentence)
   - **Scope** — what is and is not included
   - **Technical Approach** — how the system will be built; reference artifact
     decisions rather than repeating them
   - **Phase Breakdown** — ordered phases with dependencies called out; each
     phase produces a testable, demonstrable increment. Feedback items tagged
     with an artifact become artifact-revision tasks (`[artifacts: name]`);
     untagged feedback items become ordinary code-change tasks. Reference
     which feedback item each such task addresses.
   - **Complexity Tracking** — table of justified deviations from the simplicity
     principle (if a constitution is present)
   - **Open Questions** — anything that must be resolved before or during
     implementation
   - **Production Annotation Summary** — list of known production shortcuts to
     annotate during implementation

8. **Write the plan** to `.project/plans/plan-<slug>-<YYYY-MM-DD>.md` with
   frontmatter:

   ```yaml
   ---
   status: draft        # draft -> approved -> superseded
   branch: <slug>
   created: YYYY-MM-DD
   ---
   ```

9. **Present a summary** to the user: phases, key decisions, open questions.
   Ask for approval before the plan is considered final. Do not generate tasks
   until the user approves.

   Once approved:
   - Flip this plan's frontmatter `status` to `approved` in place.
   - If step 6 identified a plan this one supersedes, flip that plan's
     `status` to `superseded` in place.
   - For each feedback file loaded in step 4, mark each item `[x]` if it was
     incorporated into the plan, or `[-]` if the user declined an override
     (per step 4) — mirroring `critique.md`'s resolution convention. Once
     every item in a file is `[x]` or `[-]`, flip that file's `status` to
     `planned` and set its `plan:` field to this plan's filename; planned
     feedback files are not edited further and become a historical record of
     what prompted the plan. If any item is still unresolved (e.g. the user
     wants to think about a declined override more), leave the file's
     `status` as `open` so the next `/ardd-plan` run picks up the remainder.
   - Remind the user to run `/ardd-analyze` to update the recommended next
     step in `STATUS.md`.
