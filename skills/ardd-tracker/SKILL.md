---
name: ardd-tracker
tier: extension
description: "Mirror the feature register (.project/features/) to and from an external issue tracker — GitHub Issues today — and report divergence in .project/TRACKER.md."
---

# /ardd-tracker

Mirror the feature register (`.project/features/*.md`) to and from an external issue
tracker. GitHub Issues (via the `gh` CLI) is the only backend today; the
design keeps the entry format, field-ownership rule, and phase structure
provider-agnostic so Jira and others can be added later as a branch inside
push/pull, not a redesign.

Usage: `/ardd-tracker` runs both phases (push then pull). `/ardd-tracker push` or
`/ardd-tracker pull` runs one.

The register owns name, slug, and description — design intent, set by
`/ardd-backlog`, `/ardd-plan`, `/ardd-implement`. The tracker
owns issue state, labels, and discussion — execution visibility. Each field
syncs in one fixed direction; `/ardd-tracker` never overwrites a tracker's
title/body after creation, and never overwrites a register entry's
`status` from tracker state. This is why conflicts can't occur — see Pull, step 2,
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

## The `gh_issue` field

Each register file gains a `gh_issue: <n>` frontmatter field once synced
(set via `ardd-state.sh feature-field <slug> gh_issue <n>`). Absent
`gh_issue` means "not yet synced" — no migration needed. The field name is
provider-specific (`gh_issue` now, `jira` later) so one entry could
eventually carry links into more than one tracker.

## Steps

### Push (register → GitHub) — run unless invoked as `pull`

1. **Read the register.** Glob `.project/features/*.md` and read each
   file's frontmatter (`slug`, `status`, `gh_issue`) and body (first line
   = description, optional `Why:` line). Before any register write in
   this phase, run `.claude/skills/ardd-scripts/project-lock.sh check
   ardd-tracker` — if it warns, surface it to the user (another invocation
   touched `.project/` recently) but proceed regardless; this is
   advisory, never a block. (A legacy single-file features.md means the
   project predates migration 0003 — tell the user to re-run install.sh
   and stop.)

2. **For each entry with no `gh_issue` field:**
   - Before creating anything, search for an issue already carrying this
     slug's marker: `gh issue list --search "ardd-sync-slug-<slug> in:body"
     --state all --json number,body --jq '.[] | "\(.number)\t\(.body)"'`.
     Use a colon/equals-free marker token (`ardd-sync-slug-<slug>`, not
     `ardd-sync:slug=<slug>`) — GitHub search parses `word:word` as a
     `qualifier:value` pair, so a colon inside the term gets silently
     dropped instead of matched literally, which would defeat the dedup
     this search exists for. The marker keeps its historic `ardd-sync-`
     prefix on purpose: it is persisted data in existing issue bodies, and
     a renamed marker would orphan every issue created before the
     ardd-sync→ardd-tracker rename — never "modernize" it.
     Confirmed empirically: a colon-bearing search
     term returned unfiltered generic results instead of zero hits, while
     the hyphenated form returned a clean, correct empty result. GitHub's
     search is lexical, not exact, so a result can be a false positive (a
     similar-but-different slug); pipe the tab-separated output into
     `.claude/skills/ardd-scripts/sync-slug-match.sh <slug>` to get back
     the exact-match issue number, if any. If a match is found, adopt its
     number instead of creating a duplicate. This is what makes push
     idempotent against a run that dies between `gh issue create` and the
     register write — the expected failure mode for something meant
     to run headlessly on a schedule, not an edge case to ignore. Note
     GitHub's search index has a short indexing lag after creation, so a
     re-run within seconds of a create can still race; this is acceptable
     for anything run hourly or less often. Note the scope of what
     `sync-slug-match.sh`'s dedup buys: it handles **crash-retry
     idempotency** (a single run that died between `gh issue create` and the
     register write, re-run later), not **true concurrent-run safety**.
     The `project-lock.sh check` above narrows but doesn't eliminate the
     residual external-system race — two genuinely simultaneous `push` runs
     can still both create a GitHub issue for the same slug before either
     sees the other's. That's a documented, known limitation, not a gap to
     silently paper over.
   - Otherwise create it. If `Status` is `implemented` (e.g. a legacy or
     `/ardd-init`-extracted entry never synced before), create it with no
     status label and close it immediately after (`gh issue close <n>`) —
     `implemented` has no `ardd:*` label, only closed state, and step 2's
     `--label ardd:<status>` below only applies to `backlogged`/`planned`/
     `tasked`: `gh issue create --title "<name>" --body "<description>\n\n<Why
     line, if present>\n\n<!-- ardd-sync-slug-<slug> -->" [--label
     ardd:<status>, omitted when Status is implemented]`.
   - Either way, record the link:
     `ardd-state.sh feature-field <slug> gh_issue <n>`.
   - After this phase's register writes are done, run
     `.claude/skills/ardd-scripts/project-lock.sh touch ardd-tracker`.

3. **For each entry with an existing `gh_issue` field:**
   - Read current state: `gh issue view <n> --json state,labels`.
   - Run `.claude/skills/ardd-scripts/sync-label-decision.sh <status>
     <current-ardd-label-or-none> <open-or-closed>` to decide the action —
     `add ardd:<status>` (no label yet), `swap <old> ardd:<status>` (label
     is behind status), `close` (`Status: implemented` and still open), or
     nothing (already correct). Apply whatever it prints: `gh issue edit <n>
     --add-label <new>` for `add`, `gh issue edit <n> --remove-label <old>
     --add-label <new>` for `swap`, `gh issue close <n>` for `close`.
   - Never edit title or body after creation — a description edited later in
     the register does not propagate. This is a stated limitation, not a
     gap: re-syncing content would blur the field-ownership rule this skill
     depends on.

### Pull (GitHub → register) — run unless invoked as `push`

1. **Import new feature requests.** Before this phase's register writes,
   run `.claude/skills/ardd-scripts/project-lock.sh check ardd-tracker` — if it
   warns, surface it to the user but proceed regardless; advisory, never a
   block. List open issues labeled `ardd-import`
   (`gh issue list --label ardd-import --limit 200
   --json number,title,body`; pass an explicit `--limit` above the CLI's
   default of 30 since an import backlog can exceed it) — this label is
   applied by stakeholders themselves, never inferred, so a stray bug report
   never gets treated as a feature idea. For each:
   - Derive a slug from the title: `ardd-state.sh slug "<title>"`, with
     the same hex-suffix collision handling as `/ardd-backlog` step 2.
   - Create the entry (description from the issue body, stripping any
     `<!-- ardd-sync-slug-... -->` marker from a prior push cycle):
     `printf '%s\n' "<description>" | ardd-state.sh feature-create <slug>`,
     then `ardd-state.sh feature-field <slug> gh_issue <n>`.
   - Swap the issue's label from `ardd-import` to `ardd:backlogged` so it
     isn't re-imported next run.

   Once the imported entries are written, run
   `.claude/skills/ardd-scripts/project-lock.sh touch ardd-tracker`.

2. **Report divergence — do not apply it.** Adoption first: if
   `.project/TRACKER.md` is absent but the legacy `SYNC.md` exists (an
   install predating the v1.0.0 rename), rename it to `TRACKER.md` before
   writing. Then, for every already-linked entry,
   run `.claude/skills/ardd-scripts/sync-divergence.sh <slug> <issue-number>
   <status> <open-or-closed>` — it decides whether current issue state
   diverges from what `status` implies (closed but not `implemented`;
   reopened but `implemented`) and prints the ready-to-use `## Diverged`
   line if so, nothing otherwise. Collect its output into `.project/TRACKER.md`
   — full overwrite every run, mirroring `/ardd-defects`'s `DEFECTS.md`
   pattern, including an explicit all-clear state:

   ```markdown
   # Tracker

   _Last synced: YYYY-MM-DD_

   ## Diverged
   - **Slug:** <slug> — issue #<n> is <closed/open>, the register says `status: <status>`

   (repeat per divergence)
   ```

   or, when nothing diverged:

   ```markdown
   # Tracker

   _Last synced: YYYY-MM-DD_

   No divergence — tracker state matches the register as of this run.
   ```

   This is the one deliberate asymmetry in "vice-versa": pull's only
   write-back into the register is importing new entries (step 1). A
   tracker-side status change is always reported, never applied — `Status`
   transitions belong to the ARDD lifecycle skills
   (`/ardd-plan`/`/ardd-implement`), not to this skill. The
   user reconciles manually or via `/ardd-feedback`.

3. **Report a summary:** issues created, labels updated, issues closed,
   entries imported, and the divergence count from `TRACKER.md` (or "all
   clear").
