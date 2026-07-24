# Installed helper scripts (`ardd-scripts/`)

install.sh copies these POSIX-sh scripts into
`.claude/skills/ardd-scripts/` in every target project. They exist because
of a working principle: **skills decide *when* (judgment); scripts do the
*writing* and the *deriving* (determinism)**. Skills shell out to them
instead of re-deriving logic in prose, and every script refuses rather
than resolves anything non-trivial. Useful directly when debugging a run
by hand.

A delegated worktree normally has its own copy (install.sh adds
`.claude/skills/ardd-*/` to the target's `.worktreeinclude`), and skills
carry the coordinator's absolute path as a fallback.

## State mutation

### `ardd-state.sh <subcommand> ...`

The single mutation point for `.project/` state. Validates current file
state first and refuses illegal transitions with a nonzero exit.
Subcommands include: `slug` (deterministic kebab sanitization), `mint
<plan|tasks|feedback|research> <slug>` (unique filenames),
`feature-create` / `feature-flip` / `feature-field` (register),
`plan-flip`, `tasks-flip` (the `completed` transition refuses if any
task checkbox is still unchecked), `task-check`, `next-task` (tasks
files), `feedback-mark` / `feedback-planned` (feedback bookkeeping), and
`stamp <file> <field> <value>` (exactly these frontmatter fields:
`last_updated`, `diagram_status`, `next_step_prompt`, `delegation`,
`merge_policy`, `plan_preview`, `plan_preview_editor` (a command
template that must contain the literal `{path}` placeholder),
`update_check_max_age_days`).

### `upsert-section.sh <file> "<Header>"`

Replaces or appends exactly one `## <Header>` section of a markdown file,
body from stdin, never touching any other line. `/ardd-diagram`'s splice
step.

## Worktree lifecycle (the parallel-work bridge)

### `worktree-align.sh`

A delegated subagent's mandatory first act. Fast-forward-merges the local
default branch into the fresh worktree branch (worktrees share the object
store, so unpushed local commits are reachable). Prints `aligned=true` or
refuses (`aligned=false reason=diverged|dirty|...`) — a subagent that
doesn't see `aligned=true` stops and reports, never works unaligned.

### `fold-to-main.sh [default]`

The eager-background prep step: fast-forward-folds the current feature
branch into the local default branch and checks it out, so a delegated
worktree can see the branch's state. Refuses
(`folded=false reason=dirty|detached|diverged|...`) rather than resolving.
A fast-forward authors no new commit.

### `worktree-reap.sh [--dry-run]`

Removes every worktree whose branch is fully merged into the local
default branch AND whose tree is clean, deleting the branch with
`git branch -d` (never `-D`). Refuses per-worktree
(`reaped=false reason=unmerged|dirty|detached|default-branch|remove-failed`)
and never forces — an unmerged abandoned worktree is deliberately
untouched. `--dry-run` prints `candidate=` lines only (what
`/ardd-status` shows as "merged, reapable").

### `inflight-worktrees.sh`

Enumerates every *other* worktree of the repo: branch, any `tasks-*.md`
at `in-progress`/`completed`, and checkbox progress. Solo mode's
coarse-state visibility channel — it survives conversation death, since
an abandoned subagent's worktree is still on disk when no conversation
remembers it.

## Deterministic checks

### `branch-info.sh`

Prints `current`, `default`, and `on_default` — the deterministic half of
the "check branch" step shared by `/ardd-plan` and `/ardd-implement`.

### `completion-flip-check.sh <tasks-file>`

Detects an orphaned completion flip: a `completed` tasks file whose work
branch merged while a bound feature still says `tasked`. A nonexistent
branch ref counts as not-merged (silent). Run by `/ardd-status` against
every completed tasks file.

### `sibling-tasks-complete.sh <tasks-file>`

A plan can have more than one tasks file; this reports whether all
siblings bound to the same plan are collectively done
(`all_complete=true`) — the condition for the `tasked → implemented`
register flip.

### `tasks-list.sh [--all]`

One line per tasks file: `<filename>\t<status>\t<x>/<y>\t<plan>`.
`abandoned` files excluded unless `--all`.

### `status-prune.sh <file> --keep <N>`

Keep-last-N tail-cut of a STATUS.md's `_Updated:` chronology: preserves the
head matter and the newest N blocks verbatim, drops the older tail (which
stays recoverable from git). Run by `/ardd-status` step 6 after its prepend,
only when the constitution sets `status_history_keep: <N>`. Prints
`pruned=true blocks=<t> kept=<k> removed=<r>`; refuses (`pruned=false
reason=...`) on a missing/unreadable file or a non-positive `--keep`, never
corrupting the file.

### `defects-unsurfaced.sh [--id <id> | --all]`

Prints `DEFECTS.md` entries no plan has surfaced yet, as
`<id>\t<claim>` lines (the id = first 8 chars of the claim's shasum).
`--id`/`--all` bypass the surfaced-union filter for `/ardd-plan`'s
explicit defect scopes.

### `project-lock.sh <check|touch> <skill>`

Warn-only concurrency marker for multi-file writes — cheap insurance
against two sessions racing on one checkout, never a block, and no
visibility across worktrees (each worktree has its own `.project/`).

## Tracker sync decisions

### `sync-slug-match.sh <slug>`

Exact-matches `gh issue list --search` candidates against a slug's
persistent `ardd-sync-slug-<slug>` body marker (GitHub search is lexical,
not exact) — what makes push crash-retry idempotent.

### `sync-label-decision.sh <status> <current-label> <issue-state>`

Decides the label action for one linked entry: `add`, `swap`, `close`, or
nothing.

### `sync-divergence.sh <slug> <issue> <status> <issue-state>`

Decides whether issue state diverges from register status and prints the
ready-to-use `## Diverged` line. Report-only.

## Install/update plumbing

### `source-resolve.sh [path] [--channel <stable|beta>]`

Resolves the recorded `Source-Path` per release channel: the tooling-owned
checkout (`~/.ardd/source`) is fetched and checked out to the latest
release tag on the channel; any other existing checkout is `channel=dev`,
read and never mutated.

### `ardd-update-check.sh`

Compares the installed commit against the source's latest release tag
within the recorded channel — `behind` means "not the latest release's
commit". No tags yet → tip comparison (`note=no-releases`). Local git
only by default; with `update_check_max_age_days` set in the
constitution it first fetches tags on the owned checkout when
`FETCH_HEAD` is older than N days (failure → `note=fetch-failed`,
comparison proceeds locally) — see
[configuration.md](configuration.md).

### `lint-project.sh [target-dir]`

The schema-of-record validator — see
[project-files.md](project-files.md) and the `/ardd-lint` page.
