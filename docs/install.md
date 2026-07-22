# Installing, updating, and release channels

Every install route converges on `install.sh` — the only real
install/upgrade entry point. `new.sh` is the acquisition bootstrap that
gets you a source checkout and runs it; `/ardd-update` re-runs it later.

## Quickstart: a brand-new project

```sh
curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/release/new.sh \
  | sh -s -- my-project
```

This creates `my-project/`, `git init`s it, clones the ArDD repo to
`~/.ardd/source` (or refreshes an existing clone), pins that checkout to
the **latest stable release** — you never install from the moving tip —
runs `install.sh` from it, and offers to open Claude Code on `/ardd-init`
(which, on a cold start, interviews you about the design first).

- `--kickoff` / `--no-kickoff` answer the handoff question in advance.
  With no flag and no terminal to ask on (a scripted or CI run), it
  declines rather than hangs, printing the command instead.
- `--harness claude|codex` (or `--harness=<name>`) picks which harness to
  install for. Omit it and `new.sh` asks interactively when a tty is
  available (`ask_harness`: 3 tries, falling back to `claude` on no clear
  answer or no tty — the same `/dev/tty` discipline as the kickoff
  handoff prompt, documented in
  `docs/decisions/0008-new-sh-tty-interactivity.md`); either way the
  choice passes straight through to `install.sh --harness "$harness"`.
  See "Codex CLI: `install.sh --harness codex`" below for the full
  behavior and caveats of choosing `codex`.
- `new.sh` refuses rather than asks anywhere it would write into a
  directory it doesn't own: a non-empty target, or a `--source` that
  isn't an ArDD checkout, is an error. Nothing is overwritten.

## An existing project

Run the same bootstrap from inside the project:

```sh
cd /path/to/your/project
curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/release/new.sh | sh -s -- --existing
```

The explicit `--existing` flag is the consent new-project mode withholds:
it accepts a populated target and installs the latest release there.

> `npx skills add` is no longer a supported install channel. Skill files
> without a completed install (e.g. from a prior `npx` acquisition) are
> finished/repaired by the `--existing` bootstrap above.

## Release channels

Each project records which channel it tracks (`Channel:` in
`.project/ardd-version.md`; absent = stable):

- **stable** (default) — tagged full releases (`vX.Y.Z`), cut by an
  explicitly dispatched workflow that also fast-forwards `main` into the
  `release` branch (the stable raw-URL base above).
- **beta** (opt-in, per project) — every push to `main` publishes a
  `vX.Y.Z-beta.N` prerelease, gated on the full test suite passing for
  that commit. Fresh work without waiting for a stable cut; no
  compatibility promises between betas. Opt in with `new.sh --beta`, or
  ask `/ardd-update` to switch an existing install.

The `release` branch in the URLs serves the stable edge of `new.sh`
itself; `…/main/new.sh` serves its beta/dev edge. The base you fetch from
doesn't set your channel — only `--beta` does.

Release versions are semver with **skill-pack semantics**: MAJOR removes
or renames a slash command (or breaks a script/schema contract), MINOR is
additive, PATCH is prose and fixes. A MAJOR bump is the cue to read the
release notes first — they're published with each release on
[GitHub Releases](https://github.com/moui72/artifact-driven-dev/releases);
compare against the `Source-Ref:` tag recorded in your project's
`.project/ardd-version.md` to see how far behind you are. Prerelease tags
carry the version the next stable will claim but bind none of those
promises.

## Dev-mode: hacking on ArDD itself

Installing from your own clone — `./install.sh /path/to/your/project`, or
pointing `new.sh` at it with `--source <path>` / `$ARDD_SOURCE` — is
**dev-mode**: the checkout is used exactly as it stands (live tip, not a
release) and is only ever read, never pulled or modified. This is the
edit-a-skill, test-it-in-a-consumer loop. `/ardd-update` warns about a
dev-mode source and asks before proceeding on every later update. Only the
`~/.ardd/source` clone, which the tooling owns, is kept at the latest
release for you.

## What install.sh actually does

- Copies `skills/*/SKILL.md` into `.claude/skills/<name>/`, plus three
  non-skill reference directories the skills expect:
  `ardd-artifact-templates/`, `ardd-constitution-data/`, and
  `ardd-scripts/` (the helper scripts —
  [reference/scripts.md](reference/scripts.md)).
- Applies any `migrations/*.sh` not yet recorded in the target's
  `.ardd-applied`.
- Writes `.project/ardd-version.md` recording the source commit, path,
  channel, and — when the source sits exactly at a release tag — the tag.
- Ships `.project/.gitattributes` marking the four report files
  `merge=ours`, and suggests the per-clone
  `git config merge.ours.driver true` opt-in.
- Ensures the target's `.worktreeinclude` contains
  `.claude/skills/ardd-*/`, so Claude Code copies the installed
  (gitignored) files into every new worktree — without this, a delegated
  subagent's worktree would lack the scripts its steps call.
- Prints a gitignore suggestion when git sees the skill files as
  untracked or committed (see below).

## Codex CLI: `install.sh --harness codex`

ArDD's primary target is Claude Code, but the same pack also installs —
in a deliberately degraded v1 form — to **OpenAI Codex CLI**:

```sh
/path/to/artifact-driven-dev/install.sh --harness codex /path/to/your/project
```

- **Same canonical skills, different root.** The identical
  `skills/*/SKILL.md` sources are installed under `.agents/skills/`
  instead of `.claude/skills/` — a single install-time transformation,
  never a forked prose tree. Skills are invoked as `$ardd-init`,
  `$ardd-status`, ... (Codex's exact-name channel; its `/`-commands are
  a fixed built-in set).
- **Degraded v1 caveats** (from the constitution's Multi-harness
  section): structured `AskUserQuestion` prompts become plain-text
  numbered questions; worktree delegation and fan-out are dropped —
  Codex v1 runs everything inline; `.worktreeinclude` copying is not
  carried over; `next_step_prompt: true`'s one-keypress offer degrades
  to a plain-text suggestion (`auto` carries over unchanged).
- **Install metadata records the harness set.** `.project/ardd-version.md`
  carries `Harness: <invoking>` plus a comma-separated, order-normalized
  `Harnesses:` line for the full installed set (absent line in an older
  file = `claude`). Dual Claude+Codex installs are first-class: install
  in either order and both skill trees coexist, both ending with
  `Harnesses: claude,codex`; reinstalling one harness never removes or
  misrepresents the other. The reviewer guide, `.worktreeinclude`
  patterns, and the gitignore suggestion all speak for every installed
  harness root — bounded to `.claude/skills/ardd-*/` and
  `.agents/skills/ardd-*/`, never a broader parent (the same ceiling as
  below, applied per harness root).
- A capability record is written to
  `<skills-root>/ardd-scripts/harness-capabilities.env`
  (`HARNESS=`, `SKILLS_DIR=`, live `codex` CLI evidence); `/ardd-update`
  reads it to preserve the installed harness on reinstall.

## Gitignore the skill files

The installed skill files are regenerated output — re-running `install.sh`
overwrites them, so committing them means merge conflicts with no
content. Commit `.project/ardd-version.md` instead: it's the intentional
record of which ArDD version produced them.

The suggested pattern is exactly `.claude/skills/ardd-*/` — **never
anything broader** (`.claude/`, or even `.claude/skills/`). Broader
patterns silently block tracking real, team-shared content ArDD doesn't
own: `.claude/settings.json`, agents, commands, hooks, or a hand-written
custom skill living alongside ArDD's. install.sh also prints the
`git rm -r --cached` command if the skills were already committed, and
warns when an existing ignore pattern is already broader than the
ceiling.

## Updating

From inside a consuming project, run `/ardd-update`. It resolves the
recorded source on the recorded channel, moves the owned checkout to the
latest release (dev-mode checkouts get a warning and a confirmation
instead), re-runs `install.sh`, and relays migrations and suggestions
into your session. `/ardd-status` tells you when an update is available.
Full mechanics: the [/ardd-update reference page](reference/skills/ardd-update.md).

## What gets created in your project

```
.project/
  artifacts/           # living decision documents
  features/            # per-feature register
  feedback/            # captured observations
  plans/               # plans and research docs
  tasks/               # execution queues
  STATUS.md            # re-entry point (written only by /ardd-status)
  DEFECTS.md           # code-vs-artifact drift (written only by /ardd-defects)
  WORKFLOW.md          # generated tour of the installed skills
  ardd-version.md      # commit this
.claude/
  skills/
    ardd-*/            # skill files — regenerated by install.sh; gitignore these
    ardd-scripts/      # helper scripts the skills shell out to (also regenerated)
```

(Per-file schemas: [reference/project-files.md](reference/project-files.md).)

## Upgrading from before v0.9.0

The skill surface was finalized at v0.9.0: six renames, four skills
folded into survivors. Old commands are pruned by install.sh (which
points at each replacement); files they owned are migrated automatically.

| Before v0.9.0 | Now |
|---|---|
| `ardd-analyze` | `/ardd-status` |
| `ardd-critique` | `/ardd-audit` (legacy owned file `critique.md` → `audit.md`) |
| `ardd-verify` | `/ardd-defects` (DEFECTS.md keeps its name) |
| `ardd-sync` | `/ardd-tracker` (legacy owned file `SYNC.md` → `TRACKER.md`) |
| `ardd-feature` | `/ardd-backlog` (`.project/features/` keeps its name) |
| `ardd-render` | `/ardd-diagram` |
| `ardd-converge` | folded into `/ardd-implement` (reconcile mode) |
| `ardd-add-artifact` | folded into `/ardd-refine` (create path) |
| `ardd-bootstrap` | merged into `/ardd-init` (greenfield path) |
| `ardd-codify` | merged into `/ardd-init` (existing-codebase path) |
