---
name: ardd-bootstrap
tier: setup
description: "One-time initialization: seed .project/ artifacts from conversation context (greenfield projects)."
---

# /ardd-bootstrap

One-time initialization. Seeds `.project/artifacts/` from the current
conversation context, then generates project workflow documentation.
Run once at project start; use `/ardd-refine` and `/ardd-add-artifact` for all
subsequent changes.

Bootstrap seeds artifacts **from conversation context**. Usually that context
already exists — you've talked the project through, or you're migrating notes.
But on a cold first session opened straight from the `new.sh` quickstart, the
directory is empty and there's no conversation yet. Step 0 handles both: when
context is thin it first conducts the design interview that *creates* that
context, then proceeds exactly as it would have with a warm conversation.
(For an *existing codebase*, use `/ardd-codify` instead — the code is the
context, so no interview is needed.)

## Steps

0. **Assess context sufficiency (and guard the install).**

   - **Guard: is the install complete?** If `.claude/skills/ardd-scripts/`
     doesn't exist, the skill files are present but `install.sh` never ran
     (e.g. copied by hand). Stop and tell the user to complete the install:
     run `install.sh` from an ARDD checkout against this project, or, from
     inside the project directory, the one-command bootstrap
     `curl -fsSL <ardd-repo>/raw/main/new.sh | sh -s -- --existing`. Every
     later step here shells out to `ardd-scripts`, so continuing would fail on
     the first script call.

   - **Enough context already?** If the conversation has established what the
     project is — its purpose, data, constraints, decisions — proceed to step
     1 and synthesize from it, as bootstrap always has. If context is thin (a
     cold first session, an empty directory, no design discussion yet),
     **conduct the design interview below first**, then proceed. Skipping the
     interview is always fine when the user would rather just talk the project
     through in their own words — both paths reach the same place.

   **Design interview** (thin-context path only). Cover the seven topics
   below, roughly in order — data before infrastructure, since storage and
   sync strategy should follow the schema rather than constrain it. Ask about
   one topic at a time, in your own words, following up where an answer opens
   a real question. This is a conversation, not a form: skip what plainly
   doesn't apply (a CLI tool has no UI topic), and go deeper where the user
   has clearly already made decisions.

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
   `[OPEN: <question>]` for the synthesis below to record — an artifact that
   honestly admits an open question is worth more than one with an invented
   decision in it, and `/ardd-status` will surface which open items actually
   block planning. Never resolve an open question by picking something
   plausible.

   Do not propose constitution principles during the interview. Step 4 has a
   curated suggestion catalog (`ardd-constitution-data/`) that it filters
   against the artifacts it's about to create, and offers at the right moment.
   Duplicating that from memory produces worse suggestions and a confusing
   double-ask.

   **Reflect the design back** before synthesizing. Summarize what you heard,
   grouped roughly the way artifacts will be (principles, data,
   infrastructure, interface), and list every `[OPEN: ...]` item you're
   carrying. Ask the user to confirm or correct it. This is the last cheap
   moment to fix a misunderstanding — after the artifacts are written it takes
   an `/ardd-refine` pass.

1. **Check for existing artifacts.** List `.project/artifacts/`. If any `.md`
   files already exist, warn the user and ask for confirmation before
   overwriting.

2. **Determine which artifacts to create** based on conversation context.
   There is no required set — an artifact exists only if the project has
   the concern it owns (a project may legitimately end up with just a
   constitution). Consider the common defaults:
   - `constitution.md` — if the project has stated principles or non-negotiables
   - `infrastructure.md` — if the project has external integrations, sync, or
     non-trivial storage
   - `datamodel.md` — if the project has a canonical schema or normalization
     requirements
   - `ui.md` — if the project has a user-facing interface

   Add additional artifacts if the conversation establishes distinct concerns
   that don't fit the defaults (e.g., `api.md` for a public API surface).
   Use judgment — don't create artifacts for concerns that fit naturally into
   an existing one.

3. **Synthesize each artifact** from everything established in the conversation:
   decisions made, constraints discussed, data shapes explored, architectural
   preferences stated. Do not invent decisions that were not made — use
   `[OPEN: <question>]` for anything unresolved.

   For each artifact, look for a template at `.claude/skills/ardd-artifact-
   templates/<name>.md` (installed by `install.sh`). Use it as structure;
   fill in content from context. Fall back to `.claude/skills/ardd-artifact-
   templates/generic.md` for custom artifacts, or to no fixed structure if
   the templates directory isn't present (e.g. `install.sh` hasn't been
   re-run since this feature landed).

   Set `status: draft` for any artifact with open questions; `stable` otherwise.

4. **If `constitution.md` is among the artifacts being created, offer
   opinionated suggestions before writing it** — this runs once, at this
   creation, not on later `/ardd-refine` passes. Read `.claude/skills/ardd-
   constitution-data/constitution-suggestions.md` (installed by
   `install.sh`). If it's missing, skip this step and note in the final
   report that suggestions weren't offered because the catalog wasn't found
   (recommend re-running `install.sh`).

   - **Filter**: keep every "Always" entry, plus any entry whose `Signal` is
     met by which artifacts are being created (step 2) or facts already
     established in conversation (language, framework, API shape, etc.).
     When a signal is ambiguous, keep the entry — bias toward offering it
     and having it rejected over not offering it at all.
   - **Dedupe**: drop any entry whose concern is already substantively
     covered by a principle you're about to synthesize from the
     conversation itself — don't offer a generic duplicate of something the
     user already stated in their own words.
   - **Present** the remaining entries via `AskUserQuestion`, multiSelect
     on, batched into as many calls as needed (max 4 questions per call, max
     4 options per question — group related entries together, short header
     per question, one-line description per option drawn from the entry's
     `Rationale`).
   - **Apply accepted entries**: insert each entry's `Suggested text`
     verbatim into the section its `Section` field names. Core Principles
     accepted here are numbered sequentially, immediately after any
     principles already synthesized from conversation, in the catalog's own
     order for ties. Quality Standard entries become bullets (or the named
     subsection, for Pre-commit Enforcement). Project Scope notes are
     appended to Project Scope & Intent. Leave wording refinement to a
     later `/ardd-refine constitution` pass — don't rewrite the suggested
     text here.

   **Set `workflow_mode` in the constitution's frontmatter.** Ask the user
   once which mode this project runs in — `solo` (state rides local worktree
   branches and merges locally) or `collaborative` (nothing lands on the
   local default branch; work moves through pushed branches / draft PRs and
   merges via PR). Suggest a default by detection: if `gh api
   repos/{owner}/{repo}/branches/{default}/protection` (or equivalent) shows
   branch protection on the default branch → suggest `collaborative`; if
   there's no git remote at all → suggest `solo`; otherwise ask with no
   default. Write the chosen value as `workflow_mode: <value>` in
   `constitution.md`'s frontmatter. This field gates the branch/delegation
   behavior of `/ardd-implement`, `/ardd-plan`, and
   `/ardd-status`. Its absence means `solo`, so projects bootstrapped before
   this field existed need no migration. (If `constitution.md` isn't among
   the artifacts being created, skip this — those skills read an absent field
   as `solo`.)

   **Set `next_step_prompt` in the constitution's frontmatter.** Alongside
   the `workflow_mode` question, ask once: "Should skills end by offering
   their recommended next step as a one-keypress prompt?" (`true` = at the
   end of `/ardd-status` and `/ardd-plan`, a concrete
   runnable `/ardd-*` recommendation is offered via AskUserQuestion —
   yes runs it, no/Esc stops; `false`/absent = recommendations stay plain
   text). Write the answer via
   `.claude/skills/ardd-scripts/ardd-state.sh stamp
   .project/artifacts/constitution.md next_step_prompt <true|false>` after
   the file is written in step 5. Like `workflow_mode`, this is a
   frontmatter workflow field, not constitution content — no Sync Impact
   Report entry and no constitution version bump applies to setting or
   changing it. Absence means `false`, so existing projects need no
   migration (and `/ardd-update` offers the same question once to installs
   whose constitution lacks the field entirely).

   **Set `delegation` (and, in solo mode, `merge_policy`) in the
   constitution's frontmatter.** Alongside the questions above, ask once:
   "When `/ardd-implement` could run in the background,
   what should they do?" — `eager` (delegate to a background worktree
   subagent without asking), `ask` (offer each time; today's behavior), or
   `inline` (never offer, run in the foreground). Then, **only if the
   answered `workflow_mode` is `solo`**, ask: "When a delegated background
   run completes, merge its branch into your default branch automatically?"
   — `auto` (merge without asking when it's fast-forward or conflict-free;
   any conflict still stops and asks) or `ask` (offer each time). Don't ask
   `merge_policy` in collaborative mode — it is never consulted there
   (merging goes through the PR), so asking would imply an effect it
   doesn't have; it can be stamped later if the project switches modes.
   Write the answers via `.claude/skills/ardd-scripts/ardd-state.sh stamp
   .project/artifacts/constitution.md delegation <eager|ask|inline>` (and
   `... merge_policy <auto|ask>`) after the file is written in step 5 —
   never hand-edit. Like the fields above these are frontmatter workflow
   fields, not constitution content — no Sync Impact Report entry, no
   version bump. Absence means `ask` for both, so existing projects need
   no migration (and `/ardd-update` backfills the question(s) once for
   installs whose constitution lacks them).

5. **Write all artifact files** to `.project/artifacts/`.

6. **Install `.project/WORKFLOW.md`** — a static skill reference shipped
   with ARDD, not transcribed by hand:
   `cp .claude/skills/ardd-artifact-templates/WORKFLOW.md .project/WORKFLOW.md`.
   If the template is missing (older install), note it in the final
   report and recommend re-running install.sh — don't reconstruct it
   from memory.

7. **Generate `.project/STATUS.md`** — the living project state snapshot. Use
   the structure below. This file changes frequently; WORKFLOW.md does not.

8. **Report** what was created, how many open questions exist per artifact,
   which constitution suggestions (if any) were accepted, and the
   recommended next step (usually `/ardd-status` then `/ardd-refine` on
   draft artifacts).

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
