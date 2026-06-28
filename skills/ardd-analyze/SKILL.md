# /ardd-analyze

Non-destructive cross-artifact consistency and quality check. Discovers and
reads all artifacts present in `.project/artifacts/`, then reports gaps,
contradictions, and implied-but-undefined decisions.

## Steps

1. **Discover artifacts** by listing `.project/artifacts/`. Read every `.md`
   file present. Note which are `status: draft` and which are referenced by
   other artifacts but missing.

2. **Check cross-artifact consistency** for every pair of artifacts:
   - Any entity, field, endpoint, or concept mentioned in one artifact must be
     defined in the artifact that owns it. Flag anything referenced but
     undefined.
   - Decisions that span artifacts must be consistent — e.g., a storage choice
     in `infrastructure.md` must match assumptions in `datamodel.md`.
   - If a view/UI artifact exists, every field it displays or uses for logic
     must exist in the data model artifact.

3. **Check against `constitution.md`** if present:
   - Flag decisions in any artifact that violate a stated principle.
   - Flag shortcuts that lack a production annotation entry (if the constitution
     includes a production annotation principle).

4. **Check within each artifact:**
   - Unresolved `[OPEN: ...]` placeholders or TODOs
   - Vague language where a concrete decision is needed
   - `status: draft` artifacts that would block planning

5. **Produce a report:**

   ```
   ## Artifacts Found
   - <name>.md — stable ✅ / draft ⚠️
   - <name>.md — missing ❌ (referenced by <other artifact>)

   ## Cross-Artifact Issues
   - [CONFLICT] <description> — <artifact A> says X, <artifact B> says Y
   - [GAP] <description> — <artifact A> implies X but <artifact B> doesn't define it

   ## Within-Artifact Issues
   ### <artifact>
   - [OPEN] <unresolved item>
   - [VAGUE] <item needing a concrete decision>

   ## Constitution Compliance
   - [VIOLATION] <description>
   - [ANNOTATION MISSING] <shortcut without a production annotation>

   ## Diagrams
   - <name>.md — up to date ✅ / stale ⚠️ (run /ardd-render <name>)
   (Only list renderable artifacts: datamodel, infrastructure, ui)

   ## Summary
   <N> issues found. Safe to /plan: yes/no. Recommended next step: ...
   ```

6. **Write `.project/STATUS.md`** from the analysis results. Use the same
   structure defined in `/ardd-bootstrap`:
   - Artifact status table (name, stable ✅ / draft ⚠️, open question count or —)
   - Open questions grouped by artifact (omit artifacts with none)
   - Recommended next step drawn from the Summary
   - Update the `_Updated:` date to today

   STATUS.md is the single re-entry point after any interruption. `/ardd-analyze`
   is its only writer — other skills prompt the user to run it rather than
   writing STATUS.md themselves.
