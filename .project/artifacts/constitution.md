<!--
SYNC IMPACT REPORT
==================
Version change: (none) → 1.0.0
Added sections: all (initial)
-->

---
name: constitution
status: stable
last_updated: 2026-07-05
---

# artifact-driven-dev Constitution

## Project Scope & Intent

artifact-driven-dev (ADD/ARDD) is a Claude Code skill pack: markdown-defined
slash commands (`skills/*/SKILL.md`) installed into other projects via
`install.sh`, plus a small number of POSIX shell scripts for the parts of
the system that must be deterministic rather than left to LLM judgment.
There is no runtime application, database, or user interface belonging to
ADD itself — the product is prose instructions an LLM executes in a target
project, plus the install/lint tooling that supports them. `datamodel.md`,
`infrastructure.md`, and `ui.md` accordingly do not exist for this project
and are not expected to: none of the concerns they own apply here.

ADD is narrower in scope than Spec Kit, not lighter in absolute terms: it
assumes the user arrives with architectural clarity and needs a system to
capture, cross-check, and execute against decisions already made, rather
than a framework that discovers those decisions through structured
elicitation. See `README.md`'s "When artifacts earn their keep" for when
that overhead is actually worth it — for this repository specifically, it's
worth it because there is no external target codebase to serve as an
implicit spec for what ADD itself should do next; the skills, scripts, and
docs *are* the product, and this constitution is the explicit source of
truth for the principles they follow.

Two install targets exist and must not be conflated: files/scripts that
govern this source repository only (e.g. `scripts/lint-docs.sh`,
`tests/fixtures/`, `scripts/hook-lint-on-write.sh` + `.claude/settings.json`),
and files `install.sh` ships into a target project to run there (every
`skills/*/SKILL.md`, `scripts/lint-project.sh`, `scripts/branch-info.sh`,
`templates/`, `migrations/`). `CLAUDE.md` carries the full technical
breakdown of this split; it's stated here as a governing principle
(Principle IV) because conflating the two has already caused real mistakes.

## Core Principles

### I. Skill Files Are the Product

A `SKILL.md` edit is a behavior change to every project that has run
`install.sh` against that commit — treat it with the same care as changing
a public API. Don't rewrite a skill's steps without considering every
project already relying on its current behavior.

### II. Deterministic Checks Over Prose, Wherever the Invariant Is Actually Checkable

Any invariant that is a pure function of file state on disk — a status
enum, a required frontmatter field, a cross-reference that must resolve, a
doc that must name a real skill — gets a real deterministic script, not
reliance on an LLM reading instructions carefully every time. Skill prose
is reserved for what genuinely requires judgment: deciding a branch name,
weighing a design tradeoff, asking the user a clarifying question. Where an
invariant looks hardenable but a hook or script provably can't verify it
(e.g. single-writer file ownership, which requires knowing *which skill* is
currently active — information no Claude Code hook payload carries), that
limit is documented explicitly as a verified dead end, not left as
unexplained soft convention.

### III. Never Suggest Ignoring More Than Is Actually Regenerated

Any `.gitignore` guidance this project gives — its own, or what
`install.sh` suggests to a target project — names the narrowest directory
that is guaranteed to be ADD-regenerated output, never a broader parent. A
broader pattern silently blocks tracking real content (`settings.json`, a
hand-written custom skill, hooks) without `-f`, and git gives no warning
when that happens. This was learned the hard way twice in the same
session, at two nested levels of the identical mistake — don't reintroduce
a third.

### IV. Two Install Targets, Never Conflated

Every script and doc in this repository is either source-side (governs
this repository only) or target-side (installed by `install.sh` into
another project and runs there). Before adding a new deterministic check or
doc, decide explicitly which side it belongs to.

### V. Deterministic Checks Are Test-First

Every code change — a deterministic script or otherwise — is preceded by a
test that exercises the behavior being added or changed, confirmed to fail
(or, for a check script, run against a deliberately-bad fixture) before the
change is considered complete. A task without a test requirement is the
exception (a pure research/decision task, or a documentation-only change),
not the default.

### VI. Simplicity / YAGNI

Complexity must be justified. Default to the simplest solution that
satisfies the requirement; introduce an abstraction only once duplication
across three or more concrete cases makes it unambiguous. Do not design for
hypothetical future requirements.

### VII. No Dead Architecture

When an approach is replaced, the old approach is deleted in the same
change — not archived in place, not left "for reference" in a directory
that no longer reflects reality. Documentation describes only what is
actually true of the current codebase.

### VIII. Check Library/Tool Idioms Before Building Custom Mechanism

Before implementing a custom mechanism to solve a problem already owned by
a depended-on tool (git, jq, the shell itself), check whether that tool
already has a built-in, idiomatic way to solve it. Reaching for a
hand-built solution without checking first is surfaced as a question
before being built, not discovered as duplicated work later.

## Quality Standards

- **Testing paradigm**: fixture-based regression tests (`tests/fixtures/
  good-*`, `tests/fixtures/bad-*`, or throwaway repos under a temp dir for
  git-state tests), verified against both a known-good and a known-bad
  case, required for every deterministic check, added in the same commit
  as the check itself.
- **Commit messages** follow Conventional Commits (`feat:`, `fix:`,
  `refactor:`, `chore:`, `docs:`, etc.).
- **Shell scripts target POSIX `sh`**, not bash-specific syntax — they may
  be installed into arbitrary target projects, and `install.sh` itself is
  `#!/usr/bin/env sh`.
- **Pre-commit Enforcement**: a pre-commit hook runs this repository's
  lint/test scripts (`scripts/lint-docs.sh`, `scripts/test-lint-project.sh`,
  `scripts/test-branch-info.sh`, `scripts/test-completion-flip-check.sh`,
  `scripts/test-sibling-tasks-complete.sh`,
  `scripts/test-sync-slug-match.sh`, `scripts/test-sync-label-decision.sh`,
  `scripts/test-sync-divergence.sh`, `scripts/test-project-lock.sh`,
  `scripts/test-hook-lint-on-write.sh`) before a commit is accepted.
  Bypassing the hook is prohibited except in a
  documented emergency, and any bypass is followed immediately by a commit
  that re-establishes the passing state.
- **No vendored dependency carries a nested `.git`**. If a dependency must
  ever be vendored, its provenance is recorded in a README note and it is
  committed as plain files, or added as a real git submodule. (Currently
  N/A — ADD vendors nothing — kept as a standing floor.)

## Development Workflow

1. When adding a new deterministic check: decide which install target it
   belongs to (Principle IV), add a CI job, and add a fixture-based
   regression test in the same commit (Principle V).
2. When editing a skill that reads or writes a shared frontmatter field,
   status enum, or `[artifacts: ...]`-style tag, check every other skill
   that touches the same field — handoffs run entirely through files on
   disk, not shared state.
3. Gitignore guidance (this repo's own, or what `install.sh` suggests) is
   re-verified against Principle III whenever a new non-skill directory is
   added under `.claude/skills/`, or a new real (non-regenerated) file is
   added under `.claude/`.

## Governance

This constitution supersedes all other practices documented in the
repository. Amendments require:

1. A written rationale explaining why the current principle is insufficient.
2. An updated Sync Impact Report (prepended as an HTML comment).
3. Version increment per semantic versioning: MAJOR for principle removal or
   redefinition; MINOR for new principle or material expansion; PATCH for
   clarifications or wording fixes.
4. `last_updated` date updated in frontmatter.

**Version**: 1.0.0 | **Ratified**: 2026-07-03 | **Last Amended**: 2026-07-03
