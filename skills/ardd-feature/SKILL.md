# /ardd-feature

Plan and apply a new feature across all affected artifacts in one coordinated
pass. Use this when adding or changing functionality that spans multiple
artifacts — instead of refining each artifact separately (which leaves them
inconsistent between passes), this skill reads the full artifact set first,
proposes all changes together, and writes them as a coherent unit.

Usage: `/ardd-feature <description>` where description is a plain-language
statement of the feature (e.g., "octokit fallback for GitHub similar to the
existing GitLab REST fallback").

## Steps

1. **Understand the feature.** Parse the user's description. If the intent is
   ambiguous or the scope is unclear, ask one clarifying question before
   proceeding. Do not ask questions answerable by reading the artifacts.

2. **Load all artifacts.** Read every `.md` file in `.project/artifacts/`.
   Build a complete picture of the current system before proposing any changes.

3. **Identify affected artifacts.** For each standard artifact, determine
   whether the feature requires a change:

   | Artifact | Change if... |
   |---|---|
   | `constitution.md` | Feature introduces a new principle, exception, or production shortcut |
   | `datamodel.md` | New entities, fields, relationships, or normalization rules |
   | `infrastructure.md` | New integration, storage concern, sync strategy, or env var |
   | `adapters.md` | New external data source or changes to an existing adapter's fetch pattern |
   | `api.md` | New routes, changed response shapes, new env vars, or auth changes |
   | `ui.md` | New views, components, states, or interaction patterns |

   List the affected artifacts and briefly state what needs to change in each.
   If the feature clearly doesn't touch an artifact, skip it — do not make
   cosmetic or precautionary edits.

4. **Propose changes.** For each affected artifact, describe the specific
   additions or modifications. Present this as a summary — not the full
   artifact text — so the user can review the scope before anything is written.
   Wait for confirmation before proceeding to step 5.

   Format the proposal as:

   ```
   ## Proposed artifact changes

   ### <artifact name>
   - <what changes and why>
   - <what changes and why>

   ### <artifact name>
   - <what changes and why>
   ```

   If the feature reveals a conflict with an existing decision (e.g., a new
   adapter that contradicts a stated principle), surface it here rather than
   silently working around it.

5. **Apply all changes.** After confirmation, update every affected artifact,
   then append an entry to `.project/artifacts/features.md`. If `features.md`
   does not exist, create it with the standard header first:

   ```markdown
   ---
   last_updated: YYYY-MM-DD
   ---

   # Features
   ```

   Append the new entry in this format:

   ```markdown
   ## <Feature Name>
   _Added <today YYYY-MM-DD> · <artifact>, <artifact>_
   <One sentence: what this capability does from the user or caller's perspective.>
   Why: <Optional — context that won't be obvious from code or artifacts later.>
   ```

   Derive the feature name from the user's description — prefer a short
   noun phrase at the capability level ("Octokit GitHub fallback") over an
   implementation label ("runOctokitFetch"). Omit the `Why:` line when the
   motivation is already obvious from the description. Update `last_updated`
   in the `features.md` frontmatter to today's date.

   Then update every affected structural artifact:
   - Apply changes consistently — if the same concept appears in multiple
     artifacts, use the same name, type, and shape everywhere.
   - Preserve all existing content not touched by this feature.
   - Add `[OPEN: ...]` items for decisions the feature introduces but doesn't
     resolve. `[OPEN: ...]` is reserved for genuine undecided-design-question
     gaps only — if the feature surfaces a known code-vs-artifact violation
     (e.g., visible in `.project/DEFECTS.md`), don't write violation narrative
     into the artifact body. Point the user at `DEFECTS.md` / `/ardd-verify`
     instead.
   - Update frontmatter on each changed artifact:
     - `last_updated: <today YYYY-MM-DD>`
     - `status: draft` if new open questions were introduced;
       `status: stable` if the artifact remains fully resolved.
     - For renderable artifacts (`datamodel`, `infrastructure`, `ui`) whose
       content changed, set `diagram_status: stale` — unless it is currently
       `unrendered`, in which case leave it `unrendered`.

6. **Run cross-artifact analysis.** After writing all artifacts, perform the
   checks from `/ardd-analyze` steps 2–4 scoped to the changed artifacts:
   - Verify all new concepts introduced in one artifact are defined wherever
     they're referenced.
   - Flag any new constitution violations introduced by the feature.
   - Report any `[OPEN: ...]` items introduced.

   Do not write `STATUS.md` — direct the user to run `/ardd-analyze` for a
   full refresh.

7. **Report:**
   - Which artifacts were changed
   - Any conflicts surfaced during the pass
   - Count of new `[OPEN: ...]` items introduced
   - Recommended next step: `/ardd-analyze` to refresh STATUS.md, then
     `/ardd-plan` if artifacts are stable, or `/ardd-refine <artifact>` for
     whichever has the most open questions.
