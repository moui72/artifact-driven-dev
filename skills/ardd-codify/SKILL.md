---
name: ardd-codify
tier: setup
description: "One-time: reverse-engineer artifacts from an existing codebase (instead of bootstrap)."
---

# /ardd-codify

Reverse-engineer project artifacts from an existing codebase. Use this to
migrate an already-built project into artifact-driven-dev, or to reconstruct
artifacts after they've drifted from the implementation.

Artifacts written by this skill are `status: draft` — they capture what the
code does, not necessarily what was intended. Review each one with
`/ardd-refine` to fill gaps and confirm decisions before planning new work.

## Steps

1. **Check for existing artifacts.** List `.project/artifacts/`. If any `.md`
   files already exist, warn the user and ask for confirmation before
   overwriting. On confirmation, proceed; on denial, exit.

2. **Survey the codebase.** Read enough of the project to understand its shape:
   - `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` — language,
     runtime, key dependencies
   - Directory tree (top 3 levels) — package boundaries, major modules
   - Entry points: `src/index.*`, `main.*`, `cmd/`, `app.*`
   - Schema files: migrations, ORM models, Prisma schema, SQL DDL
   - API surface: route files, controllers, OpenAPI specs, tRPC routers
   - UI: component tree root, shared component directory
   - External integrations: fetch/HTTP client call sites, env vars, config files
   - CI/CD: `.github/`, `Dockerfile`, deploy config

   Read broadly but stop before reading every file — the goal is coverage, not
   exhaustion. When a directory is clearly implementation detail (e.g., `dist/`,
   `node_modules/`, `__pycache__/`), skip it.

3. **Determine which standard artifacts to generate** based on what was found:

   | Artifact | Generate if... |
   |---|---|
   | `constitution.md` | Always — every project has implied principles; codify them |
   | `datamodel.md` | Schema files, ORM models, or typed data structures exist |
   | `infrastructure.md` | External APIs, sync jobs, background workers, or non-trivial storage |
   | `adapters.md` | Multiple distinct external data sources with different fetch patterns |
   | `api.md` | Defined HTTP routes or RPC surface |
   | `ui.md` | Frontend components or views exist |

   Also generate custom artifacts for significant concerns that don't fit the
   standard set (e.g., `auth.md`, `billing.md`). Use judgment — don't split
   what fits naturally in one artifact.

4. **Generate each artifact** from what the code reveals:

   - Extract concrete facts: field names and types from schema, routes from
     router files, component names from file structure, env vars from config.
   - Where the code is clear, write definitive statements.
   - Where intent is ambiguous (e.g., a field exists but its purpose isn't
     obvious), use `[OPEN: <question>]` rather than guessing.
   - Do not invent decisions not evident in the code.
   - For `constitution.md`: infer principles from observed patterns (e.g.,
     "REST over RPC" if only REST routes exist; "SQLite for storage" if that's
     what's imported). Mark inferred principles explicitly so the user can
     correct them.

     After inference, **offer opinionated suggestions** the same way
     `/ardd-bootstrap` does, before writing the artifact. Read `.claude/
     skills/ardd-constitution-data/constitution-suggestions.md` (installed
     by `install.sh`); if missing, skip this step and note it in the step 8
     report (recommend re-running `install.sh`). Filter by signal (using the
     step 2 codebase survey, which gives stronger signal than conversation
     alone — e.g. `tsconfig.json`/`.ts` files for a typed language, route
     files for API/REST shape, the component tree plus its framework for UI
     signals, presence of any test files/runner for the Test-First signal),
     dedupe against principles already inferred, then present via
     `AskUserQuestion` and apply accepted entries — all exactly as described
     in `/ardd-bootstrap` step 4.

     **Codify-specific:** for each accepted entry, check whether the step 2
     survey already shows it's currently violated (e.g. Test-First accepted
     but zero test files found anywhere in the survey). If so, append
     `[VIOLATED: <one-line evidence from the survey>]` to the inserted text,
     the same way other inferred content is marked for the user to see and
     correct. Never write to `DEFECTS.md` or the feature register here — report the
     violated count in step 8 instead, recommending `/ardd-defects` (to log
     each gap in `DEFECTS.md`) followed by `/ardd-feature` to backlog closing
     it. This preserves those files' existing single-writer ownership.

   Use the standard section structure for each known artifact type (see
   `/ardd-refine` built-in guidance). For custom artifacts, derive structure
   from the content.

   Set frontmatter on every artifact:
   ```
   status: draft
   last_updated: <today YYYY-MM-DD>
   ```
   Add `diagram_status: unrendered` for renderable artifacts (`datamodel`,
   `infrastructure`, `ui`) — codify never generates a diagram itself, so
   these always start unrendered, never `current`.

5. **Write all artifact files** to `.project/artifacts/`.

6. **Offer to extract the feature register.** Codify reconstructs *artifacts*
   (the system's current-state design); the feature register
   (`.project/features/`) is the complementary capability history. Right after
   the artifacts land is the moment to backfill it from the same codebase.
   Offer this to the user — it's optional and can be run later as part of the
   normal flow — and skip it if declined; otherwise:

   - **Check for an existing register.** If `.project/features/` already has
     entries (or a legacy `.project/artifacts/features.md` exists), warn and
     ask for confirmation before overwriting; on denial, skip the rest of this
     step.

   - **Survey the codebase for capability signals**, in this priority order —
     earlier sources give the clearest feature names and dates, later ones
     fill gaps. This complements the step-2 structural survey, which you can
     reuse: (1) **git log** (`git log --format="%ad %s" --date=short` —
     `feat:` commits and PR merge titles are most reliable); (2) **changelog**
     (`CHANGELOG.md`, a `## Changelog`/`## What's New` README section, or
     `gh release list` / `glab release list` if available); (3) **test
     descriptions** (`describe`/`it`/`test` names are often the clearest
     capability documentation); (4) **CLI help text and flag definitions**;
     (5) **API routes** (group related routes into one feature); (6) **named
     modules and exported functions**; (7) **README and docs**; (8)
     **environment variables** (optional integrations are usually discrete
     features).

   - **Synthesize features.** A feature is a user- or caller-visible
     capability describable in one sentence. Name at the capability level, not
     the implementation level ("GitLab REST fallback", not
     `runGitLabRestFetch`). Merge signals that serve the same capability;
     split independently-useful or togglable ones. When one commit names
     multiple features, give each the same date and mark each `[REVIEW: date
     inferred from bundled commit "<message>"]` — don't drop a feature for
     sharing a commit. When it's unclear whether something is user-visible,
     include it and mark `[REVIEW: may be implementation detail rather than
     user-facing capability]`. Infer the add-date from the git log on the
     feature's primary file; omit the date if history is ambiguous. Note which
     artifacts each feature primarily touches.

   - **Write one register file per feature.** Sanitize the slug
     (`.claude/skills/ardd-scripts/ardd-state.sh slug "<name>"`, 4-char hex
     suffix on collision), then create the file with the body on stdin:

     ```
     printf '%s\n' "<one-sentence description>" "Why: <optional>" \
       | .claude/skills/ardd-scripts/ardd-state.sh feature-create <slug>
     ```

     `feature-create` writes `status: backlogged`; these are already-shipped
     capabilities, so immediately advance each one through
     `ardd-state.sh feature-flip <slug> planned`, `... tasked`,
     `... implemented` (the script enforces one stage at a time) — extracted
     history isn't a backlog. Note which artifacts each feature touches as a
     body line; omit the `Why:` line when there's no non-obvious context.
     Place `[REVIEW: <reason>]` as the first body line of any uncertain entry.

7. **Install `.project/WORKFLOW.md`** — same as `/ardd-bootstrap`:
   `cp .claude/skills/ardd-artifact-templates/WORKFLOW.md .project/WORKFLOW.md`
   (recommend re-running install.sh if the template is missing).
8. **Generate `.project/STATUS.md`** summarizing what was written. Use the
   standard STATUS.md structure (same as `/ardd-bootstrap`). In the
   "Recommended next step" line, direct the user to review draft artifacts with
   `/ardd-refine` and resolve open questions before running `/ardd-status`.

9. **Report:**
   - How many artifacts were written and which ones
   - If the register was extracted: how many features, which sources were most
     useful, and the count of `[REVIEW: ...]` entries with a brief note on each
   - Total `[OPEN: ...]` items across all artifacts (count only)
   - One sentence on what the codebase survey found that was most surprising
     or ambiguous
   - Which constitution suggestions (if any) were accepted, and how many of
     those are marked `[VIOLATED: ...]` — if any are, recommend running
     `/ardd-defects` next to log them in `DEFECTS.md`, then `/ardd-feature` to
     backlog closing each gap
   - Recommended next step: `/ardd-refine <artifact>` for whichever artifact
     has the most open questions, then `/ardd-status` when all are resolved
