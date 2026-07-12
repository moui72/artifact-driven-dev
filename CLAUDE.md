# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

artifact-driven-dev (ARDD) is a Claude Code skill pack, not an application.
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
./new.sh [--kickoff|--no-kickoff] [--source <path>] <target-dir>  # quickstart: create a new project, install, offer /ardd-bootstrap
./scripts/test-new.sh                  # regression test for new.sh (hermetic — pins $ARDD_SOURCE, never clones)
./scripts/release.sh [--dry-run] <vX.Y.Z> # cut a release: validate (clean/on-default/suite green), SSH-signed tag, push, gh release
./scripts/test-release.sh              # regression test for release.sh's refusal logic (fixture repos; network steps untested by design)
./scripts/source-resolve.sh [path]     # resolve a Source-Path to the release channel: fetch ~/.ardd/source, checkout latest semver tag; other paths = channel=dev, never mutated
./scripts/test-source-resolve.sh       # regression test for source-resolve.sh (local fixture remotes; pins v:refname ordering)
./scripts/lint-docs.sh                 # verify README/USAGE/guides only reference real skill names
./scripts/lint-project.sh [target-dir] # validate a target's .project/ frontmatter + [artifacts: ...] refs (defaults to .)
./scripts/test-lint-project.sh         # regression test for lint-project.sh against tests/fixtures/{good,bad}-project
./scripts/branch-info.sh               # print current/default branch + on_default (used by ardd-plan/implement)
./scripts/test-branch-info.sh          # regression test for branch-info.sh's default-branch fallback chain
./scripts/completion-flip-check.sh <tasks-file> # detect an orphaned tasked->implemented flip (branch merged, register not flipped); used by ardd-status
./scripts/test-completion-flip-check.sh # regression test for completion-flip-check.sh
./scripts/worktree-align.sh [ref]      # ff-merge local default branch into a fresh delegated worktree; a delegated subagent's mandatory first act
./scripts/test-worktree-align.sh       # regression test for worktree-align.sh
./scripts/fold-to-main.sh [default]    # ff-fold current feature branch into local default + checkout it; the eager-background gate's prep step (ardd-implement)
./scripts/test-fold-to-main.sh         # regression test for fold-to-main.sh
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

## Working in this repo: the primary checkout stays on `main`

> **Slated for retirement (plan-remote-install-source, Phase 6).** The
> release channel below removes this section's reason to exist: once the
> first release is cut and all consumers are repointed to resolve tagged
> releases via `~/.ardd/source`, no consumer reads this checkout live and
> the mandate becomes unnecessary. Until that amendment actually lands, it
> remains **fully binding** — including for the implementation work of that
> very plan.

This repo is the local *source* other projects install and update from
(constitution, Project Scope & Intent — standing decision, 2026-07-11). A
consumer's `install.sh`/`/ardd-update` reads *this* checkout and installs
from whatever branch is out, so a feature branch checked out in the primary
directory serves unmerged, possibly-broken skills to every consumer that
updates while it's out — and can trigger a consumer's update flow to
re-checkout `main` under your in-flight work (a real ref-lock collision hit
this on 2026-07-11). So **when a skill offers a
branch gate here (e.g. `/ardd-implement`'s — solo-mode `/ardd-plan` no
longer has one and its quick plan/tasks/state commits to `main` are fine),
do not take the inline `git checkout -b` option.** Instead
`git worktree add <path> -b <branch>` and work there — populate that
worktree's `.claude/skills/` from the primary first, since that dir is
gitignored and `git worktree add` won't carry it — or use the skills'
`isolation: "worktree"` delegation. Merge the branch back to `main` when
done; the primary stays parked on `main` throughout. Recovery if the primary
is ever found off `main`: `git checkout main` — unmerged work is safe on its
own branch/worktree. (This binds *this* source repo only; the inline
branch-gate path is fine in ordinary target projects.)

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

**`new.sh` is source-side, and acquisition-only.** It is fetched and run
outside any checkout (`curl … | sh`), never installed into a target — so
under the source/target split it is source-side, classified by what it
governs (acquiring the source), not by where its output lands. It resolves a
source checkout and then *invokes* that checkout's `install.sh`; it never
reimplements any part of it, and must never grow a bridge skill — it calls
the installer directly. (The `npx skills add` channel and its `/ardd-setup`
bridge were removed 2026-07-11; a plain clone and `new.sh` are the two
acquisition routes now, both converging directly on `install.sh`.)

Three rules to preserve when editing it (constitution). It **refuses
rather than asks** wherever writing into a directory it doesn't own is at
stake — a non-empty target in new-project mode, a `--source` that isn't an
ARDD checkout. (Its `--existing` mode deliberately *accepts* a populated
target: the explicit flag is the consent new-project mode withholds by
default, so that guard is inverted, not removed.) It
**never blocks on a question it cannot ask** — no usable `/dev/tty` means
take the safe default, never hang a pipeline. And it only ever clones or
pulls the checkout it owns at `~/.ardd/source`; a checkout named via
`--source` or `$ARDD_SOURCE` belongs to the user and is read, never mutated
(that last rule is also what makes `scripts/test-new.sh` hermetic).

It *does* prompt, once: the Claude Code handoff is offered on `/dev/tty`,
with `--kickoff`/`--no-kickoff` to answer in advance. An earlier constitution
revision (v1.2.3) claimed it "must never prompt" *because* `curl | sh` hands
it a pipe on stdin — an unsound inference, since a `read` can name `/dev/tty`
explicitly rather than take whatever stdin holds. Don't
reintroduce the absolute. Three traps that cost real debugging: `[ -r /dev/tty ]`
tests permission bits and passes on a CI runner with no controlling terminal
(where the open then fails with `ENXIO`), so use a real open — `tty_ok()`;
every branch that decides whether to reach the `read` must be covered by
a timeout guard in the test, or a regression stalls CI instead of failing it;
and the `read` prompt's `/dev/tty` discipline must **not** be extended to the
`exec`, which has the opposite requirement. Claude Code uses `process.stdin`
only when `stdin.isTTY && stdout.isTTY`, and otherwise opens `/dev/tty` `r+`
itself. So `exec claude … < /dev/tty` hands it a *read-only* fd that passes
that check: the TUI paints and then silently ignores every keystroke (`<>
/dev/tty` makes it exit instead). An EOF'd pipe on stdin is what it handles
correctly — `launch()` must leave stdin alone. No tty exists in CI to catch
this, so `test-new.sh` case 14 guards the source line statically.

**GitHub releases are the stable install channel; a live checkout is
explicit dev-mode** (constitution standing decision, 2026-07-12). Consumers
install from the latest semver tag, resolved through `~/.ardd/source` — the
one checkout the tooling owns and may mutate. The pieces: `scripts/release.sh`
cuts a release (validate → SSH-signed annotated tag → push → `gh release`;
refusals fixture-tested, the network block thin and untested by design);
`scripts/source-resolve.sh` (installed to `ardd-scripts`) resolves a recorded
`Source-Path` — owned checkout: fetch tags offline-tolerantly and check out
the latest strict-`vX.Y.Z` tag via `git tag --sort=v:refname` (ordering
pinned by fixture tests, incl. v1.10.0 > v1.9.0 — no hand-rolled compare
needed); any other existing checkout: `channel=dev`, read and never mutated.
`new.sh` duplicates that selection rule minimally (it runs with no checkout
to source scripts from); `ardd-update-check.sh`'s `behind` means "not the
latest release's commit" (no tags yet → tip comparison, `note=no-releases`);
`install.sh` records `Source-Ref: <tag>` when the source HEAD sits exactly at
a release tag. Dev-mode (`--source`/`$ARDD_SOURCE`, or a `Source-Path`
naming a live checkout) is the deliberate escape hatch for the
edit-a-skill, test-it-in-a-consumer loop — `/ardd-update` warns and asks
before proceeding on it. There is no tip-of-main channel (Principle VI).
Cutting a release is the act that publishes skill changes to consumers;
merging to `main` alone no longer does.

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
`.project/ardd-version.md` is the intentional, committed record of which ARDD
version produced it. Adding a new non-skill directory under
`.claude/skills/`? Add its name to the `case` allowlist in install.sh's
gitignore-check section too, or it'll be misreported as a tracked
non-ARDD skill.

**Never suggest anything broader than `.claude/skills/ardd-*/` in the
gitignore check — that pattern is the permanent ceiling (Constitution
Principle III).** Broader patterns (`.claude/`, `.claude/skills/`)
silently block tracking real content (`settings.json`, a hand-written
custom skill) and each was tried and burned once — full story in
`docs/decisions/0002-gitignore-ceiling.md`. install.sh carries two
standing warnings for targets that already over-broadly ignore; don't
drop either, or the check goes silent forever.

**A declared artifact set, refined iteratively, not generated once.**
Artifacts (`constitution.md` nearly always, plus
`infrastructure.md`/`datamodel.md`/`ui.md`/`api.md`/`adapters.md`/...
as the project's concerns warrant) live in a target project's
`.project/artifacts/` and are the system's actual state; the feature
register is per-feature files in `.project/features/` (constitution
standing decision, 2026-07-06). Every skill either reads them, refines
one of them, or turns them into plans/tasks/code. `status: draft` /
`status: stable` frontmatter gates whether an artifact is safe to plan
against.

**Single-writer ownership of generated files is, deliberately, prose-only —
this is not enforceable by a hook, and that was verified, not assumed.**
- `.project/STATUS.md` — written only by `/ardd-status`
- `.project/DEFECTS.md` — written only by `/ardd-defects`
- `.project/TRACKER.md` — written only by `/ardd-tracker`
- `.project/audit.md` — written only by `/ardd-audit`
- `.project/features/*.md` `status` field — mutated only via
  `ardd-state.sh feature-*` subcommands, invoked by `/ardd-backlog`,
  `/ardd-plan` (both the `backlogged→planned` approval flip and the
  `planned→tasked` flip, now that tasking is folded in), `/ardd-implement`,
  `/ardd-tracker` (pull imports new `backlogged` entries), and
  `/ardd-status` (one narrow exception: the `tasked→implemented` flip,
  on user confirmation, for an orphaned completion flip its
  `completion-flip-check.sh` detects — see the note below)

Every other skill treats these as read-only. At merge/rebase these files
are **disposable**: take either side without deliberation — never
hand-reconcile, never re-apply — and let the owning skill regenerate
from disk (full treatment: README's "Concurrency and `.project/` merge
conflicts" section). A PreToolUse/PostToolUse hook
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
enums and required fields** — not the SKILL.md prose. Enums (six of them:
artifact `status`, `diagram_status`, plan `status`, tasks `status`, feedback
`status`, plus the per-feature register's `status`) live in one block at the
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
`ardd-plan` and `ardd-implement` both shell out to it
instead of re-deriving the current/default-branch fallback chain. What's still duplicated
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
`tasked→implemented` flip in the register — rides the branch the work
happens on, and merge is the single atomic event that lands code and state
together.** (Why the earlier "state-commit-before-branch" design
died: `docs/decisions/0001-branch-identity-and-worktree-native-state.md`.)
The default branch now means *merged truth*; worktrees mean *in-flight
truth*; and three installed scripts bridge them:

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
  scripts. (Live-validated; see decision record 0001.)
- `scripts/fold-to-main.sh` — the counterpart to `worktree-align.sh` for the
  *eager-background* path. Because a delegated worktree branches from
  `<default>` and align only fast-forwards local `<default>` in, a run that's
  already on a feature branch can't be backgrounded until its state reaches
  local `<default>`. This script fast-forward-folds the current branch into
  the local default branch and checks it out (returning the focused session
  to `<default>`), refusing (`folded=false reason=dirty|detached|diverged|...`)
  rather than resolving — same discipline as align. The delegation gate in
  `ardd-implement` runs it when the user opts to background
  while on a branch. A fast-forward authors no new commit, so the
  "no state-commit before the branch" invariant holds. (Decision record
  0004; supersedes the old "on a branch → run inline" default.)
- `scripts/inflight-worktrees.sh` — enumerates every *other* worktree of
  the repo and its tasks-file state (branch, status, checkbox progress).
  This is solo mode's coarse-state visibility channel: `ardd-implement` runs it before the pick list (so a second run can start
  safely while another is in flight) and before delegating (it replaced the
  old harness-`TaskList` coordination check — deterministic, scriptable,
  and it survives conversation death, since an abandoned subagent's
  worktree is still on disk when no conversation remembers it), and
  `/ardd-status` sources `STATUS.md`'s "In Flight" section from it.

A consequence worth stating: an abandoned worktree never poisons the
default branch — main keeps saying `ready`/`tasked`, which becomes accurate
again the moment the worktree is deleted. There is no `worktree_branch:`
bookkeeping, no post-merge held-flip step, and no "delegated subagent must
not touch the register" rule anymore: the subagent *does* flip it
at completion, in its worktree, precisely because the flip cannot escape to
the default branch before the code does. After a delegated run reports
back, the coordinator checks the primary checkout for the `core.bare = true`
side effect (decision record 0001) and offers an eager merge into the default
branch — eager merge is what keeps solo mode's in-flight window short.

**Two operating modes**, declared as `workflow_mode: solo | collaborative`
in `constitution.md` frontmatter (absent = `solo`; enum enforced by
`lint-project.sh`; asked once by `/ardd-bootstrap`, detection-suggested):
- **solo** — single developer, same machine. Direct commits to the local
  default branch are fine for inline runs; `/ardd-plan` doesn't even ask —
  no branch gate in solo mode, plan+tasks commit straight to the current
  (normally default) branch; delegated runs use worktrees and
  merge eagerly on completion. The delegation gate offers backgrounding
  *eagerly* — regardless of whether the run is already on a feature branch;
  being on a branch isolates state but shouldn't force foreground execution.
  When the user backgrounds while on a branch, `fold-to-main.sh` folds it
  into local `<default>` and returns the focused session there first (so the
  delegated worktree can see the state). Visibility = `inflight-worktrees.sh`.
- **collaborative** — nothing may be committed to the *local* default
  branch, ever (branch protection makes it unlandable anyway). Work always
  moves to a branch; after the first commit the skill offers to push and
  open a *draft PR* titled with the feature slug(s) — the pushed draft PR
  is this mode's in-flight visibility channel (`gh pr list --draft`). The
  register flip rides the branch and lands when the PR merges. Never
  push without user confirmation (commits may be unsigned when 1Password is
  locked). One extra constraint: a delegated worktree branches from
  `origin/<default>`, so plan/tasks files must have reached the remote
  before delegated implementation can see them — `/ardd-plan` carries a
  note about this; solo mode doesn't need one because `worktree-align.sh`
  carries unpushed local commits in.

There is no custom script for the worktree-creation part itself — a
hand-built one was tried and removed (Principle VIII; decision record
0001, bug #1).

**A second constitution frontmatter workflow field, `next_step_prompt:
true | false`** (absent = `false`; boolean enforced by `lint-project.sh`;
asked once by `/ardd-bootstrap`, and once by `/ardd-update` for installs
whose constitution lacks the field). When `true`, exactly two skills —
`/ardd-status` and `/ardd-plan` — end by offering their
recommended next step via AskUserQuestion, and only when that
recommendation is a concrete runnable `/ardd-*` invocation; plan
normally hands off to analyze, which then owns the single prompt of
the turn (one prompt per user-visible turn end — the prose in both
skills states this). Set the field via `ardd-state.sh stamp <file>
next_step_prompt <true|false>`, never by hand-editing. Like
`workflow_mode`, it's a workflow field, not constitution content: no Sync
Impact Report entry and no constitution version bump applies. Don't widen
the two-skill scope casually — every other skill's terminal analyze
handoff already funnels into `/ardd-status`'s prompt.

`ardd-plan` never delegates — and in solo mode it no longer gates. In solo
mode (`workflow_mode` absent or `solo`) there is no branch-gate prompt at
all: the run proceeds on the current branch (normally the default branch)
and commits plan+tasks there — a `ready` tasks file on the default branch
is planned truth, already accepted there (decision record 0005). Only
collaborative mode keeps the branch-gate step (a plain one, offering only
a regular branch, never a worktree). In both modes it deliberately never
delegates, even though it spans both drafting a plan (which can run long
for a targeted feature) *and* generating that plan's tasks file (the old
`/ardd-tasks`, folded in at an approval checkpoint). The reason is
unchanged: the plan and tasks files it writes
(`.project/plans/plan-*.md`, `.project/tasks/tasks-*.md`) are themselves the
state the next steps (`/ardd-implement`) need to see. Delegating to a worktree
would trap those files there until a manual merge, severing the handoff.
`ardd-plan`'s tasking half also has no branch-gate of its own — its
plan-approval and register flips are quick state updates the workflow wants
on the default branch promptly, with no separate long-running work to
isolate. The plan's `branch:` frontmatter names the branch inline
implementation *would* use; in the solo no-gate flow that ref may never be
created, and `completion-flip-check.sh` treats a nonexistent ref as
not-merged (silent). Tried the delegating-plan variant once and reverted —
decision record 0001 has the story if the "make plan consistent with
implement" temptation recurs.

`isolation: "worktree"` creates and names its own worktree/branch — there
is no parameter to point it at a pre-made one, and the branch name is only
known from what the subagent's result reports back, never chosen up front.
This is why the delegation step doesn't offer to name the worktree the way
it does for a plain `git checkout -b`. Nothing needs to *record* that
branch name anymore either — under worktree-native state there is no
post-merge step that must find it later; the branch merges or it doesn't,
and `inflight-worktrees.sh` sees it on disk either way.

Getting the branch-identity question wrong has produced three real bugs
(ephemeral-name mismatch; the fallback detector reading the plan's
`branch:` instead of the real worktree branch; the harness `baseRef`
behavior that killed state-commit-before-branch and the `core.bare`
side effect). Full narratives:
`docs/decisions/0001-branch-identity-and-worktree-native-state.md`.
The standing morals: never trust an in-memory branch name — use what the
subagent reports; never check ancestry against a branch you merely
intended to use; never trust the harness worktree base in either
direction — align deterministically and refuse otherwise.

**Orphaned-completion-flip detection (legacy safety net).**
`scripts/completion-flip-check.sh` (sibling to `sibling-tasks-complete.sh`,
same purpose-built deterministic check pattern) catches a failure mode the
old design produced and worktree-native state shouldn't: a
`status: completed` tasks file whose work-branch has merged into the
default branch while a bound feature still says `tasked` in the
register. Under the current design the flip rides the branch, so a
merged branch normally carries its own flip — but the check stays wired
because it's cheap and still catches a delegated run that crashed between
its `→completed` flip and its register flip, plus any tasks files
written under the old design. Mechanics: it reads the tasks file's
`worktree_branch:` frontmatter if present (a field only old-design files
have — nothing writes it anymore), falling back to the plan's `branch:`
field (the inline case), checks `git merge-base --is-ancestor <branch>
<default>`, and reports any still-`tasked` slug from the plan's
`features:` list. `/ardd-status` runs it against every completed tasks
file on each invocation and, on user confirmation, performs the
`tasked→implemented` flip itself. This is a deliberate, narrow exception
to `/ardd-status` never writing the register (see the single-writer
ownership list above) — justified because no other skill invocation is
left to catch it otherwise.

That's a different thing from a skill telling the agent, as its own last
step, to run another skill and stop — a terminal handoff, not a subroutine
call. Most skills that change state `/ardd-status` reports on end by
instructing the agent to run `/ardd-status` directly, since Claude Code
lets a skill's prose trigger another skill by name. No shared logic and no
value passed back — analyze re-derives everything itself from disk, same as
if the user had typed it. See `/ardd-status`'s own SKILL.md for the
canonical list of which skills do this.

**Mechanization non-goals (audited 2026-07-06, deliberately NOT scripted
per Principle VI).** A determinism audit that produced `ardd-state.sh`,
`defects-unsurfaced.sh`, `tasks-list.sh`, and `upsert-section.sh` also
explicitly rejected these — don't re-propose scripting them without new
evidence: `audit.md`'s staleness date-compare (advisory, low blast
radius); STATUS.md count assembly (its counts are byproducts of the
scripts above); `ardd-tracker`'s remaining `gh` glue (error handling needs
judgment; the decisions are already in the three `sync-*.sh` scripts);
the post-delegation `core.bare` check (a one-line `git config --get`);
and all genuine-judgment steps (Mermaid diagram content, feature naming,
reconcile mode's gap identification).

## Conventions

- **Commit messages follow Conventional Commits** (`feat:`, `fix:`, `refactor:`,
  `chore:`, `docs:`, etc.) — matches existing repo history.
- **Skill files are the product.** A `SKILL.md` edit is a behavior change to
  every project that runs `install.sh` against this commit — treat it with
  the same care as changing a public API.
- **Shell scripts target POSIX `sh`**, not bash-specific syntax — they're
  installed into arbitrary target projects and `install.sh` itself is
  `#!/usr/bin/env sh`.
