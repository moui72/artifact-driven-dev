# Working an established project with ArDD

Use this guide once a project is past setup — artifacts exist, some work
has shipped, and you're living in the recurring delivery loop — ArDD's
steady state. (Starting fresh? See [greenfield.md](greenfield.md).
Adopting ArDD in an existing codebase? See
[existing-project.md](existing-project.md).)

The steady state is simple: **ideas and observations flow in
continuously; each plan run turns a batch of them into shipped code.**
This is the guide for questions like *"how do I add a feature to a stable
project?"* (log it, then plan it), *"how do I fix a bug I just found?"*
(capture it as feedback; the next plan turns it into a fix), or *"how do I
pick work back up after an interruption?"* — each has a section below, and
[USAGE.md](https://github.com/moui72/artifact-driven-dev/blob/main/USAGE.md)'s "How do I…?" table routes these questions
directly.

---

## Log ideas the moment you have them

```
/ardd-backlog octokit fallback for GitHub similar to the GitLab REST fallback
```

This records the idea in the feature register
(`.project/features/<slug>.md`, `status: backlogged`) and nothing more —
no artifact edits, no design work. Logging is deliberately cheap so you
never lose an idea to "I'll write it down later." The backlog carries no
ordering obligation: work items in any order, whenever you pick them up.

## Capture what you notice — constantly

```
/ardd-feedback the export button silently fails on empty datasets; also
reconsidering the CSV-only decision from May
```

Run this every time using the built thing teaches you something: bugs,
UX friction, decisions that no longer hold. Items get stable IDs
(`F001`, …) in a per-invocation file under `.project/feedback/`, and the
next plan run consumes them — incorporated items become tasks, declined
ones are recorded as declined and never re-prompted. Reconsidered items
tagged with an artifact trigger an explicit confirm-the-reversal prompt
at planning time, so a decision reversal is never silent.

Feature or feedback? **Feature** = new capability worth designing later.
**Feedback** = something you learned inspecting what exists. When in
doubt, feedback — its items can spawn features during planning.

## Plan a batch

```
/ardd-plan octokit-github-fallback        # target backlogged feature(s)
/ardd-plan feedback-export-bugs-3f2a.md   # or scope to one feedback file
/ardd-plan                                # or sweep all open feedback
```

Targeting a feature slug is where its design work happens: the run
proposes coordinated changes across every affected artifact, waits for
your confirmation, applies them as a consistent unit, then drafts the
plan — use this instead of sequential `/ardd-refine` passes, which leave
artifacts inconsistent between edits.

Scoping to a feedback file matters when several are open: an unscoped
run consumes them all into one plan; a scoped run leaves the others
untouched for a later plan. Unsurfaced `DEFECTS.md` entries (from
`/ardd-defects`) are offered once per defect here too.

Not sure what to target, or your backlog has grown into a pile? `/ardd-plan
--slate` is a read-only, advisory pass: it grades a footprint confidence
for each backlogged item and groups them into Bundles (plan together,
sequentially), Parallel sets (safe to fan out as separate runs), and
Solo-deferred items, then stops — no plan, no writes. Use its output to
decide which `/ardd-plan <slug> [...]` call to make next.

## Approve, task, implement, merge

```
/ardd-plan         # ...pauses at the approve/revise/stop checkpoint; approving generates the tasks file
/ardd-implement    # executes; offers worktree delegation (on any branch)
```

Approving the plan at `/ardd-plan`'s checkpoint is what generates the tasks
file — there's no separate tasks step. `/ardd-plan --from <plan>`
re-tasks an already-approved plan.

All run state — checkboxes, status flips, the feature register's
`tasked → implemented` flip — rides the work branch and lands on merge,
atomically with the code. Merge eagerly when a run completes; in-flight
work stays visible to other sessions via the sibling-worktree check
either way. (The full delegation/worktree model — fan-out, merge
policies, conflict handling — is [parallel-work.md](parallel-work.md).)

## When things get interrupted

```
/ardd-implement --reconcile <tasks-file>
```

Reconcile mode compares the codebase against the tasks file — marks work
that's actually done, notes partial work, appends gaps — then the same
run (or the next `/ardd-implement`) continues. `/ardd-implement` also
offers this itself when you pick an interrupted file — one that says
`in-progress` but that no live worktree is working, the fingerprint of a
crashed run. Reach for the explicit flag after a crashed run, a manual detour, or
any "I did some of this by hand" situation.

## Periodic hygiene

(Not sure which checking skill you want? [checking.md](checking.md)
compares all four.)

- `/ardd-defects` — occasionally, or before major planning: checks
  artifacts against the *code* and records drift in `DEFECTS.md`; each
  defect is offered as a fix task by the next plan run, exactly once.
- `/ardd-audit` — when a design decision deserves pressure-testing
  rather than just consistency-checking.
- `/ardd-lint` — anytime, free: structural validation of `.project/`.
- `/ardd-update` — when `/ardd-status` reports an update available (or
  anytime): resolves the recorded source to the latest release on your
  channel (a dev-mode checkout gets a pull *offer* instead), re-runs
  install.sh, and relays its output — migrations and suggestions reach
  your session.

## A typical week

```
Mon: /ardd-backlog (two ideas logged during standup)
Tue: /ardd-feedback (bug noticed while demoing)
Wed: /ardd-plan feedback-demo-bug-1a2b.md (checkpoint → tasks) → /ardd-implement → merge
Fri: /ardd-plan search-filters (checkpoint → tasks) → /ardd-implement (delegated) → merge
```

`STATUS.md` is the re-entry point after any gap — it always names the
recommended next step.
