---
name: docs-sweep
description: Source-side only (never installed to consumers). Judges whether this repo's human-facing docs (README.md, USAGE.md, docs/concepts.md, docs/guides/*, docs/install.md, docs/reference/skills/*.md hand-written bodies) still accurately describe each skill's current SKILL.md behavior, each in-scope root-level script's (new.sh, install.sh) current behavior, and — via a discovered-not-hardcoded check — whether any new standalone (non-skill-invoked) script has zero doc coverage at all, then triages findings to /ardd-feedback. Usage — /docs-sweep [--all]
---

# Docs sweep

You are checking whether this repo's human-facing documentation still
matches what the skills actually do, what the root-level entry-point
scripts (`new.sh`, `install.sh`) actually do, and whether any new
standalone script has gone entirely undocumented. This is a judgment
task — the mechanizable slice (do referenced command names exist? are
generated reference-page headers in sync with skill frontmatter?) is
already covered by `scripts/lint-docs.sh` and `scripts/gen-skill-docs.sh
--check`; this skill never re-does that, it looks at prose accuracy and
completeness, which has no script oracle. §2c's discovery step runs a
`grep` as part of following this prose, same as §1's `git log`
scope-resolution — that's the agent executing an instruction, not a new
committed automation script.

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
`new.sh` and `install.sh` are the two scripts with an *existing,
established* doc target (`docs/install.md`) and get the full §2b
judgment procedure. If either appears in the `-- new.sh install.sh` log
range, add it to the scripts-in-scope set. `--all` also forces both
scripts into scope, exactly as it forces every skill into scope. If no
stable tag exists yet, scripts-in-scope falls back to both, same as the
skills fallback.

**Standalone-script discovery (§2c)** is a separate, coarser check that
covers the general case `new.sh`/`install.sh` don't: *any* new
non-skill-invoked script going completely undocumented, not just drift
in those two. It isn't hardcoded to a fixed list — a brand-new script
matching the pattern is caught automatically, with no docs-sweep edit
required. See §2c for the discovery procedure.

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

## 2c. Standalone-script discovery (zero-coverage net)

This step catches the general case: a brand-new script that isn't invoked
by any skill's prose and has *no mention anywhere* in the human-facing
docs — the failure mode that let `new.sh --harness codex` almost slip
through, generalized so a future script doesn't need a docs-sweep edit to
be caught. It's a coarse completeness net, not a behavior audit — it
never replaces §2b's deep read for `new.sh`/`install.sh`, and it doesn't
try to judge whether an already-mentioned script's docs are *accurate*,
only whether a new one is mentioned *at all*.

1. Build the known skill-invoked set: grep every `skills/*/SKILL.md` for
   script references —
   ```
   grep -ohE '(scripts/[A-Za-z0-9_.-]+\.sh|\.claude/skills/ardd-scripts/[A-Za-z0-9_.-]+\.sh)' skills/*/SKILL.md | sed 's#.*/##' | sort -u
   ```
   These are already documented by the skill prose that names them
   inline — never treated as candidates here.
2. Build the candidate pool: every root-level `*.sh` plus every
   `scripts/*.sh`, minus the invoked set above, minus anything matching
   `test-*.sh` or `lint-*.sh` (covered by their own CI job + regression
   test — that pairing *is* their documentation), minus `new.sh` and
   `install.sh` (already handled fully by §2b, not re-flagged here).
3. Two more automation channels also count as "documented by its own
   wiring," not a candidate, even though they don't match the
   `test-*`/`lint-*` name pattern — check both before treating a
   remaining candidate as genuinely standalone:
   - referenced directly in a `.github/workflows/*.yml` `run:` step
     (`grep -rohE 'scripts/[A-Za-z0-9_.-]+\.sh' .github/workflows/*.yml`)
     — CI-invoked internal automation, e.g. `next-version.sh`,
     `release-notes.sh`, `smoke-assert.sh`.
   - referenced in `.claude/settings.json`'s hook `command` fields — a
     wired hook, e.g. `hook-lint-on-write.sh`.
   A script that clears all these filters (not skill-invoked, not
   `test-*`/`lint-*`, not CI-workflow-invoked, not hook-wired, not
   `new.sh`/`install.sh`) is a genuine standalone candidate — a script a
   human is expected to run directly with no other automation vouching
   for its documentation. As of this writing that filter empties the
   `scripts/` pool entirely (everything left over turns out to be
   invoked from a workflow or a hook) — the two root-level scripts are
   the only standing members. Don't take that as permanent: the point of
   this step is that a *future* script landing in `scripts/` or at the
   repo root without joining any of those channels gets caught
   automatically, with no docs-sweep edit required.
4. Scope to *new* candidates only, same pattern as skills/§1: `git log
   --oneline --diff-filter=A <last-stable-tag>..HEAD -- '*.sh'
   'scripts/*.sh'`, then re-apply the step 2–3 filters to that added set
   (a script can be added and later become CI/hook-wired within the same
   window — filter after diffing, not before). `--all` widens this to
   every script in the repo, not just ones added since the last stable
   tag. No stable tag yet: same fallback as §1, full pool.
5. For each new standalone candidate, grep `docs/install.md`,
   `README.md`, `USAGE.md`, and `docs/concepts.md` for any mention of its
   filename. Zero hits across all four: flag it in the findings table as
   "new standalone script `<path>` — check for doc coverage" — this is
   deliberately coarse, just "does anything reference this script's
   existence," not a claim about what the doc should say. Any hit at all
   is a non-finding for this step (its *accuracy* is still open to
   ordinary human judgment/a future docs-sweep pass, just not this net).

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
