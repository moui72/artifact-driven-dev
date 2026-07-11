# Project Workflow Guide

This project uses [artifact-driven-dev (ARDD)](https://github.com/moui72/artifact-driven-dev).
This file is a static reference generated from the installed skill set —
regenerate by re-running install.sh after an ARDD upgrade.

## Skills

| Command | What it does |
|---|---|
| `/ardd-setup` | Complete an npx-acquired install — locate or clone the ARDD source checkout and run install.sh from it. |
| `/ardd-bootstrap` | One-time initialization: seed .project/ artifacts from conversation context (greenfield projects). |
| `/ardd-codify` | One-time: reverse-engineer artifacts from an existing codebase (instead of bootstrap). |
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
| `/ardd-render` | Generate a Mermaid diagram from any artifact that declares a diagram_type and upsert it into a configurable destination (README.md by default). |
| `/ardd-sync` | Mirror the feature register to/from an external issue tracker (GitHub Issues today). |
| `/ardd-update` | Update this project's ARDD install from its recorded source checkout — check standing, offer a source pull, re-run install.sh, and relay its output. |
| `/ardd-add-artifact` | Create a new, non-standard artifact from a template. |

## Operating mode

`workflow_mode` in `constitution.md`'s frontmatter (one of `solo` |
`collaborative`; absent means `solo`) governs where in-progress work lives.
**Solo**: committing to your local default branch is fine for inline runs;
delegated runs use an isolated worktree and merge back on completion. **Collaborative**: nothing lands on the local default branch — work moves to
a branch and, after the first commit, the skill offers to push and open a
draft PR titled with the feature slug, which is the shared in-flight signal.

See `STATUS.md` for current artifact statuses, open questions, and the
recommended next step. Artifacts live in `.project/artifacts/`; the
feature register in `.project/features/`.
