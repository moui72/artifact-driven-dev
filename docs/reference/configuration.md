# Configuration — the constitution workflow knobs

ArDD's behavior knobs live in `constitution.md`'s **frontmatter** — they
are workflow settings, not constitution content: setting or changing one
never bumps the constitution version and never touches the Sync Impact
Report. `next_step_prompt`, `delegation`, `merge_policy`, and
`update_check_max_age_days` are stamped via `ardd-state.sh stamp <file>
<field> <value>`, never hand-edited; `workflow_mode` is written into the
frontmatter by `/ardd-init` directly.
Every one has a safe default when absent — projects initialized before a
field existed need no migration.

`/ardd-init` asks each question once at setup. By default, `/ardd-update`
only backfills: it asks `next_step_prompt`, `delegation`, and (solo mode)
`merge_policy` once for installs whose constitution lacks the field
entirely — `workflow_mode` is never asked by the default path and simply
defaults to `solo` when absent. Run `/ardd-update --reconfigure` to
re-ask all four fields, including `workflow_mode`, on demand — regardless
of whether they're already set — showing each field's current value
before asking whether to keep it or change it; this is the only way to
change `workflow_mode` outside of `/ardd-init`. Enum enforcement: the
installed `lint-project.sh`.

## `workflow_mode` — where in-progress work lives

`solo` | `collaborative` — absent = `solo`.

- **solo** — single developer, one machine. Committing to the local
  default branch is fine for inline runs; `/ardd-plan` has no branch gate
  at all. Delegated runs use isolated worktrees that merge back eagerly
  and are then reaped. In-flight visibility: `inflight-worktrees.sh` /
  `/ardd-status`'s In Flight section.
- **collaborative** — nothing is ever committed to the *local* default
  branch. Work always moves to a branch; after the first commit the skill
  offers to push and open a **draft PR** titled with the feature slug(s) —
  the mode's shared in-flight signal. Register flips ride the branch and
  land when the PR merges. Pushes always require explicit confirmation.
  One extra constraint: delegated worktrees branch from
  `origin/<default>`, so plan/tasks files must reach the remote before
  delegated implementation can see them.

Suggested by detection at init: branch protection on the default branch →
`collaborative`; no remote → `solo`.

## `next_step_prompt` — one-keypress next steps

`true` | `false` — absent = `false`.

When `true`, exactly two skills — `/ardd-status` and `/ardd-plan` — end by
offering their recommended next step via a yes/no prompt, and only when
that recommendation is a concrete runnable `/ardd-*` invocation (anything
else stays plain text). One prompt per user-visible turn end: when plan
hands off to status, status owns the prompt. `false`/absent keeps
recommendations as plain text, so delegated and scripted runs are
unaffected.

## `delegation` — the background gate

`eager` | `ask` | `inline` — absent = `ask`. Consulted by
`/ardd-implement`'s delegation gate:

- `eager` — delegate to a background worktree subagent without prompting
- `ask` — offer each time, suggesting yes
- `inline` — never offer; run in the foreground

## `merge_policy` — landing a delegated run

`auto` | `ask` — absent = `ask`. **Solo mode only** — collaborative mode
merges through the PR and never consults it (which is why init doesn't
ask it there).

- `auto` — when a delegated run completes, merge its branch into the
  default branch without asking, when the merge is fast-forward or
  conflict-free. Any conflict aborts, surfaces, and falls back to asking —
  nothing is ever auto-resolved.
- `ask` — offer the merge each time, suggesting yes (eager merging keeps
  the in-flight window short).

## `plan_preview` — the browser-preview question at `/ardd-plan`'s checkpoint

`always-browser` | `always-console` | `ask` — absent = `ask`. Consulted
by `/ardd-plan`'s approval checkpoint (step 10), before the three-way
approve/revise/stop question:

- `always-browser` — skip the question; always publish the plan file via
  the `Artifact` tool and open it, then proceed to the three-way question
- `always-console` — skip the question; never publish, proceed straight
  to the three-way question
- `ask` — offer the "view in browser first?" question each time (the
  original, still-default behavior)

Not asked by `/ardd-init` or backfilled by default `/ardd-update` —
opt in deliberately via `ardd-state.sh stamp <file> plan_preview <value>`.

## `update_check_max_age_days` — opt-in freshness fetch for the update check

A positive integer — absent = never fetch (the default: the update check
is local-git-only). Neither `/ardd-init` nor `/ardd-update` asks for it;
opt in deliberately:

```sh
ardd-state.sh stamp .project/artifacts/constitution.md update_check_max_age_days 7
```

When set, `ardd-update-check.sh` runs `git fetch --tags` on the source
before comparing — but only when the source is the release-channel owned
checkout (`~/.ardd/source`; a dev-mode checkout is read, never mutated,
and the self-hosted case never fetches) *and* the checkout's
`.git/FETCH_HEAD` is older than N days (missing = stale). A failed fetch
appends `note=fetch-failed` to the check's output line and the comparison
proceeds against local tags — offline machines lose nothing. An invalid
value behaves like absent (and is flagged by `lint-project.sh`).

## Related per-clone git opt-ins (not frontmatter)

Two settings git refuses to take from a repo commit, suggested by
install.sh and set once per clone:

```sh
git config merge.ours.driver true    # report files merge clean, keeping the current side
```

(and in this source repo only, `git config core.hooksPath hooks` for the
pre-commit checks — see CONTRIBUTING.md.)
