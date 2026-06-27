# /ardd-research

Investigate a specific topic and produce a research document. Usage:
`/research <topic>` (e.g., `/research sqlite orm options`,
`/research carepoint appointment sync strategy`).

## Steps

1. **Understand the topic** from the user's invocation. If ambiguous, ask one
   clarifying question before proceeding.

2. **Load relevant artifacts** from `.project/artifacts/` to understand context.
   Do not re-investigate things already decided in an artifact.

3. **Investigate** using available tools: read code, fetch URLs, search, inspect
   APIs, check library documentation. Be thorough on the specific question.

4. **Write a research document** to `.project/plans/research-<slug>-<YYYY-MM-DD>.md`
   using this structure:

   ```markdown
   ---
   topic: <topic>
   date: YYYY-MM-DD
   status: complete
   ---

   # Research: <Topic>

   ## Question
   <The specific question this research answers>

   ## Findings
   <What was discovered — facts, tradeoffs, examples>

   ## Recommendation
   <Concrete recommendation with rationale>

   ## Rejected Alternatives
   <What was considered and why it was ruled out>

   ## Open Questions
   <Anything that needs a follow-up decision>
   ```

5. **Report** the recommendation to the user in 2–3 sentences and note the
   file path where the full research was saved.
