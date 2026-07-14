---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: actor-language-skill-prose-aud
created: 2026-07-14
features: []
surfaced-defects: []
---

# Plan: Actor-language audit of skill prose

## Goal

Bring every `skills/*/SKILL.md` file into compliance with constitution
Principle IX ("Unambiguous Actor Language in Agent-Facing Prose") by
resolving ambiguous "you"/"your"/"I"/"we" pronouns into explicit terms —
"the user"/"the human" for the person running ArDD, "the agent"/"Claude"
for the automated actor executing the skill — wherever the referent isn't
already unambiguous from context.

## Scope

**In scope**: the 14 files under `skills/*/SKILL.md` — the product
surface Principle I designates for this level of care. Grep confirms 10 of
the 14 contain at least one `you`/`your`/`I`/`we`/`our` occurrence worth
reviewing (`ardd-init`, `ardd-plan`, `ardd-feedback`, `ardd-update`,
`ardd-backlog`, `ardd-defects`, `ardd-audit`, `ardd-status`, `ardd-refine`,
`ardd-implement`); the remaining 4 (`ardd-diagram`, `ardd-lint`,
`ardd-research`, `ardd-tracker`) have none and need no edit.

**Out of scope**: `CLAUDE.md`, `README.md`, `USAGE.md`, and other
human-facing docs (Principle IX targets agent-facing prose specifically);
`docs/decisions/*` (historical record, not instructions); AskUserQuestion
option-text strings already written as imperative/quoted dialogue rather
than pronoun-bearing prose (e.g. "Yes — run `/ardd-implement` now") — those
already read unambiguously as UI copy, not narrator voice. This plan does
not touch templates or scripts.

## Technical Approach

Principle IX only requires new/edited prose to use explicit terms, not a
mandatory sweep — but the user has asked for a full review now, so this
plan performs one. For each in-scope file: read every `you`/`your`/`I`/
`we`/`our` occurrence in context, classify it (ambiguous person/agent
referent → rewrite explicitly; unambiguous from surrounding context, e.g.
addressing the reader-as-implementer in a way both actors would read
identically → leave as-is with no edit), and apply only the rewrites that
actually remove ambiguity. This is a judgment call per occurrence, not a
mechanical find/replace — a script can't tell "you" (the user) from "you"
(the agent) from context, which is exactly why Principle II leaves this to
prose review rather than a lint rule.

## Phase Breakdown

### Phase 1: Per-skill actor-language pass (each task independent — `[parallel]`)

- [ ] T001 [parallel] Review `skills/ardd-init/SKILL.md` — 6 occurrences
  flagged (lines ~69, 74, 102, 104, 209, 274, 307): "in your own words",
  "what you're trying to surface", "summarize what you...", "a principle
  you're about to synthesize", "merge into your default branch", "which
  you can reuse". Several address the agent performing the interview
  ("your own words" = the agent's own words) — rewrite those to name "the
  agent" explicitly; the ones addressing the human answering interview
  questions ("your default branch") stay `you`/`your` only if unambiguous
  in context, otherwise become "the user's default branch".
- [ ] T002 [parallel] Review `skills/ardd-plan/SKILL.md` — 7 occurrences
  (lines ~77, 136, 213, 286, 297, 304, 350). Most are agent-instruction
  voice ("you actually choose to work an idea", "the plan you just wrote")
  where the referent flips between the human (choosing, approving) and the
  agent (drafting) within the same sentence in places — resolve each to
  name the correct actor explicitly, especially line 350's "the plan you
  just wrote", which is genuinely ambiguous (the agent wrote it; the human
  is the one re-reading it at this checkpoint).
- [ ] T003 [parallel] Review `skills/ardd-feedback/SKILL.md` — 4
  occurrences (lines ~10, 11, 15, 27): "decisions you've reconsidered",
  "this is you reporting what you found", "your notes". These describe the
  human's manual-inspection act — rewrite to "the user" explicitly since
  the skill's whole premise is distinguishing human observation from
  agent-side critique (`/ardd-audit`), so leaving the pronoun ambiguous
  undercuts the skill's own stated purpose.
- [ ] T004 [parallel] Review `skills/ardd-update/SKILL.md` — 3 occurrences
  (lines ~10, 12, 100). Mixed: "without you having to remember" (the user),
  "in your own session" (the user), "merge into your default branch" (the
  user, in an AskUserQuestion prompt string — verify whether that string
  counts as UI copy already out of scope per this plan, or needs the same
  treatment as the analogous ardd-init line).
- [ ] T005 [parallel] Review `skills/ardd-backlog/SKILL.md` — 2
  occurrences (lines ~14, 15): "you accumulate a backlog", "you think of
  one" — both clearly the user; rewrite for explicitness only if doing so
  doesn't make the sentence awkward (these read as directly addressing the
  user in second person throughout the paragraph, which may be acceptable
  style rather than referent ambiguity — use judgment per the Technical
  Approach).
- [ ] T006 [parallel] Review `skills/ardd-defects/SKILL.md` — 2
  occurrences (frontmatter `description:` line ~4, and line ~27): "report
  what you saw", "a bug you noticed" — both the user; rewrite, including
  the frontmatter description string (verify `lint-project.sh` has no
  length/format constraint on `description:` that this would violate).
- [ ] T007 [parallel] Review `skills/ardd-audit/SKILL.md` — 2 occurrences
  (lines ~104 and one more found on full read): "if you cannot write a
  tight command" — addresses the agent performing the audit step; rewrite
  to "the agent" or restructure as a conditional not keyed to a pronoun.
- [ ] T008 [parallel] Review `skills/ardd-status/SKILL.md` — 1 occurrence
  (line ~26): "anytime you want a fresh check" — the user; rewrite.
- [ ] T009 [parallel] Review `skills/ardd-refine/SKILL.md` — 1 occurrence
  (line ~105): "if you find one written inline" — addresses the agent
  performing the refine; rewrite to "the agent".
- [ ] T010 [parallel] Review `skills/ardd-implement/SKILL.md` — 1
  occurrence (line ~134): "On `folded=true` you..." — addresses the agent
  executing the fold step; rewrite to "the agent".

### Phase 2: Consistency pass

- [ ] T011 After T001–T010 land, grep all `skills/*/SKILL.md` for residual
  `\byou\b|\byour\b|\bI\b|\bwe\b|\bour\b` and confirm every remaining hit
  was a deliberate leave-as-is call (documented in this plan's task list
  above), not a miss. Run `./scripts/lint-docs.sh` and
  `./scripts/lint-project.sh` to confirm nothing broke.

## Open Questions

- Does the `next_step_prompt` AskUserQuestion option-text convention
  ("Yes — run `/ardd-<next>` now") ever need actor language, or does its
  quoted-dialogue framing make it exempt by construction? T004 surfaces one
  concrete instance (`ardd-update`) to decide against.
- Should this same pass extend to `templates/constitution-suggestions.md`
  and `templates/artifacts/*.md` (agent-facing seed content, arguably
  in-scope under Principle IX's "other agent-facing prose this repository
  controls" clause)? Left out of this plan's scope deliberately — flag as
  a follow-up feedback item if the answer turns out to be yes, rather than
  scope-creeping this run.

## Production Annotation Summary

N/A — this plan makes no production shortcuts.
