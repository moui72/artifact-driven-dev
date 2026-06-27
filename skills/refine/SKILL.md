# /refine

Refine a project artifact. Usage: `/refine <artifact>` where artifact is one of:
`constitution`, `infrastructure`, `datamodel`, `ui`.

## Steps

1. **Load the artifact** from `.project/artifacts/<artifact>.md`. If it does not
   exist, create it from scratch using the structure in the Template section below.

2. **Understand the user's intent.** The user may have provided guidance in their
   invocation (e.g., `/refine datamodel add a source_ehr field to protocols`).
   If no guidance was provided, read the artifact and ask up to 3 targeted
   clarifying questions about gaps, ambiguities, or decisions that appear unresolved.
   Do not ask questions that can be answered by reading the other artifacts.

3. **Apply changes.** Update the artifact content to reflect the user's guidance
   and any gaps you identified. Preserve all existing decisions unless the user
   explicitly changes them.

4. **Special rules for `constitution`:**
   - Follow version-bump semantics (MAJOR/MINOR/PATCH).
   - Prepend an updated Sync Impact Report HTML comment.
   - Update `last_updated` in frontmatter and the version line at the bottom.

5. **Update frontmatter** on all other artifacts:
   - Set `status: stable` if the artifact is substantially complete with no open
     questions. Set `status: draft` if significant gaps remain.
   - Set `last_updated` to today's date (YYYY-MM-DD).

6. **Write the updated artifact** back to `.project/artifacts/<artifact>.md`.

7. **Report** what changed in 2–3 sentences. Note any open questions deferred
   for a future `/refine` pass.

## Artifact Template

Use this structure when creating an artifact from scratch:

```markdown
---
name: <artifact>
status: draft
last_updated: YYYY-MM-DD
---

# <Title>

<content>
```

### `infrastructure.md` sections
- **Overview** — sync strategy, storage choice, rationale
- **EHR Adapters** — one subsection per EHR: fetch strategy, pagination, auth
- **Sync Jobs** — bootstrap and incremental sync; parameters; scheduling note
- **Production Annotations** — list of known shortcuts with Principle VI notes

### `datamodel.md` sections
- **Overview** — canonical model purpose, source-of-truth note
- **Entities** — one subsection per entity (Patient, Appointment, Encounter,
  CareProtocol); fields table with type, source mapping (MedChart → canonical,
  CarePoint → canonical), and notes
- **Normalization Rules** — date formats, ID schemes, enum values, string parsing
- **Indexes** — query patterns that require indexes

### `ui.md` sections
- **Overview** — purpose, target user, key interactions
- **Daily View** — layout, date navigation, per-practice presentation
- **Appointment Row** — fields displayed, recommended action badges
- **Recommended Actions** — one subsection per action type with detection logic
  summary and display spec
- **States** — loading, empty, error
