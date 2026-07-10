---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: quickstart-new-project
created: 2026-07-09
features: [quickstart-new-project]
surfaced-defects: []
---

# Plan — quickstart-new-project

## Goal

Collapse greenfield onboarding into one command: `curl … | sh -s -- <dir>`
creates the project, installs ARDD through `install.sh`, and drops the user
into a first Claude Code session that interviews them and runs
`/ardd-bootstrap`.

## Scope

**Included**

- `new.sh` at the repo root — the curl-to-sh entry point. Resolves a source
  checkout, creates and `git init`s the target, invokes `install.sh`, then
  hands off to Claude Code.
- `skills/ardd-kickoff/SKILL.md` — a new `setup`-tier skill that conducts the
  greenfield design interview (`guides/greenfield.md` Step 1) and then invokes
  `/ardd-bootstrap`, which reads that conversation as its context.
- `scripts/test-new.sh` — fixture-based regression test, written first
  (Principle V), hermetic (no network, no clone).
- A CI job for the test; docs updated (`README.md`, `USAGE.md`,
  `guides/greenfield.md`, `CLAUDE.md`) and the generated skill tables
  regenerated.

**Not included**

- `gh repo create` / any GitHub remote setup. A local `git init` only. The
  absence of a remote is exactly what makes `/ardd-bootstrap` suggest
  `workflow_mode: solo`, so this is a coherent stopping point, not a gap.
- Extracting the shared source-resolution logic out of `/ardd-setup` (see
  Complexity Tracking).
- Any behavior change to `install.sh` beyond its final "Next steps" message.

## Technical Approach

`new.sh` is source-side (constitution, Project Scope & Intent, as amended at
v1.2.3): fetched and executed outside any checkout, never shipped into a
target. It converges onto `install.sh` by invoking it directly — no bridging
skill, no reimplemented install logic.

**Non-interactivity is a hard constraint, not a preference.** Under
`curl | sh` the script's stdin *is* the pipe carrying its own source. A `read`
would consume script text or block. So `new.sh` never prompts:

| Situation | Interactive installer would… | `new.sh` does |
|---|---|---|
| Target dir exists, non-empty | ask to overwrite | refuse, exit 1 |
| `ARDD_SOURCE` exists, not an ARDD checkout | ask for another path | refuse, exit 1 |
| Source checkout absent | ask before cloning | clone (it owns `~/.ardd/source`) |
| Source checkout present | ask before pulling | `git pull --ff-only`, warn on failure, proceed |

This mirrors `/ardd-setup` step 2's rule — never write into a directory the
tool doesn't own — while replacing every *ask* with a *refuse*.

The terminal handoff reopens the TTY: stdout is still the terminal under
`curl | sh`, so `[ -t 1 ]` holds while stdin does not. `exec claude
"/ardd-kickoff" < /dev/tty` from inside the target directory. If `claude`
isn't on PATH or `/dev/tty` isn't readable, print the equivalent commands and
exit 0 — the install genuinely succeeded, and a nonzero exit would misreport
that. `--no-launch` forces this path (and is what the test uses).

Ordering matters: `install.sh` requires the target to exist, and runs its
gitignore guidance through `git -C "$TARGET" rev-parse`. So `mkdir -p` and
`git init` both precede the `install.sh` call, or the gitignore suggestions
silently never fire.

`ARDD_SOURCE` overrides the default `~/.ardd/source`. This is both a user
affordance and what makes the test hermetic: pointed at the repo under test,
`new.sh` never reaches the network.

`/ardd-kickoff` exists because `/ardd-bootstrap`'s contract is to seed
artifacts *from conversation context* — on a cold first session that context
is empty. Kickoff creates it: it walks the seven topics from
`guides/greenfield.md` Step 1 (what it does, who uses it, data, integrations,
storage, stack, principles), records "don't know yet" as `[OPEN: …]` rather
than inventing a decision, reflects a summary back for confirmation, then
invokes `/ardd-bootstrap`. It never writes artifacts itself — bootstrap
remains their sole author.

## Phase Breakdown

Phases are ordered by dependency. Each ends at a demonstrable increment.

### Phase 1 — `new.sh`, test-first

Depends on: nothing.

- **T001** `[artifacts: constitution]` Write `scripts/test-new.sh` and confirm
  it fails against the absent `new.sh` (Principle V: red before green).
  Cases: happy path (`ARDD_SOURCE` = this repo, `--no-launch`, temp target) →
  asserts target is a git repo and contains `.claude/skills/ardd-scripts/` and
  `.project/ardd-version.md`; non-empty target → exit 1; `ARDD_SOURCE` not an
  ARDD checkout → exit 1; `--no-launch` never execs `claude`.
- **T002** Implement `new.sh` (POSIX `sh`) until T001 passes.
- **T003** Add a `new-project` job to `.github/workflows/lint.yml`. The
  pre-commit hook already picks `test-new.sh` up by glob — no list to extend.

### Phase 2 — `/ardd-kickoff`

Depends on: nothing in Phase 1 (parallelizable), but `new.sh` references the
skill by name, so both must land before the quickstart is coherent end to end.

- **T004** `[parallel]` Write `skills/ardd-kickoff/SKILL.md` (`tier: setup`,
  `name`/`description` frontmatter required by `lint-docs.sh`). Guards: if
  `.project/artifacts/*.md` exists, stop and point at `/ardd-analyze`; if
  `.claude/skills/ardd-scripts/` is missing, stop and point at `/ardd-setup`.
- **T005** Register `ardd-kickoff` in `scripts/gen-skill-docs.sh`'s
  `ORDER_setup`, positioned after `ardd-setup` and before `ardd-bootstrap`.

### Phase 3 — Docs and dogfood

Depends on: Phases 1 and 2.

- **T006** Regenerate the README skill tables via `scripts/gen-skill-docs.sh`;
  add a "Quickstart" section to `README.md` above the existing `## Install`.
- **T007** Update `guides/greenfield.md` (quickstart as the new front door,
  existing manual path retained beneath it) and `USAGE.md`.
- **T008** Update `CLAUDE.md`'s Commands block with `new.sh` and its test, and
  note the source-side classification.
- **T009** Update `install.sh`'s closing "Next steps" message to mention
  `/ardd-kickoff` for a new project (it currently names only
  `/ardd-bootstrap`).
- **T010** Re-run `./install.sh .` to dogfood the new skill into this repo's
  own `.claude/skills/`, refreshing `.project/ardd-version.md`.

## Complexity Tracking

| Deviation | Why justified | Why the simpler option was rejected |
|---|---|---|
| Source-resolution logic now exists twice: as prose in `/ardd-setup` step 2, and as shell in `new.sh` | The two have incompatible interaction models — `/ardd-setup` runs inside a session and *asks* before cloning; `new.sh` runs on a pipe and cannot ask at all | Extracting a shared `ardd-source.sh` would have to either prompt (impossible for `new.sh`) or never prompt (a regression for `/ardd-setup`, which the constitution's "never clone without confirmation" rule requires). Principle VI abstracts at three concrete cases; there are two. Revisit if a third appears. |

## Open Questions

- `[OPEN: should new.sh optionally run `gh repo create` behind a flag?]`
  Deferred, not rejected. It would need a prompt (or a flag) and would flip
  `/ardd-bootstrap`'s `workflow_mode` detection toward `collaborative`. Log as
  a feature if wanted.
- `[OPEN: should new.sh pin to a tag rather than tracking main?]` Today it
  clones the default branch and `git pull --ff-only`s an existing checkout, so
  a quickstart always installs tip-of-main. `.project/ardd-version.md` records
  the exact commit either way, so this is a stability preference, not a
  traceability gap.

## Production Annotation Summary

None. `new.sh` takes no shortcuts that need a production annotation: its
failure modes are refusals, and the one degraded path (no TTY → print next
steps, exit 0) is a designed behavior with a test, not a stopgap.
