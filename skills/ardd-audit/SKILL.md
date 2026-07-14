---
name: ardd-audit
tier: extension
description: "Challenge artifact decisions — simplicity, failure modes, robustness, semantics — and write the findings checklist to .project/audit.md. Takes no proposal input — vet new ideas with /ardd-research instead."
---

# /ardd-audit

Critically review project artifacts and challenge design decisions. Unlike
`/ardd-status` (which checks consistency and completeness), this skill asks
whether the decisions themselves are good — then persists findings to
`.project/audit.md` as a working checklist.

Usage: `/ardd-audit` to review all artifacts, or `/ardd-audit <name>`
to focus on a single artifact.

## Steps

0. **Reject non-artifact arguments** (mirrors `/ardd-plan`'s argument
disambiguation, as an explicit early step). The only legal argument is the
name of an existing `.project/artifacts/*.md` file (with or without the
`.md`). Anything else — a proposal, an idea, a "what if we..." — is not an
artifact to audit: stop and redirect to `/ardd-research <proposal>`, whose
proposal-vetting mode applies this skill's lenses to a *hypothetical*
change; this skill audits only decisions already recorded in artifacts. Do
not silently ignore the argument and run a full pass anyway.

1. **Check for an existing `.project/audit.md`.**

   - Adoption first: if `audit.md` is absent but the legacy `critique.md` exists
     (an install predating the v1.0.0 rename), rename it to `audit.md` and
     continue as if `audit.md` had always been there.
   - If it exists and has unresolved items (`- [ ]`):
     - Report the count of open items grouped by artifact.
     - Check whether any artifacts have been updated (via `last_updated`
       frontmatter) since the audit file was last written (check the
       file's own `_Updated:` line). If any have, note them: "N artifact(s)
       updated since last audit — findings for those may be stale."
     - Present three options and wait for the user to choose:
       1. Continue working through existing findings (exit — user will
          use `/ardd-refine` directly from the checklist)
       2. Refresh findings for a specific artifact (proceed to step 2
          scoped to that artifact, then upsert only that artifact's section)
       3. Generate a full fresh report (proceed to step 2 for all artifacts,
          overwrite the file)
   - If it exists but all items are resolved or rejected (`[x]` / `[-]`):
     - Note that all prior findings are closed.
     - Proceed to generate a fresh report without prompting.
   - If it does not exist: proceed to step 2.

2. **Load artifacts.** If scoped to a named artifact, load that file. Otherwise
   load all `.md` files in `.project/artifacts/`. Also load the feature register (`.project/features/*.md`) if
   present.

3. **Apply critical lenses.** For each artifact, work through every lens below.
   Skip a lens only when it genuinely has nothing to surface — err toward
   raising the question rather than silently passing.

   ### Simplicity
   - What could be removed without losing meaningful capability?
   - Are there abstractions that exist for hypothetical future needs?
   - Is any entity, field, route, or component doing more than one job?

   ### Failure modes
   - What happens when an external dependency is unavailable or returns
     unexpected data?
   - What decisions assume happy-path conditions that won't always hold?
   - What's the failure behavior for the most likely runtime errors — explicit
     (error surfaced) or silent (corrupt state, wrong result)?
   - What data can become inconsistent, stale, or orphaned?

   ### Standardness
   - Are established conventions being reinvented?
   - Would a developer unfamiliar with this codebase recognize the patterns?

   ### Robustness and fragility
   - What decisions couple things that should be independent?
   - What would ripple if a key assumption changed?
   - Are there single points of failure with no fallback?

   ### DRYness
   - Is the same concept defined in more than one place?
   - What would go out of sync first if the system evolved?

   ### Semantics and intuitiveness
   - Are names clear about what they represent without needing context?
   - Are there misleading names — things that imply more or less than they do?
   - Are enum values or type discriminators exhaustive and mutually exclusive?

   ### Proportionality
   - Are any decisions over-engineered for the stated scope?
   - Are any decisions under-specified where the cost of getting it wrong later
     is high?
   - Do the principles in `constitution.md` actually constrain the other
     artifacts, or are they decorative?

4. **Synthesize findings.** Consolidate into distinct findings. Discard
   stylistic preferences with no consequence. Keep only findings where acting
   would concretely improve simplicity, correctness, robustness, clarity, or
   maintainability.

   Classify each finding as:
   - **[S] Suggestion** — a concrete change with a clear resolution. Must
     include a command (see step 5). If the agent cannot write a tight
     command, reclassify as a Question.
   - **[Q] Question** — a decision that needs the user's input before a
     recommendation is possible; state the trade-off clearly. No command.
   - **[R] Risk** — a failure mode or fragility worth acknowledging even if
     no change is warranted now. No command.

   Do not soften findings to avoid discomfort. A finding held back is worse
   than one that turns out to be wrong — the user can reject it; they can't
   act on one never raised.

5. **Write `.project/audit.md`.** If refreshing a single artifact's section,
   upsert only that section and preserve the rest. Otherwise write the full
   file.

   Format:

   ```markdown
   # Audit
   _Updated: YYYY-MM-DD_

   ## <artifact name>

   - [ ] **[S]** <finding — what the problem is and why it matters>
     > `/ardd-refine <artifact> <tight directive describing the change>`

   - [ ] **[Q]** <finding — the trade-off; what the answer changes>

   - [ ] **[R]** <finding — what could go wrong and under what conditions>

   ## <artifact name>
   ...

   ## Summary
   <N> suggestions · <N> questions · <N> risks across <N> artifacts.
   ```

   Rules for commands on Suggestions:
   - Use `/ardd-refine <artifact> <directive>` for artifact changes.
   - Use `/ardd-backlog <description>` if the finding implies a cross-artifact
     change.
   - The directive must be specific enough to act on without re-reading the
     finding (e.g., "consolidate AiNote and StoredNote into a single Note type
     with optional id and created_at" not "fix the note types").
   - Keep it to one command per finding. If a finding requires two separate
     refine calls, split it into two findings.

6. **Report** in one sentence: how many findings were written and where the
   file was saved. Do not reprint the findings — the file is the deliverable.

## Resolution workflow

As the user works through findings, they update `.project/audit.md` directly:

- `- [ ]` → open
- `- [x]` → resolved (ran the command or took equivalent action)
- `- [-]` → rejected or deferred (with an optional note on the same line)

The next `/ardd-audit` run will see these statuses and report accordingly.
