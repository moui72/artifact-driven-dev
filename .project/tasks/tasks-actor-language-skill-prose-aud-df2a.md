---
plan: plan-actor-language-skill-prose-aud-2026-07-14-d4b6.md
generated: 2026-07-14
status: ready   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Per-skill actor-language pass

- [ ] T001 [parallel] Review `skills/ardd-init/SKILL.md` for ambiguous
  `you`/`your`/`I`/`we` usage (flagged lines ~69, 74, 102, 104, 209, 274,
  307: "in your own words", "what you're trying to surface", "summarize
  what you...", "a principle you're about to synthesize", "merge into your
  default branch", "which you can reuse"). Where the referent is the agent
  conducting the interview (e.g. "your own words" = the agent's own
  words), rewrite to name "the agent" explicitly. Where the referent is
  the human answering interview questions (e.g. "your default branch"),
  rewrite to "the user('s) ..." if ambiguous in context, otherwise leave
  as-is. No test requirement — documentation-only change (Principle V
  exception).
- [ ] T002 [parallel] Review `skills/ardd-plan/SKILL.md` for ambiguous
  pronouns (flagged lines ~77, 136, 213, 286, 297, 304, 350). Pay
  particular attention to line 350's "the plan you just wrote" — the agent
  wrote it, the human is re-reading it at the approval checkpoint — resolve
  to name the correct actor explicitly at each site. No test requirement.
- [ ] T003 [parallel] Review `skills/ardd-feedback/SKILL.md` for ambiguous
  pronouns (flagged lines ~10, 11, 15, 27: "decisions you've
  reconsidered", "this is you reporting what you found", "your notes").
  Rewrite to "the user" explicitly — the skill's stated purpose is
  distinguishing human observation from agent-side critique
  (`/ardd-audit`), so the pronoun should not be ambiguous here. No test
  requirement.
- [ ] T004 [parallel] Review `skills/ardd-update/SKILL.md` for ambiguous
  pronouns (flagged lines ~10, 12, 100: "without you having to remember",
  "in your own session", "merge into your default branch" — the last
  inside an AskUserQuestion prompt string). Rewrite the prose occurrences
  to "the user". For the AskUserQuestion string, decide whether quoted UI
  copy needs the same treatment as narrator prose (this plan's Open
  Questions flags it as undecided) and apply consistently; record the
  decision in this task's completion note so T011 can check consistency
  against it. No test requirement.
- [ ] T005 [parallel] Review `skills/ardd-backlog/SKILL.md` for ambiguous
  pronouns (flagged lines ~14, 15: "you accumulate a backlog", "you think
  of one"). Both refer to the user; rewrite for explicitness only if doing
  so doesn't produce an awkward sentence — direct second-person address of
  the user throughout a paragraph may already be unambiguous style rather
  than a referent problem. Use judgment; leaving text unchanged with a
  documented reason is an acceptable outcome. No test requirement.
- [ ] T006 [parallel] Review `skills/ardd-defects/SKILL.md` for ambiguous
  pronouns (flagged frontmatter `description:` line ~4, and line ~27:
  "report what you saw", "a bug you noticed"). Both refer to the user;
  rewrite, including the frontmatter description string. Before editing
  the frontmatter string, check `scripts/lint-project.sh` for any
  length/format constraint on `description:` that the rewrite must
  respect. No test requirement.
- [ ] T007 [parallel] Review `skills/ardd-audit/SKILL.md` for ambiguous
  pronouns (flagged line ~104: "if you cannot write a tight command" —
  addresses the agent performing the audit step, plus any other
  occurrence found on a full read of the file). Rewrite to name "the
  agent" explicitly, or restructure the conditional to avoid the pronoun
  entirely. No test requirement.
- [ ] T008 [parallel] Review `skills/ardd-status/SKILL.md` for ambiguous
  pronouns (flagged line ~26: "anytime you want a fresh check" — the
  user). Rewrite to "the user". No test requirement.
- [ ] T009 [parallel] Review `skills/ardd-refine/SKILL.md` for ambiguous
  pronouns (flagged line ~105: "if you find one written inline" —
  addresses the agent performing the refine). Rewrite to "the agent". No
  test requirement.
- [ ] T010 [parallel] Review `skills/ardd-implement/SKILL.md` for
  ambiguous pronouns (flagged line ~134: "On `folded=true` you..." —
  addresses the agent executing the fold step). Rewrite to "the agent".
  No test requirement.

## Phase 2: Consistency pass

- [ ] T011 After T001–T010 are complete, grep all `skills/*/SKILL.md` for
  residual `\byou\b|\byour\b|\bI\b|\bwe\b|\bour\b` matches and confirm
  every remaining hit corresponds to a deliberate leave-as-is call made in
  one of T001–T010 (not a miss). Run `./scripts/lint-docs.sh` and
  `./scripts/lint-project.sh` and confirm both pass clean. No test
  requirement beyond running these two existing lint scripts.
