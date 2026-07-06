---
name: ardd-add-artifact
description: Create a new, non-standard artifact from a template.
---

# /ardd-add-artifact

Create a new artifact in `.project/artifacts/`. Usage:
`/ardd-add-artifact <name> [brief description of purpose]`

## Steps

1. **Check for conflicts.** If `.project/artifacts/<name>.md` already exists,
   tell the user and stop.

2. **Find a template.** Look for `.claude/skills/ardd-artifact-templates/
   <name>.md` (installed by `install.sh`). If found, use it as the starting
   structure. Otherwise use `.claude/skills/ardd-artifact-templates/
   generic.md`, or no fixed structure if the templates directory isn't
   present.

3. **Seed the artifact** from conversation context and the user's description.
   Replace all placeholder tokens. Use `[OPEN: <question>]` for anything
   unresolved.

   Set frontmatter explicitly, matching `/ardd-codify` step 4's field list:
   ```
   status: <draft if open questions remain, else stable>
   last_updated: <today YYYY-MM-DD>
   ```
   Add `diagram_status: unrendered` if the new artifact is a renderable one
   (`datamodel`, `infrastructure`, `ui`) — this skill never generates a
   diagram itself, so a renderable artifact always starts `unrendered`, never
   `current`.

4. **Write** the artifact to `.project/artifacts/<name>.md`.

5. **Update `.project/WORKFLOW.md`** — add a row for the new artifact in the
   Artifacts table.

6. **Update `CLAUDE.md`** — add the new artifact to the artifacts list.

7. **Report** what was created. If other artifacts may reference this one,
   run `/ardd-analyze` now instead of just suggesting it.
