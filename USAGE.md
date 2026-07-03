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

Before planning, run:

```
/ardd-analyze
```

This reads all four artifacts and reports:
- **Conflicts** — artifact A says one thing, artifact B says another
- **Gaps** — artifact A implies something artifact B never defines
- **Missing artifacts** — anything still at `status: draft`
- **Constitution violations** — decisions that break your principles

Fix issues with `/ardd-refine` until `/ardd-analyze` reports clean.

---

### 4. Research anything uncertain

For open questions — library choices, API behaviour, algorithmic approaches —
run:

```
/ardd-research sqlite full-text search options
/ardd-research carepoint appointment pagination edge cases
```

Research outputs go to `.project/plans/research-<topic>-<date>.md`. The
findings are available to `/ardd-plan` automatically.

---

### 5. Generate a plan

When artifacts are stable:

```
/ardd-plan
```

Claude reads all artifacts and any research docs, drafts a phased
implementation plan, and presents it for your review. The plan isn't written
to disk until you approve it.

---

### 6. Generate tasks

After approving the plan:

```
/ardd-tasks
```

This asks which approved plan to generate tasks for, then produces
`.project/tasks/tasks-<slug>-<hex>.md` — an ordered checklist where each
task declares which artifacts it needs:

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

Claude asks which tasks file to work on, then executes tasks sequentially:
loads the declared artifacts for each task, writes and runs tests per
whatever paradigm the constitution declares (TDD, test-after, or none),
implements to pass them, marks the task complete, and commits. It stops and
surfaces blockers rather than working around them.

---

### 8. Resume after interruption

If `/ardd-implement` is interrupted — or you pick the project up in a new session:

```
/ardd-converge
```

This asks which tasks file to reconcile, compares the codebase against it,
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

## When to use ADD vs Spec Kit

[Spec Kit](https://github.com/github/spec-kit) is an agent-agnostic
spec-driven development framework. Use it when:
- You need structured requirement discovery
- You're working from a vague brief that needs user story generation
- You want a full spec-to-task pipeline with templates and validation

Use ADD when:
- You already have a clear picture of what you're building
- You want to capture and cross-check decisions, not generate them
- You prefer lean artifacts over templated ceremony

ADD is currently Claude Code-specific. Spec Kit works across agents.
