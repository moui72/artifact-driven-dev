# /ardd-status

_Tier: core_

> Full cross-artifact consistency check — reads every artifact, plan, tasks file, and the register — and writes STATUS.md (its single writer); auto-runs after most state-changing skills.

<!-- generated:end — the header above is generated from skills/ardd-status/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-status
```

No arguments. Non-destructive: it reads everything and writes exactly one
file. Most state-changing skills run it automatically as their final step
(`/ardd-backlog`, `/ardd-plan`, `/ardd-refine`, `/ardd-feedback`,
`/ardd-implement` on completion, `/ardd-defects` — the canonical list
lives in this skill's own SKILL.md). Manual runs are the right call after
`/ardd-init` + a refine pass, or anytime you want a fresh check.

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
- `completion-flip-check.sh` per completed tasks file — orphaned
  completion flips
- `ardd-update-check.sh` — whether the ARDD install is behind its source

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

## Writes

- `.project/STATUS.md` — its single writer. Artifact status table, open
  questions by artifact, defect/feedback/backlog summary lines, orphaned
  flips, the In Flight section, the update-available line, and a
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
