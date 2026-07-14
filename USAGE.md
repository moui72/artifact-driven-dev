<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/lockup-dark.svg">
    <img src="docs/assets/lockup.svg" alt="artifact-driven-dev" width="320">
  </picture>
</p>

# Using artifact-driven-dev — start here

> 📖 Browse these docs as a website:
> **<https://moui72.github.io/artifact-driven-dev/>**

ArDD is a workflow, not a generator: it gives you a place to put decisions
you've already made, checks them for consistency, and turns them into an
executable task list. This page is the map of the documentation; the
[README](README.md) has the pitch and quickstart.

## New to ArDD?

1. [Concepts](docs/concepts.md) — the mental model in one page
2. [Example](docs/example.md) — what the files actually look like
3. [Install](docs/install.md) — one command for a new or existing project
4. Then the guide that matches your situation:

| Your situation | Guide |
|---|---|
| Starting from scratch — no code, just an idea | [greenfield.md](docs/guides/greenfield.md) |
| Code exists; bringing it under ArDD | [existing-project.md](docs/guides/existing-project.md) |
| Set up and shipping — the day-to-day loop | [core-loop.md](docs/guides/core-loop.md) |
| Coming from Spec Kit | [from-spec-kit.md](docs/guides/from-spec-kit.md) |

## How do I…?

The everyday questions, routed. Each answer is one command; the link has
the full story.

| I want to… | Run | Details |
|---|---|---|
| Add a feature to a stable project | `/ardd-backlog <idea>`, then `/ardd-plan <slug>` when ready to build it | [Log ideas](docs/guides/core-loop.md#log-ideas-the-moment-you-have-them) · [Plan a batch](docs/guides/core-loop.md#plan-a-batch) |
| Fix a bug | `/ardd-feedback <the bug>`, then `/ardd-plan` to plan the fix | [Capture what you notice](docs/guides/core-loop.md#capture-what-you-notice--constantly) |
| Fix bad UX | `/ardd-feedback <what's wrong>`, then `/ardd-plan` to plan the change | [Capture what you notice](docs/guides/core-loop.md#capture-what-you-notice--constantly) |
| Revisit a decision that no longer holds | `/ardd-feedback <the decision and why it no longer holds>` — planning confirms the reversal explicitly | [Capture what you notice](docs/guides/core-loop.md#capture-what-you-notice--constantly) |
| Execute on my backlog | `/ardd-plan <slug> [...]` (approve at the checkpoint) → `/ardd-implement` | [Plan a batch](docs/guides/core-loop.md#plan-a-batch) |
| Resume work that got interrupted | `/ardd-implement` — pick the file; it offers to reconcile first | [When things get interrupted](docs/guides/core-loop.md#when-things-get-interrupted) |
| Deal with a dead background run (abandoned worktree) | `/ardd-status` shows it In Flight; merge its branch to keep the work, or delete the worktree to discard it | [parallel-work.md](docs/guides/parallel-work.md#visibility-how-you-see-in-flight-work) |
| Fix conflict markers in `STATUS.md` (or another `.project/` report) | Take either side — it's regenerated; re-run the owning skill (e.g. `/ardd-status`) | [When files conflict](docs/guides/parallel-work.md#when-project-files-conflict-on-merge) |
| See what changed before updating ArDD | Check the release notes on GitHub Releases against the `Source-Ref:` in `.project/ardd-version.md` | [install.md](docs/install.md#updating) |
| See where everything stands | `/ardd-status` — or just read `.project/STATUS.md` | [ardd-status](docs/reference/skills/ardd-status.md) |
| Run implementation in the background, or several at once | Say yes at `/ardd-implement`'s delegation offer | [parallel-work.md](docs/guides/parallel-work.md) |
| Record a new decision in the docs | `/ardd-refine <artifact> <the decision>` | [ardd-refine](docs/reference/skills/ardd-refine.md) |
| Vet a big idea before committing to it | `/ardd-research proposal: <idea>` — for reversals you're *not yet sure about* (sure ones go straight to `/ardd-feedback`) | [ardd-research](docs/reference/skills/ardd-research.md) |
| Check the docs still match the code | `/ardd-defects` | [checking.md](docs/guides/checking.md) |
| Update ArDD itself | `/ardd-update` | [install.md](docs/install.md) |

## Going deeper

| Topic | Doc |
|---|---|
| Which of the four checking skills you want | [checking.md](docs/guides/checking.md) |
| Background runs, worktrees, parallel execution, merge conflicts | [parallel-work.md](docs/guides/parallel-work.md) |
| Mirroring the feature register to GitHub Issues | [tracker-sync.md](docs/guides/tracker-sync.md) |
| Rendering artifacts as Mermaid diagrams | [diagrams.md](docs/guides/diagrams.md) |

## Reference

| What | Where |
|---|---|
| Every skill, one page each — usage, reads/writes, behavior | [reference/skills/](docs/reference/skills/) |
| `.project/` file formats, frontmatter schemas, status enums | [project-files.md](docs/reference/project-files.md) |
| The constitution workflow knobs (`workflow_mode`, `delegation`, …) | [configuration.md](docs/reference/configuration.md) |
| The installed helper scripts skills shell out to | [scripts.md](docs/reference/scripts.md) |

## The short version of the workflow

```
/ardd-init                  # once: seed artifacts (interview or codebase survey)
/ardd-refine <artifact>     # capture decisions as you make them
/ardd-backlog <idea>        # log feature ideas the moment you have them
/ardd-feedback <notes>      # capture what you notice using the built thing
/ardd-plan [<slug> ...]     # draft plan → approval checkpoint → tasks file
/ardd-implement             # execute tasks; offers background delegation
/ardd-status                # where do things stand? (auto-runs after most skills)
```

You don't have to type the full name: Claude Code's command picker filters
as you type, so `/impl` surfaces `/ardd-implement` and `/stat` surfaces
`/ardd-status`. Claude Code has built-in commands named `feedback` and
`status` that rank above the `ardd-` skills when you type the bare word —
include a hyphen to skip past them: the built-ins have none, so `/a-f`
(or even `/-f`) targets `/ardd-feedback` directly.

`STATUS.md` is the re-entry point after any interruption — it always names
the recommended next step.
