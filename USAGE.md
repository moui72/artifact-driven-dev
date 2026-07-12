# Using artifact-driven-dev

ARDD is a workflow, not a generator. It doesn't write your spec for you — it
gives you a place to put decisions you've already made, checks them for
consistency, and turns them into an executable task list.

## The core idea

You keep a declared set of living documents called **artifacts**. They
capture what you've decided about your system. Which artifacts exist is
up to your project — a constitution plus the concerns you actually have.
The common defaults:

- **constitution** — your principles and non-negotiables (nearly always)
- **infrastructure** — how data moves, where it's stored, external integrations
- **datamodel** — your canonical schema and any normalization rules
- **ui** — what users see and how the app behaves

A CLI tool might carry only a constitution and an `api.md`; this repo's
own `.project/` carries only a constitution. `/ardd-init` suggests a
set; `/ardd-refine <new-name>` extends it anytime.

You refine these iteratively. When they're stable, you generate a plan, then
tasks, then execute. If work gets interrupted, `/ardd-implement`'s reconcile mode picks up where you
left off.

## Setup

Brand-new project, nothing installed? One command creates it, installs
ARDD from the **latest tagged release** (releases are the stable install
channel — the tooling keeps its own `~/.ardd/source` checkout pinned to
one), and offers to open the first session (`--kickoff` / `--no-kickoff`
answer that offer in advance):

```sh
curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/main/new.sh \
  | sh -s -- my-project
```

Already have a project? Run the same bootstrap from inside it with
`--existing` — `curl -fsSL <repo>/raw/main/new.sh | sh -s -- --existing` —
and it installs the latest release there instead.

Installing from your own clone is dev-mode — for hacking on ARDD itself; it
installs whatever state the clone holds, and `/ardd-update` warns about it:

```sh
cd /path/to/artifact-driven-dev
./install.sh /path/to/your/project
```

Then open Claude Code in your project.

README's Install and Quickstart sections have the details. All routes
converge on `install.sh`; it is the only real install/upgrade entry point.
Once it has run, `/ardd-update` handles updates — resolving the recorded
source to the latest release before reinstalling.

## Getting started (once per project)

Bring the project under ARDD: seed artifacts, refine until stable. After
this you live in [the core loop](#the-core-loop) below. Consistency
checking (`/ardd-status`) runs automatically at the end of most
state-changing skills. Everything under [Extensions](#extensions) —
diagrams, tracker sync, design audits, code-vs-artifact verification,
research — is opt-in and can be ignored until you want it.

### Seed your artifacts

After discussing your project with Claude, run:

```
/ardd-init
```

(On a greenfield project `/ardd-init` conducts that discussion as an
interview itself, in its step 0, before seeding artifacts. The quickstart
above opens straight into it.)

This reads the conversation and writes initial artifacts to
`.project/artifacts/` — whichever set your project's concerns actually
call for (a constitution nearly always; infrastructure/datamodel/ui/api
only when those concerns exist). Each gets `status: draft` if there are
open questions. When a constitution is among them, bootstrap also offers
an opinionated suggestion catalog (accept or reject per suggestion) and
asks once whether the project runs `solo` or `collaborative`
(`workflow_mode`, which gates branch/delegation behavior later), and once
whether skills should end by offering their recommended next step as a
one-keypress prompt (`next_step_prompt: true|false` — absent means
`false`; with `true`, `/ardd-status` and `/ardd-plan`
offer a concrete runnable `/ardd-*` recommendation via a yes/no prompt
instead of plain text). Existing installs whose constitution lacks the
field get asked the same question once by `/ardd-update`; neither answer
ever bumps the constitution version.

Adopting ARDD in an existing codebase? Run `/ardd-init` there too — it detects the code and
reverse-engineers the artifacts from the code (see
[guides/existing-project.md](guides/existing-project.md)).

---

### Refine artifacts

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

### Check consistency

`/ardd-refine` and most other skills that change project state now run this
for you automatically as their final step, so you usually won't need to
invoke it by hand — see `/ardd-status`'s own SKILL.md for the exact list. To run it standalone — e.g. before planning, or any time you
want a fresh check outside those flows:

```
/ardd-status
```

This reads every artifact and reports:
- **Conflicts** — artifact A says one thing, artifact B says another
- **Gaps** — artifact A implies something artifact B never defines
- **Missing artifacts** — anything still at `status: draft`
- **Constitution violations** — decisions that break your principles
- **Orphaned completion flips** — a completed tasks file whose work branch
  already merged, but whose bound feature is still `Status: tasked` in
  the feature register (the fingerprint of a run that crashed between flips, or a
  tasks file from before state rode the work branch). If found, Claude asks
  whether to flip it to `implemented` now.
- **In-flight work** — anything living in a sibling worktree (branch, tasks
  file, checkbox progress) or, in collaborative mode, an open draft PR —
  work that exists on disk but hasn't merged to your default branch yet.

Fix issues with `/ardd-refine` until `/ardd-status` reports clean — each
`/ardd-refine` pass triggers the next check itself.

#### Which checking skill do I want?

Four skills check your project, at different layers. They don't overlap:

| Skill | What it checks | When to run |
|---|---|---|
| `/ardd-status` | Cross-artifact **consistency** — conflicts, gaps, draft artifacts, constitution violations, orphaned completion flips, in-flight work. Uses LLM judgment. | Before planning. Auto-runs as the final step of most state-changing skills. |
| `/ardd-lint` | **Structural** validity only — frontmatter `status`/required fields and `[artifacts: ...]` references. Fast, deterministic, no LLM judgment. | Anytime, cheaply — especially after hand-editing anything in `.project/`. |
| `/ardd-defects` | Artifacts vs. the **actual codebase** — drift between what an artifact says and what the code does, recorded in `DEFECTS.md`. | Periodically, or before major planning. |
| `/ardd-audit` | The **decisions themselves** — simplicity, failure modes, robustness, semantics. Challenges intent, doesn't just check consistency. | When you want a design pressure-tested, not just checked. |

---

---

## The core loop

The recurring delivery cycle. Ideas and observations flow in
continuously; each plan run turns a batch of them into shipped code.
(Guide-length treatment: [guides/continuing.md](guides/continuing.md).)

### 1. Log ideas as they occur

```
/ardd-backlog octokit fallback for GitHub similar to the GitLab REST fallback
```

This records the idea in the feature register (`.project/features/<slug>.md`,
`status: backlogged`) — no design work happens yet, so logging is cheap;
do it the moment an idea exists. Work backlog items in any order,
whenever you choose, by targeting the slug in step 3.

### 2. Capture what you notice

After actually using what's been built:

```
/ardd-feedback the export button silently fails on empty datasets; also
reconsidering the CSV-only decision
```

Bugs, UX friction, reconsidered decisions — each becomes a tracked item
(`F001`, `F002`, …) in `.project/feedback/`, consumed by the next plan.
Reconsidered items tagged with an artifact get an explicit
confirm-the-reversal prompt at planning time.

### 3. Plan and generate tasks

When you're ready to work a batch:

```
/ardd-plan
```

Claude reads all stable artifacts and open feedback, drafts a phased
implementation plan, writes it to disk as `status: draft`, and then **pauses
at an explicit approve / revise / stop checkpoint**. Approving is what flips
the plan to `approved` and continues — in the same run — into generating its
task list (see below). Revising loops back to redraft; stopping leaves the
plan as a durable `draft` you can task later with `/ardd-plan --from <plan>`.

Passing a feedback filename (`/ardd-plan feedback-<slug>-<hex>.md`) scopes
the run to that feedback file — other open feedback files are left
untouched for a later plan, which is how two open feedback files feed two
separate plans cleanly.

Passing one or more backlogged feature slugs (`/ardd-plan <slug> ...`) does
real artifact-design work first, which can run long, but `/ardd-plan` never
delegates to a worktree the way `/ardd-implement` do — the
plan and tasks file it produces are themselves the state the next steps need
to see, so isolating them in a worktree would just trap them there until a
manual merge. In solo mode it doesn't prompt about branches at all: the plan
and tasks files commit to the branch you're on (normally the default
branch). In `workflow_mode: collaborative` it still offers a plain branch,
same as before.

Passing `defect:<id>` (one or more, using the 8-char identifiers
`/ardd-defects` records in `DEFECTS.md`) or the literal `defects` scopes
the defect check to those entries — and re-offers them even if a prior
plan already surfaced (and you declined) them, which is how a
previously-declined defect gets pulled back into a plan. The `defect:`
prefix is what distinguishes these from feature slugs and feedback
filenames in the same argument list.

On approval, `/ardd-plan` continues straight into task generation — there is
no separate tasks command. It produces
`.project/tasks/tasks-<slug>-<hex>.md`, an ordered checklist where each task
declares which artifacts it needs:

```markdown
- [ ] T001 [artifacts: datamodel] Create Patient table migration
- [ ] T002 [artifacts: datamodel, infrastructure] [parallel] Implement MedChart adapter
```

Approving the plan also flips its targeted backlog features from
`backlogged` to `planned` to `tasked`. To regenerate a fresh tasks file for
an already-written plan without re-drafting it — for instance after
abandoning a stale one — run `/ardd-plan --from <plan-file>`, which skips the
planning half and re-enters at task generation. Review the task list and
adjust before running `/ardd-implement`.

---

### 4. Implement

```
/ardd-implement
```

Before anything else it checks for sibling worktrees already working a
tasks file, so a second `/ardd-implement` can start safely while another is
still in flight. It then offers to delegate execution to a background
subagent in an isolated worktree — **regardless of which branch you're on**;
being on a feature branch isolates state but shouldn't tie up your focused
session. The `delegation` field in `constitution.md`'s frontmatter tunes
this gate: `eager` delegates without asking, `ask` (or absent) offers each
time, `inline` never offers. If delegation proceeds while you're on a
feature branch (a recovery case now that solo `/ardd-plan` doesn't create
one), Claude folds that
branch into your default branch and returns you to it first (so the delegated
worktree can see the work), then runs the subagent in the background.
Executing tasks is exactly the long-running, code-producing work isolation is
for. Claude asks
which tasks file to work on, then executes tasks sequentially: loads the
declared artifacts for each task, writes and runs tests per whatever
paradigm the constitution declares (TDD, test-after, or none), implements
to pass them, marks the task complete, and commits. It stops and surfaces
blockers rather than working around them.

If the worktree path ever misbehaves (it leans on harness behavior that
has regressed before), decline the delegation offer and run inline on a
plain branch (`git checkout -b`) — same state model, same merge, nothing
lost. Delegation is an optimization, not a requirement.

Every status change — the tasks file's own flips, checkboxes, and the
feature-backlog flip (`tasked` → `implemented`) — rides the work branch and
reaches your default branch when that branch merges, atomically with the
code. So the feature register never claims work is done before the code has
landed, and until merge the in-flight truth is visible via the sibling-
worktree check above and `/ardd-status`'s "In Flight" section. On a
delegated run's completion, Claude offers to merge the worktree branch
right away — or, with `merge_policy: auto` in `constitution.md`'s
frontmatter, merges it without asking when the merge is fast-forward or
conflict-free (any conflict stops and asks; nothing is ever auto-resolved).
(In `workflow_mode: collaborative`, merging goes through a
pushed draft PR instead — nothing is committed to your local default
branch, and `merge_policy` is never consulted.)

---

### 5. Resume after interruption

If `/ardd-implement` is interrupted — or you pick the project up in a new session:

```
/ardd-implement --reconcile <tasks-file>
```

Same worktree-delegation offer and state model as a normal `/ardd-implement`
run (reconcile is a mode of the same skill; picking an interrupted file in
the pick list offers it too). It compares the codebase against the file,
marks tasks that are already done, notes partial work, and appends any gaps
as new tasks. Then you can run `/ardd-implement` again to continue.

---

## Artifact status

Each artifact has a `status` field in its frontmatter:

- `draft` — has open questions; not safe to plan against
- `stable` — decisions are made; ready for planning

`/ardd-refine` sets this for you. `/ardd-status` will warn if you try to plan over a
`draft` artifact.

---

## Extensions

Everything below is opt-in — useful, but never required by the core loop.

### Research anything uncertain

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
surfaces new backlog-worthy scope instead, use `/ardd-backlog`.

---

### Visualize your artifacts

An artifact becomes renderable by declaring a `diagram_type` in its
frontmatter — the Mermaid diagram-type it should be drawn as. There is no
fixed list of renderable artifacts and no built-in set of diagram types: any
artifact opts in by declaring one. To generate a Mermaid diagram and upsert it
into `README.md` (the default destination):

```
/ardd-diagram datamodel
/ardd-diagram infrastructure
```

`/ardd-diagram datamodel` renders `datamodel.md` (which declares
`diagram_type: erDiagram`) and writes it under a `## Datamodel` section;
`/ardd-diagram infrastructure` renders `infrastructure.md` under
`## Infrastructure`. Running bare `/ardd-diagram` renders every artifact that
declares a `diagram_type`. GitHub renders Mermaid code fences natively — no
extra tooling needed.

The render fields live in the artifact's own frontmatter:

```yaml
# .project/artifacts/datamodel.md
diagram_type: erDiagram        # the Mermaid type — declaring it makes the artifact renderable
render_hint: |                 # optional; domain guidance for what to draw/omit
  One block per entity; derive relationships from FK refs; omit index detail.
render_target: docs/ARCHITECTURE.md   # optional; default README.md
render_section: Datamodel             # optional; default = capitalized artifact stem
```

`diagram_type` is the literal Mermaid diagram-type declaration, used verbatim
as the first line of the fence — `erDiagram`, `sequenceDiagram`, `graph TD` /
`flowchart LR`, `classDiagram`, `gantt`, and so on. ARDD keeps no enumerated
list; **see the Mermaid docs at [mermaid.js.org](https://mermaid.js.org) for
the supported diagram types and their syntax** — that is the canonical source
of valid `diagram_type` values. A typo'd or unsupported value surfaces at
render time, not at lint.

The standard `datamodel` / `infrastructure` / `ui` templates ship with a
`diagram_type` and a `render_hint` already; other artifacts (`api`, custom
ones) render only if you add a `diagram_type` yourself.

Setting `render_target` keeps `README.md` free of raw Mermaid where it must
stay clean — e.g. an npm package page, whose renderer doesn't render Mermaid
fences — while the diagram still renders on GitHub in the target doc.

---

### Sync features with GitHub Issues

To mirror the feature register (`.project/features/`) to GitHub Issues and back:

```
/ardd-tracker
```

Or run one direction only: `/ardd-tracker push` (create/update issues from
backlog entries) or `/ardd-tracker pull` (import issues labeled `ardd-import` as
new backlog entries, and report — but not apply — any tracker-side state
that's diverged from the register, e.g. an issue closed manually).

The register stays the source of truth for what a feature *is* (name, slug,
description); the tracker becomes the source of truth for its status and
discussion. Each synced entry gets a `gh_issue: <n>` frontmatter field.

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
      - run: claude -p "/ardd-tracker"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## When to use ARDD

### vs. Spec Kit

[Spec Kit](https://github.com/github/spec-kit) is an agent-agnostic
spec-driven development framework aimed at *discovering* requirements —
structured elicitation, user story generation, a full spec-to-task pipeline.
Use it when you're working from a vague brief and need the framework to help
you arrive at decisions.

ARDD assumes you've already arrived at the decisions and need a system to
capture, cross-check, and execute against them instead — narrower in scope
than Spec Kit, not lighter in absolute terms; it still carries real process
overhead. ARDD is also currently Claude Code-specific; Spec Kit works across
agents.

### vs. a good CLAUDE.md and direct conversation

The sharper question for most projects. Short version — see
[README.md](README.md#when-artifacts-earn-their-keep) for the full
reasoning: ARDD earns its overhead when the codebase can't serve as an
implicit spec an agent can pattern-match against (greenfield, or a pivot
away from existing patterns), and buys you less when it already can (a
mature, consistent codebase a good `CLAUDE.md` already covers).
