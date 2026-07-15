---
name: ardd-refine
tier: core
description: "Update a named artifact — apply new decisions, resolve open questions, handle constitution versioning; given a name that doesn't exist yet, it creates the artifact from a template (absorbs ardd-add-artifact)."
---

# /ardd-refine

Refine a project artifact. Usage: `/ardd-refine <name>` where name matches a file
in `.project/artifacts/` (e.g., `constitution`, `infrastructure`, `datamodel`,
`ui`, or any custom artifact). Naming an artifact that doesn't exist yet
enters the create path (step 1) — there is no separate add-artifact
command.

## No-argument mode

If invoked without a `<name>` (just `/ardd-refine`), refine every artifact
that has open questions instead of a single one:

1. Read `.project/STATUS.md` for the open-question counts per artifact (run
   `/ardd-status` first if `STATUS.md` is missing or stale).
2. Build the list of artifacts with at least one open question, sorted by
   open-question count descending (most open issues first). Skip any artifact
   with zero open questions.
3. Run the normal refine steps below (steps 1–8) on each artifact in that
   order, using its open questions as the guidance/clarifying-question input
   for step 2 instead of asking from scratch.
4. After the pass, run `/ardd-status` once automatically to refresh
   `STATUS.md` for all refined artifacts, rather than after each one — skip
   the per-artifact trigger in step 8 below while running in this mode.

## Steps

1. **Load the artifact** from `.project/artifacts/<name>.md`. If it does not
   exist, offer to create it (the create path, formerly
   `ardd-add-artifact`):
   - **Find a template.** Look for `.claude/skills/ardd-artifact-templates/
     <name>.md` (installed by `install.sh`), falling back to
     `.claude/skills/ardd-artifact-templates/generic.md`, or to no fixed
     structure if the templates directory isn't present.
   - **Seed it** from conversation context and any description the user
     gave. Replace all placeholder tokens; use `[OPEN: <question>]` for
     anything unresolved.
   - **Set frontmatter explicitly**, matching `/ardd-init`'s frontmatter field
     list: `status: <draft if open questions remain, else stable>` and
     `last_updated: <today YYYY-MM-DD>`. Add `diagram_status: unrendered`
     if the new artifact is a renderable one (`datamodel`,
     `infrastructure`, `ui`) — creation never generates a diagram itself,
     so a renderable artifact always starts `unrendered`, never `current`.
   - **Register it**: add a row for the new artifact to
     `.project/WORKFLOW.md`'s Artifacts table, and add it to the artifacts
     list in `CLAUDE.md`.
   - Then continue with the steps below on the freshly created file (steps
     2–3 typically have little to change on a just-seeded artifact; if
     nothing further is needed, skip to step 7's capture — where the whole
     new artifact is the delta — then step 8's report; and since other
     artifacts may reference the new one, run `/ardd-status` rather than
     just suggesting it).

2. **Understand the user's intent.** The user may have provided guidance in
   their invocation (e.g., `/ardd-refine datamodel add a source_ehr field`).
   If no guidance was provided, read the artifact and ask up to 3 targeted
   clarifying questions about gaps, ambiguities, or unresolved decisions.
   Do not ask questions answerable by reading other artifacts.

3. **Apply changes.** Update the artifact to reflect guidance and resolved gaps.
   Preserve all existing decisions unless the user explicitly changes them.

   `[OPEN: ...]` is reserved for genuine undecided-design-question gaps only.
   If the user mentions a known code-vs-artifact violation (e.g., something
   visible in `.project/DEFECTS.md`), do not write violation narrative into
   the artifact body — the artifact describes the intended/current design,
   not a defect log. Point the user at `DEFECTS.md` / `/ardd-defects` instead.

4. **Special rules for `constitution`:**
   - Follow version-bump semantics (MAJOR/MINOR/PATCH).
   - Prepend an updated Sync Impact Report HTML comment.
   - Update `last_updated` in frontmatter and the version line at the bottom.

5. **Update frontmatter** on all other artifacts:
   - Set `status: stable` if substantially complete with no open questions.
     Set `status: draft` if significant gaps remain.
   - Set `last_updated` via `.claude/skills/ardd-scripts/ardd-state.sh
     stamp <file> last_updated <today>`.
   - If the artifact is renderable (`datamodel`, `infrastructure`, or `ui`),
     run `ardd-state.sh stamp <file> diagram_status stale` — unless it is
     currently `unrendered`, in which case leave it `unrendered` (no
     diagram has ever been generated, so there's nothing to go stale).

6. **Write** the updated artifact back to `.project/artifacts/<name>.md`.

7. **Capture newly documented capabilities — delta-scoped.** A refine can
   introduce scope the system doesn't have yet — a pivot recorded in the
   artifact but tracked nowhere. The candidates are ONLY capabilities
   newly introduced or materially changed by the edit just applied in
   steps 3–6 — never the artifact's long-standing documented scope; the
   user must not be re-prompted about unchanged content on every refine.
   On the create path (step 1), the whole new artifact is the delta.

   - **Enumerate candidates from the delta.** The agent lists each
     capability the edit newly describes or materially changes that has
     (a) no entry in `.project/features/` — checked against every
     status, including `implemented` and `retired` — and (b) no existing
     implementation. What counts as a capability versus a design note is
     the agent's judgment; when unsure, offer it and let the user
     decline.
   - **Confirm in one batched prompt.** If any candidates exist, present
     them in ONE grouped prompt (AskUserQuestion, multiSelect on) with
     per-item accept/decline — never N sequential prompts (the same
     pattern as `/ardd-feedback`'s re-file step). If there are no
     candidates, skip silently.
   - **Create accepted entries.** For each accepted item: derive a slug
     (`.claude/skills/ardd-scripts/ardd-state.sh slug "<item>"`), then
     create the register entry:

     ```
     printf '%s\n' "<one-sentence description>" \
       | .claude/skills/ardd-scripts/ardd-state.sh feature-create <slug>
     ```

     Declined items are simply not created; the user's judgment is
     final for this run.

8. **Report** what changed in 2–3 sentences. Note any open questions deferred
   for a future `/ardd-refine` pass. If invoked for a single artifact (not
   via no-argument mode), run `/ardd-status` now to refresh `STATUS.md` with
   the updated artifact status and open questions — in no-argument mode this
   is skipped here since it already runs once after the full pass (above).

## Built-in artifact guidance

When refining a known artifact type, use these section structures as guidance.
For custom artifacts, follow the sections already present in the file.

Any artifact documenting a known production shortcut or gap does so under a
`## Production Annotations` heading, never as inline prose in another
section — this is what lets `/ardd-plan`'s Production Annotation Summary
step and `/ardd-audit` find them reliably. If the agent finds one written
inline elsewhere while refining, move it under `## Production Annotations` (adding
the section if it doesn't exist yet) rather than leaving it in place.

### `infrastructure.md`
- **Overview** — sync strategy, storage choice, rationale
- **Integration Components** — one subsection per external source/service:
  fetch strategy, pagination, auth
- **Sync Jobs** — bootstrap and incremental sync; parameters; scheduling note
- **Production Annotations** — known shortcuts with production annotation notes

### `datamodel.md`
- **Overview** — canonical model purpose, source-of-truth note
- **Entities** — one subsection per entity; fields table with type, source
  mapping, and notes
- **Normalization Rules** — date formats, ID schemes, enum values, string parsing
- **Indexes** — query patterns that require indexes
- **Production Annotations** — known shortcuts with production annotation notes

### `ui.md`
- **Overview** — purpose, target user, key interactions
- **Views** — one subsection per distinct view or screen
- **Components** — shared components used across views
- **States** — loading, empty, error handling per view
- **Production Annotations** — known shortcuts with production annotation notes
