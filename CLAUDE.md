# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

artifact-driven-dev (ADD/ARDD) is a Claude Code skill pack, not an application.
The deliverable is the content of `skills/*/SKILL.md` — markdown files that
become slash commands in a *target* project once installed there. There is no
application code, build step, or test suite in the conventional sense; the
"code" is prose instructions an LLM executes, plus a handful of POSIX shell
scripts for the parts that must be deterministic.

Read `README.md` for the philosophy and artifact/skill overview, and
`USAGE.md` for the end-to-end workflow. Both are user-facing docs, not
internal notes — keep them in sync with the skills themselves.

## Commands

```sh
./install.sh /path/to/target/project   # install/upgrade skills into a project
./scripts/lint-docs.sh                 # verify README/USAGE/guides only reference real skill names
./scripts/lint-project.sh [target-dir] # validate a target's .project/ frontmatter + [artifacts: ...] refs (defaults to .)
./scripts/test-lint-project.sh         # regression test for lint-project.sh against tests/fixtures/{good,bad}-project
./scripts/branch-info.sh               # print current/default branch + on_default (used by ardd-plan/implement/converge)
./scripts/test-branch-info.sh          # regression test for branch-info.sh's default-branch fallback chain
./scripts/worktree-info.sh create <slug> [dir] # create/locate a worktree branched from the default branch's tip (used by ardd-implement/converge only — ardd-plan never delegates)
./scripts/test-worktree-info.sh        # regression test for worktree-info.sh (idempotency, branches-from-default-tip)
./scripts/completion-flip-check.sh <tasks-file> # detect an orphaned tasked->implemented flip (branch merged, features.md not updated); used by ardd-analyze
./scripts/test-completion-flip-check.sh # regression test for completion-flip-check.sh
./scripts/hook-lint-on-write.sh        # PostToolUse hook body: lints .project/ writes, wired via .claude/settings.json
./scripts/test-hook-lint-on-write.sh   # regression test for the hook (silent/silent/valid-JSON-findings cases)
./scripts/test-hooks-pre-commit.sh     # regression test for hooks/pre-commit's aggregation/short-circuit logic
git config core.hooksPath hooks        # one-time, per-clone opt-in — enables hooks/pre-commit (see constitution.md)
```

All lint/test scripts run in CI (`.github/workflows/lint.yml`) on
push/PR to `main`. That's the full extent of automation, deliberately — a
skill's *behavior* (does `/ardd-plan` actually draft a good plan?) is not
something these scripts check and isn't a near-term goal; only the
structural/mechanical properties covered above are. When you add a new
deterministic check, add both a CI job and a fixture-based regression test in
the same commit (see `tests/fixtures/`) — don't ship a lint script whose own
correctness is unverified.

## Architecture

**Two install targets, don't conflate them.** Some scripts/docs govern *this*
repo only (`scripts/lint-docs.sh`, its CI job, `tests/fixtures/`,
`scripts/hook-lint-on-write.sh` + `.claude/settings.json` — dogfooding this
repo's own `.project/`). Others are installed by `install.sh` into a
*target* project and run there (every `skills/*/SKILL.md`, the constitution
suggestion catalog, artifact templates, migrations, `scripts/lint-project.sh`,
`scripts/branch-info.sh`, `scripts/worktree-info.sh`,
`scripts/completion-flip-check.sh`). When adding a new deterministic check, decide
which side it belongs to before writing it — a check against *this* repo's
own files (docs, skill names) is source-side; a check against a *target*
project's generated `.project/` state ships via `install.sh`.
`hook-lint-on-write.sh` currently hardcodes `$PROJECT_ROOT/scripts/lint-project.sh`
(the source-repo path), so it isn't installable as-is — wiring an
equivalent hook into target projects via `install.sh` is a separate,
not-yet-made decision, not an oversight.

**`install.sh` is the only entry point into a target project.** It copies
`skills/*/SKILL.md` into `.claude/skills/<name>/`, copies
`templates/constitution-suggestions.md`, `templates/artifacts/*.md`, and
`scripts/lint-project.sh` into non-skill reference directories under
`.claude/skills/` (`ardd-constitution-data`, `ardd-artifact-templates`,
`ardd-scripts` — so the fixed paths those skills expect actually resolve
outside this repo), applies any `migrations/*.sh` not yet recorded in the
target's `.ardd-applied`, and writes `.project/ardd-version.md` recording the
source commit. It also inspects the target's git-tracked files under
`.claude/` to print the right `.gitignore` suggestion — `.claude/skills/` is
regenerated output and should never be committed in a target project;
`.project/ardd-version.md` is the intentional, committed record of which ADD
version produced it. Adding a new non-skill directory under
`.claude/skills/`? Add its name to the `case` allowlist in install.sh's
gitignore-check section too, or it'll be misreported as a tracked
non-ARDD skill.

**Never suggest anything broader than `.claude/skills/ardd-*/` in the
gitignore check — this bit us twice, in our own dogfooding, at two nested
levels of the same mistake.** First: `install.sh` suggested blanket
`.claude/` (correctly, at the time — nothing else was tracked yet), which
would have silently blocked `.claude/settings.json` — real, team-shared
config for the `PostToolUse` lint hook added later — from ever being
tracked without `git add -f`. Fixed by narrowing the default to
`.claude/skills/`. Then, in this repo's own `.gitignore`, that narrower
pattern turned out to have the *identical* problem one level down:
`.claude/skills/` is not entirely ARDD-owned either — only the `ardd-*`
subdirectories are; a hand-written custom skill could live alongside them.
So the default narrowed again, to `.claude/skills/ardd-*/`, which is now
the ceiling — nothing broader should ever be suggested again. Two standing
warnings cover targets that already over-broadly ignore: one checks
whether `.claude/settings.json` would be blocked, the other whether a
synthetic custom-skill path under `.claude/skills/` would be — both fire
independently since a blanket `.claude/` triggers both, while a blanket
`.claude/skills/` alone triggers only the second. If you touch this logic
again: `.claude/skills/ardd-*/` is the correctness floor, and don't drop
either standing warning, since the check otherwise goes silent forever once
anything under `.claude/` is already ignored.

**Four artifacts, refined iteratively, not generated once.**
`constitution.md`, `infrastructure.md`, `datamodel.md`, `ui.md` (plus
`features.md` and optional artifacts like `adapters.md`/`api.md`) live in a
target project's `.project/artifacts/` and are the system's actual state.
Every skill either reads them, refines one of them, or turns them into
plans/tasks/code. `status: draft` / `status: stable` frontmatter gates
whether an artifact is safe to plan against.

**Single-writer ownership of generated files is, deliberately, prose-only —
this is not enforceable by a hook, and that was verified, not assumed.**
- `.project/STATUS.md` — written only by `/ardd-analyze`
- `.project/DEFECTS.md` — written only by `/ardd-verify`
- `.project/SYNC.md` — written only by `/ardd-sync`
- `.project/critique.md` — written only by `/ardd-critique`
- `.project/artifacts/features.md` `Status` field — written only by
  `/ardd-feature`, `/ardd-plan`, `/ardd-tasks`, `/ardd-implement`,
  `/ardd-converge`, `/ardd-sync` (pull step 1 appends new
  `Status: backlogged` entries imported from the tracker), and `/ardd-analyze`
  (one narrow exception: the `tasked→implemented` flip, on user confirmation,
  for an orphaned completion flip its `completion-flip-check.sh` detects —
  see the note below)

Every other skill treats these as read-only. A PreToolUse/PostToolUse hook
cannot enforce this: its payload (`tool_name`, `tool_input`, `transcript_path`,
etc.) carries no field identifying which skill/slash-command is currently
active, and the transcript format is explicitly undocumented and
version-fragile, so it can't be parsed for one either (confirmed against
Claude Code's hook docs, not assumed). The only way around that would be
each skill setting a sentinel before writing its owned file — which
reintroduces the exact LLM-compliance dependency this convention exists to
eliminate, i.e. it isn't real enforcement, just soft convention with extra
steps. So: preserve the boundary explicitly in prose when adding or editing
a skill, same as before, and don't try to "harden" it with a hook — that's
a dead end, not an unfinished task. What a hook *can* do, and does
(`.claude/settings.json`'s `PostToolUse` on `Write|Edit` →
`scripts/hook-lint-on-write.sh`), is catch schema violations in whatever
gets written to `.project/`, regardless of which skill wrote it — that's
real hardening, just a different, narrower guarantee than ownership
enforcement. Don't conflate the two.

**Skill-to-skill handoffs run entirely through files on disk**, not shared
state: frontmatter `status` fields, `[artifacts: ...]` tags on task/feedback
lines, and `plan:` / `features:` frontmatter linking tasks files back to the
plan and feature slugs that produced them. When editing a skill that reads or
writes one of these, check every other skill that touches the same field.

**`scripts/lint-project.sh` is the schema-of-record for frontmatter status
enums and required fields** — not the SKILL.md prose. Enums (five of them:
artifact `status`, `diagram_status`, plan `status`, tasks `status`, feedback
`status`, plus `features.md`'s per-entry `Status`) live in one block at the
top of that script, not scattered through skill prose, precisely so they
don't drift the way `USAGE.md`'s command names once did. If a skill starts
writing a new status value (e.g. tasks' `generating` state), update the enum
in `lint-project.sh` in the same commit — a stale validator that rejects
valid files is worse than no validator, since it trains people to ignore its
output. `/ardd-lint` is the user-facing skill that runs it against the
current project; it never writes, only reports.

**The "check branch" step's deterministic half is a shared script, not
duplicated prose.** `scripts/branch-info.sh` (installed to
`.claude/skills/ardd-scripts/`) computes `current`/`default`/`on_default`;
`ardd-plan`, `ardd-implement`, and `ardd-converge` all shell out to it
instead of re-deriving the current/default-branch fallback chain
(`ardd-tasks` deliberately doesn't — see below). What's still duplicated
across those three, deliberately, is the *interactive* half — suggesting a
semantic name, asking the user, deciding what to do with the answer —
because that requires judgment a script doesn't have; skills can't call
into another skill as a subroutine to share that judgment or get a return
value back, so this residual duplication stays prose. If you touch the
deterministic detection logic, edit `branch-info.sh` (and its regression
test, `test-branch-info.sh`) once; if you touch the interactive framing, all
three skills still need the same edit.

**State-commit-before-branch: coarse state lands on the default branch
immediately, fine-grained work is delegated to a worktree.**
`ardd-implement` and `ardd-converge` are the long-running,
code-producing skills — their branch-gate step defaults to creating a
worktree via `scripts/worktree-info.sh` (sibling to `branch-info.sh`, same
shared-deterministic-half/judgment-stays-in-prose split: it creates or
locates a worktree branched from the default branch's *current tip*,
nothing more) and delegating the substantive work to a subagent (`Agent`
tool, `isolation: "worktree"`).

`ardd-plan` and `ardd-tasks` are both exceptions, for related but distinct
reasons. `ardd-tasks` has no branch-gate step at all — its own actions
(plan approval, `features.md` Status flips) *are* the coarse state update
the other two are trying to get onto the default branch promptly, so
there's nothing to defer behind a worktree. `ardd-plan` *does* have a
branch-gate step (a plain one, offering only a regular branch, never a
worktree) — it deliberately never delegates, even though drafting a plan
for a targeted feature can run just as long as implementing one: the draft
plan file it produces (`.project/plans/plan-*.md`) is itself the artifact
`ardd-tasks` needs to see on the default branch, with no separate coarse
marker to pre-commit the way a tasks file's `ready→in-progress` flip
provides. Delegating it to a worktree would trap that file there until a
manual merge, severing the plan→tasks handoff (`ardd-tasks` globs
`.project/plans/` on whatever branch it's invoked from, not across
worktrees). This was caught and reverted after initially being implemented
the other way — worth remembering if the temptation to "make plan
consistent with implement/converge" comes up again.

For the two skills that *do* delegate, satisfying `worktree-info.sh`'s own
precondition — any state flip is committed to the default branch before
the worktree is created — is a real ordering requirement, not a suggestion:
each reorders its steps so the tasks file is selected and, if this is the
first task in it, flipped `ready→in-progress` and committed *before* the
branch-gate/delegation step runs, so the worktree it creates is branched
from a commit that already carries the flip. `ardd-converge` has no
equivalent flip to pre-commit (its own completed/in-progress outcome isn't
knowable until after the reconciliation work runs), but still picks its
tasks file before the delegation decision, for the same structural reason.

This creates a deliberate split in what happens where:
- **Coarse, cross-cutting state** (`features.md` `Status`, plan/tasks
  frontmatter `status`) is what other sessions, people, or `STATUS.md`
  actually need to see promptly, and is what can conflict across
  concurrently-running worktrees if left to merge timing. It lands on the
  default branch as soon as it changes — before a worktree is even created
  for the substantive work — and, for flips a delegated subagent would
  otherwise perform on completion (`tasked→implemented`), is deliberately
  held until the coordinating conversation confirms (`git merge-base
  --is-ancestor <branch> main`) the worktree's branch has actually merged.
  `features.md` never claims "implemented" before the code has landed. (In
  practice that confirming conversation is often gone by the time a merge
  actually happens, leaving the flip permanently pending — see the
  orphaned-completion-flip note below for how this is caught.)
- **Fine-grained, single-owner state** (a tasks file's own
  `ready→in-progress→completed` transitions, individual task checkboxes) has
  no cross-branch conflict risk — nothing else concurrently edits the same
  tasks file — so it stays immediate, inside the worktree, and reaches the
  default branch the same way the code does: on merge. Syncing every
  checkbox to the default branch in real time would eliminate the isolation
  the worktree exists to provide, for no corresponding benefit.

**Orphaned-completion-flip detection.** `scripts/completion-flip-check.sh`
(sibling to `sibling-tasks-complete.sh`, same purpose-built deterministic
check pattern) is what catches the case above: given a `status: completed`
tasks file, it resolves its plan's `branch:` and `features:` frontmatter,
checks `git merge-base --is-ancestor <branch> <default>`, and — if the
branch has merged but a bound feature is still `Status: tasked` in
`features.md` — reports the slug. `/ardd-analyze` runs it against every
completed tasks file on each invocation (so a session-less gap between
merge and detection is fine — the next `/ardd-analyze` run, from anyone,
catches it) and, on user confirmation, performs the `tasked→implemented`
flip itself. This is a deliberate, narrow exception to `/ardd-analyze`
never writing `features.md` (see the single-writer ownership list above) —
justified because the entire reason this check exists is that no other
skill invocation is left to catch it otherwise.

A coordination check (list in-flight background subagents via the harness's
`TaskList` — not something a POSIX script can wrap, so this stays prose,
per Principle II) runs before `ardd-implement`/`ardd-converge` delegate new
work, warning the user if a prior delegated run against this repo is still
active before starting a second one.

That's a different thing from a skill telling the agent, as its own last
step, to run another skill and stop — a terminal handoff, not a subroutine
call. Most skills that change state `/ardd-analyze` reports on end by
instructing the agent to run `/ardd-analyze` directly, since Claude Code
lets a skill's prose trigger another skill by name. No shared logic and no
value passed back — analyze re-derives everything itself from disk, same as
if the user had typed it. See `/ardd-analyze`'s own SKILL.md for the
canonical list of which skills do this.

## Conventions

- **Commit messages follow Conventional Commits** (`feat:`, `fix:`, `refactor:`,
  `chore:`, `docs:`, etc.) — matches existing repo history.
- **Skill files are the product.** A `SKILL.md` edit is a behavior change to
  every project that runs `install.sh` against this commit — treat it with
  the same care as changing a public API.
- **Shell scripts target POSIX `sh`**, not bash-specific syntax — they're
  installed into arbitrary target projects and `install.sh` itself is
  `#!/usr/bin/env sh`.
