# /ardd-implement

_Tier: core_

> Execute tasks sequentially — offers worktree delegation; all state rides the work branch and lands on merge. --reconcile <file> re-syncs an interrupted tasks file with the codebase first (absorbs ardd-converge).

<!-- generated:end — the header above is generated from skills/ardd-implement/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-implement                       # pick a tasks file and execute it
/ardd-implement --reconcile <file>    # reconcile mode: sync the file with the codebase instead
/ardd-implement --list                # print ready/in-progress tasks files and stop (read-only, no pick flow)
```

`--list` is a pure side door: it runs `tasks-list.sh`, filters its output
to `ready`/`in-progress` rows only, prints the result, and stops before
step 1 — no `inflight-worktrees.sh` cross-reference, no interactive pick,
and no writes of any kind.

Tasks run sequentially; each is self-contained and loads only the
artifacts its `[artifacts: ...]` tag declares. The skill stops and
surfaces blockers rather than working around them.

## Reads

- `.project/tasks/tasks-*.md` via `tasks-list.sh` (status, progress, plan
  binding; `abandoned` files excluded)
- Sibling worktrees via `inflight-worktrees.sh` — a tasks file a live
  worktree claims at `in-progress` is excluded from the pick (its real
  state lives there, not here)
- `parallel-matrix.sh` — pairwise overlap verdicts used to annotate every
  pick-list and fan-out multi-select option: `independent` (**no declared
  overlap only** — not conflict-free), `shared-artifact (<tags>)`,
  `shared-feature (<slugs>)`, or `claimed` (the same tasks file, ready
  here and claimed by an in-flight worktree). A `shared-feature` verdict
  is a strong warning in the option text, never a hard exclusion — the
  same-file claim check stays the only hard exclusion, which a `claimed`
  verdict simply reports (the rule itself is unchanged), and `merge_policy` conflict
  handling still governs at merge time. When two candidates merely look
  related, the agent skims both and flags likely code-path contact
  before fanning out
- Constitution frontmatter knobs: `workflow_mode`, `delegation`,
  `merge_policy`
- The declared artifacts, per task

## Writes

- Code, tests, and commits — one commit per task
- The tasks file: `ready → in-progress` flip, per-task checkboxes
  (`ardd-state.sh task-check`), the `→ completed` flip
- The feature register: `tasked → implemented`, when
  `sibling-tasks-complete.sh` reports every tasks file bound to the same
  plan is done

Every one of those state changes **rides the work branch** and reaches the
default branch only on merge, atomically with the code — there is no
pre-delegation state commit, and an abandoned worktree never poisons the
default branch.

## The delegation gate

In solo mode, delegation to a background subagent in an isolated worktree
is offered **eagerly** — regardless of which branch you're on (a branch
isolates state; backgrounding frees your session). The constitution's
`delegation` knob tunes the gate: `eager` delegates without asking, `ask`
(or absent) offers each time, `inline` never offers.

- **Pre-flight, before the fold below**: the chosen tasks file and its
  bound plan must be committed, or a delegated worktree simply can't see
  them. This extends to two more resolved-path kinds: the plan's bound
  feature-register files (from its `features:` frontmatter) and any
  feedback files whose `plan:` frontmatter names this plan — all four
  kinds are checked and, where the mode allows, committed together. In
  solo mode, anything dirty/untracked among these four is auto-committed
  (scoped `git add` of exactly those resolved paths, then a signed
  commit) — no prompt, the committed paths and hash are printed. In
  collaborative mode this is unchanged: the user is asked to commit or
  delegation is blocked. Also verifies the plan file resolved from the
  tasks file's `plan:` frontmatter actually exists on disk first (a
  nonexistent path makes `git status --short` print nothing, which would
  otherwise look identical to "already clean"). Separately,
  `.project/artifacts/` is checked as a whole directory — since artifact
  edits carry no back-reference to the plan that produced them — and this
  one always asks before committing, in both solo and collaborative mode;
  it's never folded into the auto-commit path above.
- Already on a feature branch when backgrounding? The branch is
  fast-forward-folded into local `<default>` first (`fold-to-main.sh`) so
  the delegated worktree can see its state; any non-trivial condition
  (`dirty`, `diverged`, …) refuses and is surfaced, never resolved.
- The delegated subagent's **mandatory first act** is `worktree-align.sh`;
  anything but `aligned=true` means stop and report, never work unaligned.
- **Fan-out**: with several `ready` files, the pick can be a multi-select —
  one parallel worktree run per file. The unit of parallelism is the tasks
  file; tasks within a file are always sequential.
- On report-back the coordinator checks for the known `core.bare=true`
  side effect, merges per `merge_policy` (`auto` merges fast-forward or
  conflict-free merges without asking — any conflict aborts and asks,
  nothing is ever auto-resolved; `ask` offers, suggesting yes — eager
  merge keeps the in-flight window short), then runs `worktree-reap.sh`
  to remove the landed worktree (refusals surfaced verbatim, never
  forced).
- A delegated subagent never runs `/ardd-status` — that write would be
  trapped on the worktree branch. The terminal analyze handoff belongs to
  the coordinator or the inline path.
- If delegation ever misbehaves, the blessed fallback is a plain branch,
  inline: decline the offer, `git checkout -b <name>`, same state model,
  same merge.

**Collaborative mode**: nothing is ever committed to the local default
branch. Work moves to a branch (worktree or plain), and after the first
commit the skill offers to push and open a draft PR titled with the
feature slug(s) — the mode's in-flight visibility channel. Merging goes
through the PR; `merge_policy` is never consulted; pushes always require
explicit confirmation.

## Reconcile mode (formerly the `ardd-converge` skill)

Compares the codebase to the tasks file and brings the file back in line:
marks tasks whose work is verifiably done, adds `[partial: <what remains>]`
notes, appends gap tasks for work that landed without a task. Entered two
ways:

- **Offered on pick** — choosing an `in-progress` file no worktree claims
  (the fingerprint of an interrupted run) folds a reconcile-first option
  into the pick confirmation itself.
- **Explicit** — `--reconcile <file>` works on `ready` files too (e.g.
  hotfix work that landed without ever being tasked).

Reconcile never resurrects a `completed` file.

## Rules

- **`completed` is terminal.** Post-completion failures are new work —
  capture with `/ardd-feedback`, never edit the status back.
- **Never skip a test task**; follow the constitution's declared testing
  paradigm (TDD, test-after, or none) — never assume one it doesn't state.
- **Never modify artifacts** during implementation — stop, surface, and
  let the user run `/ardd-refine`. (The register status flip is the one
  exception: bookkeeping, not design.)
- **Never write to `DEFECTS.md`** — report incidental findings in the task
  output and point at `/ardd-defects`.

## Related

- `/ardd-plan` — produces the tasks files this executes; `--from` re-tasks
- `/ardd-status` — the In Flight section shows unmerged work
- [guides/parallel-work.md](../../guides/parallel-work.md) — the full
  delegation/worktree model
