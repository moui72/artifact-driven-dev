---
name: ardd-update
tier: extension
description: Update this project's ArDD install from its recorded source — resolve the release channel (dev-mode checkouts warned), check standing, re-run install.sh, and relay its output.
---

# /ardd-update

Update this project's installed ArDD skills from the source checkout,
without the user having to remember where that checkout lives. Also the way
to *see* install-time output (migrations applied, badge/gitignore
suggestions) in the user's own session — suggestions only print to whoever
runs install.sh, which is exactly why this skill exists.

Usage: `/ardd-update` (backfill absent workflow fields only, resolve on
the recorded channel), `/ardd-update --reconfigure` (re-ask all four
workflow fields, regardless of whether they're already set),
`/ardd-update --stable` (switch to, or stay on, the latest full release),
`/ardd-update --beta` (switch to, or stay on, the latest release
including prereleases), or `/ardd-update --local` (switch to a dev-mode
checkout). `--stable`, `--beta`, and `--local` are mutually exclusive —
passing more than one at once is a usage error, reported before step 1
proceeds.

## Steps

1. **Resolve the source.** Behavior branches on which flag, if any, was
   passed:

   - **`--stable` / `--beta` (deliberate channel switch):** skip reading
     the recorded `Channel:` line entirely. Run
     `.claude/skills/ardd-scripts/source-resolve.sh --channel stable` (or
     `--channel beta`) directly against the owned checkout (installed
     copy; if it's missing — an install that predates it — fall back to
     the source repo's own `scripts/source-resolve.sh` by absolute path,
     same rule as other ardd-scripts calls). Set `ARDD_CHANNEL=stable` (or
     `beta`) for step 4's reinstall, so `install.sh` re-records the new
     channel in `ardd-version.md` regardless of what was previously
     recorded there. This is the same act the old "offer a channel switch
     only when raised" path described by hand — the flag itself is now
     the raising.
   - **`--local` (deliberate dev-mode switch):** resolve a live checkout
     to reinstall from. If the recorded `Source-Path` (from
     `.project/ardd-version.md`) already resolves `channel=dev` via
     `source-resolve.sh`, use it as-is. Otherwise ask the user for a live
     checkout's path — don't guess or search the filesystem, same
     discipline as the `resolved=false` handling below. In step 4,
     reinstall from that checkout's own `install.sh` and do **not** set
     `ARDD_CHANNEL` — dev-mode ignores it (`source-resolve.sh`'s existing
     doc comment).
   - **Bare form (no flag):** unchanged — read the `Channel:` line from
     `.project/ardd-version.md` (absent = `stable` — files from older
     installs have no line and need none), then run
     `.claude/skills/ardd-scripts/source-resolve.sh --channel <recorded>`
     (installed copy; same fallback rule as above). It reads
     `Source-Path:` from `.project/ardd-version.md` and, for the
     tooling-owned checkout (`~/.ardd/source`), fetches tags and moves it
     to the latest release *on that channel* (`stable` = tagged full
     releases; `beta` = the latest tag including `vX.Y.Z-beta.N`
     prereleases, where a newer stable still beats an older beta) — that
     *is* this skill's "update the source" act, delegated to the script:
     the skill decides what to do with the outcome, the script does all
     the writing. Report which channel the project tracks alongside the
     resolved tag.

   Whichever path ran, act on the printed line:
   - `channel=release`: proceed, and report the resolved tag (relay
     `warning=offline` — resolution used on-disk state — or
     `warning=no-tags` — no releases exist yet — or `note=fetch-skipped-
     fresh-cache` — the `update_check_max_age_days` gate applied and
     FETCH_HEAD was still fresh, so this run didn't ask the remote at
     all and the resolved tag may lag a just-published release, distinct
     from `warning=offline`'s "asked and failed" — if present).
   - `channel=dev`: surface an explicit dev-mode warning — this is a
     live checkout, and its current state may hold unreleased,
     possibly-broken skills — and ask the user before proceeding (skip
     this confirmation when the user just asked for `--local`
     explicitly — the flag itself is the confirmation).
   - `resolved=false`: relay the reason (`missing`/`not-ardd` — the
     recorded path is gone or isn't an ArDD checkout; `no-source-path` —
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

5. **Ask the workflow-field questions.** After the reinstall, check
   `.project/artifacts/constitution.md` frontmatter (if the file exists).
   These four fields are workflow settings, not constitution content:
   `workflow_mode` is written inline into the frontmatter by `/ardd-init`
   directly, at initial creation; `next_step_prompt`, `delegation`, and
   `merge_policy` are always written via `ardd-state.sh stamp`, here and
   in `/ardd-init` alike — never hand-edited. Behavior branches on whether
   this run passed `--reconfigure`:

   **Without `--reconfigure` (default): backfill absent fields only, once.**
   If the frontmatter lacks a `next_step_prompt` field *entirely*, ask the
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

   Backfill `delegation` and `merge_policy` the same way. If the
   constitution frontmatter lacks a `delegation` field *entirely*, ask the
   same question `/ardd-init` asks — "When `/ardd-implement` could run in
   the background, what should it do?" (`eager` | `ask` | `inline`) — and
   stamp the answer via `ardd-state.sh stamp
   .project/artifacts/constitution.md delegation <value>`. If
   `workflow_mode` is `solo` (or absent) and the frontmatter lacks
   `merge_policy`, also ask "When a delegated background run completes,
   merge its branch into your default branch automatically?" (`auto` |
   `ask`) and stamp it likewise. Never ask `merge_policy` in collaborative
   mode — it isn't consulted there. Field presence (either value)
   suppresses re-asking forever; on paths that skip the ask (bare
   `./install.sh`, headless/scripted contexts) absent simply stays `ask` —
   never block, never default to `eager`/`auto`. Same workflow-field rules
   as above: no Sync Impact Report entry, no version bump. `workflow_mode`
   itself is never asked here — its absence just defaults to `solo`.

   **With `--reconfigure`: re-ask all four fields, regardless of
   presence.** For each of `workflow_mode`, `next_step_prompt`,
   `delegation`, and — only when the (possibly just-reconfigured)
   `workflow_mode` is `solo` — `merge_policy`, show the field's current
   value (or "not yet set" if absent) and ask whether to keep it or choose
   a new one, using the exact question wording `/ardd-init` uses for each
   field (`workflow_mode`: "solo" (state rides local worktree branches and
   merges locally) or "collaborative" (nothing lands on the local default
   branch; work moves through pushed branches / draft PRs and merges via
   PR); `next_step_prompt`: "Should skills end by offering their
   recommended next step as a one-keypress prompt?"; `delegation`: "When
   `/ardd-implement` could run in the background, what should it do?"
   (`eager` | `ask` | `inline`); `merge_policy`: "When a delegated
   background run completes, merge its branch into your default branch
   automatically?" (`auto` | `ask`)). Ask `workflow_mode` first, since its
   answer determines whether `merge_policy` is asked at all; never ask
   `merge_policy` in collaborative mode, same as the default path. Stamp
   only the fields the user actually chooses to change, via
   `ardd-state.sh stamp <file> <field> <value>` — leave untouched fields
   as they are. Same workflow-field rules apply: no Sync Impact Report
   entry, no constitution version bump for any of the four.

6. **Report** old commit → new commit (from the check in step 2 vs. the
   rewritten `.project/ardd-version.md`), migrations applied, and
   suggestions surfaced. Remind the user to commit
   `.project/ardd-version.md` (and `.ardd-applied` if migrations ran).
   Then run `/ardd-status` — its update-availability line should now
   be clear, and any register/schema migrations get re-checked.
