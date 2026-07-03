# artifact-driven-dev — Workflow Guide

This project uses [artifact-driven-dev](https://github.com/[owner]/artifact-driven-dev) on itself.

## Artifacts

| Artifact | Purpose |
|---|---|
| constitution.md | Principles, quality standards, governance for ADD's own development |

`infrastructure.md`, `datamodel.md`, and `ui.md` don't exist for this
project and aren't expected to — ADD has no runtime, schema, or UI of its
own to describe. See `constitution.md`'s Project Scope & Intent.

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
| `/ardd-lint` | Fast, deterministic check of frontmatter status/fields and `[artifacts: ...]` references — no LLM judgment involved |
| `/ardd-verify` | Check artifacts against the actual codebase and record drift in `DEFECTS.md` |
| `/ardd-sync [push\|pull]` | Mirror `features.md` to/from an external issue tracker |

See `STATUS.md` for current artifact statuses, open questions, and recommended next step.
