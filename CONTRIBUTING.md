# Contributing to artifact-driven-dev

This is about working on ARDD's own source — installing ARDD *into* a
project is [docs/install.md](docs/install.md).

## What you're editing

The deliverable is the content of `skills/*/SKILL.md` — markdown files
that become slash commands in a target project once installed. There is no
application code or build step; the "code" is prose instructions an LLM
executes, plus POSIX-`sh` scripts for the parts that must be
deterministic. **A SKILL.md edit is a behavior change to every project
that installs from that commit — treat it with the care of a public API
change.**

Two install targets, don't conflate them: some scripts/docs govern *this*
repo only (`lint-docs.sh`, `gen-skill-docs.sh`, `tests/fixtures/`); others
ship into target projects via `install.sh` (every SKILL.md, the templates,
migrations, and the `ardd-scripts/` helpers). Decide which side a new
check belongs to before writing it. `CLAUDE.md` carries the full working
notes.

## One-time per-clone setup

```sh
git config core.hooksPath hooks       # enables hooks/pre-commit (lint + tests)
git config merge.ours.driver true     # conflict-free merges for generated .project/ reports
```

Git won't enable a tracked hooks directory or honor repo-committed merge
drivers automatically, so both are deliberate per-clone opt-ins.

## The checks

```sh
./scripts/lint-docs.sh          # docs only reference real skill names; generated docs in sync
./scripts/lint-project.sh       # this repo's own dogfooded .project/ validates
./scripts/test-*.sh             # fixture-based regression tests, one per deterministic script
```

All of it runs in CI (`.github/workflows/lint.yml`) on push/PR to `main`.
That's deliberately the full extent of automation — a skill's *behavior*
(does `/ardd-plan` draft a good plan?) is not something these scripts
check. When you add a new deterministic check, add both a CI job and a
fixture-based regression test in the same commit — don't ship a lint
script whose own correctness is unverified.

## Generated documentation

`scripts/gen-skill-docs.sh` single-sources skill documentation from each
SKILL.md's frontmatter: the README's Skills table, the header block of
every `docs/reference/skills/*.md` page (the body below the
`generated:end` marker is hand-written), the reference index, and
`templates/WORKFLOW.md`. Edit the frontmatter `description:`, then re-run
it; `--check` (wired into lint-docs and the pre-commit hook) fails CI on
drift.

## Conventions

- **Commit messages**: Conventional Commits (`feat:`, `fix:`, `docs:`, …).
- **Shell scripts target POSIX `sh`** — they're installed into arbitrary
  target projects.
- **Skill naming**: report-owners are nouns named for the file they own
  (`/ardd-status` → `STATUS.md`); lifecycle actions are imperative verbs
  (`/ardd-plan`); capture skills are named for what you hand them
  (`/ardd-backlog` takes a feature idea). Descriptions follow object →
  data-flow → redirect clause.

## Releases

Two channels, both driven by CI (`scripts/release.sh` is retired): pushing
`main` publishes a suite-gated `vX.Y.Z-beta.N` prerelease; dispatching
`.github/workflows/stable-release.yml` cuts a full release and
fast-forwards `main` into the `release` branch. Versions come from
`scripts/next-version.sh`, the single version authority.

## The behavioral smoke tier

`.github/workflows/smoke.yml` runs real headless skill flows against
throwaway targets, but the `ANTHROPIC_API_KEY` secret is deliberately
unprovisioned, so every smoke job currently skips fast and is advisory.
Provisioning that secret is the single manual step that turns the
scenarios live. If you change a skill's state-mutating path, keep the
scenarios current in the same change — details in the workflow's header
comment.

## History note

`main` was rewritten once on 2026-07-04 to add commit signatures —
recovery steps preserved in
[docs/decisions/0003-rewritten-main-recovery.md](docs/decisions/0003-rewritten-main-recovery.md).
The other decision records in [docs/decisions/](docs/decisions/) hold the
full narratives behind rules the skills and `CLAUDE.md` now state tersely —
read them before re-proposing something that looks obvious.
