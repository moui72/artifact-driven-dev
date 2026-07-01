# /ardd-verify

Verify artifacts against the actual codebase and report drift. Where
`/ardd-analyze` checks artifacts against each other and against
`constitution.md` (cheap, docs-only), `/ardd-verify` checks artifacts against
what the code actually does (expensive — requires re-surveying source,
similar cost to `/ardd-codify`). Run this before major planning or
periodically to catch documentation that has drifted from implementation —
not as a routine post-refine check. `/ardd-analyze` is the cheap, frequent
check; `/ardd-verify` is the expensive, occasional one.

Findings go into `.project/DEFECTS.md` only. This skill never writes into
artifact bodies — artifacts describe intended/current design, not a defect
log.

## Steps

1. **Discover artifacts** by listing `.project/artifacts/`. Read every `.md`
   file present (excluding `DEFECTS.md` and `STATUS.md`, which are not
   artifacts).

2. **Survey the codebase** for each artifact's claims, using an approach
   similar to `/ardd-codify` step 2 — read only what's relevant to what the
   artifact documents:
   - `datamodel.md` → schema files, ORM models, typed data structures,
     request/response types on both server and client
   - `infrastructure.md` → sync jobs, integration code, storage setup, env vars
   - `api.md` → route files, controllers, request/response shapes actually
     returned
   - `ui.md` → component tree, views, states as implemented
   - `constitution.md` → spot-check stated principles against actual practice
     (e.g., a "single source of truth" claim — check for parallel
     hand-duplicated types instead of a shared import)

   For each artifact, check whether the code matches what's documented:
   entity shapes match the real types, endpoints exist with the documented
   request/response shapes, stated principles are actually upheld.

3. **Record every mismatch** as a defect: which artifact, which specific
   claim, what the code actually does, file/line references, and a
   severity/confidence note if useful (e.g., cosmetic drift vs. a broken
   contract).

4. **Never write findings into artifact bodies.** This is the core rule —
   defects are recorded only in `.project/DEFECTS.md`, never as edits,
   annotations, or `[OPEN: ...]` items inside `.project/artifacts/*.md`.

5. **Write `.project/DEFECTS.md`** — full overwrite, never an append. This
   mirrors `STATUS.md`'s ownership pattern: `/ardd-verify` is the single
   writer, and every run fully regenerates the file from a fresh survey, so a
   defect that's since been fixed in code silently drops out on the next run
   rather than requiring anyone to remember to remove it.

   ```markdown
   # Defects

   _Last verified: YYYY-MM-DD_

   ## <artifact>.md
   - **Claim:** <what the artifact says>
     **Actual:** <what the code does>
     **Location:** <file:line>
     **Severity:** <cosmetic / drift / broken-contract>

   (repeat per defect, grouped by artifact)
   ```

   If zero defects are found, still write the file in an all-clear state:

   ```markdown
   # Defects

   _Last verified: YYYY-MM-DD_

   No defects found — artifacts match the codebase as of this run.
   ```

   Writing the all-clear state on every clean run is what distinguishes
   "checked, all clean" from "never checked."

6. **Report a summary:**
   - Defect count, grouped by artifact
   - One line per defect (artifact, claim, actual behavior)
   - Remind the user that `/ardd-analyze` will surface `DEFECTS.md`'s summary
     in `STATUS.md` the next time it runs — `/ardd-verify` does not touch
     `STATUS.md` itself.
