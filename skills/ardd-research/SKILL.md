---
name: ardd-research
tier: extension
description: "Targeted investigation or proposal vetting, written to .project/plans/ — one-off output with no lifecycle; substantial or decision-reversing ideas get vetted here before they reach the backlog or a plan."
---

# /ardd-research

Investigate a specific topic — or vet a proposal — and produce a research
document. Usage: `/ardd-research <topic>` (e.g., `/ardd-research sqlite orm
options`, `/ardd-research carepoint appointment sync strategy`), or, for
**proposal vetting**, hand it the idea itself (e.g., `/ardd-research
proposal: replace the per-feature register with a single features table` —
anything substantial, architecture-shaped, or reversing a committed
decision).

## Steps

1. **Understand the topic** from the user's invocation. If ambiguous, ask one
   clarifying question before proceeding.

   **Classify the object:** a *question to investigate* runs the steps below
   as written; a *proposal to vet* (a change to how the system should work,
   rather than a question about facts) runs them with the proposal-vetting
   emphases marked in steps 2–4.

2. **Load relevant artifacts** from `.project/artifacts/` to understand context.
   Do not re-investigate things already decided in an artifact.

   *Proposal vetting:* load the **current** artifacts the proposal would
   touch — the point is to evaluate the idea against what the system
   actually is today, not against a remembered sketch of it.

3. **Investigate** using available tools: read code, fetch URLs, search, inspect
   APIs, check library documentation. Be thorough on the specific question.

   *Proposal vetting:* additionally apply `/ardd-audit`'s critical lenses
   **by reference** — work through the lens list in its "Apply critical
   lenses" step (simplicity, failure modes, standardness, robustness,
   DRYness, semantics, proportionality; read it from
   `.claude/skills/ardd-audit/SKILL.md` rather than reproducing it here) to
   the proposal itself, and answer explicitly: what goals does it serve?
   what are the strongest challenges to it? which committed decisions in
   the artifacts would it reverse (name them and where they're recorded)?
   and, weighing all of that — is it worth it?

4. **Write a research document** to `.project/plans/<filename>`, minting
   the filename via `.claude/skills/ardd-scripts/ardd-state.sh mint
   research <slug>` (sanitize the topic first with `ardd-state.sh slug`)
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

   *Proposal vetting:* the same structure, with the Findings section
   carrying the lens results and reversed-decisions list, and the
   Recommendation section closing with exactly one of three routes:
   **`/ardd-backlog <description>`** (worth doing — log it and let
   `/ardd-plan <slug>` design it later), **`/ardd-plan`** (worth doing now
   and already well-enough understood to plan directly), or **drop** (state
   why, so the next person with the same idea finds the reasoning). The
   output stays a one-off `.project/plans/` document with no lifecycle —
   the recommended route is where the idea acquires one.

5. **Report** the recommendation to the user in 2–3 sentences and note the
   file path where the full research was saved. If the recommendation is a
   standing decision (a library choice, a sync strategy, anything that
   belongs in an artifact), recommend `/ardd-refine <artifact>` as the next
   step to actually record it — a research doc is a one-off write with no
   lifecycle, so nothing else in the system will pick it up automatically.
   If it instead surfaces new backlog-worthy scope rather than a decision,
   recommend `/ardd-backlog` instead.
