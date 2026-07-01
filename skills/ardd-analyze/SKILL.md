# /ardd-analyze

Non-destructive cross-artifact consistency and quality check. Discovers and
reads all artifacts present in `.project/artifacts/`, then reports gaps,
contradictions, and implied-but-undefined decisions.

## Steps

1. **Discover artifacts** by listing `.project/artifacts/`. Read every `.md`
   file present. Note which are `status: draft` and which are referenced by
   other artifacts but missing.

   Also check for `.project/DEFECTS.md`. If present, read its last-verified
   date and defect count — this is read-only: `/ardd-analyze` never
   regenerates, edits, or appends to `DEFECTS.md` (that file belongs solely to
   `/ardd-verify`). If absent, note that verify has never run.

   Also glob `.project/feedback/feedback-*.md` and read frontmatter. Count
   files with `status: open` — this is read-only visibility; `/ardd-analyze`
   never writes to feedback files (that belongs solely to `/ardd-feedback`
   and `/ardd-plan`).

   Also read `.project/artifacts/features.md` if present. Count entries by
   `Status` (`backlogged`/`planned`/`tasked`/`implemented`) — read-only
   visibility; `/ardd-analyze` never writes to `features.md` (that belongs to
   `/ardd-feature`, `/ardd-plan`, `/ardd-tasks`, `/ardd-implement`, and
   `/ardd-converge`).

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
   - <name>.md — current ✅ / stale ⚠️ (run /ardd-render <name>) / unrendered ⚠️ (never generated — run /ardd-render <name>)
   (Only list renderable artifacts: datamodel, infrastructure, ui. Read each
   one's `diagram_status` frontmatter field directly — do not infer from
   whether a README section merely exists.)

   ## Code-vs-Artifact Defects
   - <N> known defects — see DEFECTS.md, last checked YYYY-MM-DD. Run
     /ardd-verify to refresh.
   (Or, if DEFECTS.md is absent: "Never checked — run /ardd-verify to compare
   artifacts against the codebase." This section is visibility only —
   `/ardd-analyze` does not read code itself and does not regenerate
   DEFECTS.md.)

   ## Feedback
   - <N> open feedback file(s) — see `.project/feedback/`, will be picked up
     by the next `/ardd-plan`. (Omit this section if none are open.)

   ## Feature Backlog
   - <N> backlogged · <N> planned · <N> tasked · <N> implemented — see
     `.project/artifacts/features.md`. Target a backlogged slug with
     `/ardd-plan <slug>`. (Omit this section if `features.md` doesn't exist.)

   ## Summary
   <N> issues found. Safe to /plan: yes/no. Recommended next step: ...
   ```

6. **Write `.project/STATUS.md`** from the analysis results. Use the same
   structure defined in `/ardd-bootstrap`:
   - Artifact status table (name, stable ✅ / draft ⚠️, open question count or —)
   - Open questions grouped by artifact (omit artifacts with none)
   - A line surfacing `DEFECTS.md`'s summary (count + last-checked date, or
     "never checked") drawn from step 1 — read-only, not regenerated here
   - A line surfacing the open feedback count from step 1 (omit if zero)
   - A line surfacing the feature backlog counts from step 1 (omit if
     `features.md` doesn't exist)
   - Recommended next step drawn from the Summary
   - Update the `_Updated:` date to today

   STATUS.md is the single re-entry point after any interruption. `/ardd-analyze`
   is its only writer — other skills prompt the user to run it rather than
   writing STATUS.md themselves.
