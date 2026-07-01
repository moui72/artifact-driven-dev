# /ardd-refine

Refine a project artifact. Usage: `/refine <name>` where name matches a file
in `.project/artifacts/` (e.g., `constitution`, `infrastructure`, `datamodel`,
`ui`, or any custom artifact added with `/ardd-add-artifact`).

## No-argument mode

If invoked without a `<name>` (just `/ardd-refine`), refine every artifact
that has open questions instead of a single one:

1. Read `.project/STATUS.md` for the open-question counts per artifact (run
   `/ardd-analyze` first if `STATUS.md` is missing or stale).
2. Build the list of artifacts with at least one open question, sorted by
   open-question count descending (most open issues first). Skip any artifact
   with zero open questions.
3. Run the normal refine steps below (steps 1–7) on each artifact in that
   order, using its open questions as the guidance/clarifying-question input
   for step 2 instead of asking from scratch.
4. After the pass, remind the user to run `/ardd-analyze` once to refresh
   `STATUS.md` for all refined artifacts, rather than after each one.

## Steps

1. **Load the artifact** from `.project/artifacts/<name>.md`. If it does not
   exist, offer to create it — look for a template at
   `templates/artifacts/<name>.md` in the ADD installation, falling back to
   `templates/artifacts/generic.md`.

2. **Understand the user's intent.** The user may have provided guidance in
   their invocation (e.g., `/refine datamodel add a source_ehr field`).
   If no guidance was provided, read the artifact and ask up to 3 targeted
   clarifying questions about gaps, ambiguities, or unresolved decisions.
   Do not ask questions answerable by reading other artifacts.

3. **Apply changes.** Update the artifact to reflect guidance and resolved gaps.
   Preserve all existing decisions unless the user explicitly changes them.

   `[OPEN: ...]` is reserved for genuine undecided-design-question gaps only.
   If the user mentions a known code-vs-artifact violation (e.g., something
   visible in `.project/DEFECTS.md`), do not write violation narrative into
   the artifact body — the artifact describes the intended/current design,
   not a defect log. Point the user at `DEFECTS.md` / `/ardd-verify` instead.

4. **Special rules for `constitution`:**
   - Follow version-bump semantics (MAJOR/MINOR/PATCH).
   - Prepend an updated Sync Impact Report HTML comment.
   - Update `last_updated` in frontmatter and the version line at the bottom.

5. **Update frontmatter** on all other artifacts:
   - Set `status: stable` if substantially complete with no open questions.
     Set `status: draft` if significant gaps remain.
   - Set `last_updated` to today's date (YYYY-MM-DD).
   - If the artifact is renderable (`datamodel`, `infrastructure`, or `ui`),
     set `diagram_status: stale` — unless it is currently `unrendered`, in
     which case leave it `unrendered` (no diagram has ever been generated,
     so there's nothing to go stale).

6. **Write** the updated artifact back to `.project/artifacts/<name>.md`.

7. **Report** what changed in 2–3 sentences. Note any open questions deferred
   for a future `/ardd-refine` pass. Remind the user to run `/ardd-analyze`
   to refresh `STATUS.md` with the updated artifact status and open questions.

## Built-in artifact guidance

When refining a known artifact type, use these section structures as guidance.
For custom artifacts, follow the sections already present in the file.

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

### `ui.md`
- **Overview** — purpose, target user, key interactions
- **Views** — one subsection per distinct view or screen
- **Components** — shared components used across views
- **States** — loading, empty, error handling per view
