# artifact-driven-dev (ADD)

A spec-driven workflow system for Claude Code, in the same lineage as
[Spec Kit](https://github.com/github/spec-kit) — but built around capturing
decisions you've already made, rather than discovering them through
structured elicitation. It's disciplined, not lightweight — four-plus
living documents, ~18 skills, several status state machines — so it's worth
knowing where that overhead pays for itself; see
[When artifacts earn their keep](#when-artifacts-earn-their-keep) below.

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
points will become clearer after a few more projects use ADD. Designing them
now would be speculative.

## Credits

ADD was inspired by [Spec Kit](https://github.com/github/spec-kit). If you
need structured requirement discovery, user story generation, or a full
spec-to-implementation pipeline, Spec Kit is the right tool. ADD is
narrower in scope — for when you arrive with architectural clarity and just
need a system to capture, cross-check, and execute against it.

## Philosophy

ADD assumes you arrive with clarity about what you're building and need a
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
  state independent of what the code currently does — though ADD doesn't
  detect the pivot for you: `/ardd-codify` captures the codebase's *current*
  patterns as a starting draft, and you still have to refine artifacts
  toward where you actually want to end up.

Where the codebase already *is* a trustworthy source of truth — mature,
consistent, already following the conventions you want — an agent
pattern-matches off it directly, and ADD's overhead buys you less than a
solid `CLAUDE.md`. Artifacts still have a minor secondary benefit there (the
code shows *how* something works, not *why* it was decided that way), but
that's not enough on its own to justify the process for a codebase that's
already a good implicit spec.

## Artifacts

Four living documents that evolve throughout the project:

| Artifact | Purpose |
|---|---|
| `constitution.md` | Principles, quality standards, governance |
| `infrastructure.md` | Architecture, integrations, storage, sync strategy |
| `datamodel.md` | Canonical schema, field mappings, normalization rules |
| `ui.md` | Views, interactions, display specs, states |

All artifacts live in `.project/artifacts/`. All are refined with `/ardd-refine`.

## Skills

| Command | When |
|---|---|
| `/ardd-bootstrap` | Once — seed artifacts from conversation context |
| `/ardd-codify` | Once — reverse-engineer artifacts from an existing codebase |
| `/ardd-featurize` | Once (after codify) — extract a feature register from the codebase |
| `/ardd-feature <description>` | Log a feature idea to the backlog (`features.md`) — no artifact edits yet |
| `/ardd-sync [push\|pull]` | Anytime — mirror `features.md` to/from an external issue tracker (GitHub Issues now) |
| `/ardd-refine <artifact>` | Anytime — update a named artifact |
| `/ardd-add-artifact <name>` | Anytime — create a new, non-standard artifact from a template |
| `/ardd-analyze` | Before planning — cross-artifact consistency check |
| `/ardd-lint` | Anytime — fast, deterministic check of frontmatter status/fields and `[artifacts: ...]` references (no LLM judgment involved) |
| `/ardd-verify` | Before major planning, or periodically — check artifacts against the actual codebase and record drift in `DEFECTS.md` |
| `/ardd-critique` | Anytime — challenge decisions: simplicity, failure modes, robustness, semantics |
| `/ardd-feedback <notes>` | After manually inspecting the implementation — capture bugs/UX/reconsidered decisions for the next plan |
| `/ardd-research <topic>` | As needed — targeted investigation |
| `/ardd-render <artifact>` | Anytime — generate a Mermaid diagram from an artifact into `README.md` |
| `/ardd-plan [slug ...]` | When artifacts are stable. Pass backlogged feature slug(s) to design, apply their artifact changes, and plan them — any order, whenever you pick them up. Never delegates to a worktree — the draft plan is itself the state `/ardd-tasks` needs to see |
| `/ardd-tasks` | Pick a plan (draft or approved) — selecting a draft one approves it as part of this step. Always runs on the current branch, no worktree gate — its own actions are quick state updates |
| `/ardd-implement` | Execute tasks sequentially. Offers to delegate to a subagent in an isolated worktree; all state rides the work branch and lands on merge |
| `/ardd-converge` | Reconcile codebase with tasks after interruption. Same worktree-delegation offer and state model as `/ardd-implement` |

## Install

```sh
./install.sh /path/to/your/project
```

**New project** — open Claude Code and run `/ardd-bootstrap` to seed artifacts
from your conversation context. See [guides/greenfield.md](guides/greenfield.md).

**Existing project** — open Claude Code and run `/ardd-codify` to
reverse-engineer artifacts from the codebase. Review the generated drafts with
`/ardd-refine`, then run `/ardd-analyze` before planning new work. See
[guides/existing-project.md](guides/existing-project.md).

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
  skills/              # ADD skill files — regenerated by install.sh, gitignore this
```

## Task format

Tasks in a `tasks-*.md` file declare which artifacts they require:

```markdown
- [ ] T001 [artifacts: datamodel, infrastructure] Create Patient table in SQLite
- [ ] T002 [artifacts: datamodel] [parallel] Create Appointment table in SQLite
```

The `/ardd-implement` skill loads only the declared artifacts before executing each
task, keeping context focused.

## Contributing to this repo

This is separate from `## Install` above, which is about installing ADD
*into a target project* — this is about working on ADD's own source. Run
once per clone:

```sh
git config core.hooksPath hooks
```

This enables `hooks/pre-commit`, which runs this repository's own lint/test
scripts before a commit is accepted. Git won't enable a tracked hooks
directory automatically, so this is a one-time, per-clone opt-in, not
something `install.sh` or any hook can do for you.

### Recovering from a rewritten `main`

`main`'s history was rewritten once (2026-07-04) to add commit signatures
retroactively — content is identical, but every commit hash after
`bbc2595` changed. If your local clone or fork still has the old history,
`git pull` will refuse or produce a mess. If you have no local work on
`main`, the simplest fix is to reset to match the remote:

```sh
git fetch origin
git checkout main
git reset --hard origin/main
```

If you have unpushed commits on top of the old `main`, rebase them onto
the new history instead of resetting (which would drop them):

```sh
git fetch origin
git rebase --onto origin/main <old-main-tip> <your-branch>
```

This shouldn't happen again — it was a one-time cleanup, not a normal
practice for this repo.
