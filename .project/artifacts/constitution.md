<!--
SYNC IMPACT REPORT
==================
Version change: 1.2.0 → 1.2.1 (PATCH — wording/naming clarification only)

Rationale: T001 of plan-repo-critique-docs-2026-07-06 (feedback item
F002): the project used "ADD" and "ARDD" interchangeably across README,
USAGE, guides, and this constitution. The user chose ARDD (2026-07-06)
as the single name — it matches every ardd-* skill name. Pure rename;
no principle, standard, or behavior changed.

Modified sections: Project Scope & Intent wording ("artifact-driven-dev
(ARDD)"); every prose "ADD" → "ARDD". Footer version updated.

Previous SIR (1.1.0 → 1.2.0, Principle II mutations + behavioral-test
tier + register decision) is in git history at this file's prior
revision.
-->

---
name: constitution
status: stable
last_updated: 2026-07-06
---

# artifact-driven-dev Constitution

## Project Scope & Intent

artifact-driven-dev (ARDD) is a Claude Code skill pack: markdown-defined
slash commands (`skills/*/SKILL.md`) installed into other projects via
`install.sh`, plus a small number of POSIX shell scripts for the parts of
the system that must be deterministic rather than left to LLM judgment.
There is no runtime application, database, or user interface belonging to
ARDD itself — the product is prose instructions an LLM executes in a target
project, plus the install/lint tooling that supports them. `datamodel.md`,
`infrastructure.md`, and `ui.md` accordingly do not exist for this project
and are not expected to: none of the concerns they own apply here.

ARDD is narrower in scope than Spec Kit, not lighter in absolute terms: it
assumes the user arrives with architectural clarity and needs a system to
capture, cross-check, and execute against decisions already made, rather
than a framework that discovers those decisions through structured
elicitation. See `README.md`'s "When artifacts earn their keep" for when
that overhead is actually worth it — for this repository specifically, it's
worth it because there is no external target codebase to serve as an
implicit spec for what ARDD itself should do next; the skills, scripts, and
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

### II. Deterministic Checks and Mutations Over Prose, Wherever the Operation Is Actually Mechanizable

Any invariant that is a pure function of file state on disk — a status
enum, a required frontmatter field, a cross-reference that must resolve, a
doc that must name a real skill — gets a real deterministic script, not
reliance on an LLM reading instructions carefully every time. The same
rule applies to state *mutations*: any transition that is itself a pure
function of file state — a status flip, a checkbox mark, a frontmatter
stamp, a register append — is performed by a script (`ardd-state.sh` and
its siblings) that validates before writing, never by the LLM hand-editing
markdown per prose instructions. Skill prose decides *when* a mutation
happens; scripts do the *writing*. Prose is reserved for what genuinely
requires judgment: deciding a branch name, weighing a design tradeoff,
asking the user a clarifying question. Where an
invariant looks hardenable but a hook or script provably can't verify it
(e.g. single-writer file ownership, which requires knowing *which skill* is
currently active — information no Claude Code hook payload carries), that
limit is documented explicitly as a verified dead end, not left as
unexplained soft convention.

### III. Never Suggest Ignoring More Than Is Actually Regenerated

Any `.gitignore` guidance this project gives — its own, or what
`install.sh` suggests to a target project — names the narrowest directory
that is guaranteed to be ARDD-regenerated output, never a broader parent. A
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
- **Behavioral smoke tests**: skill behavior is verified by
  fixture-project smoke scenarios — a minimal installable target project,
  a headless `claude -p "/ardd-<skill>"` run, and deterministic
  assertions on file outcomes (expected files exist, statuses legal per
  `lint-project.sh`, single-writer files untouched) — required for
  state-mutating skill paths. This is a second tier alongside
  fixture-based regression tests: regression tests verify the scripts;
  smoke tests verify the skills invoke them to the right end state. CI
  smoke jobs may run conditionally (path-filtered, secret-gated) but
  must exist.
- **Commit messages** follow Conventional Commits (`feat:`, `fix:`,
  `refactor:`, `chore:`, `docs:`, etc.).
- **Shell scripts target POSIX `sh`**, not bash-specific syntax — they may
  be installed into arbitrary target projects, and `install.sh` itself is
  `#!/usr/bin/env sh`.
- **Pre-commit Enforcement**: a pre-commit hook (`hooks/pre-commit`,
  enabled per clone via `git config core.hooksPath hooks`) runs
  `scripts/lint-docs.sh`, `scripts/lint-project.sh`, and **every**
  `scripts/test-*.sh`, discovered by glob — never an enumerated list —
  before a commit is accepted. A new test script is therefore enforced
  the moment it exists, in the same commit that adds its CI job, with no
  list to remember to extend (v1.0.0 enumerated ten scripts and silently
  fell four behind CI; that pattern is prohibited here for the same reason
  Principle II prohibits it generally). A test too slow for the hook is a
  signal to make it faster, not grounds for an exclusion list; if a
  deliberate exclusion is ever truly needed, it must be an explicit,
  visible opt-out marker, not an omission. Bypassing the hook is
  prohibited except in a documented emergency (e.g. committing a
  deliberate test-first red state, stated in the commit body), and any
  bypass is followed immediately by a commit that re-establishes the
  passing state.
- **Feature register format (standing decision, 2026-07-06)**: the
  feature register is **per-feature files** at
  `.project/features/<slug>.md`, not a single `features.md` — merge and
  parse robustness win over single-file glanceability, especially for
  collaborative mode and tracker sync. Schema per file — frontmatter,
  required: `slug`, `status` (`backlogged|planned|tasked|implemented`),
  `logged` (YYYY-MM-DD); optional: `plan` and `tasks` (filenames of the
  binding plan/tasks files), `gh_issue` (issue number). Body: a
  one-sentence description, optionally followed by a `Why:` line.
  Register-wide views are produced by enumeration (glob), never by a
  second hand-maintained index file. This decision was made explicitly
  (repo critique, 2026-07-06) — do not re-litigate it when touching
  register tooling; amend it here first if it ever needs to change.
- **No vendored dependency carries a nested `.git`**. If a dependency must
  ever be vendored, its provenance is recorded in a README note and it is
  committed as plain files, or added as a real git submodule. (Currently
  N/A — ARDD vendors nothing — kept as a standing floor.)

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

**Version**: 1.2.1 | **Ratified**: 2026-07-03 | **Last Amended**: 2026-07-06
