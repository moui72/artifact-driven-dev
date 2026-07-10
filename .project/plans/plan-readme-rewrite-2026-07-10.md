---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: readme-rewrite
created: 2026-07-10
features: []
surfaced-defects: []
---

# Plan — README.md rewrite to reflect current state

## Goal

Bring `README.md` back into correspondence with what ARDD actually is and
does, correcting counted/structural drift and closing the one substantive
documentation gap (`workflow_mode`).

## Scope

**In scope** — `README.md` only.

**Not in scope**, deliberately:

- `USAGE.md` and `guides/*.md`. The feedback named the README. Those files
  have their own drift risk, but folding them in triples the diff and they
  merge-conflict with each other (the 2026-07-06 docs plan learned this: its
  README/USAGE-touching items had to ride one branch). If a read of the
  README surfaces a claim that only makes sense once USAGE also changes,
  log it via `/ardd-feedback` rather than widening this plan.
- The generated skill tables. `gen-skill-docs.sh` owns those three tables and
  `lint-docs.sh --check` currently passes, so they are correct by
  construction. No task may hand-edit them; a task that changes a skill
  *description* edits that skill's frontmatter and re-runs the generator.
- Skill behavior. This plan changes no `SKILL.md`, no script, no artifact.

## Technical Approach

The README is prose, so the "approach" is mostly a discipline: **verify each
claim against the repo before rewriting it, never against the README's own
account of itself** (the feedback says this explicitly, and it is the reason
the drift accumulated). Three sources of truth, in order: the shipped
`skills/*/SKILL.md` frontmatter and prose; the actual behavior of
`install.sh` / `new.sh`; and `constitution.md`. Where README prose and
`CLAUDE.md` disagree about repo architecture, `CLAUDE.md` is the more
recently maintained of the two and wins unless the code says otherwise.

Drift confirmed during planning (evidence, not conjecture):

| Claim | Reality |
|---|---|
| "~18 skills" (line 7) | 21 skills in `skills/` |
| "Project structure created" block | Omits `features/`, `feedback/`, `STATUS.md`, `DEFECTS.md`, `WORKFLOW.md`, and `.claude/skills/ardd-scripts/` |
| "Like `workflow_mode`, it's a frontmatter workflow field" (line 110) | `workflow_mode` is referenced exactly once and defined nowhere in the README |

The third is the only *substantive* gap: solo vs. collaborative mode governs
whether work may be committed to the local default branch, and a
collaborative-mode user who never reads `CLAUDE.md` has no way to learn it
exists. The first two are mechanical.

## Phase Breakdown

**Phase 1 — Establish ground truth.** Read every README claim against the
repo and produce a written drift inventory (in the tasks file, not a new
artifact): claim, location, verdict (accurate / stale / dangling / missing).
No edits yet. This phase exists so the rewrite is bounded by evidence rather
than by taste, and so Phase 3's judgment calls are visible before they're
made. Depends on nothing.

**Phase 2 — Correct the mechanical drift.** [feedback: F001] Fix what Phase 1
proved wrong and needs no design judgment: the skill count, and the
"Project structure created" block (add `features/`, `feedback/`,
`STATUS.md`, `DEFECTS.md`, `WORKFLOW.md`, `.claude/skills/ardd-scripts/`,
each with a one-line gloss). Prefer a claim that cannot rot over a precise
one that can — "the skills" beats "~18 skills" beats "21 skills", since the
count changes every time a skill lands. Depends on Phase 1.

**Phase 3 — Close the `workflow_mode` gap.** [feedback: F001] Document solo
vs. collaborative as a short section near the existing `next_step_prompt`
prose (they are siblings: both are `constitution.md` frontmatter workflow
fields, both asked once at bootstrap, neither bumps the constitution
version). State the operative difference — collaborative never commits to
the *local* default branch, and its in-flight channel is a pushed draft PR
rather than `inflight-worktrees.sh` — and resolve the dangling "Like
`workflow_mode`" reference by making it point at something real. Source the
content from `CLAUDE.md`'s "Two operating modes" and `lint-project.sh`'s
enum; do not invent behavior. Depends on Phase 2 (same region of the file).

**Phase 4 — Coherence pass.** [feedback: F001] Read the rewritten file
start to finish as a first-time reader. Fix ordering damage the earlier
phases didn't cause but did expose — notably the dangling
"For an existing project, use `install.sh` directly:" line that ends the
Quickstart section by introducing the `## Install` heading that follows it.
Confirm every internal anchor link still resolves. Depends on Phases 2–3.

**Verification** for every phase: `./scripts/lint-docs.sh` (skill-name and
generated-table drift) must pass, and the diff must touch `README.md` alone.
There is no behavioral test for prose; the pre-commit hook covers the rest.

## Complexity Tracking

None. This plan adds no abstraction, no script, and no state. Constitution
Principle VI (mechanization) is not engaged: the drift this plan fixes is
prose, and `lint-docs.sh` already mechanizes the one part that *can* be
checked deterministically (skill names and generated tables).

## Open Questions

1. **Should the skill count be stated at all?** Phase 2 recommends removing
   the number rather than correcting it — a count is drift-by-construction.
   The counter-argument is that "disciplined, not lightweight" is a real and
   useful warning to a reader deciding whether to adopt ARDD, and a bare
   "the skills" understates the surface area. Resolve during Phase 2; either
   answer is defensible, but decide deliberately rather than by default.

2. **Does `workflow_mode` belong in the README at all, or only in
   `CLAUDE.md`?** This plan assumes the README, because the field is set by
   `/ardd-bootstrap` in a *target* project whose author may never read this
   repo's `CLAUDE.md`. If Phase 3 finds the explanation can't be made short,
   a pointer to a guide is an acceptable outcome.

## Production Annotation Summary

None. No shortcuts are taken and no code ships.
