# /ardd-feature

Log a feature idea to the backlog in `.project/artifacts/features.md`. This
skill only records the idea — it does not touch artifacts. Design work
(identifying affected artifacts, proposing and applying changes) happens
later, when the idea is targeted by slug in `/ardd-plan <slug>`. This lets
you accumulate a backlog of ideas and work them in whatever order you like,
rather than committing to design-and-apply the moment you think of one.

Usage: `/ardd-feature <description>` where description is a plain-language
statement of the feature (e.g., "octokit fallback for GitHub similar to the
existing GitLab REST fallback").

## Steps

1. **Understand the feature.** Parse the user's description. If the intent is
   genuinely unclear (not just under-specified — backlog entries don't need
   full design detail), ask one clarifying question. Do not ask questions
   answerable by reading the artifacts.

2. **Derive a slug.** Kebab-case, ~30 chars, from the description (e.g.
   "octokit fallback for GitHub" → `octokit-github-fallback`). Check existing
   slugs in `features.md` (see step 3) — if it collides, append a freshly
   generated 4-char hex token (`openssl rand -hex 2`).

3. **Check for `features.md`.** If `.project/artifacts/features.md` doesn't
   exist, create it with the standard header:

   ```markdown
   ---
   last_updated: YYYY-MM-DD
   ---

   # Features
   ```

   If it exists, read it to check for slug collisions (step 2) and to append
   after the last entry.

4. **Append the backlog entry:**

   ```markdown
   ## <Feature Name>
   _Slug: `<slug>` · Status: backlogged · Logged <today YYYY-MM-DD>_
   <One sentence: what this capability does from the user or caller's perspective.>
   Why: <Optional — context that won't be obvious from code or artifacts later.>
   ```

   Derive the feature name from the user's description — prefer a short
   noun phrase at the capability level ("Octokit GitHub fallback") over an
   implementation label. Omit the `Why:` line when the motivation is already
   obvious from the description. Update `last_updated` in the frontmatter to
   today's date.

   Entries with no `Slug`/`Status` line predate this convention (written by
   an older `/ardd-feature` or by `/ardd-featurize`) — treat them as
   `Status: implemented` and leave them as-is; don't retrofit them unless the
   user asks.

5. **Report** the slug and a one-line confirmation. Remind the user: run
   `/ardd-plan <slug>` (any time, in any order relative to other backlog
   items) when ready to design and plan this feature — that's when affected
   artifacts get identified, proposed, and applied.
