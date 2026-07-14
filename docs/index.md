<div class="ardd-hero" markdown="0">
  <img class="ardd-lockup-light" src="assets/lockup.svg" alt="artifact-driven-dev">
  <img class="ardd-lockup-dark" src="assets/lockup-dark.svg" alt="artifact-driven-dev">
  <p class="ardd-tagline">Hold the decisions you've made. Check them. Turn them into code.</p>
</div>

<hr class="ardd-spectrum">

# artifact-driven-dev (ArDD)

ArDD is a Claude Code skill pack for artifact-driven development: a small
set of living documents (`.project/artifacts/`) holds the decisions you've
actually made, and slash commands check them for consistency and turn them
into plans, task lists, and code. It's a workflow, not a generator — you
refine the artifacts iteratively, and everything downstream is derived
from them.

**Is it for you?** ArDD earns its overhead where the codebase can't serve
as an implicit spec — greenfield work, or a major pivot away from the
patterns the code currently shows. On a mature, consistent codebase a solid
`CLAUDE.md` often buys more for less. The honest version:
[When artifacts earn their keep](concepts.md#when-artifacts-earn-their-keep).

## New to ArDD?

1. [Concepts](concepts.md) — the mental model in one page
2. [Example](example.md) — what the files actually look like
3. [Install](install.md) — one command for a new or existing project
4. Then the guide that matches your situation:

| Your situation | Guide |
|---|---|
| Starting from scratch — no code, just an idea | [Greenfield project](guides/greenfield.md) |
| Code exists; bringing it under ArDD | [Existing project](guides/existing-project.md) |
| Set up and shipping — the day-to-day loop | [The core loop](guides/core-loop.md) |
| Coming from Spec Kit | [Coming from Spec Kit](guides/from-spec-kit.md) |

## Going deeper

| Topic | Doc |
|---|---|
| Which of the four checking skills you want | [Checking skills](guides/checking.md) |
| Background runs, worktrees, parallel execution, merge conflicts | [Parallel work](guides/parallel-work.md) |
| Mirroring the feature register to GitHub Issues | [Tracker sync](guides/tracker-sync.md) |
| Rendering artifacts as Mermaid diagrams | [Diagrams](guides/diagrams.md) |

## Reference

| What | Where |
|---|---|
| Every skill, one page each — usage, reads/writes, behavior | [Skills reference](reference/skills/README.md) |
| `.project/` file formats, frontmatter schemas, status enums | [Project files](reference/project-files.md) |
| The constitution workflow knobs (`workflow_mode`, `delegation`, …) | [Configuration](reference/configuration.md) |
| The installed helper scripts skills shell out to | [Scripts](reference/scripts.md) |

Why things are the way they are — the decision records — live in the
repository under
[`docs/decisions/`](https://github.com/moui72/artifact-driven-dev/tree/main/docs/decisions).
They're source-repo development history rather than user documentation, so
they're kept out of this site.

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

---

This site renders the repository's `docs/` directory. The repo's
[README](https://github.com/moui72/artifact-driven-dev#readme) and
[USAGE](https://github.com/moui72/artifact-driven-dev/blob/main/USAGE.md)
hold the GitHub-facing equivalents of this page.
