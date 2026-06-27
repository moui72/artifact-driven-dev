# /plan

Generate an implementation plan from the current artifacts and any research docs.
Run `/analyze` first — do not plan over unresolved conflicts.

## Steps

1. **Load all artifacts** from `.project/artifacts/`. If any are `status: draft`
   or missing, warn the user and ask whether to proceed.

2. **Load any research documents** from `.project/plans/research-*.md` that are
   relevant to the current work.

3. **Check constitution compliance.** Review Principle III (Simplicity) and flag
   any planned patterns that require a Complexity Tracking entry.

4. **Draft the plan** covering:

   - **Goal** — what this plan delivers (one sentence)
   - **Scope** — what is and is not included
   - **Technical Approach** — how the system will be built; reference artifact
     decisions rather than repeating them
   - **Phase Breakdown** — ordered phases with dependencies called out; each
     phase produces a testable, demonstrable increment per Principle I and V
   - **Complexity Tracking** — table of any justified deviations from Principle III
   - **Open Questions** — anything that must be resolved before or during implementation
   - **Production Annotation Summary** — list of known Principle VI items to add

5. **Write the plan** to `.project/plans/plan-<YYYY-MM-DD>.md`.

6. **Present a summary** to the user: phases, key decisions, any open questions.
   Ask for approval before the plan is considered final. Do not generate tasks
   until the user approves.
