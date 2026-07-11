---
status: planned      # open -> planned
created: 2026-07-11
plan: plan-scrap-npx-channel-2026-07-11.md
---

# Feedback

## UX
- [x] F001 The `npx skills add moui72/artifact-driven-dev` install channel
  works poorly. Two concrete failures from real use: (a) the vercel-labs
  skills CLI presents a multiselect of all ~20 skills and the user must pick
  through the whole list; (b) it leaves the project with no local ARDD source
  checkout, so `install.sh` (which isn't among the copied files anyway) feels
  broken. Root reframe: on the npx path, `install.sh` — run by `/ardd-setup`
  after it clones the source — *regenerates the entire* `.claude/skills/ardd-*/`
  set anyway, so every skill selected in the CLI picker beyond `/ardd-setup`
  is thrown away. The channel is really just a convoluted delivery mechanism
  for the one `/ardd-setup` bootstrap skill.

## Reconsidered
- [x] F002 Scrap the `npx skills add` acquisition channel entirely.
  [artifacts: constitution] Decision chosen: replace it (F003), not merely
  document it better ("select only `/ardd-setup`"). The constitution's
  standing decision (2026-07-09, lines ~69-90) enumerates three acquisition
  channels — git clone, `npx skills add`, and the `new.sh` quickstart — and
  justifies `/ardd-setup` as the bridge that completes an npx-acquired
  install. Removing the npx channel reverses that: the constitution's
  acquisition-channels section and its `/ardd-setup` justification both need
  revision. Tradeoff explicitly accepted: dropping npx loses presence in the
  vercel-labs skills registry (a discoverability surface); the user judged a
  simpler, self-owned install story worth more than the registry listing.
- [x] F003 Replace the npx channel with an existing-project curl bootstrap —
  a sibling to `new.sh` (or a `new.sh` `--existing`/mode) that clones the
  source to `~/.ardd/source` and runs `install.sh` against the current,
  already-populated project directory. This structurally fixes both F001
  failures: no skill picker, and it ends with a real owned source checkout
  (so `/ardd-update` works from then on). It MUST honor `new.sh`'s three
  standing invariants (constitution / CLAUDE.md): refuse rather than ask when
  writing into a directory it doesn't own; never block on a question it can't
  ask (no usable `/dev/tty` → safe default, never hang a pipeline); and only
  ever clone/pull the `~/.ardd/source` checkout it owns (a `--source`/
  `$ARDD_SOURCE` path is read, never mutated). Note the one real difference
  from `new.sh`: the target dir is deliberately NON-empty here, so `new.sh`'s
  "refuse a non-empty target" guard cannot be reused as-is — an existing-
  project bootstrap must distinguish "populated project I'm installing into"
  from "directory I don't own."
- [x] F004 Delete `/ardd-setup` as dead architecture once the npx channel is
  gone (Principle VII — no dead architecture). [artifacts: constitution] It
  exists solely to complete an npx-acquired install; with the curl bootstrap
  (F003) invoking `install.sh` directly like `new.sh` does, nothing is left
  for it to bridge. Bonus: removes one setup-tier skill, aligning with the
  in-flight catalog-consolidation plan
  (`plan-consolidate-setup-skills-2026-07-11.md`) — but keep this a SEPARATE
  change; that plan's implementation is running in a background worktree and
  must not be entangled. Ripple: `README` Install section, `USAGE`,
  `guides/`, `scripts/lint-docs.sh` (drop the `ardd-setup` name),
  `CLAUDE.md`'s npx/`ardd-setup` discussion, and the constitution's
  acquisition-channels standing decision (the [artifacts: constitution] tag
  on F002 covers the artifact edit).
