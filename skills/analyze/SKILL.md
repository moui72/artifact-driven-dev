# /analyze

Non-destructive cross-artifact consistency and quality check. Reads all artifacts
and reports gaps, contradictions, and implied-but-undefined decisions.

## Steps

1. **Load all artifacts** from `.project/artifacts/`: `constitution.md`,
   `infrastructure.md`, `datamodel.md`, `ui.md`. Note which are missing or
   still `status: draft`.

2. **Check cross-artifact consistency** across these dimensions:

   - **Infrastructure ↔ Datamodel**: Every entity the infrastructure layer
     fetches and stores must exist in the data model. Every field the sync
     jobs write must be defined. Storage choice must be consistent.

   - **Datamodel ↔ UI**: Every field the UI displays or uses for business logic
     (recommended action detection, sorting, filtering) must exist in the data
     model. No UI field should be undefined or ambiguous in its source.

   - **Infrastructure ↔ UI**: Sync frequency and data freshness assumptions must
     be compatible with what the UI promises to users.

   - **Constitution ↔ All**: Check that no artifact decision violates a
     constitution principle (e.g., a pattern that introduces unjustified
     complexity per Principle III, or a shortcut missing a Principle VI
     annotation).

3. **Check within each artifact** for:
   - Unresolved placeholders or TODOs
   - Vague language where a concrete decision is needed
   - Missing rationale for non-obvious choices
   - `status: draft` artifacts that block planning

4. **Produce a report** structured as:

   ```
   ## Cross-Artifact Issues
   - [CONFLICT] <description> — <artifact A> says X, <artifact B> says Y
   - [GAP] <description> — <artifact A> implies X but <artifact B> doesn't define it
   - [MISSING] <artifact> does not exist yet

   ## Within-Artifact Issues
   ### <artifact>
   - [TODO] <unresolved item>
   - [VAGUE] <item needing a concrete decision>

   ## Constitution Compliance
   - [VIOLATION] <description>
   - [ANNOTATION MISSING] <shortcut without a Principle VI note>

   ## Summary
   <N> issues found. Safe to /plan: yes/no. Recommended next step: ...
   ```

5. **Do not modify any files.** This skill is read-only.
