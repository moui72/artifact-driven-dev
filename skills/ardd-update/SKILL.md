---
name: ardd-update
tier: extension
description: Update this project's ARDD install from its recorded source — resolve the release channel (dev-mode checkouts warned), check standing, re-run install.sh, and relay its output.
---

# /ardd-update

Update this project's installed ARDD skills from the source checkout,
without you having to remember where that checkout lives. Also the way
to *see* install-time output (migrations applied, badge/gitignore
suggestions) in your own session — suggestions only print to whoever
runs install.sh, which is exactly why this skill exists.

Usage: `/ardd-update` — no arguments.

## Steps

1. **Resolve the source, on the recorded channel.** Read the `Channel:`
   line from `.project/ardd-version.md` (absent = `stable` — files from
   older installs have no line and need none). Then run
   `.claude/skills/ardd-scripts/source-resolve.sh --channel <recorded>`
   (installed copy; if it's missing — an install that predates it — fall
   back to the source repo's own `scripts/source-resolve.sh` by absolute
   path, same rule as other ardd-scripts calls). It reads `Source-Path:`
   from `.project/ardd-version.md` and, for the tooling-owned checkout
   (`~/.ardd/source`), fetches tags and moves it to the latest release
   *on that channel* (`stable` = tagged full releases; `beta` = the
   latest tag including `vX.Y.Z-beta.N` prereleases, where a newer
   stable still beats an older beta) — that *is* this skill's "update
   the source" act, delegated to the script: the skill decides what to
   do with the outcome, the script does all the writing. Report which
   channel the project tracks alongside the resolved tag. **Offer a
   channel switch only when the user raises it** — never as a routine
   prompt; to switch, re-run `source-resolve.sh --channel <new>` and run
   step 4's reinstall with `ARDD_CHANNEL=<new>` set, which makes
   install.sh record the new channel in `ardd-version.md`. Act on the
   printed line:
   - `channel=release`: proceed, and report the resolved tag (relay
     `warning=offline` — resolution used on-disk state — or
     `warning=no-tags` — no releases exist yet — if present).
   - `channel=dev`: surface an explicit dev-mode warning — this is a
     live checkout, and its current state may hold unreleased,
     possibly-broken skills — and ask the user before proceeding.
   - `resolved=false`: relay the reason (`missing`/`not-ardd` — the
     recorded path is gone or isn't an ARDD checkout; `no-source-path` —
     the install predates Source-Path recording) and ask the user for
     the checkout's path — don't guess or search the filesystem. Re-run
     `source-resolve.sh <path>` with the answer. The reinstall in step 4
     re-records whatever path is used.

2. **Report standing.** Run
   `.claude/skills/ardd-scripts/ardd-update-check.sh` (installed copy;
   it compares the installed commit against the source's latest release
   tag *within the recorded channel* — a `channel=beta` token means it
   counted prereleases; `note=no-releases` means it fell back to a tip
   comparison). Tell the user where they stand — `up-to-date` is still worth
   continuing when the user wants a reinstall (e.g. to see suggestions
   or repair skill files); confirm rather than exiting.

3. **Dev-mode sources only: offer — never assume — a pull.** The owned
   checkout was already brought to the latest release in step 1; a
   `channel=dev` checkout belongs to the user and is never touched by
   the script, so here (and only here) the old offer applies: when it
   has a remote (`git -C <source> remote`) *and* a clean working tree,
   ask whether to `git -C <source> pull` first. On a dirty source tree,
   skip the offer and surface the dirtiness — the user decides what to
   do with their own checkout. Never push, and never pull without
   explicit confirmation this run.

4. **Reinstall.** Run `<source>/install.sh <this project's root>` and
   **relay its full output verbatim** — the migrations it applied and
   every suggestion it printed (badge snippet, gitignore guidance).
   These suggestions are the user's to accept or ignore; offer to apply
   any they want (e.g. paste the badge into README) but never apply one
   unprompted.

5. **Ask the next-step-prompt question, once, if never asked.** After the
   reinstall, check `.project/artifacts/constitution.md` frontmatter (if the
   file exists): if it lacks a `next_step_prompt` field *entirely*, ask the
   same question `/ardd-init` asks — "Should skills end by offering
   their recommended next step as a one-keypress prompt?" — and write the
   answer via `.claude/skills/ardd-scripts/ardd-state.sh stamp
   .project/artifacts/constitution.md next_step_prompt <true|false>`. Field
   presence (either value) suppresses re-asking forever. On paths that skip
   this ask — a bare `./install.sh` run, headless/scripted contexts —
   absent simply stays `false`; never block on the question and never
   default it on. Like `workflow_mode`, this is a frontmatter workflow
   field, not constitution content: no Sync Impact Report entry and no
   constitution version bump applies.

   **Backfill `delegation` and `merge_policy` the same way.** In the same
   check: if the constitution frontmatter lacks a `delegation` field
   *entirely*, ask the same question `/ardd-init` asks — "When
   `/ardd-implement` could run in the background, what
   should they do?" (`eager` | `ask` | `inline`) — and stamp the answer via
   `ardd-state.sh stamp .project/artifacts/constitution.md delegation
   <value>`. If `workflow_mode` is `solo` (or absent) and the frontmatter
   lacks `merge_policy`, also ask "When a delegated background run
   completes, merge its branch into your default branch automatically?"
   (`auto` | `ask`) and stamp it likewise. Never ask `merge_policy` in
   collaborative mode — it isn't consulted there. Field presence (either
   value) suppresses re-asking forever; on paths that skip the ask (bare
   `./install.sh`, headless/scripted contexts) absent simply stays `ask` —
   never block, never default to `eager`/`auto`. Same workflow-field rules
   as above: no Sync Impact Report entry, no version bump.

6. **Report** old commit → new commit (from the check in step 2 vs. the
   rewritten `.project/ardd-version.md`), migrations applied, and
   suggestions surfaced. Remind the user to commit
   `.project/ardd-version.md` (and `.ardd-applied` if migrations ran).
   Then run `/ardd-status` — its update-availability line should now
   be clear, and any register/schema migrations get re-checked.
