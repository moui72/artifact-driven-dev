# /ardd-refine

_Tier: core_

> Update a named artifact — apply new decisions, resolve open questions, handle constitution versioning; given a name that doesn't exist yet, it creates the artifact from a template (absorbs ardd-add-artifact).

<!-- generated:end — the header above is generated from skills/ardd-refine/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-refine <name>                    # refine one artifact
/ardd-refine <name> <guidance>         # refine with inline direction
/ardd-refine                           # no-argument mode: sweep all artifacts with open questions
```

`<name>` matches a file in `.project/artifacts/` (`constitution`,
`datamodel`, any custom name). Naming an artifact that doesn't exist enters
the **create path** — it's seeded from the installed template (or
`generic.md`), registered in `.project/WORKFLOW.md`'s Artifacts table and
`CLAUDE.md`, and then refined normally. There is no separate add-artifact
command.

No-argument mode reads `.project/STATUS.md` for per-artifact open-question
counts and refines every artifact that has any, most-open first.

## Reads

- `.project/artifacts/<name>.md` (or all artifacts, in no-argument mode)
- `.project/STATUS.md` — no-argument mode's work list
- `.claude/skills/ardd-artifact-templates/` — create path only

## Writes

- `.project/artifacts/<name>.md` — the refined artifact
- Frontmatter, script-stamped via `ardd-state.sh stamp`:
  `status` (`stable` when substantially complete, `draft` when significant
  gaps remain), `last_updated`, and `diagram_status: stale` on renderable
  artifacts (unless still `unrendered` — nothing rendered can't go stale)

## Behavior notes

- **Constitution is special**: version-bump semantics (MAJOR/MINOR/PATCH),
  a prepended Sync Impact Report comment, and the version line at the
  bottom are all handled here.
- `[OPEN: ...]` is reserved for genuine undecided design questions. Known
  code-vs-artifact violations never get narrated into an artifact body —
  they belong in `DEFECTS.md` via `/ardd-defects`.
- Production shortcuts are recorded under a `## Production Annotations`
  heading, never inline elsewhere — that heading is what `/ardd-plan` and
  `/ardd-audit` scan for. Refine moves stray inline ones there.
- With no inline guidance it asks up to 3 targeted clarifying questions —
  never questions answerable by reading other artifacts.
- **Delta-scoped capture**: capabilities newly introduced or materially
  changed by this refine that have no register entry (any status) and no
  implementation are offered in one batched confirmation and, if
  accepted, created `backlogged` in `.project/features/` — never a
  re-prompt about the artifact's long-standing scope. On the create path
  the whole new artifact is the delta.
- Ends by running `/ardd-status` (once per single-artifact run; once after
  the whole pass in no-argument mode).

## Related

- `/ardd-init` — the one-time initial seeding this skill takes over from
- `/ardd-audit` — challenges whether the recorded decisions are *good*;
  refine applies decisions you've made
