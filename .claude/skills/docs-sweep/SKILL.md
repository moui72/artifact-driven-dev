---
name: docs-sweep
description: Source-side only (never installed to consumers). Judges whether this repo's human-facing docs (README.md, USAGE.md, docs/concepts.md, docs/guides/*, docs/install.md, docs/reference/skills/*.md hand-written bodies) still accurately describe each skill's current SKILL.md behavior and each in-scope root-level script's (new.sh, install.sh) current behavior, then triages findings to /ardd-feedback. Usage — /docs-sweep [--all]
---

# Docs sweep

You are checking whether this repo's human-facing documentation still
matches what the skills actually do, and what the root-level entry-point
scripts (`new.sh`, `install.sh`) actually do. This is a judgment task — the
mechanizable slice (do referenced command names exist? are generated
reference-page headers in sync with skill frontmatter?) is already covered
by `scripts/lint-docs.sh` and `scripts/gen-skill-docs.sh --check`; this
skill never re-does that, it looks at prose accuracy and completeness,
which has no script oracle.

## 1. Resolve scope

Default: skills changed since the last stable release tag, plus a parallel
check for the root-level entry-point scripts.

```
git describe --tags --match 'v[0-9]*.[0-9]*.[0-9]*' --abbrev=0 2>/dev/null
git log --oneline <last-stable-tag>..HEAD -- skills/
git log --oneline <last-stable-tag>..HEAD -- new.sh install.sh
```

- If a last-stable tag exists, list the skills whose `skills/<name>/SKILL.md`
  (or `docs/reference/skills/<name>.md`) appears in that log range.
- If no stable tag exists yet (first-ever run, or a fork with no releases),
  fall back to a full sweep of every skill under `skills/` — note in the
  final report why (no stable tag to diff against), don't error out.
- `--all` argument: always do a full sweep of every skill under `skills/`
  regardless of recent changes, ignoring the git-log scoping above.

Local-only skills (this one, `scenario-sweep`) are never in scope for
their own sweep — they have no `docs/reference/skills/` page and no
installed consumer surface to judge freshness against.

**Scripts in scope** is a separate set from skills in scope — a script
isn't a skill, and its ground-truth/doc-target shape differs (see §2b).
`new.sh` and `install.sh` are the only two candidates (root-level,
user-invoked acquisition/install entry points documented in
`docs/install.md`; ordinary files under `scripts/` are internal
automation with no independent human-facing doc page and stay out of
scope). If either appears in the `-- new.sh install.sh` log range,
add it to the scripts-in-scope set. `--all` also forces both scripts into
scope, exactly as it forces every skill into scope. If no stable tag
exists yet, scripts-in-scope falls back to both, same as the skills
fallback.

## 2. Per-skill judgment procedure

For each in-scope skill, in order:

1. Read its `skills/<name>/SKILL.md` in full — this is ground truth for
   current behavior (modes, flags, arguments, handoffs, edge cases).
2. Check whether `docs/reference/skills/<name>.md` exists. If it doesn't
   (a local-only skill has none), skip steps 2b–2c for that skill.
   - Read the hand-written body below its `<!-- generated:end -->`
     marker (the header above it is generated and out of scope here —
     `gen-skill-docs.sh --check` already guards that).
   - Judge: does the body accurately and completely describe the
     skill's current modes/flags/behavior? Note specific gaps — a
     missing mode, a stale claim, a flag that no longer exists, an
     out-of-date example — with a `file:line` citation, never a vague
     "seems stale." An accurate, complete body is a non-finding; don't
     manufacture drift to fill the table.
3. Check `USAGE.md`'s command table/routing section: is the skill (and
   any new mode/flag surfaced in step 1) represented there? `USAGE.md`
   is deliberately selective, not an exhaustive enumeration — apply
   judgment about whether the capability is user-visible/significant
   enough to warrant a mention. An absence is not automatically a gap;
   only flag it when a user would plausibly look for that routing and
   not find it.
4. Check `docs/concepts.md`'s narrative for the same kind of
   representation, with the same "selective by design" caveat as step 3.
5. Spot-check `README.md` for staleness against the current skill
   list/workflow description — this is a spot-check, not a line-by-line
   audit; look for a skill missing from the roster, a renamed skill
   still referenced by an old name, or a workflow description that no
   longer matches the actual lifecycle.

Also check `docs/guides/*` narrative guides for the same kind of
drift when a skill's behavior materially affects one of them (e.g. a
guide that walks through a flow the skill participates in).

## 2b. Per-script judgment procedure

For each in-scope script (`new.sh`, `install.sh`), in order. A script's
ground truth is its own source, not a `SKILL.md` — there's no separate
frontmatter/body split to read.

1. Read the script in full, or at minimum its header comment block and
   its flag-parsing/usage logic (the `while ... case` argument loop,
   any `-h`/`--help`/`usage()` output) — this is ground truth for its
   current flags, arguments, modes, and behavior.
2. Check `docs/install.md`'s coverage of this script for staleness or
   gaps: a flag that exists in code but isn't mentioned, a documented
   behavior that no longer matches, a mode (e.g. `--existing`, a new
   `--harness` value) missing from the writeup. Note specific gaps with
   a `file:line` citation on the script side, never a vague "seems
   stale." An accurate, complete writeup is a non-finding.
3. Check `USAGE.md` and `README.md` for a mention of the script's
   behavior, with the same "selective by design, only flag a
   plausible-lookup miss" caveat as steps 3–4 above — these docs aren't
   exhaustive, so an absence is only a gap when a user would plausibly
   look there and not find it.
4. Check `docs/concepts.md`'s narrative for the same kind of
   representation, same caveat.

## 3. Present findings and triage (do NOT skip straight to /ardd-feedback)

Present one table: `skill/script/file | gap | suggested fix` — same shape as
`scenario-sweep`'s scenario-report triage. Get accept/decline per row
from the user before filing anything.

There is no durable per-run report file for this skill (unlike
`scenario-sweep`'s `dev-notes/scenario-runs/`) — a docs-sweep run is
lighter-weight than a full prerelease dry-run. The only durable output is
whatever `/ardd-feedback` entries result from the triage below.

On accept, run `/ardd-feedback` with the accepted findings consolidated
(this repo dogfoods its own `.project/`) — batch genuinely related
findings into one feedback file, but split unrelated findings (e.g. an
undocumented epic-view gap vs. an unrouted flag) into separate
`/ardd-feedback` invocations/items rather than forcing them into one
artificial batch. Declined and harness-artifact rows never get filed.

Never commit anything yourself during a sweep beyond what `/ardd-feedback`
itself commits as part of its own write.
