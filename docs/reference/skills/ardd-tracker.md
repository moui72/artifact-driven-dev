# /ardd-tracker

_Tier: extension_

> Mirror the feature register (.project/features/) to and from an external issue tracker — GitHub Issues today — and report divergence in .project/TRACKER.md (formerly ardd-sync).

<!-- generated:end — the header above is generated from skills/ardd-tracker/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-tracker         # both phases: push then pull
/ardd-tracker push    # register → GitHub only
/ardd-tracker pull    # GitHub → register only
```

GitHub Issues (via `gh`) is the only backend today; the entry format,
field-ownership rule, and phase structure are provider-agnostic so others
can be added as a branch inside push/pull, not a redesign. Prerequisites:
`gh` authenticated inside a GitHub repo; the label set
(`ardd:backlogged`, `ardd:planned`, `ardd:tasked`, `ardd-import`) is
created idempotently each run.

## Field ownership — why conflicts can't occur

Every field syncs in one fixed direction. The **register owns** name,
slug, and description (design intent). The **tracker owns** issue state,
labels, and discussion (execution visibility). The skill never edits an
issue's title/body after creation, and never overwrites a register entry's
`status` from tracker state.

## Push (register → GitHub)

- Entries without a `gh_issue:` field get an issue created (title = name,
  body = description + a persistent `ardd-sync-slug-<slug>` marker), the
  matching `ardd:<status>` label, and the issue number recorded via
  `ardd-state.sh feature-field`. `implemented` entries are created closed —
  a closed issue *is* the implemented state; there is no label for it.
- Before creating, a marker search (exact-matched by
  `sync-slug-match.sh`) adopts an existing issue instead of duplicating —
  this makes push **crash-retry idempotent** (a run that died between
  create and record, re-run later). Two genuinely simultaneous pushes can
  still race; that's a documented limitation.
- Already-linked entries get their label advanced (or the issue closed)
  per `sync-label-decision.sh`. A description edited later in the
  register deliberately does not propagate.

## Pull (GitHub → register)

- Open issues labeled `ardd-import` (a label stakeholders apply
  themselves, never inferred) become new `backlogged` register entries;
  the label is swapped to `ardd:backlogged` so they aren't re-imported.
- **Divergence is reported, never applied**: for every linked entry,
  `sync-divergence.sh` checks whether issue state contradicts register
  status (closed but not `implemented`; reopened but `implemented`).
  Findings go to `.project/TRACKER.md` — its single writer, full
  overwrite each run with an explicit all-clear state. Status transitions
  belong to the lifecycle skills, not to sync.

## Writes

- GitHub issues, labels, closures
- `.project/features/<slug>.md` — `gh_issue: <n>` links and pull-imported
  entries only
- `.project/TRACKER.md` — the divergence report

## Headless operation

Designed to run unattended — e.g. a GitHub Actions workflow on a schedule
or on `issues` events, invoking `claude -p "/ardd-tracker"` with
`GITHUB_TOKEN` set. See
[guides/tracker-sync.md](../../guides/tracker-sync.md) for a workflow
snippet.

## Related

- `/ardd-backlog` — creates the register entries push mirrors out
- [guides/tracker-sync.md](../../guides/tracker-sync.md)
