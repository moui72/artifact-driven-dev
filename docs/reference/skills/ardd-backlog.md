# /ardd-backlog

_Tier: core_

> Log a feature idea to the per-feature register (.project/features/) — no artifact edits yet; bugs and UX problems with existing behavior belong in /ardd-feedback instead (formerly ardd-feature).

<!-- generated:end — the header above is generated from skills/ardd-backlog/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-backlog <plain-language description of the capability>
```

Logging is deliberately cheap: one register file, no artifact edits, no
design work. The design happens later, when you target the slug with
`/ardd-plan <slug>` — in any order, whenever you choose. Substantial or
decision-reversing ideas should be vetted with `/ardd-research` first.

## Reads

- `.project/features/` — slug collision check

## Writes

- `.project/features/<slug>.md` — created via `ardd-state.sh
  feature-create <slug>` (which writes the frontmatter: `slug`,
  `status: backlogged`, `logged: <date>`). The body is one sentence on
  what the capability does from the user's perspective, plus an optional
  `Why:` line for non-obvious context.

## Behavior notes

- **Mirror check**: if the description is really a complaint about
  *existing* behavior (a bug, UX friction, "works but shouldn't work that
  way"), it offers to capture it as `/ardd-feedback` instead.
- Slug wording is judgment (short capability-level noun phrase); the
  sanitization is deterministic (`ardd-state.sh slug`), with a 4-char hex
  suffix on collision.
- A legacy single-file `.project/artifacts/features.md` means the install
  predates the per-feature migration — it tells you to re-run install.sh
  rather than appending to the legacy file.
- Ends by running `/ardd-status` to refresh the backlog count.

## Related

- `/ardd-feedback` — observations about existing behavior
- `/ardd-research` — vet a substantial idea before it earns an entry
- `/ardd-plan <slug>` — where the logged idea's design work happens
- `/ardd-init` — its existing-codebase path offers a one-time *bulk*
  register extraction; this skill logs single new ideas going forward
