# /ardd-update

_Tier: extension_

> Update this project's ArDD install from its recorded source — resolve the release channel (dev-mode checkouts warned), check standing, re-run install.sh, and relay its output.

<!-- generated:end — the header above is generated from skills/ardd-update/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-update
/ardd-update --reconfigure
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

## What a run does

1. **Resolve the source on the recorded channel.** Reads `Channel:` from
   `.project/ardd-version.md` (absent = `stable`) and runs
   `source-resolve.sh --channel <recorded>`. For the tooling-owned
   checkout (`~/.ardd/source`) that fetches tags and moves it to the
   latest release on that channel — stable means strict `vX.Y.Z` tags;
   beta counts `vX.Y.Z-beta.N` prereleases, where a newer stable still
   beats an older beta. A **dev-mode** source (any other live checkout)
   gets an explicit warning — its current state may hold unreleased,
   possibly-broken skills — and a confirmation before proceeding.
   Channel switches are offered only when you raise them, never as a
   routine prompt.
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
