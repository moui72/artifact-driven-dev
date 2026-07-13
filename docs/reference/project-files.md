# `.project/` file formats

Every file ARDD writes into a target project, its schema, and who owns it.
The **schema-of-record for status enums and required fields is the
installed `lint-project.sh`** (run via `/ardd-lint`) — this page describes;
that script enforces. If they ever disagree, the script wins and this page
has a bug.

## Directory layout

```
.project/
  artifacts/           # living decision documents
  features/            # per-feature register — one file per idea
  feedback/            # captured observations, consumed by the next plan
  plans/               # generated plans and research docs
  tasks/               # tasks-<slug>-<hex>.md — execution queues
  STATUS.md            # written only by /ardd-status
  DEFECTS.md           # written only by /ardd-defects
  TRACKER.md           # written only by /ardd-tracker
  audit.md             # written only by /ardd-audit
  WORKFLOW.md          # static skill reference, installed by /ardd-init from the shipped template
  ardd-version.md      # commit this — records the installed ARDD source
  .gitattributes       # shipped by install.sh: report files merge=ours
```

## Status enums

Six lifecycles. Five are script-mutated via `ardd-state.sh` (skills decide
*when* a transition happens; the script does the writing and refuses
illegal transitions); the exception is the artifact `status` field, which
the editing skill sets directly while writing the artifact body — a
judgment call, not a mechanical flip:

| File kind | Field | Values |
|---|---|---|
| Artifact | `status` | `draft` → `stable` (and back, if gaps reopen) |
| Artifact | `diagram_status` | `unrendered` → `current` ↔ `stale` |
| Plan | `status` | `draft` → `approved` → `superseded` |
| Tasks | `status` | `generating` → `ready` → `in-progress` → `completed` (or → `abandoned`) |
| Feedback | `status` | `open` → `planned` |
| Feature register | `status` | `backlogged` → `planned` → `tasked` → `implemented` (or → `retired`) |

Who advances the feature register: `backlogged` entries come from
`/ardd-backlog` (or `/ardd-tracker` pull); `/ardd-plan` flips
`backlogged → planned` at plan approval and `planned → tasked` when the
tasks file is generated; `/ardd-implement` flips `tasked → implemented`
when every tasks file bound to the plan completes (with `/ardd-status`
performing that last flip in the orphaned-completion case).

`retired` means "shipped, then deliberately removed" — it is entered only
from `implemented` and is terminal. No skill automates removal decisions,
so the flip is performed manually:
`ardd-state.sh feature-flip <slug> retired`.

`completed` and `planned` (feedback) are terminal: a completed tasks file
never reopens (post-completion failures become new feedback), and a
planned feedback file is a historical record.

## Artifacts (`artifacts/<name>.md`)

```yaml
---
status: draft | stable        # draft = open questions; not safe to plan against
last_updated: YYYY-MM-DD
diagram_type: erDiagram       # optional — declaring it makes the artifact renderable
diagram_status: unrendered    # required once diagram_type is present
render_hint: ...              # optional render fields — see the /ardd-diagram page
render_target: ...
render_section: ...
---
```

The constitution additionally carries the workflow knobs
(`workflow_mode`, `next_step_prompt`, `delegation`, `merge_policy`) — see
[configuration.md](configuration.md) — plus its own version line and Sync
Impact Report comment. Open design questions appear in bodies as
`[OPEN: <question>]`; production shortcuts under a
`## Production Annotations` heading.

## Feature register (`features/<slug>.md`)

One file per feature. Frontmatter: `slug`, `status`, `logged`, plus
`plan:` / `tasks:` pointers stamped as the feature advances and an
optional `gh_issue: <n>` once synced by `/ardd-tracker`. Body: one
sentence on the capability, optional `Why:` line.

## Feedback (`feedback/feedback-<slug>-<hex>.md`)

Frontmatter: `status`, `created`, `plan` (null until consumed). Items get
stable IDs `F001…` numbered across the whole file, grouped under
`## Bugs` / `## UX` / `## Reconsidered`, each optionally tagged
`[artifacts: <name>]`. Checkboxes are 3-state: `[ ]` open, `[x]`
incorporated, `[-]` declined.

## Plans (`plans/plan-<slug>-<date>-<hex>.md`)

```yaml
---
status: draft
branch: <slug>                  # the branch inline implementation would use; may never be created
created: YYYY-MM-DD
features: [<slug>, ...]         # register slugs this plan designs
surfaced-defects: [<id>, ...]   # DEFECTS.md identifiers already offered (accepted or declined)
---
```

Research docs (`plans/research-*.md`) share the directory but have no
lifecycle — frontmatter `topic`/`date`/`status: complete`, nothing reads
them back.

## Tasks (`tasks/tasks-<slug>-<hex>.md`)

```yaml
---
plan: plan-<slug>-<date>-<hex>.md   # authoritative binding to the source plan
generated: YYYY-MM-DD
status: generating
---
```

Task lines:

```markdown
- [ ] T001 [artifacts: datamodel, infrastructure] Create Patient table
- [ ] T002 [artifacts: datamodel] [parallel] Create Appointment table
```

`[artifacts: ...]` declares what `/ardd-implement` loads before executing
the task (omitted entirely when none apply — never a placeholder);
`[parallel]` marks tasks with no shared files or dependencies. A legacy
`worktree_branch:` frontmatter field may appear in files from before
worktree-native state; nothing writes it anymore.

## Report files — single-writer, disposable at merge

`STATUS.md`, `DEFECTS.md`, `TRACKER.md`, and `audit.md` each have exactly
one writing skill; every other skill treats them as read-only. At
merge/rebase they are disposable: take either side without deliberation
and let the owning skill regenerate from disk. The shipped
`.project/.gitattributes` marks them `merge=ours`, and with the per-clone
opt-in `git config merge.ours.driver true` they merge clean automatically.
These four are deliberately *not* schema-validated by `lint-project.sh` —
they're prose for humans, not machine-checkable state.

## `WORKFLOW.md`

A static, generated tour of the installed skill set — the same command
table you see in the [skills reference](skills/README.md), seeded into
`.project/WORKFLOW.md` by `/ardd-init` (copied from the shipped template,
not hand-written) and refreshed by re-running `install.sh` after an
upgrade. It's a convenience pointer for humans opening the project, not
machine-checkable state, so `lint-project.sh` doesn't validate it. Commit
it or not as you like — re-running install.sh reproduces it.

## `ardd-version.md`

Written by install.sh on every run: the source commit, date,
`Source-Path:` (where the checkout lives), `Source-Ref: <tag>` when the
source sat exactly at a release tag, and `Channel: <stable|beta>` (absent
= stable). Commit this file — it's the project's record of which ARDD
version was active — while gitignoring the regenerated
`.claude/skills/ardd-*/` files themselves.
