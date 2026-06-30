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

   Use the standard section structure for each known artifact type (see
   `/ardd-refine` built-in guidance). For custom artifacts, derive structure
   from the content.

   Set frontmatter on every artifact:
   ```
   status: draft
   last_updated: <today YYYY-MM-DD>
   ```
   Add `diagram_stale: false` for renderable artifacts (`datamodel`,
   `infrastructure`, `ui`).

5. **Write all artifact files** to `.project/artifacts/`.

6. **Generate `.project/STATUS.md`** summarizing what was written. Use the
   standard STATUS.md structure (same as `/ardd-bootstrap`). In the
   "Recommended next step" line, direct the user to review draft artifacts with
   `/ardd-refine` and resolve open questions before running `/ardd-analyze`.

7. **Report:**
   - How many artifacts were written and which ones
   - Total `[OPEN: ...]` items across all artifacts (count only)
   - One sentence on what the codebase survey found that was most surprising
     or ambiguous
   - Recommended next step: `/ardd-refine <artifact>` for whichever artifact
     has the most open questions, then `/ardd-analyze` when all are resolved
