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
     correct. Never write to `DEFECTS.md` or `features.md` here — report the
     violated count in step 8 instead, recommending `/ardd-verify` (to log
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

6. **Generate `.project/WORKFLOW.md`** — the stable skill-reference doc, so the
   existing-project onboarding path produces the same reference the greenfield
   `/ardd-bootstrap` path does. Reuse the same structure and skills-table
   content as `/ardd-bootstrap` (see its "WORKFLOW.md structure" section);
   keep skill descriptions generic (what each skill does), not
   project-specific.

7. **Generate `.project/STATUS.md`** summarizing what was written. Use the
   standard STATUS.md structure (same as `/ardd-bootstrap`). In the
   "Recommended next step" line, direct the user to review draft artifacts with
   `/ardd-refine` and resolve open questions before running `/ardd-analyze`.

8. **Report:**
   - How many artifacts were written and which ones
   - Total `[OPEN: ...]` items across all artifacts (count only)
   - One sentence on what the codebase survey found that was most surprising
     or ambiguous
   - Which constitution suggestions (if any) were accepted, and how many of
     those are marked `[VIOLATED: ...]` — if any are, recommend running
     `/ardd-verify` next to log them in `DEFECTS.md`, then `/ardd-feature` to
     backlog closing each gap
   - Recommended next step: `/ardd-refine <artifact>` for whichever artifact
     has the most open questions, then `/ardd-analyze` when all are resolved
