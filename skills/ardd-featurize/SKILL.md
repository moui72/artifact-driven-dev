# /ardd-featurize

Extract a feature register from an existing codebase and write it to
`.project/artifacts/features.md`. Use this once after `/ardd-codify` to
backfill the capability history of an existing project. After that,
`/ardd-feature` keeps `features.md` current as new features are added.

## Steps

1. **Check for existing `features.md`.** If it already exists and has entries,
   warn the user and ask for confirmation before overwriting. On confirmation,
   proceed; on denial, exit.

2. **Survey the codebase for capability signals.** Work through sources in
   this priority order — earlier sources give the clearest feature names and
   dates, later sources fill gaps:

   1. **Git log** — `git log --format="%ad %s" --date=short` gives dates and
      names for almost every shipped feature. Conventional commit messages
      (`feat: ...`) and PR merge titles are especially reliable.

   2. **Changelog** — look in multiple places:
      - `CHANGELOG.md` or `CHANGELOG` at the repo root
      - A `## Changelog` or `## What's New` section inside `README.md`
      - GitHub/GitLab releases: run `gh release list` (GitHub) or
        `glab release list` (GitLab) if the respective CLI is available.
        Release notes often contain the clearest user-facing feature names.
      Use whichever of these exists; use all that exist.

   3. **Test descriptions** — `describe` / `it` / `test` names like
      `"falls back to REST when glab unavailable"` are often the clearest
      capability documentation in the repo. Read test files broadly.

   4. **CLI help text and flag definitions** — each flag or subcommand is a
      declared capability. Read the entry point and any help strings.

   5. **API routes** — each route is a capability declaration; group related
      routes into one feature rather than listing individually.

   6. **Named modules and exported functions** — top-level module names and
      exported function names encode intent (e.g., `runGitLabFallback`,
      `carepointSync`).

   7. **README and docs** — named features, capability descriptions, usage
      examples. Useful for confirmation and context after higher-priority
      sources have already named the features.

   8. **Environment variables** — optional integrations toggled by env var
      are usually discrete features.

   Also load any existing artifacts from `.project/artifacts/` — they provide
   context that helps name and scope features correctly.

3. **Synthesize features.** Group capability signals into named features.
   A feature is a user- or caller-visible capability that could be described
   in one sentence. Guidelines:

   - Name features at the capability level, not the implementation level.
     "GitLab REST fallback" not "runGitLabRestFetch function."
   - Merge related signals into one feature when they serve the same
     capability. Multiple routes that together implement "PR review workflow"
     are one feature.
   - Split when capabilities are independently useful or togglable.
   - **Bundled commits**: when a single commit message names or implies
     multiple distinct features, assign each feature the same date and mark
     each with `[REVIEW: date inferred from bundled commit "<message>"]` so
     the user can verify. Do not omit features because they shared a commit.
   - **Ambiguous scope**: when it's unclear whether something is a
     user-visible capability or an internal implementation detail, err toward
     including it and mark it `[REVIEW: may be implementation detail rather
     than user-facing capability]`.
   - Infer the add-date from the git log on the primary file for the feature.
     If git history is unavailable or ambiguous, omit the date.
   - Note which standard artifacts each feature primarily touches
     (infrastructure, adapters, api, ui, datamodel).

4. **Write `.project/artifacts/features.md`** using this format:

   ```markdown
   ---
   last_updated: YYYY-MM-DD
   ---

   # Features

   ## <Feature Name>
   _Added <YYYY-MM-DD> · <artifact>, <artifact>_
   <One sentence: what this capability does from the user or caller's perspective.>
   Why: <Optional — context that won't be obvious from code or artifacts later.>

   ## <Feature Name>
   ...
   ```

   Order entries from oldest to newest (by inferred add-date, or by logical
   dependency if dates are unavailable). Omit the `Why:` line when there's no
   non-obvious context to add.

   Place `[REVIEW: <reason>]` on the line immediately after the header of any
   entry that is uncertain — wrong date, ambiguous scope, inferred from a
   bundled commit, or not clearly user-visible. This makes uncertain entries
   findable without reading the report.

5. **Report:**
   - How many features were extracted
   - Which sources were most useful (git log, releases, tests, README, etc.)
   - Count of `[REVIEW: ...]` entries and a brief note on each
   - Recommended next step: review `features.md`, resolve or remove
     `[REVIEW: ...]` entries, then run `/ardd-analyze` to ensure all artifacts
     are current
