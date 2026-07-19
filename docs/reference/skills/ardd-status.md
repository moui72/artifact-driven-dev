# /ardd-status

_Tier: core_

> Full cross-artifact consistency check — reads every artifact, plan, tasks file, and the register — and writes STATUS.md (its single writer); auto-runs after most state-changing skills.

<!-- generated:end — the header above is generated from skills/ardd-status/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-status
/ardd-status --view    # read-only side door: print the report and stop
```

No arguments. Non-destructive: it reads everything and writes exactly one
file. Most state-changing skills run it automatically as their final step
(`/ardd-backlog`, `/ardd-plan`, `/ardd-refine`, `/ardd-feedback`,
`/ardd-implement` on completion, `/ardd-defects` — the canonical list
lives in this skill's own SKILL.md). Manual runs are the right call after
`/ardd-init` + a refine pass, or anytime you want a fresh check.

`--view` is a pure side door: it runs the same discovery and report
assembly (steps 1–5), prints the report straight to the terminal, and
stops — no `STATUS.md` write, no orphaned-flip confirmation, and no
next-step prompt. Same "no writes of any kind" shape as `/ardd-plan
--list` and `/ardd-implement --list`. Use it for a quick full consistency
check without touching `STATUS.md` or being asked anything.

**Run only from the primary checkout, never inside a delegated worktree** —
that would trap the `STATUS.md` write on the worktree's branch.

## Reads

- Every `.project/artifacts/*.md`
- `.project/DEFECTS.md` (count + last-verified date — read-only)
- `.project/feedback/*` open count, `.project/features/*` status counts
- `.project/plans/*` and `.project/tasks/*`
- `inflight-worktrees.sh` — sibling worktrees' branches and tasks-file
  progress; `worktree-reap.sh --dry-run` — merged-reapable candidates
  (visibility only, never mutates); `gh pr list --draft` in collaborative
  mode
- `parallel-matrix.sh` — pairwise overlap verdicts among `ready` tasks
  files and in-flight worktree claims (shared feature slugs via the
  tasks → plan chain, shared `[artifacts: ...]` tags)
- `completion-flip-check.sh` per completed tasks file — orphaned
  completion flips
- `ardd-update-check.sh` — whether the ArDD install is behind its source
  (local git by default; fetches first only when the constitution's
  `update_check_max_age_days` opt-in says the owned checkout's tags have
  gone stale). A dev-mode checkout that's actually *ahead* of the latest
  release tag reports distinctly (`dev-ahead`) and is never nudged to
  "update" — doing so would regress it.

## What it checks

- **Cross-artifact consistency** — concepts referenced but undefined,
  decisions that disagree across artifacts, UI fields missing from the
  data model
- **Constitution compliance** — violations of the principles it actually
  declares (never an assumed fixed set)
- **Within-artifact issues** — unresolved `[OPEN: ...]` items, vague
  language, `draft` artifacts that would block planning
- **Diagram staleness** — each renderable artifact's `diagram_status`
- **In-flight work** — sibling worktrees, reapable worktrees, draft PRs
- **Work Queue** — one entry per `ready` tasks file (filename, bound
  plan/features, verdicts against the other ready files and in-flight
  claims, from `parallel-matrix.sh`). `independent` means **no declared
  overlap only** — not "conflict-free"; `merge_policy` conflict handling
  still governs at merge time. Read-only visibility, omitted entirely
  when no `ready` tasks file exists
- **By-epic breakdown** — when any register feature carries a non-empty
  `epic` field, the Feature Backlog counts (backlogged/planned/tasked)
  are additionally grouped and reported per `epic` value; omitted
  entirely when no feature carries one
- **Documented but untracked** — capabilities a `stable` artifact
  describes that have no register entry (any status) and no
  implementation, each pointing at `/ardd-backlog --from-artifacts`.
  Advisory only — it never creates register entries (drafts are skipped;
  the section is omitted when nothing is untracked)

## Writes

- `.project/STATUS.md` — its single writer. Artifact status table, open
  questions by artifact, defect/feedback/backlog summary lines, orphaned
  flips, the Work Queue section, the In Flight section, the
  update-available line, and a
  recommended next step. STATUS.md is the single re-entry point after any
  interruption.
- **One narrow register exception**: for each orphaned completion flip
  found (a completed tasks file whose work branch merged while its
  feature still says `tasked`), it asks and — on confirmation — performs
  the `tasked → implemented` flip itself. Justified because no other
  skill run is left to catch it; a decline is simply re-reported next run.

## Behavior notes

- With `next_step_prompt: true` in the constitution frontmatter, the run
  ends by offering the recommended next step as a one-keypress prompt —
  only when it's a concrete runnable `/ardd-*` invocation; anything else
  stays plain text.

## Related

- `/ardd-lint` — structural validation (fast, deterministic; this skill
  is the judgment-based consistency check)
- `/ardd-defects` — artifacts vs. the *code*; this skill never reads code
- [guides/checking.md](../../guides/checking.md) — which checking skill
  you want, and when
