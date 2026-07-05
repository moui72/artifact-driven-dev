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
./scripts/completion-flip-check.sh <tasks-file> # detect an orphaned tasked->implemented flip (branch merged, features.md not updated); used by ardd-analyze
./scripts/test-completion-flip-check.sh # regression test for completion-flip-check.sh
./scripts/worktree-align.sh [ref]      # ff-merge local default branch into a fresh delegated worktree; a delegated subagent's mandatory first act
./scripts/test-worktree-align.sh       # regression test for worktree-align.sh
./scripts/inflight-worktrees.sh        # enumerate other worktrees + their tasks-file state (solo mode's in-flight visibility channel)
./scripts/test-inflight-worktrees.sh   # regression test for inflight-worktrees.sh
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
`scripts/branch-info.sh`, `scripts/completion-flip-check.sh`). When adding a new deterministic check, decide
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
source commit. It also ensures the target's `.worktreeinclude` contains
`.claude/skills/ardd-*/` (creating the file or idempotently appending) so
Claude Code copies the installed, gitignored ardd files into every new
worktree — without this, a delegated subagent's worktree contains none of
the ardd scripts its steps call. The gitignore check's ceiling rule applies
here too: never a pattern broader than `.claude/skills/ardd-*/`. It also inspects the target's git-tracked files under
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

**Worktree-native state: every piece of state a run produces — the tasks
file's `ready→in-progress→completed` flips, checkboxes, and the
`tasked→implemented` flip in `features.md` — rides the branch the work
happens on, and merge is the single atomic event that lands code and state
together.** This replaced an earlier "state-commit-before-branch" design
(coarse state pre-committed to the default branch before delegating) after
a live smoke test found its premise didn't hold — see bug #3 below.
The default branch now means *merged truth*; worktrees mean *in-flight
truth*; and two installed scripts bridge them:

- `scripts/worktree-align.sh` — run as a delegated subagent's mandatory
  first act. `Agent`'s `isolation: "worktree"` branches from
  `origin/<default>` (harness `worktree.baseRef: fresh` default — not
  steerable from skill prose, and the setting has regressed in *both*
  directions across harness versions, so it must never be trusted either
  way). But git worktrees share the repo's object store and local branch
  refs, so unpushed local commits are still reachable: the script
  fast-forward-merges the local default branch into the fresh worktree
  branch, refusing (`aligned=false`, `reason=diverged|dirty|...`) rather
  than resolving anything non-trivial. A subagent that doesn't see
  `aligned=true` must stop and report, never work unaligned. The worktree
  normally has its own copy — `install.sh` ensures the target's
  `.worktreeinclude` contains `.claude/skills/ardd-*/`, so Claude Code
  copies the installed (gitignored) ardd files into every new worktree —
  but the coordinator always passes its copy's absolute path as fallback:
  `.worktreeinclude` is skipped under a `WorktreeCreate` hook, older
  installs predate it, and a worktree's base commit may predate the
  scripts. Live-validated 2026-07-05: a real `Agent` worktree based well
  behind local state (`origin/main`) fast-forwarded cleanly onto an
  unpushed local commit; the `core.bare` corruption (bug #3) did not
  reproduce on that run, but the coordinator's post-delegation check
  stays.
- `scripts/inflight-worktrees.sh` — enumerates every *other* worktree of
  the repo and its tasks-file state (branch, status, checkbox progress).
  This is solo mode's coarse-state visibility channel: `ardd-implement`/
  `ardd-converge` run it before the pick list (so a second run can start
  safely while another is in flight) and before delegating (it replaced the
  old harness-`TaskList` coordination check — deterministic, scriptable,
  and it survives conversation death, since an abandoned subagent's
  worktree is still on disk when no conversation remembers it), and
  `/ardd-analyze` sources `STATUS.md`'s "In Flight" section from it.

A consequence worth stating: an abandoned worktree never poisons the
default branch — main keeps saying `ready`/`tasked`, which becomes accurate
again the moment the worktree is deleted. There is no `worktree_branch:`
bookkeeping, no post-merge held-flip step, and no "delegated subagent must
not touch features.md" rule anymore: the subagent *does* flip `features.md`
at completion, in its worktree, precisely because the flip cannot escape to
the default branch before the code does. After a delegated run reports
back, the coordinator checks the primary checkout for the `core.bare = true`
side effect (bug #3 below) and offers an eager merge into the default
branch — eager merge is what keeps solo mode's in-flight window short.

**Two operating modes**, declared as `workflow_mode: solo | collaborative`
in `constitution.md` frontmatter (absent = `solo`; enum enforced by
`lint-project.sh`; asked once by `/ardd-bootstrap`, detection-suggested):
- **solo** — single developer, same machine. Direct commits to the local
  default branch are fine for inline runs; delegated runs use worktrees and
  merge eagerly on completion. Visibility = `inflight-worktrees.sh`.
- **collaborative** — nothing may be committed to the *local* default
  branch, ever (branch protection makes it unlandable anyway). Work always
  moves to a branch; after the first commit the skill offers to push and
  open a *draft PR* titled with the feature slug(s) — the pushed draft PR
  is this mode's in-flight visibility channel (`gh pr list --draft`). The
  `features.md` flip rides the branch and lands when the PR merges. Never
  push without user confirmation (commits may be unsigned when 1Password is
  locked). One extra constraint: a delegated worktree branches from
  `origin/<default>`, so plan/tasks files must have reached the remote
  before delegated implementation can see them — `/ardd-plan` carries a
  note about this; solo mode doesn't need one because `worktree-align.sh`
  carries unpushed local commits in.

There is no custom script for the worktree-creation part itself: a
hand-built `worktree-info.sh` was tried first and removed (see below) after
turning out to duplicate what the tool already does, incompatibly —
Constitution Principle VIII exists precisely to catch this before it's
built, not just after.

`ardd-plan` and `ardd-tasks` are both exceptions, for related but distinct
reasons. `ardd-tasks` has no branch-gate step at all — its own actions
(plan approval, `features.md` Status flips) are quick state updates with no
long-running work to isolate. `ardd-plan` *does* have a branch-gate step (a
plain one, offering only a regular branch, never a worktree) — it
deliberately never delegates, even though drafting a plan for a targeted
feature can run just as long as implementing one: the draft plan file it
produces (`.project/plans/plan-*.md`) is itself the artifact `ardd-tasks`
needs to see. Delegating it to a worktree would trap that file there until
a manual merge, severing the plan→tasks handoff (`ardd-tasks` globs
`.project/plans/` on whatever branch it's invoked from, not across
worktrees). This was caught and reverted after initially being implemented
the other way — worth remembering if the temptation to "make plan
consistent with implement/converge" comes up again.

`isolation: "worktree"` creates and names its own worktree/branch — there
is no parameter to point it at a pre-made one, and the branch name is only
known from what the subagent's result reports back, never chosen up front.
This is why the delegation step doesn't offer to name the worktree the way
it does for a plain `git checkout -b`. Nothing needs to *record* that
branch name anymore either — under worktree-native state there is no
post-merge step that must find it later; the branch merges or it doesn't,
and `inflight-worktrees.sh` sees it on disk either way.

Getting the branch-identity question wrong has produced three real bugs
already, all worth remembering if this area is touched again (bugs #1 and
#2 describe machinery — `worktree_branch:` persistence, a post-merge
held-flip step — that worktree-native state has since removed entirely;
they're kept because they document *why* in-memory branch names and
wrong-branch ancestry checks are traps, which still applies):
1. An earlier version called a separate script (`worktree-info.sh`) to
   make one branch, delegated via `Agent` (which silently made a
   *different* one), then checked merge-ancestry against the first, empty
   branch — which trivially reported "merged" and flipped `features.md` to
   `implemented` while the real code sat unmerged elsewhere. Fixed by
   removing the separate script and using the `Agent`-reported branch
   directly (see the worktree-info.sh removal note above).
2. Even after that fix, the *fallback* detector
   (`completion-flip-check.sh`, for when the coordinating conversation is
   long gone by the time of merge) kept reading the *plan's* `branch:`
   field — unrelated to the ephemeral worktree branch — so it silently
   never caught the case it exists for. Fixed by persisting
   `worktree_branch:` to the tasks file (this note) and having
   `completion-flip-check.sh` read that field first, falling back to the
   plan's `branch:` only for the non-delegated/inline case.
3. **The bug that killed state-commit-before-branch.** A live smoke test
   (committing a throwaway plan+tasks file, then delegating via `Agent`
   with `isolation: "worktree"` and inspecting the result directly, rather
   than reasoning about it) found that the resulting worktree's branch had
   a merge-base with `origin/main`, not with the branch the coordinating
   session was actually on — it never saw either pre-delegation commit.
   This traces to the harness's own `worktree` isolation branching from
   `origin/<default-branch>` (setting `worktree.baseRef`, default `fresh`;
   `head` branches from local HEAD instead) — not something a `SKILL.md`'s
   prose can override, since the `Agent` tool exposes no parameter for it,
   and per the harness issue tracker the setting has regressed in both
   directions across versions, so neither value can be relied on. The fix
   is `worktree-align.sh` (above): instead of assuming anything about the
   base, the subagent deterministically fast-forwards the local default
   branch in as its first act and refuses to proceed if it can't.
   Separately, the same live test surfaced that creating the `Agent`-tool
   worktree flipped this repo's own `.git/config` to `core.bare = true`,
   breaking ordinary work-tree git commands in the primary checkout until
   manually reverted (`git config core.bare false`) — which is why the
   coordinator checks for exactly that after every delegated run.

**Orphaned-completion-flip detection (legacy safety net).**
`scripts/completion-flip-check.sh` (sibling to `sibling-tasks-complete.sh`,
same purpose-built deterministic check pattern) catches a failure mode the
old design produced and worktree-native state shouldn't: a
`status: completed` tasks file whose work-branch has merged into the
default branch while a bound feature still says `Status: tasked` in
`features.md`. Under the current design the flip rides the branch, so a
merged branch normally carries its own flip — but the check stays wired
because it's cheap and still catches a delegated run that crashed between
its `→completed` flip and its `features.md` flip, plus any tasks files
written under the old design. Mechanics: it reads the tasks file's
`worktree_branch:` frontmatter if present (a field only old-design files
have — nothing writes it anymore), falling back to the plan's `branch:`
field (the inline case), checks `git merge-base --is-ancestor <branch>
<default>`, and reports any still-`tasked` slug from the plan's
`features:` list. `/ardd-analyze` runs it against every completed tasks
file on each invocation and, on user confirmation, performs the
`tasked→implemented` flip itself. This is a deliberate, narrow exception
to `/ardd-analyze` never writing `features.md` (see the single-writer
ownership list above) — justified because no other skill invocation is
left to catch it otherwise.

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
