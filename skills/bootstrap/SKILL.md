# /bootstrap

One-time initialization. Seeds `.project/artifacts/` from the current
conversation context. Run once at the start of a project; use `/refine`
for all subsequent updates.

## Steps

1. **Check for existing artifacts.** If `infrastructure.md`, `datamodel.md`,
   or `ui.md` already exist in `.project/artifacts/`, warn the user and ask
   for confirmation before overwriting.

2. **Synthesize each artifact** from everything established in the current
   conversation: API explorations, architectural decisions, data shapes, UI
   intentions, constraints discussed. Do not invent decisions that were not
   made — use `[OPEN: <question>]` for anything unresolved.

3. **Write three artifacts:**

   ### `.project/artifacts/infrastructure.md`
   Cover: sync strategy per EHR, storage choice and rationale, adapter pattern,
   bootstrap vs incremental sync, job parameters, production annotation summary.

   ### `.project/artifacts/datamodel.md`
   Cover: canonical entities (Patient, Appointment, Encounter, CareProtocol),
   field-level mapping tables (MedChart → canonical, CarePoint → canonical),
   normalization rules (dates, IDs, enums, diagnosis string parsing), indexes.

   ### `.project/artifacts/ui.md`
   Cover: daily view layout, date navigation scope, per-practice presentation,
   appointment row fields, recommended action types and detection logic summary,
   loading/empty/error states.

   Use the artifact template from `/refine`:
   ```markdown
   ---
   name: <artifact>
   status: draft
   last_updated: YYYY-MM-DD
   ---
   ```
   Set `status: draft` for any artifact with open questions.

4. **Report** what was written, how many open questions were left in each
   artifact, and suggest running `/analyze` next to catch cross-artifact issues
   before refining further.
