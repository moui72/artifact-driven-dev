---
name: ardd-init
tier: setup
description: "One-time initialization of .project/ — detects greenfield vs existing code, then seeds artifacts from the design conversation (interviewing first if needed) or reverse-engineers them from the codebase; seeds .project/ artifacts, not CLAUDE.md (for CLAUDE.md use the built-in /init)."
---

# /ardd-init

One-time initialization. Brings a project under ARDD by creating
`.project/artifacts/` and the workflow files around it, by whichever of two
paths fits the project — detected, then confirmed with one question:

- **Greenfield path** — seeds artifacts from the current conversation
  context, conducting the design interview first when that context is thin.
- **Existing-codebase path** — reverse-engineers artifacts from the code:
  the code is the context, so no interview is needed. Also useful to
  reconstruct artifacts after they've drifted from the implementation.

Run once at project start; use `/ardd-refine` (which also creates new
artifacts) for all subsequent changes. This skill seeds `.project/`
artifacts, not `CLAUDE.md` — for generating a `CLAUDE.md`, use Claude
Code's own built-in `/init` command, which is unrelated.

Artifacts written by the existing-codebase path are `status: draft` — they
capture what the code does, not necessarily what was intended. Review each
with `/ardd-refine` before planning new work.

## Steps

0. **Guard the install, then detect the mode.**

   - **Guard: is the install complete?** If `.claude/skills/ardd-scripts/`
     doesn't exist, the skill files are present but `install.sh` never ran
     (e.g. copied by hand). Stop and tell the user to complete the install:
     run `install.sh` from an ARDD checkout against this project, or, from
     inside the project directory, the one-command bootstrap
     `curl -fsSL <ardd-repo>/raw/release/new.sh | sh -s -- --existing`. Every
     later step here shells out to `ardd-scripts`, so continuing would fail
     on the first script call.

   - **Detect the mode, then confirm — one question, no flags.** Look for
     existing source files: code beyond docs/config scaffolding (a
     `src/`/`lib/`/`app/` tree, entry points, a manifest like
     `package.json`/`pyproject.toml`/`go.mod`/`Cargo.toml` with real code
     behind it). If found, suggest the **existing-codebase path**; if the
     directory is empty or holds only docs/config, suggest the
     **greenfield path**. Ask the user to confirm the suggestion (the other
     path is the alternative option in the same question) — detection can
     be wrong at the margins (e.g. a repo holding only design notes, or a
     scaffold with no real code yet), and the user knows which they mean.

1. **Check for existing artifacts.** List `.project/artifacts/`. If any
   `.md` files already exist, warn the user and ask for confirmation before
   overwriting. On confirmation, proceed; on denial, exit.

2. **Build the context** (path-specific).

   **Greenfield: assess context sufficiency.** If the conversation has
   established what the project is — its purpose, data, constraints,
   decisions — proceed to step 3 and synthesize from it. If context is thin
   (a cold first session, an empty directory, no design discussion yet),
   **conduct the design interview below first**, then proceed. Skipping the
   interview is always fine when the user would rather just talk the
   project through in their own words — both paths reach the same place.

   **Design interview** (thin-context greenfield only). Cover the seven
   topics below, roughly in order — data before infrastructure, since
   storage and sync strategy should follow the schema rather than constrain
   it. Ask about one topic at a time, in your own words, following up where
   an answer opens a real question. This is a conversation, not a form:
   skip what plainly doesn't apply (a CLI tool has no UI topic), and go
   deeper where the user has clearly already made decisions.

   | Topic | What you're trying to surface |
   |---|---|
   | What it does | The problem it solves, in a sentence or two |
   | Who uses it | Role, technical level, how often |
   | Data | Entities, where they come from, how they relate |
   | External integrations | APIs, third-party services, other systems |
   | Storage | SQL vs NoSQL, hosted vs embedded — and why |
   | Tech stack | Language, framework, hard constraints |
   | Principles | What the project won't compromise on |

   Use `AskUserQuestion` where the choice is genuinely discrete (storage
   engine, language, solo vs collaborative workflow) and plain conversation
   where it isn't ("what problem does this solve?" has no options list).

   **"I don't know yet" is a first-class answer.** Say so explicitly the
   first time the user hesitates. Carry every undecided item forward as an
   `[OPEN: <question>]` for the synthesis below to record — an artifact
   that honestly admits an open question is worth more than one with an
   invented decision in it, and `/ardd-status` will surface which open
   items actually block planning. Never resolve an open question by picking
   something plausible.

   Do not propose constitution principles during the interview. Step 5 has
   a curated suggestion catalog (`ardd-constitution-data/`) that it filters
   against the artifacts it's about to create, and offers at the right
   moment. Duplicating that from memory produces worse suggestions and a
   confusing double-ask.

   **Reflect the design back** before synthesizing. Summarize what you
   heard, grouped roughly the way artifacts will be (principles, data,
   infrastructure, interface), and list every `[OPEN: ...]` item you're
   carrying. Ask the user to confirm or correct it. This is the last cheap
   moment to fix a misunderstanding — after the artifacts are written it
   takes an `/ardd-refine` pass.

   **Existing codebase: survey the code.** Read enough of the project to
   understand its shape:
   - `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` —
     language, runtime, key dependencies
   - Directory tree (top 3 levels) — package boundaries, major modules
   - Entry points: `src/index.*`, `main.*`, `cmd/`, `app.*`
   - Schema files: migrations, ORM models, Prisma schema, SQL DDL
   - API surface: route files, controllers, OpenAPI specs, tRPC routers
   - UI: component tree root, shared component directory
   - External integrations: fetch/HTTP client call sites, env vars, config
     files
   - CI/CD: `.github/`, `Dockerfile`, deploy config

   Read broadly but stop before reading every file — the goal is coverage,
   not exhaustion. When a directory is clearly implementation detail (e.g.
   `dist/`, `node_modules/`, `__pycache__/`), skip it.

3. **Determine which artifacts to create.** There is no required set — an
   artifact exists only if the project has the concern it owns (a project
   may legitimately end up with just a constitution).

   Greenfield, from conversation context:
   - `constitution.md` — if the project has stated principles or
     non-negotiables
   - `infrastructure.md` — if the project has external integrations, sync,
     or non-trivial storage
   - `datamodel.md` — if the project has a canonical schema or
     normalization requirements
   - `ui.md` — if the project has a user-facing interface

   Existing codebase, from what the survey found:

   | Artifact | Generate if... |
   |---|---|
   | `constitution.md` | Always — every project has implied principles; codify them |
   | `datamodel.md` | Schema files, ORM models, or typed data structures exist |
   | `infrastructure.md` | External APIs, sync jobs, background workers, or non-trivial storage |
   | `adapters.md` | Multiple distinct external data sources with different fetch patterns |
   | `api.md` | Defined HTTP routes or RPC surface |
   | `ui.md` | Frontend components or views exist |

   Either way, add custom artifacts for significant concerns that don't fit
   the defaults (e.g. `api.md` for a public API surface on the greenfield
   path; `auth.md`, `billing.md` on either). Use judgment — don't split
   what fits naturally in one artifact.

4. **Produce each artifact's content** (path-specific).

   **Greenfield: synthesize** from everything established in the
   conversation: decisions made, constraints discussed, data shapes
   explored, architectural preferences stated. Do not invent decisions that
   were not made — use `[OPEN: <question>]` for anything unresolved. Set
   `status: draft` for any artifact with open questions; `stable`
   otherwise.

   **Existing codebase: extract** from what the code reveals:
   - Extract concrete facts: field names and types from schema, routes from
     router files, component names from file structure, env vars from
     config.
   - Where the code is clear, write definitive statements.
   - Where intent is ambiguous (e.g. a field exists but its purpose isn't
     obvious), use `[OPEN: <question>]` rather than guessing.
   - Do not invent decisions not evident in the code.
   - For `constitution.md`: infer principles from observed patterns (e.g.
     "REST over RPC" if only REST routes exist; "SQLite for storage" if
     that's what's imported). Mark inferred principles explicitly so the
     user can correct them.
   - Set `status: draft` on every artifact this path writes.

   Both paths: look for a template at
   `.claude/skills/ardd-artifact-templates/<name>.md` (installed by
   `install.sh`). Use it as structure; fill in content from context. Fall
   back to `.claude/skills/ardd-artifact-templates/generic.md` for custom
   artifacts, or to no fixed structure if the templates directory isn't
   present. Use the standard section structure for each known artifact type
   (see `/ardd-refine` built-in guidance). Set `last_updated: <today
   YYYY-MM-DD>` on every artifact, and add `diagram_status: unrendered` for
   renderable ones (`datamodel`, `infrastructure`, `ui`) — this skill never
   generates a diagram itself, so these always start `unrendered`, never
   `current`.

5. **If `constitution.md` is among the artifacts being created, offer
   opinionated suggestions before writing it** — this runs once, at this
   creation, not on later `/ardd-refine` passes. Read `.claude/skills/ardd-
   constitution-data/constitution-suggestions.md` (installed by
   `install.sh`). If it's missing, skip this step and note in the final
   report that suggestions weren't offered because the catalog wasn't found
   (recommend re-running `install.sh`).

   - **Filter**: keep every "Always" entry, plus any entry whose `Signal`
     is met by which artifacts are being created (step 3) or facts already
     established (greenfield: conversation facts — language, framework, API
     shape; existing codebase: the step 2 survey, which gives stronger
     signal than conversation alone — e.g. `tsconfig.json`/`.ts` files for
     a typed language, route files for API/REST shape, the component tree
     plus its framework for UI signals, presence of any test files/runner
     for the Test-First signal). When a signal is ambiguous, keep the
     entry — bias toward offering it and having it rejected over not
     offering it at all.
   - **Dedupe**: drop any entry whose concern is already substantively
     covered by a principle you're about to synthesize or infer — don't
     offer a generic duplicate of something the user already stated (or the
     code already shows) in its own words.
   - **Present** the remaining entries via `AskUserQuestion`, multiSelect
     on, batched into as many calls as needed (max 4 questions per call,
     max 4 options per question — group related entries together, short
     header per question, one-line description per option drawn from the
     entry's `Rationale`).
   - **Apply accepted entries**: insert each entry's `Suggested text`
     verbatim into the section its `Section` field names. Core Principles
     accepted here are numbered sequentially, immediately after any
     principles already synthesized/inferred, in the catalog's own order
     for ties. Quality Standard entries become bullets (or the named
     subsection, for Pre-commit Enforcement). Project Scope notes are
     appended to Project Scope & Intent. Leave wording refinement to a
     later `/ardd-refine constitution` pass — don't rewrite the suggested
     text here.
   - **Existing-codebase extra:** for each accepted entry, check whether
     the step 2 survey already shows it's currently violated (e.g.
     Test-First accepted but zero test files found anywhere in the survey).
     If so, append `[VIOLATED: <one-line evidence from the survey>]` to the
     inserted text, the same way other inferred content is marked for the
     user to see and correct. Never write to `DEFECTS.md` or the feature
     register here — report the violated count in step 9 instead,
     recommending `/ardd-defects` (to log each gap in `DEFECTS.md`)
     followed by `/ardd-backlog` to backlog closing it. This preserves
     those files' existing single-writer ownership.

   **Set `workflow_mode` in the constitution's frontmatter.** Ask the user
   once which mode this project runs in — `solo` (state rides local
   worktree branches and merges locally) or `collaborative` (nothing lands
   on the local default branch; work moves through pushed branches / draft
   PRs and merges via PR). Suggest a default by detection: if `gh api
   repos/{owner}/{repo}/branches/{default}/protection` (or equivalent)
   shows branch protection on the default branch → suggest `collaborative`;
   if there's no git remote at all → suggest `solo`; otherwise ask with no
   default. Write the chosen value as `workflow_mode: <value>` in
   `constitution.md`'s frontmatter. This field gates the branch/delegation
   behavior of `/ardd-implement`, `/ardd-plan`, and `/ardd-status`. Its
   absence means `solo`, so projects initialized before this field existed
   need no migration. (If `constitution.md` isn't among the artifacts being
   created, skip this — those skills read an absent field as `solo`.)

   **Set `next_step_prompt` in the constitution's frontmatter.** Alongside
   the `workflow_mode` question, ask once: "Should skills end by offering
   their recommended next step as a one-keypress prompt?" (`true` = at the
   end of `/ardd-status` and `/ardd-plan`, a concrete runnable `/ardd-*`
   recommendation is offered via AskUserQuestion — yes runs it, no/Esc
   stops; `false`/absent = recommendations stay plain text). Write the
   answer via `.claude/skills/ardd-scripts/ardd-state.sh stamp
   .project/artifacts/constitution.md next_step_prompt <true|false>` after
   the file is written in step 6. Like `workflow_mode`, this is a
   frontmatter workflow field, not constitution content — no Sync Impact
   Report entry and no constitution version bump applies to setting or
   changing it. Absence means `false`, so existing projects need no
   migration (and `/ardd-update` offers the same question once to installs
   whose constitution lacks the field entirely).

   **Set `delegation` (and, in solo mode, `merge_policy`) in the
   constitution's frontmatter.** Alongside the questions above, ask once:
   "When `/ardd-implement` could run in the background, what should it
   do?" — `eager` (delegate to a background worktree subagent without
   asking), `ask` (offer each time; today's behavior), or `inline` (never
   offer, run in the foreground). Then, **only if the answered
   `workflow_mode` is `solo`**, ask: "When a delegated background run
   completes, merge its branch into your default branch automatically?" —
   `auto` (merge without asking when it's fast-forward or conflict-free;
   any conflict still stops and asks) or `ask` (offer each time). Don't ask
   `merge_policy` in collaborative mode — it is never consulted there
   (merging goes through the PR), so asking would imply an effect it
   doesn't have; it can be stamped later if the project switches modes.
   Write the answers via `.claude/skills/ardd-scripts/ardd-state.sh stamp
   .project/artifacts/constitution.md delegation <eager|ask|inline>` (and
   `... merge_policy <auto|ask>`) after the file is written in step 6 —
   never hand-edit. Like the fields above these are frontmatter workflow
   fields, not constitution content — no Sync Impact Report entry, no
   version bump. Absence means `ask` for both, so existing projects need no
   migration (and `/ardd-update` backfills the question(s) once for
   installs whose constitution lacks them).

6. **Write all artifact files** to `.project/artifacts/`.

7. **Existing codebase only: offer to extract the feature register.** This
   path reconstructs *artifacts* (the system's current-state design); the
   feature register (`.project/features/`) is the complementary capability
   history. Right after the artifacts land is the moment to backfill it
   from the same codebase. Offer this to the user — it's optional and can
   be run later as part of the normal flow — and skip it if declined;
   otherwise:

   - **Check for an existing register.** If `.project/features/` already
     has entries (or a legacy `.project/artifacts/features.md` exists),
     warn and ask for confirmation before overwriting; on denial, skip the
     rest of this step.

   - **Survey the codebase for capability signals**, in this priority
     order — earlier sources give the clearest feature names and dates,
     later ones fill gaps. This complements the step-2 structural survey,
     which you can reuse: (1) **git log** (`git log --format="%ad %s"
     --date=short` — `feat:` commits and PR merge titles are most
     reliable); (2) **changelog** (`CHANGELOG.md`, a `## Changelog`/`##
     What's New` README section, or `gh release list` / `glab release list`
     if available); (3) **test descriptions** (`describe`/`it`/`test` names
     are often the clearest capability documentation); (4) **CLI help text
     and flag definitions**; (5) **API routes** (group related routes into
     one feature); (6) **named modules and exported functions**; (7)
     **README and docs**; (8) **environment variables** (optional
     integrations are usually discrete features).

   - **Synthesize features.** A feature is a user- or caller-visible
     capability describable in one sentence. Name at the capability level,
     not the implementation level ("GitLab REST fallback", not
     `runGitLabRestFetch`). Merge signals that serve the same capability;
     split independently-useful or togglable ones. When one commit names
     multiple features, give each the same date and mark each `[REVIEW:
     date inferred from bundled commit "<message>"]` — don't drop a feature
     for sharing a commit. When it's unclear whether something is
     user-visible, include it and mark `[REVIEW: may be implementation
     detail rather than user-facing capability]`. Infer the add-date from
     the git log on the feature's primary file; omit the date if history is
     ambiguous. Note which artifacts each feature primarily touches.

   - **Write one register file per feature.** Sanitize the slug
     (`.claude/skills/ardd-scripts/ardd-state.sh slug "<name>"`, 4-char hex
     suffix on collision), then create the file with the body on stdin:

     ```
     printf '%s\n' "<one-sentence description>" "Why: <optional>" \
       | .claude/skills/ardd-scripts/ardd-state.sh feature-create <slug>
     ```

     `feature-create` writes `status: backlogged`; these are
     already-shipped capabilities, so immediately advance each one through
     `ardd-state.sh feature-flip <slug> planned`, `... tasked`,
     `... implemented` (the script enforces one stage at a time) —
     extracted history isn't a backlog. Note which artifacts each feature
     touches as a body line; omit the `Why:` line when there's no
     non-obvious context. Place `[REVIEW: <reason>]` as the first body line
     of any uncertain entry.

8. **Install `.project/WORKFLOW.md` and seed `.project/STATUS.md`.**
   WORKFLOW.md is a static skill reference shipped with ARDD, not
   transcribed by hand:
   `cp .claude/skills/ardd-artifact-templates/WORKFLOW.md .project/WORKFLOW.md`.
   If the template is missing (older install), note it in the final report
   and recommend re-running install.sh — don't reconstruct it from memory.
   Then generate `.project/STATUS.md` — the living project state snapshot —
   using the structure below. STATUS.md changes frequently; WORKFLOW.md
   does not.

9. **Report:**
   - Which path ran (greenfield or existing codebase) and what was created
   - How many open questions exist per artifact (`[OPEN: ...]` count)
   - Which constitution suggestions (if any) were accepted — and, on the
     existing-codebase path, how many are marked `[VIOLATED: ...]`; if any
     are, recommend running `/ardd-defects` next to log them in
     `DEFECTS.md`, then `/ardd-backlog` to backlog closing each gap
   - If the register was extracted: how many features, which sources were
     most useful, and the count of `[REVIEW: ...]` entries with a brief
     note on each
   - Existing-codebase path: one sentence on what the survey found that was
     most surprising or ambiguous
   - Recommended next step (usually `/ardd-refine` on whichever draft
     artifact has the most open questions, then `/ardd-status` when all are
     resolved)

## STATUS.md structure

```markdown
# [Project Name] — Project Status

_Updated: [YYYY-MM-DD]. Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| [name].md | stable ✅ / draft ⚠️ | [count or —] |

## Open Questions

**[artifact]**
- [question]

## In Flight

- [worktree branch / tasks file / progress, or draft PR — work not yet
  merged to the default branch. Omit this section when nothing is in flight.
  Written by /ardd-status from `inflight-worktrees.sh` (and `gh pr list
  --draft` in collaborative mode).]

## Recommended Next Step

[One sentence: what to do now and why.]
```
