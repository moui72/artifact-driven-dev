# /ardd-plan

Generate an implementation plan from the current artifacts and any research
docs. Run `/ardd-analyze` first — do not plan over unresolved conflicts.

## Steps

1. **Discover artifacts** by listing `.project/artifacts/`. Read every `.md`
   file present. If any are `status: draft`, warn the user and ask whether
   to proceed.

2. **Load any research documents** from `.project/plans/research-*.md` relevant
   to the current work.

3. **Check constitution compliance** if `constitution.md` is present. Flag any
   planned patterns that require a Complexity Tracking entry per the simplicity
   principle.

4. **Draft the plan** covering:
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

5. **Write the plan** to `.project/plans/plan-<YYYY-MM-DD>.md`.

6. **Present a summary** to the user: phases, key decisions, open questions.
   Ask for approval before the plan is considered final. Do not generate tasks
   until the user approves. Once approved, remind the user to run
   `/ardd-analyze` to update the recommended next step in `STATUS.md`.
