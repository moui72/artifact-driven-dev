# artifact-driven-dev (ARDD)

A spec-driven workflow system for Claude Code, in the same lineage as
[Spec Kit](https://github.com/github/spec-kit) — but built around capturing
decisions you've already made, rather than discovering them through
structured elicitation. It's disciplined, not lightweight — a declared set of
living documents, ~18 skills, several status state machines — so it's worth
knowing where that overhead pays for itself; see
[When artifacts earn their keep](#when-artifacts-earn-their-keep) below.

## Philosophy

ARDD assumes you arrive with clarity about what you're building and need a
system to capture, cross-check, and execute against those decisions — not
one that generates the decisions for you through structured discovery. The
workflow is:

1. **Capture** decisions in living artifacts
2. **Analyze** artifacts for consistency before planning
3. **Plan** once artifacts are stable
4. **Execute** against an ordered task list
5. **Converge** when work is interrupted

## When artifacts earn their keep

An agent working in an existing codebase normally infers conventions by
pattern-matching nearby code — that's usually enough, and a good `CLAUDE.md`
plus direct conversation covers the rest. Artifacts pay for their overhead
specifically when the codebase *can't* serve as that implicit spec:

- **Greenfield** — there's no code yet to pattern-match against. Artifacts
  are the only explicit source of truth until enough code exists to become
  one itself.
- **A major pivot** — the codebase exists, but reflects patterns you're
  actively moving away from. An agent copying it faithfully reproduces
  exactly what you're trying to escape. Artifacts let you declare the target
  state independent of what the code currently does — though ARDD doesn't
  detect the pivot for you: `/ardd-codify` captures the codebase's *current*
  patterns as a starting draft, and you still have to refine artifacts
  toward where you actually want to end up.

Where the codebase already *is* a trustworthy source of truth — mature,
consistent, already following the conventions you want — an agent
pattern-matches off it directly, and ARDD's overhead buys you less than a
solid `CLAUDE.md`. Artifacts still have a minor secondary benefit there (the
code shows *how* something works, not *why* it was decided that way), but
that's not enough on its own to justify the process for a codebase that's
already a good implicit spec.

## Artifacts

A declared set of living documents that evolve throughout the project —
typically a constitution plus whichever concerns your project actually
has. There is no fixed set: `/ardd-bootstrap` proposes artifacts based on
what your project needs (this repo's own dogfooded `.project/` carries
only a constitution), and `/ardd-add-artifact` adds non-standard ones
anytime. The common defaults:

| Artifact | Suggested when |
|---|---|
| `constitution.md` | Nearly always — principles, quality standards, governance |
| `infrastructure.md` | External integrations, sync, or non-trivial storage |
| `datamodel.md` | A canonical schema or normalization rules |
| `ui.md` | A user-facing interface |
| `api.md`, `adapters.md`, ... | A public API surface, external data sources, or any distinct concern |

All artifacts live in `.project/artifacts/`. All are refined with `/ardd-refine`.

## Getting started

Run once (or rarely) to bring a project under ARDD. (This table is
generated from each skill's frontmatter by `scripts/gen-skill-docs.sh` —
edit the `description:` there, then re-run it.)

| Command | What it does |
|---|---|
| `/ardd-setup` | Complete an npx-acquired install — locate or clone the ARDD source checkout and run install.sh from it. |
| `/ardd-bootstrap` | One-time initialization: seed .project/ artifacts from conversation context (greenfield projects). |
| `/ardd-codify` | One-time: reverse-engineer artifacts from an existing codebase (instead of bootstrap). |
| `/ardd-featurize` | One-time (after codify): extract a feature register from an existing codebase. |

## The core loop

The recurring delivery cycle — ideas and observations come in, plans and
shipped code come out. This is the loop a project lives in after setup;
everything else is opt-in. (Generated — see note under Getting started.)

| Command | What it does |
|---|---|
| `/ardd-feature` | Log a feature idea to the per-feature register (.project/features/) — no artifact edits yet. |
| `/ardd-feedback` | Capture bugs/UX/reconsidered decisions from inspecting the implementation, for the next plan to consume. |
| `/ardd-refine` | Update a named artifact — apply new decisions, resolve open questions, handle constitution versioning. |
| `/ardd-plan` | Draft a phased implementation plan from artifacts, feedback, and optionally backlogged features; feedback-file arguments scope which feedback is consumed. |
| `/ardd-tasks` | Generate an ordered task list from a plan; selecting a draft plan approves it. |
| `/ardd-implement` | Execute tasks sequentially; offers worktree delegation, all state rides the work branch and lands on merge. |

`/ardd-analyze` (cross-artifact consistency) runs automatically as the
final step of most state-changing skills, so it isn't a step you have to
remember — run it by hand anytime for a fresh check.

**Opt-in next-step prompt.** With `next_step_prompt: true` in
`constitution.md`'s frontmatter, `/ardd-analyze`, `/ardd-plan`, and
`/ardd-tasks` end by offering their recommended next step as a
one-keypress prompt (yes runs it; no/Esc stops) — only when that
recommendation is a concrete runnable `/ardd-*` invocation. `false` or an
absent field keeps recommendations as plain text, so delegated and
scripted runs are unaffected. `/ardd-bootstrap` asks the question once at
setup; `/ardd-update` asks it once for existing installs whose
constitution lacks the field. Like `workflow_mode`, it's a frontmatter
workflow field — setting it never bumps the constitution version.

## Extensions

Opt-in skills for concerns the core loop doesn't force on you.
(Generated — see note under Getting started.)

| Command | What it does |
|---|---|
| `/ardd-analyze` | Cross-artifact consistency check; writes STATUS.md (its single writer). Auto-runs after most state-changing skills. |
| `/ardd-lint` | Fast, deterministic check of .project/ frontmatter schemas and [artifacts: ...] references — no LLM judgment. |
| `/ardd-verify` | Check artifacts against the actual codebase and record drift in DEFECTS.md (its single writer). |
| `/ardd-critique` | Challenge artifact decisions: simplicity, failure modes, robustness, semantics. |
| `/ardd-converge` | Reconcile the codebase with a tasks file after an interruption; same delegation and state model as implement. |
| `/ardd-research` | Targeted investigation written to .project/plans/ — one-off output with no lifecycle. |
| `/ardd-render` | Generate a Mermaid diagram from a renderable artifact and upsert it into README.md. |
| `/ardd-sync` | Mirror the feature register to/from an external issue tracker (GitHub Issues today). |
| `/ardd-update` | Update this project's ARDD install from its recorded source checkout — check standing, offer a source pull, re-run install.sh, and relay its output. |
| `/ardd-add-artifact` | Create a new, non-standard artifact from a template. |

## Install

From a clone of this repo:

```sh
./install.sh /path/to/your/project
```

Or without cloning first, via the [vercel-labs skills CLI](https://github.com/vercel-labs/skills):

```sh
cd /path/to/your/project
npx skills add moui72/artifact-driven-dev   # choose COPY mode, not symlink
```

then open Claude Code and run `/ardd-setup`. The npx path is an
*acquisition* channel only — it delivers the skill files, and
`/ardd-setup` completes the install by locating (or cloning) the source
and running `install.sh` from it. `install.sh` is the only real
install/upgrade entry point either way; after `/ardd-setup` runs once,
both paths are indistinguishable and `/ardd-update` handles updates.
Avoid the CLI's symlink mode: `install.sh` regenerates
`.claude/skills/`, and symlinks there would point regeneration into the
CLI's cache (install.sh replaces any it finds, with a warning).

**New project** — open Claude Code and run `/ardd-bootstrap` to seed artifacts
from your conversation context. See [guides/greenfield.md](guides/greenfield.md).

**Existing project** — open Claude Code and run `/ardd-codify` to
reverse-engineer artifacts from the codebase. Review the generated drafts with
`/ardd-refine`, then run `/ardd-analyze` before planning new work. See
[guides/existing-project.md](guides/existing-project.md).

**Established project** — already set up and shipping? The steady-state
loop (features, feedback, targeted plans) is
[guides/continuing.md](guides/continuing.md).

**Updating** — from inside a consuming repo, run `/ardd-update`: it finds
the source checkout recorded at install time, re-runs `install.sh`, and
relays migrations and suggestions. `/ardd-analyze` tells you when an
update is available.

**Gitignore the skill files** in the target project. They're regenerated
output — re-running `install.sh` overwrites them from whatever commit of
this repo you point it at, so committing them just means merge conflicts
with no real content. `install.sh` writes `.project/ardd-version.md` on
every run recording the source commit and date — commit *that* instead, so
the project's own history shows which ARDD version was active at any point
without vendoring the skill files themselves.

If `git` sees the skills as untracked or already committed, `install.sh`
suggests adding `.claude/skills/ardd-*/` to `.gitignore` — never anything
broader (`.claude/`, or even `.claude/skills/`), since both can also hold
real, team-shared content ARDD doesn't own: `.claude/settings.json`,
`agents/`, `commands/`, hooks, or a hand-written custom skill living
alongside ARDD's own under `.claude/skills/`. A broader pattern silently
blocks tracking any of that later — git refuses to `add` an ignored path
without `-f`.

If the `ardd-*` skills were already committed, it also prints the
`git rm -r --cached` command to untrack them. If `.claude/skills/ardd-*/`
is *already* gitignored but the actual pattern is broader than that (a
blanket `.claude/` or `.claude/skills/`), it warns about the specific real
content that pattern would also block, since that check would otherwise go
silent forever once anything is already ignored.

## Project structure created

```
.project/
  artifacts/           # living decision documents
  plans/               # generated plans and research
  tasks/               # tasks-<slug>-<hex>.md — the execution queue, one per plan run
  ardd-version.md      # commit this — records which ARDD source commit is installed
.claude/
  skills/              # ARDD skill files — regenerated by install.sh, gitignore this
```

## If worktree delegation misbehaves

`/ardd-implement` and `/ardd-converge` offer to delegate execution to a
subagent in an isolated git worktree. That path depends on harness
worktree behavior (`worktree.baseRef`) that has regressed in both
directions across versions — `worktree-align.sh` compensates, and a
subagent that can't align refuses to work rather than working on the
wrong base. If delegation ever misbehaves anyway, the blessed fallback
is simply **a plain branch, inline**: decline the delegation offer, run
`git checkout -b <name>`, and let the same skill execute inline — all
state rides that branch identically and lands on merge. A harness
regression degrades the workflow to ordinary branching; it never blocks
it.

## Concurrency and `.project/` merge conflicts

ARDD's concurrency guard (`project-lock.sh`, used by the state-writing skills)
is a warn-only marker with **no visibility across `git worktree` checkouts** —
its lock file lives inside each worktree's own `.project/`, so two worktrees
of the same repo won't see each other's runs. Treat it as insurance against
two sessions sharing one checkout, not as cross-worktree locking.

When `.project/` files conflict on merge:

- **Single-writer report files** (`STATUS.md`, `DEFECTS.md`, `SYNC.md`,
  `critique.md`) — disposable: take either side without deliberation
  (never hand-reconcile or re-apply changes across a rebase) and re-run
  the owning skill (`/ardd-analyze`, `/ardd-verify`, `/ardd-sync`,
  `/ardd-critique` respectively); it regenerates the file from current
  state, so which side you kept doesn't matter. Conflict markers in a
  generated report are noise, not data loss.
- **`.project/features/`** — per-feature files, so two independently-added
  features can't conflict at all; a conflict inside one file means the same
  feature was advanced on two branches — take the further-along status,
  then run `/ardd-lint` to confirm the frontmatter and cross-references
  still validate.

## Task format

Tasks in a `tasks-*.md` file declare which artifacts they require:

```markdown
- [ ] T001 [artifacts: datamodel, infrastructure] Create Patient table in SQLite
- [ ] T002 [artifacts: datamodel] [parallel] Create Appointment table in SQLite
```

The `/ardd-implement` skill loads only the declared artifacts before executing each
task, keeping context focused.

## Contributing to this repo

This is separate from `## Install` above, which is about installing ARDD
*into a target project* — this is about working on ARDD's own source. Run
once per clone:

```sh
git config core.hooksPath hooks
```

This enables `hooks/pre-commit`, which runs this repository's own lint/test
scripts before a commit is accepted. Git won't enable a tracked hooks
directory automatically, so this is a one-time, per-clone opt-in, not
something `install.sh` or any hook can do for you.

(One-time history note: `main` was rewritten once on 2026-07-04 to add
commit signatures — recovery steps preserved in
`docs/decisions/0003-rewritten-main-recovery.md`.)

## Credits

ARDD was inspired by [Spec Kit](https://github.com/github/spec-kit). If you
need structured requirement discovery, user story generation, or a full
spec-to-implementation pipeline, Spec Kit is the right tool. ARDD is
narrower in scope — for when you arrive with architectural clarity and just
need a system to capture, cross-check, and execute against it.

## Future directions

`/ardd-analyze` now runs automatically as the final step of most skills that
change state it reports on — see the list in `/ardd-analyze`'s own SKILL.md,
which is canonical. Each skill's own prose tells the agent to invoke it,
since Claude Code lets a skill's instructions trigger another skill
directly. That doesn't need a hooks
system; it only reaches the skills that already end with "now run
`/ardd-analyze`" written into them.

A real hooks system (pre/post skill execution, similar to spec-kit's
extension model) is still the more general next step — it would enable
triggering *arbitrary* validation around *any* skill, including ones this
repo hasn't anticipated, without editing that skill's prose. The right hook
points will become clearer after a few more projects use ARDD. Designing them
now would be speculative.

