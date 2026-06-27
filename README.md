# artifact-driven-dev (ADD)

A lightweight, artifact-driven workflow system for Claude Code. Inspired by
spec-driven development but designed for builders who already know what they're
building — the artifacts capture decisions, not discover them.

## Philosophy

Traditional spec frameworks generate clarity through ceremony. ADD assumes you
arrive with clarity and need a system to capture, cross-check, and execute
against it. The workflow is:

1. **Capture** decisions in living artifacts
2. **Analyze** artifacts for consistency before planning
3. **Plan** once artifacts are stable
4. **Execute** against an ordered task list
5. **Converge** when work is interrupted

## Artifacts

Four living documents that evolve throughout the project:

| Artifact | Purpose |
|---|---|
| `constitution.md` | Principles, quality standards, governance |
| `infrastructure.md` | Architecture, integrations, storage, sync strategy |
| `datamodel.md` | Canonical schema, field mappings, normalization rules |
| `ui.md` | Views, interactions, display specs, states |

All artifacts live in `.project/artifacts/`. All are refined with `/refine`.

## Skills

| Command | When |
|---|---|
| `/bootstrap` | Once — seed artifacts from conversation context |
| `/refine <artifact>` | Anytime — update a named artifact |
| `/analyze` | Before planning — cross-artifact consistency check |
| `/research <topic>` | As needed — targeted investigation |
| `/plan` | When artifacts are stable |
| `/tasks` | After plan approval |
| `/implement` | Execute tasks sequentially |
| `/converge` | Reconcile codebase with tasks after interruption |

## Install

```sh
./install.sh /path/to/your/project
```

Then open Claude Code in your project and run `/bootstrap`.

## Project structure created

```
.project/
  artifacts/    # living decision documents
  plans/        # generated plans and research
  tasks/        # tasks.md — the execution queue
.claude/
  skills/       # ADD skill files
```

## Task format

Tasks in `tasks.md` declare which artifacts they require:

```markdown
- [ ] T001 [artifacts: datamodel, infrastructure] Create Patient table in SQLite
- [ ] T002 [artifacts: datamodel] [parallel] Create Appointment table in SQLite
```

The `/implement` skill loads only the declared artifacts before executing each
task, keeping context focused.
