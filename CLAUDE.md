# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

artifact-driven-dev (ADD/ARDD) is a Claude Code skill pack, not an application.
The deliverable is the content of `skills/*/SKILL.md` — markdown files that
become slash commands in a *target* project once installed there. There is no
application code, build step, or test suite in the conventional sense; the
"code" is prose instructions an LLM executes, plus a handful of POSIX shell
scripts for the parts that must be deterministic.

Read `README.md` for the philosophy and artifact/skill overview, and
`USAGE.md` for the end-to-end workflow. Both are user-facing docs, not
internal notes — keep them in sync with the skills themselves.

## Commands

```sh
./install.sh /path/to/target/project   # install/upgrade skills into a project
./scripts/lint-docs.sh                 # verify README/USAGE/guides only reference real skill names
./scripts/lint-project.sh [target-dir] # validate a target's .project/ frontmatter + [artifacts: ...] refs (defaults to .)
./scripts/test-lint-project.sh         # regression test for lint-project.sh against tests/fixtures/{good,bad}-project
./scripts/branch-info.sh               # print current/default branch + on_default (used by ardd-plan/implement/tasks)
./scripts/test-branch-info.sh          # regression test for branch-info.sh's default-branch fallback chain
./scripts/hook-lint-on-write.sh        # PostToolUse hook body: lints .project/ writes, wired via .claude/settings.json
./scripts/test-hook-lint-on-write.sh   # regression test for the hook (silent/silent/valid-JSON-findings cases)
```

All lint/test scripts run in CI (`.github/workflows/lint.yml`) on
push/PR to `main`. That's the full extent of automation, deliberately — a
skill's *behavior* (does `/ardd-plan` actually draft a good plan?) is not
something these scripts check and isn't a near-term goal; only the
structural/mechanical properties covered above are. When you add a new
deterministic check, add both a CI job and a fixture-based regression test in
the same commit (see `tests/fixtures/`) — don't ship a lint script whose own
correctness is unverified.

## Architecture

**Two install targets, don't conflate them.** Some scripts/docs govern *this*
repo only (`scripts/lint-docs.sh`, its CI job, `tests/fixtures/`,
`scripts/hook-lint-on-write.sh` + `.claude/settings.json` — dogfooding this
repo's own `.project/`). Others are installed by `install.sh` into a
*target* project and run there (every `skills/*/SKILL.md`, the constitution
suggestion catalog, artifact templates, migrations, `scripts/lint-project.sh`,
`scripts/branch-info.sh`). When adding a new deterministic check, decide
which side it belongs to before writing it — a check against *this* repo's
own files (docs, skill names) is source-side; a check against a *target*
project's generated `.project/` state ships via `install.sh`.
`hook-lint-on-write.sh` currently hardcodes `$PROJECT_ROOT/scripts/lint-project.sh`
(the source-repo path), so it isn't installable as-is — wiring an
equivalent hook into target projects via `install.sh` is a separate,
not-yet-made decision, not an oversight.

**`install.sh` is the only entry point into a target project.** It copies
`skills/*/SKILL.md` into `.claude/skills/<name>/`, copies
`templates/constitution-suggestions.md`, `templates/artifacts/*.md`, and
`scripts/lint-project.sh` into non-skill reference directories under
`.claude/skills/` (`ardd-constitution-data`, `ardd-artifact-templates`,
`ardd-scripts` — so the fixed paths those skills expect actually resolve
outside this repo), applies any `migrations/*.sh` not yet recorded in the
target's `.ardd-applied`, and writes `.project/ardd-version.md` recording the
source commit. It also inspects the target's git-tracked files under
`.claude/` to print the right `.gitignore` suggestion — `.claude/skills/` is
regenerated output and should never be committed in a target project;
`.project/ardd-version.md` is the intentional, committed record of which ADD
version produced it. Adding a new non-skill directory under
`.claude/skills/`? Add its name to the `case` allowlist in install.sh's
gitignore-check section too, or it'll be misreported as a tracked
non-ARDD skill.

**Four artifacts, refined iteratively, not generated once.**
`constitution.md`, `infrastructure.md`, `datamodel.md`, `ui.md` (plus
`features.md` and optional artifacts like `adapters.md`/`api.md`) live in a
target project's `.project/artifacts/` and are the system's actual state.
Every skill either reads them, refines one of them, or turns them into
plans/tasks/code. `status: draft` / `status: stable` frontmatter gates
whether an artifact is safe to plan against.

**Single-writer ownership of generated files is, deliberately, prose-only —
this is not enforceable by a hook, and that was verified, not assumed.**
- `.project/STATUS.md` — written only by `/ardd-analyze`
- `.project/DEFECTS.md` — written only by `/ardd-verify`
- `.project/SYNC.md` — written only by `/ardd-sync`
- `.project/critique.md` — written only by `/ardd-critique`
- `.project/artifacts/features.md` `Status` field — written only by
  `/ardd-feature`, `/ardd-plan`, `/ardd-tasks`, `/ardd-implement`,
  `/ardd-converge`

Every other skill treats these as read-only. A PreToolUse/PostToolUse hook
cannot enforce this: its payload (`tool_name`, `tool_input`, `transcript_path`,
etc.) carries no field identifying which skill/slash-command is currently
active, and the transcript format is explicitly undocumented and
version-fragile, so it can't be parsed for one either (confirmed against
Claude Code's hook docs, not assumed). The only way around that would be
each skill setting a sentinel before writing its owned file — which
reintroduces the exact LLM-compliance dependency this convention exists to
eliminate, i.e. it isn't real enforcement, just soft convention with extra
steps. So: preserve the boundary explicitly in prose when adding or editing
a skill, same as before, and don't try to "harden" it with a hook — that's
a dead end, not an unfinished task. What a hook *can* do, and does
(`.claude/settings.json`'s `PostToolUse` on `Write|Edit` →
`scripts/hook-lint-on-write.sh`), is catch schema violations in whatever
gets written to `.project/`, regardless of which skill wrote it — that's
real hardening, just a different, narrower guarantee than ownership
enforcement. Don't conflate the two.

**Skill-to-skill handoffs run entirely through files on disk**, not shared
state: frontmatter `status` fields, `[artifacts: ...]` tags on task/feedback
lines, and `plan:` / `features:` frontmatter linking tasks files back to the
plan and feature slugs that produced them. When editing a skill that reads or
writes one of these, check every other skill that touches the same field.

**`scripts/lint-project.sh` is the schema-of-record for frontmatter status
enums and required fields** — not the SKILL.md prose. Enums (five of them:
artifact `status`, `diagram_status`, plan `status`, tasks `status`, feedback
`status`, plus `features.md`'s per-entry `Status`) live in one block at the
top of that script, not scattered through skill prose, precisely so they
don't drift the way `USAGE.md`'s command names once did. If a skill starts
writing a new status value (e.g. tasks' `generating` state), update the enum
in `lint-project.sh` in the same commit — a stale validator that rejects
valid files is worse than no validator, since it trains people to ignore its
output. `/ardd-lint` is the user-facing skill that runs it against the
current project; it never writes, only reports.

**The "check branch" step's deterministic half is a shared script, not
duplicated prose.** `scripts/branch-info.sh` (installed to
`.claude/skills/ardd-scripts/`) computes `current`/`default`/`on_default`;
`ardd-plan`, `ardd-implement`, and `ardd-tasks` all shell out to it instead
of re-deriving the current/default-branch fallback chain. What's still
duplicated across those three, deliberately, is the *interactive* half —
suggesting a semantic branch name, asking the user, deciding what to do with
the answer — because that requires judgment a script doesn't have; skills
can't invoke other skills structurally, so this residual duplication stays
prose. If you touch the deterministic detection logic, edit
`branch-info.sh` (and its regression test, `test-branch-info.sh`) once; if
you touch the interactive framing, all three skills still need the same
edit.

## Conventions

- **Commit messages follow Conventional Commits** (`feat:`, `fix:`, `refactor:`,
  `chore:`, `docs:`, etc.) — matches existing repo history.
- **Skill files are the product.** A `SKILL.md` edit is a behavior change to
  every project that runs `install.sh` against this commit — treat it with
  the same care as changing a public API.
- **Shell scripts target POSIX `sh`**, not bash-specific syntax — they're
  installed into arbitrary target projects and `install.sh` itself is
  `#!/usr/bin/env sh`.
