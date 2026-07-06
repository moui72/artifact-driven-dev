# Project Workflow Guide

This project uses [artifact-driven-dev (ARDD)](https://github.com/moui72/artifact-driven-dev).
This file is a static reference generated from the installed skill set —
regenerate by re-running install.sh after an ARDD upgrade.

## Skills

| Command | What it does |
|---|---|
| `/ardd-bootstrap` | One-time initialization: seed .project/ artifacts from conversation context (greenfield projects). |
| `/ardd-codify` | One-time: reverse-engineer artifacts from an existing codebase (instead of bootstrap). |
| `/ardd-featurize` | One-time (after codify): extract a feature register from an existing codebase. |
| `/ardd-feature` | Log a feature idea to the per-feature register (.project/features/) — no artifact edits yet. |
| `/ardd-feedback` | Capture bugs/UX/reconsidered decisions from inspecting the implementation, for the next plan to consume. |
| `/ardd-refine` | Update a named artifact — apply new decisions, resolve open questions, handle constitution versioning. |
| `/ardd-plan` | Draft a phased implementation plan from artifacts, feedback, and optionally backlogged features; feedback-file arguments scope which feedback is consumed. |
| `/ardd-tasks` | Generate an ordered task list from a plan; selecting a draft plan approves it. |
| `/ardd-implement` | Execute tasks sequentially; offers worktree delegation, all state rides the work branch and lands on merge. |
| `/ardd-analyze` | Cross-artifact consistency check; writes STATUS.md (its single writer). Auto-runs after most state-changing skills. |
| `/ardd-lint` | Fast, deterministic check of .project/ frontmatter schemas and [artifacts: ...] references — no LLM judgment. |
| `/ardd-verify` | Check artifacts against the actual codebase and record drift in DEFECTS.md (its single writer). |
| `/ardd-critique` | Challenge artifact decisions: simplicity, failure modes, robustness, semantics. |
| `/ardd-converge` | Reconcile the codebase with a tasks file after an interruption; same delegation and state model as implement. |
| `/ardd-research` | Targeted investigation written to .project/plans/ — one-off output with no lifecycle. |
| `/ardd-render` | Generate a Mermaid diagram from a renderable artifact and upsert it into README.md. |
| `/ardd-sync` | Mirror the feature register to/from an external issue tracker (GitHub Issues today). |
| `/ardd-add-artifact` | Create a new, non-standard artifact from a template. |

See `STATUS.md` for current artifact statuses, open questions, and the
recommended next step. Artifacts live in `.project/artifacts/`; the
feature register in `.project/features/`.
