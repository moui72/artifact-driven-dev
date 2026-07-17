# /ardd-plan

_Tier: core_

> Draft a phased plan from artifacts, feedback, and backlogged features, pause at an approval checkpoint, then generate its ordered task list; --from <plan> re-tasks an approved plan without re-planning.

<!-- generated:end — the header above is generated from skills/ardd-plan/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-plan                              # plan from artifacts + all open feedback
/ardd-plan <slug> [<slug> ...]          # additionally target backlogged features
/ardd-plan feedback-<slug>-<hex>.md     # scope to named feedback file(s) only
/ardd-plan defect:<id> [...] | defects  # scope the defect check; re-offers declined entries
/ardd-plan --from <plan-file>           # re-task mode: skip planning, regenerate tasks for an existing plan
/ardd-plan --list                       # print backlogged features and stop (read-only, no pick flow)
/ardd-plan --slate                      # advisory defrag grouping over the backlog, then stop (read-only)
```

`--list` is a pure side door: it runs `feature-list.sh` (default filter —
`backlogged`), prints its output, and stops before step 1 — no branch
check, no artifact discovery, no feedback load, no interactive pick, and
no writes of any kind.

`--slate` is also read-only and ephemeral — like `--list`, it skips
straight past the normal flow (steps 1–15) and runs a separate procedure
instead. Where `--list` prints a bare backlog, `--slate` computes an
advisory "defrag" grouping over it: for each `backlogged` item it grades
a footprint confidence (`high`/`medium`/`low`) grounded in real codebase
greps, then for every pair it determines file-set overlap and ordering
dependency as two separate axes, and classifies every item into exactly
one of Bundle (sequential — recommended as one multi-slug `/ardd-plan
<slug1> <slug2> ...` call), Parallel set (safe to fan out — separate
`/ardd-plan <slug>` calls), or Solo-deferred (low/speculative confidence
or gated on a non-code decision — its own single-slug call). N=0 or N=1
backlogged items is a degenerate case (report "nothing to defrag" and
stop; N=1 recommends that single slug directly) rather than a fabricated
slate. The full grading/relation/classification shape is in the plan's
Technical Approach (`.project/plans/plan-plan-time-defrag-slate-analysi-2026-07-17-1a95.md`)
and the skill's own "Slate mode" section. It writes nothing — no plan, no
register mutation — and recomputes fresh on every invocation.

Argument disambiguation: a plain kebab-case argument is always a feature
slug; `feedback-*.md` is always a feedback scope; `defect:<id>` (the 8-char
identifiers from `DEFECTS.md`) or the literal `defects` is always a defect
scope. Argument types can be mixed in one invocation.

## Shape of a run

The run has two halves separated by a real gate:

1. **Planning** — design targeted features' artifact changes, load
   feedback and defects, draft the plan, write it `status: draft`, then
   **pause at an approve / revise / stop checkpoint**. Approval is a
   decision, not a default.
2. **Tasking** — only on explicit approval (or `--from`, which *is* that
   decision): flip the plan `approved`, flip its features
   `backlogged→planned`, generate the ordered task list, flip features
   `planned→tasked`.

Stopping at the checkpoint is a legitimate outcome — the draft plan is
durable, and `/ardd-plan --from <plan>` tasks it later.

## Reads

- Every `.project/artifacts/*.md` (warns before planning over `draft` ones)
- `.project/feedback/feedback-*.md` with `status: open` (or the scoped set)
- `.project/features/<slug>.md` for targeted slugs (must be `backlogged`)
- `.project/DEFECTS.md`, via `defects-unsurfaced.sh` — entries no prior
  plan has surfaced (or the explicitly scoped ones)
- Existing `.project/plans/plan-*.md` — asks whether the new plan
  supersedes an `approved` one

## Writes

- `.project/plans/plan-<slug>-<date>-<hex>.md` — frontmatter: `status`
  (`draft → approved → superseded`), `branch`, `created`, `features`,
  `surfaced-defects`
- `.project/tasks/tasks-<slug>-<hex>.md` — written `status: generating`
  first (so an interrupted generation is visibly incomplete), flipped to
  `ready` when all tasks are in
- Targeted artifacts — the confirmed design changes for targeted feature
  slugs (this is where a backlogged idea's artifact design work actually
  happens; `/ardd-backlog` only logs)
- Feedback bookkeeping — `[x]`/`[-]` marks per item and the
  `open → planned` flip, at negotiation time (not at approval — declined
  items would otherwise be lost)
- Register flips: `backlogged → planned → tasked` for targeted features

All status mutations are script-performed via `ardd-state.sh`
(`plan-flip`, `feature-flip`, `feature-field`, `tasks-flip`,
`feedback-mark`, `feedback-planned`).

## Behavior notes

- **Run `/ardd-status` first** — don't plan over unresolved conflicts.
- **Browser preview at the approval checkpoint**: before the approve /
  revise / stop question, a one-time preliminary question offers to view
  the plan in the browser — on yes, the plan file is published via the
  `Artifact` tool and its URL is shown, then the checkpoint proceeds as
  normal; on no, straight to the checkpoint. This re-fires every time a
  Revise loop returns to the checkpoint, and a later redeploy of the same
  plan file (same path) targets the same artifact URL, so the preview
  always reflects the latest draft.
- **Reconsidered feedback items are confirmed, never assumed**: each one
  tagged with an artifact gets an explicit confirm-the-reversal prompt,
  showing what the artifact says vs. what the feedback says.
- **Defects are surfaced once**: presented entries (accepted or declined)
  are recorded in the plan's `surfaced-defects:` list, which is what stops
  re-prompting; the `defect:`/`defects` scope arguments deliberately
  bypass that to pull a declined defect back in.
- **Branching**: in solo mode there is no branch gate at all — plan and
  tasks commit to the current branch (normally the default branch); a
  `ready` tasks file on the default branch is planned truth. In
  collaborative mode it offers a plain branch (never a worktree). The
  plan's `branch:` frontmatter records the branch inline implementation
  *would* use; that ref may never be created, which is fine.
- **Never delegates to a worktree** — the plan and tasks files it writes
  are exactly the state the next steps need to see; a worktree would trap
  them until a manual merge.
- **Collaborative-mode visibility**: a delegated `/ardd-implement`
  worktree branches from `origin/<default>`, so the plan and tasks files
  must reach the remote before delegated implementation can see them.
  Solo mode needs nothing — `worktree-align.sh` carries unpushed local
  commits in.
- Re-tasking a plan that already has tasks files asks before generating a
  new one (a deliberate fork, never an overwrite) and offers to mark
  superseded non-completed siblings `abandoned`.
- Task format: unique `T00N` IDs, `[artifacts: ...]` tags (omitted when
  none apply), `[parallel]` markers, test requirements per whatever
  paradigm the constitution declares. Tasks must be executable without
  reading the plan.
- Ends by running `/ardd-status`; with `next_step_prompt: true` the
  recommended next step (usually `/ardd-implement`) may be offered as a
  one-keypress prompt — but only when this run ends the turn itself.

## Related

- `/ardd-implement` — executes the tasks file
- `/ardd-backlog` / `/ardd-feedback` / `/ardd-defects` — the three intake
  streams this skill consumes
- `/ardd-research` — vet substantial ideas before planning them
