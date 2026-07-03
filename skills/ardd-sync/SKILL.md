# /ardd-sync

Mirror `.project/artifacts/features.md` to and from an external issue
tracker. GitHub Issues (via the `gh` CLI) is the only backend today; the
design keeps the entry format, field-ownership rule, and phase structure
provider-agnostic so Jira and others can be added later as a branch inside
push/pull, not a redesign.

Usage: `/ardd-sync` runs both phases (push then pull). `/ardd-sync push` or
`/ardd-sync pull` runs one.

`features.md` owns name, slug, and description — design intent, set by
`/ardd-feature`, `/ardd-plan`, `/ardd-tasks`, `/ardd-implement`. The tracker
owns issue state, labels, and discussion — execution visibility. Each field
syncs in one fixed direction; `/ardd-sync` never overwrites a tracker's
title/body after creation, and never overwrites `features.md`'s `Status`
from tracker state. This is why conflicts can't occur — see Pull, step 2,
for the one deliberate exception (report-only, never applied).

## Prerequisites

1. **Check `gh` is usable.** Run `gh auth status` and `gh repo view`. If
   either fails, tell the user what's missing (not installed, not
   authenticated, not inside a GitHub repo) and stop — don't guess at a repo
   or attempt unauthenticated calls.

2. **Ensure the label set exists**: `ardd:backlogged`, `ardd:planned`,
   `ardd:tasked`, `ardd-import`. Create any missing ones with `gh label
   create <name> --color <any> --description <short>`, ignoring "already
   exists" errors — this is idempotent and safe to run every invocation.
   `Status: implemented` has no label — a closed issue *is* the implemented
   state.

## The `GH:` field

Each `features.md` entry's metadata line gets a new trailing field once
synced, following the existing `·`-separated convention (`Slug`, `Status`,
`Logged`, `Plan`, `Tasks`):

```
_Slug: `foo` · Status: planned · Logged 2026-06-01 · Plan: plan-foo-2026-06-05.md · GH: #123_
```

Absent `GH:` means "not yet synced" — no migration needed for existing
`features.md` files. The field name is provider-specific (`GH:` now, `Jira:`
later) so one entry could eventually carry links into more than one tracker.

## Steps

### Push (`features.md` → GitHub) — run unless invoked as `pull`

1. **Read `.project/artifacts/features.md`.** Parse each entry: name (H2),
   slug, status, and metadata line fields, same parsing `/ardd-feature`
   already does. Entries with no `Slug`/`Status` line at all (legacy,
   pre-convention) are `Status: implemented` by convention — skip them
   entirely; there's no design intent to publish for lines already fully
   applied before this workflow existed.

2. **For each entry with no `GH:` field:**
   - Before creating anything, search for an issue already carrying this
     slug's marker: `gh issue list --search "ardd-sync-slug-<slug> in:body"
     --state all --json number`. Use a colon/equals-free marker token
     (`ardd-sync-slug-<slug>`, not `ardd-sync:slug=<slug>`) — GitHub search
     parses `word:word` as a `qualifier:value` pair, so a colon inside the
     term gets silently dropped instead of matched literally, which would
     defeat the dedup this search exists for. Confirmed empirically: a
     colon-bearing search term returned unfiltered generic results instead
     of zero hits, while the hyphenated form returned a clean, correct empty
     result. If a match is found, adopt its number instead of creating a
     duplicate. This is what makes push idempotent against a run that dies
     between `gh issue create` and the `features.md` write — the expected
     failure mode for something meant to run headlessly on a schedule, not
     an edge case to ignore. Note GitHub's search index has a short indexing
     lag after creation, so a re-run within seconds of a create can still
     race; this is acceptable for anything run hourly or less often.
   - Otherwise create it. If `Status` is `implemented` (e.g. a legacy or
     `/ardd-featurize`-written entry never synced before), create it with no
     status label and close it immediately after (`gh issue close <n>`) —
     `implemented` has no `ardd:*` label, only closed state, and step 2's
     `--label ardd:<status>` below only applies to `backlogged`/`planned`/
     `tasked`: `gh issue create --title "<name>" --body "<description>\n\n<Why
     line, if present>\n\n<!-- ardd-sync-slug-<slug> -->" [--label
     ardd:<status>, omitted when Status is implemented]`.
   - Either way, append `· GH: #<n>` to the entry's metadata line and write
     `features.md`.

3. **For each entry with an existing `GH:` field:**
   - Read current state: `gh issue view <n> --json state,labels`.
   - If `Status` has advanced past what the current `ardd:*` label reflects,
     swap the label (`gh issue edit <n> --remove-label ardd:<old> --add-label
     ardd:<new>`).
   - If `Status: implemented` and the issue is still open, close it (`gh
     issue close <n>`).
   - Never edit title or body after creation — a description edited later in
     `features.md` does not propagate. This is a stated limitation, not a
     gap: re-syncing content would blur the field-ownership rule this skill
     depends on.

### Pull (GitHub → `features.md`) — run unless invoked as `push`

1. **Import new feature requests.** List open issues labeled `ardd-import`
   (`gh issue list --label ardd-import --limit 200
   --json number,title,body`; pass an explicit `--limit` above the CLI's
   default of 30 since an import backlog can exceed it) — this label is
   applied by stakeholders themselves, never inferred, so a stray bug report
   never gets treated as a feature idea. For each:
   - Derive a slug from the title using the same kebab-case + collision
     logic as `/ardd-feature` step 2.
   - Append a new `features.md` entry: `Status: backlogged`, `Logged
     <today>`, `GH: #<n>`, description taken from the issue body (strip the
     `<!-- ardd-sync-slug-... -->` marker if present from a prior push
     cycle).
   - Swap the issue's label from `ardd-import` to `ardd:backlogged` so it
     isn't re-imported next run.

2. **Report divergence — do not apply it.** For every already-linked entry,
   compare current issue state against what `Status` implies (closed but not
   `implemented`; reopened but `implemented`). Collect mismatches into
   `.project/SYNC.md` — full overwrite every run, mirroring `/ardd-verify`'s
   `DEFECTS.md` pattern, including an explicit all-clear state:

   ```markdown
   # Sync

   _Last synced: YYYY-MM-DD_

   ## Diverged
   - **Slug:** <slug> — issue #<n> is <closed/open>, features.md says `Status: <status>`

   (repeat per divergence)
   ```

   or, when nothing diverged:

   ```markdown
   # Sync

   _Last synced: YYYY-MM-DD_

   No divergence — tracker state matches features.md as of this run.
   ```

   This is the one deliberate asymmetry in "vice-versa": pull's only
   write-back into `features.md` is importing new entries (step 1). A
   tracker-side status change is always reported, never applied — `Status`
   transitions belong to the ARDD lifecycle skills
   (`/ardd-plan`/`/ardd-tasks`/`/ardd-implement`), not to this skill. The
   user reconciles manually or via `/ardd-feedback`.

3. **Report a summary:** issues created, labels updated, issues closed,
   entries imported, and the divergence count from `SYNC.md` (or "all
   clear").
