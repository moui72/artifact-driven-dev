# Adopting ARDD in an existing project

Use this guide when code already exists — a partial implementation, an MVP,
or a mature codebase you want to start managing with ARDD.

The process is the same regardless of how complete the project is:
`/ardd-init` (existing-codebase path) reads the codebase and generates draft artifacts that capture
what the code actually does. You then review, fill gaps, and optionally use
ARDD to plan new work.

---

## Prerequisites

Install ARDD into your project:

```sh
cd /path/to/artifact-driven-dev
./install.sh /path/to/your/project
```

Then open Claude Code in your project.

---

## Step 1: Run init

```
/ardd-init
```

Claude surveys the codebase — schema files, routes, components, config,
integrations, entry points — and generates whichever standard artifacts apply:

| Artifact | Generated if... |
|---|---|
| `constitution.md` | Always — infers principles from observed patterns |
| `datamodel.md` | Schema files, ORM models, or typed data structures exist |
| `infrastructure.md` | External APIs, sync jobs, background workers, or non-trivial storage |
| `adapters.md` | Multiple distinct external data sources with different fetch patterns |
| `api.md` | Defined HTTP routes or RPC surface |
| `ui.md` | Frontend components or views exist |

All generated artifacts start at `status: draft`. Claude reports how many were
written and the total count of `[OPEN: ...]` items across all of them.

**What the codebase survey captures well:**
- Field names and types from schema files
- Route signatures and response shapes
- Component tree structure
- Environment variables and config keys
- Pagination and auth patterns in fetch code

**What it can't infer:**
- Why a decision was made (only what was decided)
- Business rules encoded in prose or comments rather than types
- Intent behind ambiguous patterns
- Decisions that live entirely in your head

These gaps surface as `[OPEN: ...]` items for you to resolve in the next step.

---

## Step 2: Review the generated artifacts

Read each artifact Claude wrote. You're looking for three things:

1. **Factual errors** — init reads code, but code can be misleading. If an
   artifact says something wrong, correct it with `/ardd-refine`.

2. **Open items** — `[OPEN: ...]` placeholders mark decisions init couldn't
   infer. These are the most important things to resolve before planning new work.

3. **Missing intent** — the artifact might accurately describe what the code
   does but miss what you intended. Add the intent; it's what future planning
   will be guided by.

---

## Step 3: Refine each artifact

Work through the artifacts with open questions, highest count first:

```
/ardd-refine datamodel
/ardd-refine infrastructure the sync window is ±30 days from today by design
/ardd-refine constitution
```

For `constitution.md` specifically: init infers principles from patterns
(e.g., "REST over RPC" if only REST routes exist). In practice it often
produces more principles than you'd expect — pattern-reading can surface
implicit values you never articulated. The first refine pass is usually about
*correcting* misread patterns rather than *completing* a sparse list. Review
each inferred principle and correct any that misrepresent your actual intent.

Repeat until you've resolved every `[OPEN: ...]` that matters. You don't have
to resolve everything before moving on — some decisions are genuinely deferred.
What matters is that the open items you leave are truly open, not accidentally
forgotten.

---

## Step 4: Check consistency

```
/ardd-status
```

This reads all artifacts and reports conflicts, gaps, and violations. Fix
issues with `/ardd-refine` until the report is clean.

For a well-implemented project, this often comes back nearly clean — init
reads the actual code, so most things it writes are internally consistent. The
issues that do appear are usually:

- Principles in `constitution.md` that the existing code already violates
  (useful to know even if you don't change anything)
- Fields used in the UI that aren't defined in the data model
- Production shortcuts that lack `[PRODUCTION]` annotations

---

## Step 5: Decide what to do next

Once artifacts are stable, you have two options:

### Use ARDD to plan new work

If you're adding significant new functionality:

```
/ardd-plan       # drafts, checkpoints, and (on approval) tasks
/ardd-implement
```

The new work will be planned against the codified artifacts, so the plan
reflects the actual system rather than a spec that may have drifted.

### Use artifacts for alignment only

Sometimes the goal is just to have a shared, accurate description of the
system — for onboarding, for auditing decisions, or as a foundation before
a major refactor. In that case, stop here. The artifacts are the deliverable.

---

## Key difference from greenfield

In a greenfield project, artifacts capture decisions *before* they're built.
In an existing project, init captures decisions *after* they were built —
some of which were never explicitly made and just emerged from the code.

This means the `constitution.md` generated this way is especially important
to review. It reflects observed patterns, not stated values. You may find
principles in there you'd disavow, or patterns you'd endorse but never
articulated. Either way, it's a useful mirror.

---

## After init

From here you're in the recurring delivery loop — logging features,
capturing feedback, planning batches. See [continuing.md](continuing.md).

---

## Typical flow

```
Session 1: /ardd-init (offers feature-register extraction) → read artifacts → /ardd-refine × N
Session 2: /ardd-status → /ardd-refine (fixes) → /ardd-status (clean)
Session 3 (optional): /ardd-plan (checkpoint → tasks) → /ardd-implement
Session N: /ardd-backlog <description> (log to backlog, anytime)
Session N+k: /ardd-plan <slug> (design + apply + plan + tasks, whenever you pick it up) → /ardd-status → /ardd-implement
```
