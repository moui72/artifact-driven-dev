# Working an established project with ARDD

Use this guide once a project is past setup — artifacts exist, some work
has shipped, and you're living in the recurring delivery loop. (Starting
fresh? See [greenfield.md](greenfield.md). Adopting ARDD in an existing
codebase? See [existing-project.md](existing-project.md).)

The steady state is simple: **ideas and observations flow in
continuously; each plan run turns a batch of them into shipped code.**

---

## Log ideas the moment you have them

```
/ardd-feature octokit fallback for GitHub similar to the GitLab REST fallback
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

## Approve, task, implement, merge

```
/ardd-plan         # ...pauses at the approve/revise/stop checkpoint; approving generates the tasks file
/ardd-implement    # executes; offers worktree delegation from the default branch
```

Approving the plan at `/ardd-plan`'s checkpoint is what generates the tasks
file — there's no separate tasks step. `/ardd-plan --from <plan>`
re-tasks an already-approved plan.

All run state — checkboxes, status flips, the feature register's
`tasked → implemented` flip — rides the work branch and lands on merge,
atomically with the code. Merge eagerly when a run completes; in-flight
work stays visible to other sessions via the sibling-worktree check
either way.

## When things get interrupted

```
/ardd-converge
```

Reconciles the codebase against a tasks file — marks work that's
actually done, notes partial work, appends gaps — then `/ardd-implement`
continues. Reach for it after a crashed run, a manual detour, or any
"I did some of this by hand" situation.

## Periodic hygiene

- `/ardd-defects` — occasionally, or before major planning: checks
  artifacts against the *code* and records drift in `DEFECTS.md`; each
  defect is offered as a fix task by the next plan run, exactly once.
- `/ardd-audit` — when a design decision deserves pressure-testing
  rather than just consistency-checking.
- `/ardd-lint` — anytime, free: structural validation of `.project/`
  (also runs automatically if the write-time hook is configured).
- `/ardd-update` — when `/ardd-status` reports an update available (or
  anytime): finds the recorded source checkout, offers a pull, re-runs
  install.sh, and relays its output — migrations and suggestions reach
  your session.

## A typical week

```
Mon: /ardd-feature (two ideas logged during standup)
Tue: /ardd-feedback (bug noticed while demoing)
Wed: /ardd-plan feedback-demo-bug-1a2b.md (checkpoint → tasks) → /ardd-implement → merge
Fri: /ardd-plan search-filters (checkpoint → tasks) → /ardd-implement (delegated) → merge
```

`STATUS.md` is the re-entry point after any gap — it always names the
recommended next step.
