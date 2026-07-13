# Troubleshooting

Common situations and how to get unstuck. Most ARDD state lives in plain
files under `.project/`, so when in doubt, look there — and remember
`/ardd-status` is the always-safe re-entry point: it reads everything and
names the recommended next step.

## Install and update

### `new.sh` refused to run

`new.sh` refuses rather than asks anywhere it would write into a directory
it doesn't own:

- **Non-empty target in new-project mode** — it won't scaffold over
  existing files. If you meant to add ARDD to an existing project, run it
  from inside the project with `--existing`.
- **`--source` that isn't an ARDD checkout** — the path you pointed it at
  doesn't look like the ARDD repo. Check the path.

Nothing is overwritten in either case. See [Install](install.md).

### I installed via `npx skills add` and commands are half-broken

`npx skills add` is no longer a supported channel. Finish/repair the install
by running the `--existing` bootstrap from inside the project — it completes
a partial acquisition:

```sh
cd /path/to/your/project
curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/release/new.sh | sh -s -- --existing
```

### `/ardd-update` keeps warning about "dev-mode"

Your project's `.project/ardd-version.md` records a `Source-Path:` pointing
at a live checkout (your own clone, or one named via `--source` /
`$ARDD_SOURCE`). That checkout is used exactly as it stands and is only ever
read, never pulled — so updates can't move it forward automatically, and
`/ardd-update` asks before proceeding every time. This is expected when
you're hacking on ARDD itself. To track releases instead, re-install from
the release channel (the tooling-owned `~/.ardd/source` clone). See
[Install → Dev-mode](install.md#dev-mode-hacking-on-ardd-itself).

### The update check never reports anything new

By default the update check is local-git-only — it never reaches the
network. Opt into a freshness fetch with `update_check_max_age_days` (see
[Configuration](reference/configuration.md#update_check_max_age_days-opt-in-freshness-fetch-for-the-update-check)).
Offline machines lose nothing: a failed fetch just falls back to local tags.

## Git and the `.project/` files

### install.sh printed a gitignore warning

The installed skill files (`.claude/skills/ardd-*/`) are regenerated output
and should be gitignored; `.project/ardd-version.md` is the intentional
record you *do* commit. install.sh suggests exactly `.claude/skills/ardd-*/`
— **never anything broader**. A broader pattern (`.claude/`, or even
`.claude/skills/`) silently blocks tracking real, team-shared content ARDD
doesn't own (`settings.json`, hooks, a hand-written custom skill). If it
warns that an existing pattern is already too broad, tighten it. See
[Install → Gitignore the skill files](install.md#gitignore-the-skill-files).

### Merge conflict in `STATUS.md` / `DEFECTS.md` / `TRACKER.md` / `audit.md`

These four report files are single-writer and **disposable at merge**: take
either side of the conflict without deliberation, then re-run the owning
skill (`/ardd-status`, `/ardd-defects`, `/ardd-tracker`, `/ardd-audit`) — it
regenerates from disk. Never hand-reconcile them. The shipped
`.project/.gitattributes` marks them `merge=ours`; enabling the per-clone
opt-in makes them merge clean automatically:

```sh
git config merge.ours.driver true
```

(Git refuses to take this from a repo commit, so it's a one-time per-clone
step install.sh suggests but can't set for you.)

### My local `main` won't pull — history looks rewritten

`main`'s history was rewritten once (2026-07-04) to add commit signatures
retroactively; content is identical but hashes after `bbc2595` changed.
If you have no local work on `main`, reset to the remote:

```sh
git fetch origin
git checkout main
git reset --hard origin/main
```

If you have unpushed commits on top of the old `main`, rebase them onto the
new history instead (resetting would drop them):

```sh
git fetch origin
git rebase --onto origin/main <old-main-tip> <your-branch>
```

This was a one-time cleanup, not normal practice.

## Runs and worktrees

### A run died mid-way — how do I pick it back up?

A tasks file left at `status: in-progress` with no live worktree claiming
it is the fingerprint of a crashed run. `/ardd-implement` detects this when
you pick the file and offers to **reconcile** first; or force it explicitly:

```sh
/ardd-implement --reconcile <tasks-file>
```

Reconcile compares the codebase against the tasks file — marks work that's
actually done, notes partial work, appends gaps — then continues. Reach for
the explicit flag after a crash, a manual detour, or any "I did some of this
by hand" situation. See [The core loop → When things get interrupted](guides/core-loop.md).

### A delegated subagent stopped instead of working

A delegated worktree's first act is `worktree-align.sh`, which fast-forwards
your local default branch into the fresh worktree branch. If it reports
anything other than `aligned=true` (e.g. `reason=diverged` or
`reason=dirty`), the subagent stops rather than working from an unaligned
base — by design. Clean up or reconcile the divergence on the default branch
and re-delegate. See [Parallel work](guides/parallel-work.md).

### `/ardd-status` shows work "In Flight" that already landed

After a delegated branch merges, its worktree is dead weight until reaped.
`/ardd-implement`'s post-merge step runs `worktree-reap.sh` automatically;
if a worktree lingers, it's because reap refused (an unmerged or dirty
worktree is never force-removed). `/ardd-status` lists reapable worktrees
via a dry run. An *unmerged* abandoned worktree is left alone deliberately —
deleting in-flight truth takes judgment. See [Parallel work](guides/parallel-work.md).

## Still stuck?

- `/ardd-lint` — fast, deterministic structural check of `.project/`
  frontmatter and references; catches schema problems with no LLM judgment.
- `/ardd-status` — the full cross-artifact consistency read; always safe to
  run, and it names the next step.
- The design history behind these behaviors lives in the repo under
  [`docs/decisions/`](https://github.com/moui72/artifact-driven-dev/tree/main/docs/decisions).
