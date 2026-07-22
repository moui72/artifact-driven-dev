<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/lockup-dark.svg">
    <img src="docs/assets/lockup.svg" alt="artifact-driven-dev" width="320">
  </picture>
</p>

# artifact-driven-dev (ArDD)

> 📖 Browse these docs as a website:
> **<https://moui72.github.io/artifact-driven-dev/>**

[![sponsor](https://shieldcn.dev/badge/sponsor-%E2%9D%A4-ea4aaa.svg?variant=secondary&theme=pink)](https://github.com/sponsors/moui72)
<!-- ardd-badge-version-start -->
[![built with ArDD](https://shieldcn.dev/badge/dynamic/json.svg?url=https://raw.githubusercontent.com/moui72/artifact-driven-dev/main/.github/badges/ardd-version.json&query=$.message&label=built%20with%20ArDD&color=7C3AED&logo=data:image/svg+xml;base64,PLACEHOLDER&variant=secondary&theme=pink)](https://github.com/moui72/artifact-driven-dev)
<!-- ardd-badge-version-end -->

A workflow system for Claude Code built around a small set of living
documents — **artifacts** — that record what you've decided about your
system: your principles, your data model, your infrastructure, whatever
your project's concerns are. Slash-command skills capture new decisions
and ideas into those documents, cross-check them for consistency, turn
them into phased plans and ordered task lists, and execute the tasks —
with all workflow state riding files on disk, so any session can pick up
exactly where another left off.

It's in the same family as [Spec Kit](https://github.com/github/spec-kit),
but built for the opposite starting point: you arrive already knowing what
you're building, and need a system that captures and executes those
decisions — not one that discovers requirements for you. (There are no
per-feature spec documents here; [docs/example.md](docs/example.md) shows
what the files actually look like.)

The loop:

1. **Capture** decisions and ideas (`/ardd-refine`, `/ardd-backlog`,
   `/ardd-feedback`)
2. **Check** consistency (`/ardd-status`)
3. **Plan** once artifacts are stable (`/ardd-plan`)
4. **Execute** the task list (`/ardd-implement`)

ArDD is disciplined, not lightweight — living documents, over a dozen
skills, several status state machines — so it's worth knowing where the
overhead pays for itself: **greenfield projects** (no code to
pattern-match against yet) and **major pivots** (the code reflects
patterns you're escaping). Where a mature, consistent codebase is already
a good implicit spec, a solid `CLAUDE.md` buys you more for less. The
full reasoning: [docs/concepts.md](docs/concepts.md).

## Quickstart

Brand-new project, nothing installed:

```sh
curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/release/new.sh \
  | sh -s -- my-project
```

That creates and `git init`s `my-project/`, installs ArDD from the latest
stable release, and offers to open Claude Code on `/ardd-init` — which
interviews you about the design and writes your first artifacts.

Existing project — run from inside it:

```sh
curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/release/new.sh | sh -s -- --existing
```

Then `/ardd-init` reverse-engineers draft artifacts from the codebase.
Channels (stable/beta), dev-mode, flags, updating, and what actually gets
installed: [docs/install.md](docs/install.md).

## Skills

Every command at a glance — each links to its full reference page under
[docs/reference/skills/](docs/reference/skills/). (This table is generated
from each skill's frontmatter by `scripts/gen-skill-docs.sh` — edit the
`description:` there, then re-run it.)

| Command | What it does |
|---|---|
| [`/ardd-init`](docs/reference/skills/ardd-init.md) | One-time initialization of .project/ — detects greenfield vs existing code, then seeds artifacts from the design conversation (interviewing first if needed) or reverse-engineers them from the codebase; seeds .project/ artifacts, not CLAUDE.md (for CLAUDE.md use the built-in /init). |
| [`/ardd-backlog`](docs/reference/skills/ardd-backlog.md) | Log a feature idea to the per-feature register (.project/features/) — no artifact edits yet; bugs and UX problems with existing behavior belong in /ardd-feedback instead. |
| [`/ardd-feedback`](docs/reference/skills/ardd-feedback.md) | Capture bugs/UX/reconsidered decisions from inspecting the implementation, for the next plan to consume — new-capability ideas belong in /ardd-backlog instead. |
| [`/ardd-refine`](docs/reference/skills/ardd-refine.md) | Update a named artifact — apply new decisions, resolve open questions, handle constitution versioning; given a name that doesn't exist yet, it creates the artifact from a template (absorbs ardd-add-artifact). |
| [`/ardd-plan`](docs/reference/skills/ardd-plan.md) | Draft a phased plan from artifacts, feedback, and backlogged features, pause at an approval checkpoint, then generate its ordered task list; --from <plan> re-tasks an approved plan without re-planning. |
| [`/ardd-implement`](docs/reference/skills/ardd-implement.md) | Execute tasks sequentially — offers worktree delegation; all state rides the work branch and lands on merge. --reconcile <file> re-syncs an interrupted tasks file with the codebase first (absorbs ardd-converge). |
| [`/ardd-status`](docs/reference/skills/ardd-status.md) | Full cross-artifact consistency check — reads every artifact, plan, tasks file, and the register — and writes STATUS.md (its single writer); auto-runs after most state-changing skills. |
| [`/ardd-lint`](docs/reference/skills/ardd-lint.md) | Fast, deterministic check of .project/ frontmatter schemas and [artifacts: ...] references — no LLM judgment. |
| [`/ardd-defects`](docs/reference/skills/ardd-defects.md) | Check artifacts against the actual codebase and record drift in .project/DEFECTS.md (its single writer); the next plan run offers each recorded defect as a fix task. Takes no observation input — report what the user saw with /ardd-feedback instead. |
| [`/ardd-audit`](docs/reference/skills/ardd-audit.md) | Challenge artifact decisions — simplicity, failure modes, robustness, semantics — and write the findings checklist to .project/audit.md. Takes no proposal input — vet new ideas with /ardd-research instead. |
| [`/ardd-research`](docs/reference/skills/ardd-research.md) | Targeted investigation or proposal vetting, written to .project/plans/ — one-off output with no lifecycle; substantial or decision-reversing ideas get vetted here before they reach the backlog or a plan. |
| [`/ardd-diagram`](docs/reference/skills/ardd-diagram.md) | Generate a Mermaid diagram from any artifact that declares a diagram_type and upsert it into a configurable destination — README.md by default. |
| [`/ardd-tracker`](docs/reference/skills/ardd-tracker.md) | Mirror the feature register (.project/features/) to and from an external issue tracker — GitHub Issues today — and report divergence in .project/TRACKER.md. |
| [`/ardd-update`](docs/reference/skills/ardd-update.md) | Update this project's ArDD install from its recorded source — resolve the release channel (dev-mode checkouts warned), check standing, re-run install.sh, and relay its output. |

## Documentation

- **[Concepts](docs/concepts.md)** — the mental model: artifacts, the
  feature register, file-based handoffs, state-rides-the-branch,
  single-writer reports, and when ArDD earns its keep
- **[Example](docs/example.md)** — what the files actually look like:
  a real artifact, feature entry, feedback file, plan, and tasks file
- **[Install & updates](docs/install.md)** — every route, both release
  channels, dev-mode, gitignore guidance
- **Guides** — flows and use cases:
  - [Greenfield project](docs/guides/greenfield.md)
  - [Adopting ArDD in an existing project](docs/guides/existing-project.md)
  - [The core loop](docs/guides/core-loop.md) — the steady-state delivery cycle
  - [Which checking skill?](docs/guides/checking.md)
  - [Parallel work](docs/guides/parallel-work.md) — delegation, worktrees, merging
  - [Tracker sync](docs/guides/tracker-sync.md) — GitHub Issues mirroring
  - [Diagrams](docs/guides/diagrams.md) — rendering artifacts as Mermaid
  - [Coming from Spec Kit](docs/guides/from-spec-kit.md) — command mapping
    and vocabulary translation
- **Reference** — the details:
  - [Per-skill pages](docs/reference/skills/) — one page per command
  - [`.project/` file formats](docs/reference/project-files.md) —
    install.sh also writes a `.project/README.md` reviewer guide into
    every target, orienting humans and AI reviewers on which files are
    live vs static records
  - [Configuration knobs](docs/reference/configuration.md)
  - [Installed helper scripts](docs/reference/scripts.md)
- **[Decision records](docs/decisions/)** — the development history
  behind the rules (source-repo internal)

[USAGE.md](USAGE.md) is the one-page index of all of the above — including
a "How do I…?" table that routes everyday questions ("add a feature to a
stable project", "document a bug I found") straight to the right command.

## Contributing

Working on ArDD's own source (as opposed to installing it into a
project)? See [CONTRIBUTING.md](CONTRIBUTING.md) — per-clone setup, the
lint/test suite, and the source/target split that decides where new code
belongs.

## Credits

ArDD was inspired by [Spec Kit](https://github.com/github/spec-kit). If
you need structured requirement discovery, user story generation, or an
agent-agnostic pipeline, Spec Kit is the right tool. ArDD is narrower —
for when you arrive with architectural clarity and need a system to
capture, cross-check, and execute against it.
