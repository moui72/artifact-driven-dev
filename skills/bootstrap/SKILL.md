# /bootstrap

One-time initialization. Seeds `.project/artifacts/` from the current
conversation context, then generates project workflow documentation.
Run once at project start; use `/refine` and `/add-artifact` for all
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

5. **Generate `.project/WORKFLOW.md`** using the structure below. Tailor the
   skill descriptions to this specific project — do not copy generic descriptions
   from USAGE.md. Each "when to use" note should reference this project's actual
   artifacts and concerns.

6. **Report** what was created, how many open questions exist per artifact, and
   the recommended next step (usually `/analyze` then `/refine` on draft
   artifacts).

## WORKFLOW.md structure

```markdown
# [Project Name] — Workflow Guide

This project uses [artifact-driven-dev](https://github.com/[owner]/artifact-driven-dev).

## Artifacts

| Artifact | Status | Purpose |
|---|---|---|
| [name].md | draft/stable | [one-line description specific to this project] |

## Skills

| Command | When to use |
|---|---|
| `/refine <artifact>` | [project-specific guidance, e.g., "use when EHR API exploration reveals new fields"] |
| `/add-artifact <name>` | [project-specific note on when a new artifact might be needed] |
| `/analyze` | [project-specific note, e.g., "run before planning to ensure datamodel and ui agree on field names"] |
| `/research <topic>` | [project-specific examples, e.g., "sqlite ORM options, sync scheduling libraries"] |
| `/plan` | [when artifacts are stable — note which artifacts are currently draft] |
| `/tasks` | After plan approval |
| `/implement` | Executes tasks from .project/tasks/tasks.md |
| `/converge` | [project-specific note on when interruptions are likely] |

## Current state

[Honest assessment: which artifacts are stable, which are draft, what the
open questions are, and what to do next.]
```
