# Project Workflow Guide

This project uses [artifact-driven-dev (ARDD)](https://github.com/moui72/artifact-driven-dev).
This file is a static reference generated from the installed skill set —
regenerate by re-running install.sh after an ARDD upgrade.

## Skills

| Command | What it does |
|---|---|
| `/ardd-init` | One-time initialization of .project/ — detects greenfield vs existing code, then seeds artifacts from the design conversation (interviewing first if needed) or reverse-engineers them from the codebase; seeds .project/ artifacts, not CLAUDE.md (for CLAUDE.md use the built-in /init). |
| `/ardd-backlog` | Log a feature idea to the per-feature register (.project/features/) — no artifact edits yet; bugs and UX problems with existing behavior belong in /ardd-feedback instead. |
| `/ardd-feedback` | Capture bugs/UX/reconsidered decisions from inspecting the implementation, for the next plan to consume — new-capability ideas belong in /ardd-backlog instead. |
| `/ardd-refine` | Update a named artifact — apply new decisions, resolve open questions, handle constitution versioning; given a name that doesn't exist yet, it creates the artifact from a template (absorbs ardd-add-artifact). |
| `/ardd-plan` | Draft a phased plan from artifacts, feedback, and backlogged features, pause at an approval checkpoint, then generate its ordered task list; --from <plan> re-tasks an approved plan without re-planning. |
| `/ardd-implement` | Execute tasks sequentially — offers worktree delegation; all state rides the work branch and lands on merge. --reconcile <file> re-syncs an interrupted tasks file with the codebase first (absorbs ardd-converge). |
| `/ardd-status` | Full cross-artifact consistency check — reads every artifact, plan, tasks file, and the register — and writes STATUS.md (its single writer); auto-runs after most state-changing skills. |
| `/ardd-lint` | Fast, deterministic check of .project/ frontmatter schemas and [artifacts: ...] references — no LLM judgment. |
| `/ardd-defects` | Check artifacts against the actual codebase and record drift in .project/DEFECTS.md (its single writer); the next plan run offers each recorded defect as a fix task. Takes no observation input — report what you saw with /ardd-feedback instead. |
| `/ardd-audit` | Challenge artifact decisions — simplicity, failure modes, robustness, semantics — and write the findings checklist to .project/audit.md. Takes no proposal input — vet new ideas with /ardd-research instead. |
| `/ardd-research` | Targeted investigation or proposal vetting, written to .project/plans/ — one-off output with no lifecycle; substantial or decision-reversing ideas get vetted here before they reach the backlog or a plan. |
| `/ardd-diagram` | Generate a Mermaid diagram from any artifact that declares a diagram_type and upsert it into a configurable destination — README.md by default. |
| `/ardd-tracker` | Mirror the feature register (.project/features/) to and from an external issue tracker — GitHub Issues today — and report divergence in .project/TRACKER.md. |
| `/ardd-update` | Update this project's ARDD install from its recorded source — resolve the release channel (dev-mode checkouts warned), check standing, re-run install.sh, and relay its output. |

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
