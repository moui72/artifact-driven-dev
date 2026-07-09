---
name: ardd-update
tier: extension
description: Update this project's ARDD install from its recorded source checkout — check standing, offer a source pull, re-run install.sh, and relay its output.
---

# /ardd-update

Update this project's installed ARDD skills from the source checkout,
without you having to remember where that checkout lives. Also the way
to *see* install-time output (migrations applied, badge/gitignore
suggestions) in your own session — suggestions only print to whoever
runs install.sh, which is exactly why this skill exists.

Usage: `/ardd-update` — no arguments.

## Steps

1. **Find the source.** Read the `Source-Path:` line from
   `.project/ardd-version.md`. If the line is absent (an install that
   predates Source-Path recording), or the path no longer contains an
   ARDD checkout (`install.sh` + `skills/`), ask the user for the
   checkout's path — don't guess or search the filesystem. The
   reinstall in step 4 re-records whatever path is used.

2. **Report standing.** Run
   `.claude/skills/ardd-scripts/ardd-update-check.sh` (installed copy;
   if step 1 got a corrected path from the user, state the comparison
   from that path instead: installed commit vs. `git -C <source>
   rev-parse --short HEAD`). Tell the user where they stand —
   `up-to-date` is still worth continuing when the user wants a
   reinstall (e.g. to see suggestions or repair skill files); confirm
   rather than exiting.

3. **Offer — never assume — a source pull.** Only when the source
   checkout has a remote (`git -C <source> remote`) *and* a clean
   working tree: ask whether to `git -C <source> pull` first. On a
   dirty source tree, skip the offer and surface the dirtiness — the
   user decides what to do with their own checkout. Never push, and
   never pull without explicit confirmation this run.

4. **Reinstall.** Run `<source>/install.sh <this project's root>` and
   **relay its full output verbatim** — the migrations it applied and
   every suggestion it printed (badge snippet, gitignore guidance).
   These suggestions are the user's to accept or ignore; offer to apply
   any they want (e.g. paste the badge into README) but never apply one
   unprompted.

5. **Ask the next-step-prompt question, once, if never asked.** After the
   reinstall, check `.project/artifacts/constitution.md` frontmatter (if the
   file exists): if it lacks a `next_step_prompt` field *entirely*, ask the
   same question `/ardd-bootstrap` asks — "Should skills end by offering
   their recommended next step as a one-keypress prompt?" — and write the
   answer via `.claude/skills/ardd-scripts/ardd-state.sh stamp
   .project/artifacts/constitution.md next_step_prompt <true|false>`. Field
   presence (either value) suppresses re-asking forever. On paths that skip
   this ask — a bare `./install.sh` run, headless/scripted contexts —
   absent simply stays `false`; never block on the question and never
   default it on. Like `workflow_mode`, this is a frontmatter workflow
   field, not constitution content: no Sync Impact Report entry and no
   constitution version bump applies.

6. **Report** old commit → new commit (from the check in step 2 vs. the
   rewritten `.project/ardd-version.md`), migrations applied, and
   suggestions surfaced. Remind the user to commit
   `.project/ardd-version.md` (and `.ardd-applied` if migrations ran).
   Then run `/ardd-analyze` — its update-availability line should now
   be clear, and any register/schema migrations get re-checked.
