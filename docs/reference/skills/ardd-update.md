# /ardd-update

_Tier: extension_

> Update this project's ArDD install from its recorded source — resolve the release channel (dev-mode checkouts warned), check standing, re-run install.sh, and relay its output.

<!-- generated:end — the header above is generated from skills/ardd-update/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-update
/ardd-update --reconfigure
/ardd-update --stable
/ardd-update --beta
/ardd-update --local
```

Bare form: no arguments. Updates the installed skills from the source
checkout recorded at install time — you don't have to remember where it
lives. It's also how install-time output (migrations applied,
gitignore/badge suggestions) reaches *your* session: install.sh only
prints to whoever runs it, which is exactly why this skill exists.

`--reconfigure`: does everything the bare form does, but also re-asks all
four workflow fields (`workflow_mode`, `next_step_prompt`, `delegation`,
and — solo mode only — `merge_policy`) regardless of whether they're
already set, showing each field's current value before asking whether to
keep it or change it.

`--stable` / `--beta`: a deliberate channel switch. Skips the recorded
`Channel:` line entirely and resolves directly on the named channel
against the owned checkout, then reinstalls with `ARDD_CHANNEL` set so
`install.sh` re-records the new channel — regardless of what was
previously recorded. This takes precedence over the recorded channel
every time it's passed, not just on the first switch.

`--local`: a deliberate dev-mode switch. Resolves to a live checkout —
the recorded `Source-Path` if it already resolves `channel=dev`, otherwise
you're asked for a live checkout's path (never guessed, never searched for)
— and reinstalls from that checkout's own `install.sh` without setting
`ARDD_CHANNEL` (dev-mode ignores it). Because the flag itself is the
deliberate request, the usual dev-mode confirmation prompt (see step 1
below) is skipped.

`--stable`, `--beta`, and `--local` are mutually exclusive; passing more
than one at once is a usage error, reported before anything else runs.

## What a run does

1. **Resolve the source.** With `--stable`/`--beta`: skips the recorded
   `Channel:` line and runs `source-resolve.sh --channel stable` (or
   `beta`) directly against the owned checkout (`~/.ardd/source`), then
   sets `ARDD_CHANNEL` for step 4's reinstall so the new channel gets
   re-recorded. With `--local`: resolves a live checkout (recorded
   `Source-Path` if already dev-mode, else a prompted path) and reinstalls
   from it in step 4 without setting `ARDD_CHANNEL`. Bare form (no flag,
   unchanged): reads `Channel:` from `.project/ardd-version.md` (absent =
   `stable`) and runs `source-resolve.sh --channel <recorded>`. For the
   tooling-owned checkout that fetches tags and moves it to the latest
   release on that channel — stable means strict `vX.Y.Z` tags; beta
   counts `vX.Y.Z-beta.N` prereleases, where a newer stable still beats an
   older beta. A **dev-mode** source (any other live checkout) gets an
   explicit warning — its current state may hold unreleased,
   possibly-broken skills — and a confirmation before proceeding, unless
   `--local` was the explicit request that led there. Outside of
   `--stable`/`--beta`, a channel switch is offered only when you raise
   it, never as a routine prompt — those two flags are that raising, made
   explicit.
2. **Report standing** via `ardd-update-check.sh` — behind, up-to-date
   (a reinstall is still offered; it repairs files and re-surfaces
   suggestions), or the source can't be found (you're asked for the
   path; the filesystem is never searched). The check itself is
   local-git-only unless the constitution opts in via
   `update_check_max_age_days` (see
   [configuration.md](../configuration.md)) — fetching otherwise
   belongs to `source-resolve.sh` in step 1.
3. **Dev-mode only: offer a pull** — never assumed, never on a dirty
   tree, never a push. The owned checkout was already moved in step 1.
4. **Reinstall**: runs `<source>/install.sh` against the project and
   relays its full output verbatim. Suggestions are yours to accept;
   none is applied unprompted.
5. **Ask the workflow-field questions.** Without `--reconfigure`
   (default): backfills only, once — for constitutions that lack
   `next_step_prompt`, `delegation`, or (solo mode only) `merge_policy`
   entirely, it asks the same questions `/ardd-init` asks and stamps the
   answers. Field presence — either value — suppresses re-asking forever;
   headless paths simply keep the safe defaults. With `--reconfigure`: it
   re-asks all four fields — `workflow_mode`, `next_step_prompt`,
   `delegation`, and (solo mode only) `merge_policy` — regardless of
   whether they're already set, showing each field's current value (or
   "not yet set") first and stamping only the fields you actually choose
   to change. This is the only way to change `workflow_mode` outside of
   `/ardd-init`.
6. **Report** old → new commit, migrations applied, and suggestions;
   reminds you to commit `.project/ardd-version.md` (and `.ardd-applied`
   if migrations ran). Ends by running `/ardd-status`.

## Reads / writes

Reads `.project/ardd-version.md`; writes nothing itself — install.sh does
the writing (skills, scripts, templates, migrations, a fresh
`ardd-version.md`), and constitution frontmatter stamps go through
`ardd-state.sh`.

## Related

- `/ardd-status` — its update-availability line is what usually prompts a
  run
- [install.md](../../install.md) — channels, dev-mode, and what install.sh
  does
