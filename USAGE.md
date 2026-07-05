# Using artifact-driven-dev

ADD is a workflow, not a generator. It doesn't write your spec for you — it
gives you a place to put decisions you've already made, checks them for
consistency, and turns them into an executable task list.

## The core idea

You have four living documents called **artifacts**. They capture what you've
decided about your system:

- **constitution** — your principles and non-negotiables
- **infrastructure** — how data moves, where it's stored, external integrations
- **datamodel** — your canonical schema and any normalization rules
- **ui** — what users see and how the app behaves

You refine these iteratively. When they're stable, you generate a plan, then
tasks, then execute. If work gets interrupted, `/ardd-converge` picks up where you
left off.

## Setup

Install ADD into your project:

```sh
cd /path/to/artifact-driven-dev
./install.sh /path/to/your/project
```

Then open Claude Code in your project.

## Typical workflow

### 1. Seed your artifacts

After discussing your project with Claude, run:

```
/ardd-bootstrap
```

This reads the conversation and writes initial versions of `infrastructure.md`,
`datamodel.md`, and `ui.md` into `.project/artifacts/`. Each gets a `status:
draft` frontmatter field if there are open questions.

If you want a constitution, run:

```
/ardd-refine constitution
```

This creates it from scratch and asks you targeted questions to fill it in.

---

### 2. Refine artifacts

As you make decisions, update the relevant artifact:

```
/ardd-refine datamodel
/ardd-refine infrastructure add a note about the CarePoint sync strategy
/ardd-refine ui
```

`/ardd-refine` reads the current artifact, applies your guidance, asks clarifying
questions for anything unresolved, and writes it back. For the constitution,
it also handles version bumping and the sync impact report.

---

### 3. Check consistency

`/ardd-refine` and most other skills that change project state now run this
for you automatically as their final step, so you usually won't need to
invoke it by hand — see `/ardd-analyze`'s own SKILL.md for the exact list. To run it standalone — e.g. before planning, or any time you
want a fresh check outside those flows:

```
/ardd-analyze
```

This reads all four artifacts and reports:
- **Conflicts** — artifact A says one thing, artifact B says another
- **Gaps** — artifact A implies something artifact B never defines
- **Missing artifacts** — anything still at `status: draft`
- **Constitution violations** — decisions that break your principles
- **Orphaned completion flips** — a completed tasks file whose work branch
  already merged, but whose bound feature is still `Status: tasked` in
  `features.md` (the fingerprint of a run that crashed between flips, or a
  tasks file from before state rode the work branch). If found, Claude asks
  whether to flip it to `implemented` now.
- **In-flight work** — anything living in a sibling worktree (branch, tasks
  file, checkbox progress) or, in collaborative mode, an open draft PR —
  work that exists on disk but hasn't merged to your default branch yet.

Fix issues with `/ardd-refine` until `/ardd-analyze` reports clean — each
`/ardd-refine` pass triggers the next check itself.

---

### 4. Research anything uncertain

For open questions — library choices, API behaviour, algorithmic approaches —
run:

```
/ardd-research sqlite full-text search options
/ardd-research carepoint appointment pagination edge cases
```

Research outputs go to `.project/plans/research-<topic>-<date>.md`. This is a
one-off write with no lifecycle — nothing reads it back automatically. If the
recommendation is a standing decision, fold it into the relevant artifact
with `/ardd-refine` so `/ardd-plan` picks it up the normal way; if it
surfaces new backlog-worthy scope instead, use `/ardd-feature`.

---

### 5. Generate a plan

When artifacts are stable:

```
/ardd-plan
```

Claude reads all stable artifacts and open feedback, drafts a phased
implementation plan, and presents it for your review. The plan is saved to
disk immediately as `status: draft` — there's no separate approval step
here. Running `/ardd-tasks` and selecting it is what approves it.

Passing one or more backlogged feature slugs (`/ardd-plan <slug> ...`) does
real artifact-design work first, which can run long, but `/ardd-plan` never
delegates to a worktree the way `/ardd-implement`/`/ardd-converge` do — the
draft plan it produces is itself the state `/ardd-tasks` needs to see, so
isolating it in a worktree would just trap it there until a manual merge.
It still offers a plain branch, same as before.

---

### 6. Generate tasks

```
/ardd-tasks
```

Always runs on whatever branch or worktree you invoke it from — no
worktree gate of its own, since approving the plan and flipping the
feature-backlog Status are quick state updates with no long-running work
to isolate. This
asks which plan to generate tasks for (draft or already-approved), and
selecting a draft one approves it as part of this step — flips it to
`approved` and flips its targeted backlog features from `backlogged` to
`planned`. It then produces `.project/tasks/tasks-<slug>-<hex>.md` — an
ordered checklist where each task declares which artifacts it needs:

```markdown
- [ ] T001 [artifacts: datamodel] Create Patient table migration
- [ ] T002 [artifacts: datamodel, infrastructure] [parallel] Implement MedChart adapter
```

Review the task list and adjust before running `/ardd-implement`.

---

### 7. Implement

```
/ardd-implement
```

Before anything else it checks for sibling worktrees already working a
tasks file, so a second `/ardd-implement` can start safely while another is
still in flight. If you're on your default branch it offers to delegate
execution to a subagent in an isolated worktree — executing tasks is
exactly the long-running, code-producing work isolation is for. Claude asks
which tasks file to work on, then executes tasks sequentially: loads the
declared artifacts for each task, writes and runs tests per whatever
paradigm the constitution declares (TDD, test-after, or none), implements
to pass them, marks the task complete, and commits. It stops and surfaces
blockers rather than working around them.

Every status change — the tasks file's own flips, checkboxes, and the
feature-backlog flip (`tasked` → `implemented`) — rides the work branch and
reaches your default branch when that branch merges, atomically with the
code. So `features.md` never claims work is done before the code has
landed, and until merge the in-flight truth is visible via the sibling-
worktree check above and `/ardd-analyze`'s "In Flight" section. On a
delegated run's completion, Claude offers to merge the worktree branch
right away (in `workflow_mode: collaborative`, merging goes through a
pushed draft PR instead — nothing is committed to your local default
branch).

---

### 8. Resume after interruption

If `/ardd-implement` is interrupted — or you pick the project up in a new session:

```
/ardd-converge
```

Same worktree-delegation offer and state model as `/ardd-implement`. This asks which tasks file to reconcile, compares the codebase against it,
marks tasks that are already done, notes partial work, and appends any gaps
as new tasks. Then you can run `/ardd-implement` again to continue.

---

## Artifact status

Each artifact has a `status` field in its frontmatter:

- `draft` — has open questions; not safe to plan against
- `stable` — decisions are made; ready for planning

`/ardd-refine` sets this for you. `/ardd-analyze` will warn if you try to plan over a
`draft` artifact.

---

### Visualize your artifacts

To generate a Mermaid diagram and upsert it into `README.md`:

```
/ardd-render datamodel
/ardd-render infrastructure
```

`/ardd-render datamodel` produces an ERD from `datamodel.md` and writes it under
a `## Datamodel` section. `/ardd-render infrastructure` produces a container
diagram from `infrastructure.md` (and `adapters.md` if present) under
`## Infrastructure`. GitHub renders Mermaid code fences natively — no extra
tooling needed.

---

### Sync features with GitHub Issues

To mirror `.project/artifacts/features.md` to GitHub Issues and back:

```
/ardd-sync
```

Or run one direction only: `/ardd-sync push` (create/update issues from
backlog entries) or `/ardd-sync pull` (import issues labeled `ardd-import` as
new backlog entries, and report — but not apply — any tracker-side state
that's diverged from `features.md`, e.g. an issue closed manually).

`features.md` stays the source of truth for what a feature *is* (name, slug,
description); the tracker becomes the source of truth for its status and
discussion. Each synced entry gets a `· GH: #<n>` field appended to its
metadata line.

To run it unattended, invoke it headlessly from a GitHub Actions workflow —
on a schedule, or on `issues` events so new `ardd-import`-labeled issues get
picked up promptly:

```yaml
on:
  schedule:
    - cron: "0 * * * *"
  issues:
    types: [labeled]
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: claude -p "/ardd-sync"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## When to use ADD

### vs. Spec Kit

[Spec Kit](https://github.com/github/spec-kit) is an agent-agnostic
spec-driven development framework aimed at *discovering* requirements —
structured elicitation, user story generation, a full spec-to-task pipeline.
Use it when you're working from a vague brief and need the framework to help
you arrive at decisions.

ADD assumes you've already arrived at the decisions and need a system to
capture, cross-check, and execute against them instead — narrower in scope
than Spec Kit, not lighter in absolute terms; it still carries real process
overhead. ADD is also currently Claude Code-specific; Spec Kit works across
agents.

### vs. a good CLAUDE.md and direct conversation

The sharper question for most projects. Short version — see
[README.md](README.md#when-artifacts-earn-their-keep) for the full
reasoning: ADD earns its overhead when the codebase can't serve as an
implicit spec an agent can pattern-match against (greenfield, or a pivot
away from existing patterns), and buys you less when it already can (a
mature, consistent codebase a good `CLAUDE.md` already covers).
