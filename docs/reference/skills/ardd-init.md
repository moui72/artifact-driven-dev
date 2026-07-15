# /ardd-init

_Tier: setup_

> One-time initialization of .project/ — detects greenfield vs existing code, then seeds artifacts from the design conversation (interviewing first if needed) or reverse-engineers them from the codebase; seeds .project/ artifacts, not CLAUDE.md (for CLAUDE.md use the built-in /init).

<!-- generated:end — the header above is generated from skills/ardd-init/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-init
```

No arguments. Run once at project start. It detects which of its two paths
fits — then confirms with one question, since detection can be wrong at the
margins:

- **Greenfield** — seeds artifacts from the design conversation. On a cold
  start (empty directory, no discussion yet) it conducts the design
  interview itself first: seven topics (what it does, who uses it, data,
  integrations, storage, stack, principles), one at a time, with
  "I don't know yet" as a first-class answer that becomes an
  `[OPEN: ...]` item.
- **Existing codebase** — surveys the code (manifests, directory tree,
  entry points, schemas, routes, UI, integrations, CI) and
  reverse-engineers draft artifacts from what it finds.

## Reads

- The conversation (greenfield) or the codebase (existing path)
- `.claude/skills/ardd-artifact-templates/*.md` — artifact structure
- `.claude/skills/ardd-constitution-data/constitution-suggestions.md` —
  the opinionated suggestion catalog, offered once at constitution creation

## Writes

- `.project/artifacts/*.md` — whichever artifacts the project's concerns
  warrant (a constitution nearly always; there is no required set).
  Existing-codebase artifacts are always `status: draft`; greenfield ones
  are `draft` only if open questions remain. Renderable artifacts start
  `diagram_status: unrendered`.
- `.project/WORKFLOW.md` — copied from the installed template, never
  transcribed from memory
- `.project/STATUS.md` — seeded once with the standard structure
  (thereafter owned by `/ardd-status`)
- `.project/features/*.md` — two distinct ways:
  - Only on the existing-codebase path, only if the offered
    feature-register extraction is accepted: capabilities mined from git
    log, changelog, tests, CLI help, routes, and docs, created
    `backlogged` and immediately advanced to `implemented` (they already
    shipped). Uncertain entries carry `[REVIEW: ...]` markers.
  - On both paths, a terminal capture step: capabilities the just-written
    artifacts describe that have no register entry (any status) and no
    implementation are offered in one batched multi-select confirmation;
    accepted ones are created `backlogged` (genuinely unbuilt work, unlike
    the extraction above). Declined items are simply not created.

## Constitution workflow knobs

When a constitution is created, init asks once for each workflow field and
stamps it into the frontmatter (via `ardd-state.sh stamp`, never by hand):

| Field | Values | Asked |
|---|---|---|
| `workflow_mode` | `solo` \| `collaborative` | Always; default suggested by detection (branch protection → collaborative, no remote → solo) |
| `next_step_prompt` | `true` \| `false` | Always; absent = `false` |
| `delegation` | `eager` \| `ask` \| `inline` | Always; absent = `ask` |
| `merge_policy` | `auto` \| `ask` | Solo mode only — never consulted in collaborative mode |

These are workflow fields, not constitution content — setting them never
bumps the constitution version. See
[configuration.md](../configuration.md).

## Behavior notes

- **Guards the install first**: if `.claude/skills/ardd-scripts/` doesn't
  exist, install.sh never ran — it stops and tells you how to complete the
  install rather than failing on the first script call.
- Warns and asks before overwriting any existing artifacts.
- Never invents decisions: anything unresolved (greenfield) or ambiguous
  (existing code) becomes `[OPEN: <question>]`, never a plausible guess.
- On the existing-codebase path, accepted constitution suggestions the
  survey already shows violated are marked `[VIOLATED: <evidence>]` — init
  never writes to `DEFECTS.md` or the register for these; it recommends
  `/ardd-defects` and `/ardd-backlog` instead.
- Does **not** run `/ardd-status` at the end (deliberately — it would just
  report expected draft-state noise). Run it after a `/ardd-refine` pass.

## Related

- `/ardd-refine` — all subsequent artifact changes, including creating new
  artifacts later
- Claude Code's built-in `/init` — generates `CLAUDE.md`; unrelated to this
  skill
