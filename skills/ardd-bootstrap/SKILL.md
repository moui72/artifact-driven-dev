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
   Always consider the standard set:
   - `constitution.md` — if the project has stated principles or non-negotiables
   - `infrastructure.md` — if the project has external integrations, sync, or
     non-trivial storage
   - `datamodel.md` — if the project has a canonical schema or normalization
     requirements
   - `ui.md` — if the project has a user-facing interface

   Add additional artifacts if the conversation establishes distinct concerns
   that don't fit the standard set (e.g., `api.md` for a public API surface).
   Use judgment — don't create artifacts for concerns that fit naturally into
   an existing one.

3. **Synthesize each artifact** from everything established in the conversation:
   decisions made, constraints discussed, data shapes explored, architectural
   preferences stated. Do not invent decisions that were not made — use
   `[OPEN: <question>]` for anything unresolved.

   For each artifact, look for a template at `templates/artifacts/<name>.md`
   in the ADD installation. Use it as structure; fill in content from context.
   Fall back to `templates/artifacts/generic.md` for custom artifacts.

   Set `status: draft` for any artifact with open questions; `stable` otherwise.

4. **Write all artifact files** to `.project/artifacts/`.

5. **Generate `.project/WORKFLOW.md`** — a stable skill reference that rarely
   needs to change. Use the structure below. Keep skill descriptions generic
   (what each skill does), not project-specific.

6. **Generate `.project/STATUS.md`** — the living project state snapshot. Use
   the structure below. This file changes frequently; WORKFLOW.md does not.

7. **Report** what was created, how many open questions exist per artifact, and
   the recommended next step (usually `/ardd-analyze` then `/ardd-refine` on
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
| `/ardd-feature <description>` | Log a feature idea to the backlog (`features.md`) with a slug and `Status: backlogged` — no artifact edits yet |
| `/ardd-feedback <notes>` | Capture bugs/UX/reconsidered-decision notes from manually inspecting the implementation, for the next `/ardd-plan` to consume |

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

## Recommended Next Step

[One sentence: what to do now and why.]
```
