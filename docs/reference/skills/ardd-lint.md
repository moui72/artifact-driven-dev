# /ardd-lint

_Tier: core_

> Fast, deterministic check of .project/ frontmatter schemas and [artifacts: ...] references — no LLM judgment.

<!-- generated:end — the header above is generated from skills/ardd-lint/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-lint
```

No arguments; always checks the current project's `.project/`. It's a thin
wrapper around the installed `lint-project.sh` — the **schema-of-record**
for every status enum and required frontmatter field (see
[project-files.md](../project-files.md)). Findings are reported verbatim,
never reinterpreted, so the file-level output stays directly actionable.

## Reads

- Everything under `.project/` that carries a schema: artifact, plan,
  tasks, feedback, and feature-register frontmatter; `[artifacts: ...]`
  tags; cross-file pointers (`plan:` → plan file, `features:` → register
  slugs)

## Writes

Nothing — this skill only reports.

## What it catches

- Invalid `status` values in any of the six enums, missing required
  frontmatter fields, `[artifacts: ...]` tags naming artifacts that don't
  exist
- Broken cross-file pointers
- A tasks file stuck at `status: generating` (a crashed tasking run)
- An approved plan whose features are still `backlogged` (an interrupted
  approval sequence)
- The same feature targeted by two live plans

It does **not** judge whether decisions are consistent or good — that's
`/ardd-status`.

## Behavior notes

- No write-time hook ships with a target install — run `/ardd-lint` (or
  the installed script directly) when you want the check. (The ARDD
  source repo dogfoods a write-time hook of its own, but it isn't
  installable as-is.)
- An unrecognized enum value may mean a typo *or* a file written by a
  newer ARDD than this install's validator — the finding says so and
  suggests `/ardd-update`.

## Related

- `/ardd-status` — the judgment-based consistency check
- [guides/checking.md](../../guides/checking.md) — the four checking
  skills compared
