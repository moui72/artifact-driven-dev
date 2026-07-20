---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: amend-path-policy
created: 2026-07-20
features: []
surfaced-defects: []
---

# Plan: Factual-corrections exemption + citation-rot guidance

## Goal

Give factual corrections to skill-written `.project/` files a sanctioned,
explicitly-stated path (a narrow hand-edit exemption, not new machinery),
and stop skills from instructing agents to write line-number citations
that are guaranteed to rot.

## Scope

**In:** the exemption rule's exact text and its placement everywhere an
agent or reviewer actually reads (installed reviewer guide, reference
docs, the writing skills' own prose, source-side CLAUDE.md); a sweep of
skill prose that tells agents to emit code citations, switching the
preference to symbol-based references.

**Out:** any `--amend` flag, `ardd-state.sh` amend subcommand, or other
mechanized amend path — F001's alternative resolution, rejected here
because correcting prose is judgment work below the deterministic bar
(constitution Principle VI shape: don't script judgment). Also out:
retro-editing existing `.project/` historical files; the rule is
forward-looking.

## Technical Approach

Resolve F001 by **exemption, not machinery**. The rule, stated once
canonically and echoed where relevant:

> **Factual corrections are exempt from the no-hand-edit rule.** A
> factual correction fixes content that is *wrong on the page* without
> re-deciding anything: a mis-cited file or symbol, a stale path, a
> typo, a wrong quotation. Anyone (human or agent) may hand-edit these
> in place, in any skill-written file's body prose. The exemption never
> covers frontmatter `status` fields, checkboxes, or any lifecycle
> state — those stay script-mutated (`ardd-state.sh`) — and never covers
> decisions, scope, or classifications: changing *what was decided* goes
> through the workflow (`/ardd-feedback`, `/ardd-refine`, a new plan).

Canonical home: `templates/dot-project-readme.md` (the installed
reviewer guide — it already explains static-record semantics, and it is
what downstream reviewers are pointed at). Echoes: the two skills whose
prose currently implies frozen-forever ("not edited further" in
`skills/ardd-feedback/SKILL.md:122` and `skills/ardd-plan/SKILL.md:332`),
`docs/reference/project-files.md`, README's workflow-discipline section,
and source-side `CLAUDE.md`'s single-writer list (one clause).

Resolve F002 by a prose sweep: wherever a skill instructs the agent to
record a code location (e.g. `/ardd-feedback` step 3's "file/location
reference", `/ardd-defects`' claims, `/ardd-audit` findings), prefer
`path + symbol name` (function, script, section heading) over bare line
numbers; line numbers allowed only as a supplementary hint. This makes
citations self-healing and shrinks the very class of factual error F001
exists to correct.

Prose-only change set — no scripts, no schema/enum changes, no test
tasks (Principle V prose exception); `lint-docs.sh` remains the check.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

**Phase 1 — Codify the exemption (F001).**
- Write the rule into `templates/dot-project-readme.md` as a short
  "Correcting a skill-written file" subsection.
- Echo it at `skills/ardd-feedback/SKILL.md` and `skills/ardd-plan/SKILL.md`
  ("not edited further" → "(factual corrections exempt — see rule)"),
  `docs/reference/project-files.md`, README, and CLAUDE.md.

**Phase 2 — Citation-rot sweep (F002), after Phase 1.**
- Sweep `skills/*/SKILL.md` (and `templates/artifacts/*.md`) for
  citation-emitting instructions; switch each to symbol-preferred
  phrasing.

## Open Questions

- None blocking. (Boundary question — does the exemption cover register
  files' body prose? — resolved in the rule text: body prose yes,
  frontmatter/lifecycle state no.)
