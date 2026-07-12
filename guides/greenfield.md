# Starting a greenfield project with ARDD

Use this guide when you're starting from scratch — no code yet, just an idea.

The short version: talk through your project with Claude until you've made the
key decisions, then run `/ardd-bootstrap` to capture them.

---

## Quickstart

If you have nothing installed yet, one command does everything below through
Step 2:

```sh
curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/main/new.sh \
  | sh -s -- my-project
```

It creates and `git init`s `my-project/`, installs ARDD into it via
`install.sh`, and offers to open Claude Code on `/ardd-bootstrap` — which, on
a cold start, conducts the Step 1 design conversation as an interview (its
step 0) and then writes your artifacts. Pick the guide back up at
[Step 3](#step-3-refine-each-artifact).

Pass `--kickoff` to skip the question and launch, or `--no-kickoff` to
install and stop.

The rest of this guide is the same path done by hand, which is worth reading
either way — the built-in interview is a convenience, not a different
workflow.

---

## Prerequisites

Install ARDD into your new project directory:

```sh
cd /path/to/artifact-driven-dev
./install.sh /path/to/your/project
```

Then open Claude Code in your project.

---

## Step 1: Have the design conversation

Before running any skill, talk through your project with Claude. This is where
the real work happens. (`/ardd-bootstrap` conducts exactly this conversation
as an interview in its step 0, if you'd rather be asked than lead.) Cover:

- **What the system does** — one or two sentences; what problem it solves
- **Who uses it** — role, technical level, how often
- **Data** — what entities exist, where they come from, how they relate
- **External integrations** — APIs, third-party services, EHR systems, etc.
- **Storage** — SQL vs NoSQL, hosted vs embedded, why
- **Tech stack** — language, framework, any constraints
- **Principles** — what you won't compromise on (latency, privacy, simplicity)

You don't need to resolve everything. Unresolved decisions become `[OPEN: ...]`
items in the artifacts. The goal is to get the known decisions out of your head
and into the conversation so `/ardd-bootstrap` has something to work with.

---

## Step 2: Bootstrap your artifacts

```
/ardd-bootstrap
```

Claude reads the conversation and writes initial versions of the standard
artifacts to `.project/artifacts/`:

- `constitution.md` — your principles and non-negotiables
- `datamodel.md` — entities, fields, relationships, normalization rules
- `infrastructure.md` — storage, sync strategy, external integrations
- `api.md` — HTTP routes or RPC surface (if applicable)
- `ui.md` — views, components, interaction patterns (if applicable)

Each artifact gets `status: draft` if there are open questions, `status: stable`
if it's complete. Expect most to start as draft.

---

## Step 3: Refine each artifact

Read through each generated artifact. For anything unclear or incomplete:

```
/ardd-refine datamodel
/ardd-refine infrastructure add a note about the CarePoint sync window
/ardd-refine constitution
```

`/ardd-refine` reads the current artifact, applies your guidance, asks up to
three clarifying questions for unresolved items, and writes it back. Repeat
until each artifact reflects your actual decisions.

**Tips for greenfield:**

- Start with `constitution.md` — it sets principles that constrain everything
  else, so catching violations early is cheaper than fixing them after planning.
- Resolve data model decisions before infrastructure ones — the storage and sync
  strategy should follow the schema, not the other way around.
- It's fine to leave `[OPEN: ...]` items in place for decisions you genuinely
  can't make yet. `/ardd-status` will surface them and tell you which ones
  block planning.

---

## Step 4: Check consistency

```
/ardd-status
```

This reads all artifacts and reports:

- **Conflicts** — artifact A says one thing, artifact B says another
- **Gaps** — artifact A implies something artifact B never defines
- **Violations** — decisions that break a constitution principle
- **Draft blockers** — artifacts still at `status: draft`

Fix issues with `/ardd-refine` until `/ardd-status` reports clean and all
artifacts are `stable`.

---

## Step 5: Research open questions

For technical decisions you haven't made yet — library choices, API behaviour,
algorithmic approaches:

```
/ardd-research sqlite full-text search options
/ardd-research rate limiting strategy for external EHR API
```

Research outputs land in `.project/plans/research-<topic>-<date>.md` —
one-off documents nothing reads back automatically. Fold standing
decisions into the relevant artifact with `/ardd-refine` so planning
sees them; log new backlog-worthy scope with `/ardd-backlog`.

---

## Step 6: Plan, task, implement

Once artifacts are stable:

```
/ardd-plan
```

Claude drafts the phased plan, saves it as `status: draft`, and pauses at an
**approve / revise / stop checkpoint**. Approve it and `/ardd-plan` continues
in the same run to produce `.project/tasks/tasks-<slug>-<hex>.md` — an ordered
checklist you can review and adjust before execution. (To task an
already-written plan without re-drafting it, run `/ardd-plan --from <plan>`.)
Then:

```
/ardd-implement
```

Claude asks which tasks file to work on, then executes tasks sequentially:
loads the relevant artifacts for each task, writes and runs tests per
whatever paradigm the constitution declares (TDD, test-after, or none),
implements to pass them, marks the task complete, and commits. It surfaces
blockers rather than working around them.

---

## After initial implementation

You're now in the recurring delivery loop — logging features, capturing
feedback, planning batches. See [continuing.md](continuing.md).

---

## Step 7: Resume if interrupted

If `/ardd-implement` gets interrupted, or you pick the project up in a new
session:

```
/ardd-implement --reconcile <tasks-file>
```

Reconcile mode compares the codebase to the tasks file, marks completed work, notes partial
work, and appends gaps as new tasks. Then run `/ardd-implement` again to
continue.

---

## Visualizing your artifacts

At any point, generate Mermaid diagrams into `README.md`:

```
/ardd-diagram datamodel
/ardd-diagram infrastructure
/ardd-diagram ui
```

GitHub renders Mermaid code fences natively — no extra tooling needed.

---

## What a clean greenfield run looks like

```
Session 1: /ardd-bootstrap (step 0 interviews you, or lead the design yourself) → /ardd-refine × 3
Session 2: /ardd-status → /ardd-refine (fixes) → /ardd-status (clean)
Session 3: /ardd-plan (checkpoint → tasks) → /ardd-implement
Session N: /ardd-implement (reconcile, then resume)
```

Each session can stand alone. `/ardd-status` is your re-entry point after
any gap — it tells you exactly where things stand and what to do next.
