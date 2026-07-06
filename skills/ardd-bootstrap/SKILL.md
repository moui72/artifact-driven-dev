---
name: ardd-bootstrap
description: One-time initialization: seed .project/ artifacts from conversation context (greenfield projects).
---

# /ardd-bootstrap

One-time initialization. Seeds `.project/artifacts/` from the current
conversation context, then generates project workflow documentation.
Run once at project start; use `/ardd-refine` and `/ardd-add-artifact` for all
subsequent changes.

## Steps

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
   behavior of `/ardd-implement`, `/ardd-converge`, `/ardd-plan`, and
   `/ardd-analyze`. Its absence means `solo`, so projects bootstrapped before
   this field existed need no migration. (If `constitution.md` isn't among
   the artifacts being created, skip this — those skills read an absent field
   as `solo`.)

5. **Write all artifact files** to `.project/artifacts/`.

6. **Generate `.project/WORKFLOW.md`** — a stable skill reference that rarely
   needs to change. Use the structure below. Keep skill descriptions generic
   (what each skill does), not project-specific.

7. **Generate `.project/STATUS.md`** — the living project state snapshot. Use
   the structure below. This file changes frequently; WORKFLOW.md does not.

8. **Report** what was created, how many open questions exist per artifact,
   which constitution suggestions (if any) were accepted, and the
   recommended next step (usually `/ardd-analyze` then `/ardd-refine` on
   draft artifacts).

## WORKFLOW.md structure

```markdown
# [Project Name] — Workflow Guide

This project uses [artifact-driven-dev](https://github.com/[owner]/artifact-driven-dev).

## Artifacts

| Artifact | Purpose |
|---|---|
| [name].md | [one-line description of what this artifact owns] |

## Skills

| Command | What it does |
|---|---|
| `/ardd-refine <artifact>` | Update a named artifact — apply new decisions, resolve open questions, add content |
| `/ardd-add-artifact <name>` | Create a new artifact for a concern that doesn't fit an existing one |
| `/ardd-analyze` | Cross-artifact consistency check — find conflicts, gaps, and unresolved decisions |
| `/ardd-research <topic>` | Investigate a specific topic and write a research doc to `.project/plans/` |
| `/ardd-plan [slug ...]` | Generate an implementation plan from all stable artifacts, into `.project/plans/`. Optionally target one or more backlogged feature slugs to design and apply their artifact changes as part of the same pass |
| `/ardd-tasks` | Generate an ordered task list from a plan you select |
| `/ardd-render [artifact]` | Generate Mermaid diagrams into `README.md`. Bare form runs all supported artifacts. |
| `/ardd-implement` | Execute tasks from a tasks file you select in `.project/tasks/` |
| `/ardd-converge` | Reconcile codebase with a tasks file you select, after an interrupted `/ardd-implement` run |
| `/ardd-codify` | Reverse-engineer artifacts from an existing codebase |
| `/ardd-featurize` | Extract a feature register from the codebase (run after codify) |
| `/ardd-critique [artifact]` | Challenge decisions — simplicity, failure modes, robustness, semantics |
| `/ardd-feature <description>` | Log a feature idea to the backlog (`.project/features/<slug>.md`, `status: backlogged`) — no artifact edits yet |
| `/ardd-feedback <notes>` | Capture bugs/UX/reconsidered-decision notes from manually inspecting the implementation, for the next `/ardd-plan` to consume |
| `/ardd-lint` | Fast, deterministic check of frontmatter status/fields and `[artifacts: ...]` references — no LLM judgment involved |
| `/ardd-verify` | Check artifacts against the actual codebase and record drift in `DEFECTS.md` |
| `/ardd-sync [push\|pull]` | Mirror the feature register to/from an external issue tracker |

See `STATUS.md` for current artifact statuses, open questions, and recommended next step.
```

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
  Written by /ardd-analyze from `inflight-worktrees.sh` (and `gh pr list
  --draft` in collaborative mode).]

## Recommended Next Step

[One sentence: what to do now and why.]
```
