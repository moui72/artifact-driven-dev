---
status: approved
branch: plan-approval-presentation
created: 2026-07-13
features: [plan-approval-presentation]
surfaced-defects: []
---

# Plan: Faithful plan presentation at the approval checkpoint

## Goal

Replace `/ardd-plan`'s freehand plan re-summary at the approval checkpoint
(SKILL.md step 10) with a faithful, bounded presentation drawn from the
plan's own sections, plus an explicit pointer to the on-disk plan file for
the full rendered text.

## Scope

**In scope**
- Rewrite `skills/ardd-plan/SKILL.md` step 10's "Present a summary"
  instruction to present three decision-relevant elements verbatim from the
  drafted plan — the **Goal** line, a **phase table**, and the **Open
  Questions** list — and to invite the user to open the saved `.md` in their
  editor / markdown preview for the complete plan.
- Confirm the terminal-rendering framing (Claude Code already renders
  GitHub-flavored markdown; the file is the full-fidelity view) is stated so
  no future reader re-proposes a browser path.
- Verify the user-facing docs that mention the checkpoint
  (`docs/guides/core-loop.md`, `docs/reference/skills/ardd-plan.md`) remain
  accurate; update only if they describe the presentation format (they
  currently describe the *gate*, not the format — expected no-op, but
  verified, not assumed).

**Out of scope**
- Browser / `Artifact`-tool rendering of the plan — vetted and dropped in
  `research-plan-approval-rendering-termin-2026-07-13-3758.md` (externalizes
  plan content; unavailable on CLI/SSH/phone surfaces; the on-disk `.md`
  already previews in any editor).
- Any change to `/ardd-status` or `/ardd-audit`. Assessed: `/ardd-status`
  already emits a fixed structured report template and `/ardd-audit` writes
  a findings checklist; neither presents a plan for an approve-decision, so
  neither carries the lossy-re-summary friction this plan fixes. No
  alignment work is warranted (resolves the research doc's open question).
- Any script, frontmatter-schema, or `lint-project.sh` enum change — this is
  a prose-only change to one SKILL.md.

## Technical Approach

The deliverable is skill prose (Principle I — a `SKILL.md` edit is a
behavior change to every install, treated like a public-API change). The
new step 10 presentation instruction specifies, in order:

1. **Goal** — reproduce the plan's Goal sentence verbatim, bolded; do not
   paraphrase it.
2. **Phase table** — a markdown table with columns `Phase | Delivers |
   Depends on`, one row per phase in the drafted Phase Breakdown. Critically,
   the checkpoint runs *before* tasking (step 12), so there are no `T###`
   IDs or final task counts yet — the table draws only on the Phase
   Breakdown's described increments and their stated dependencies. The
   instruction must say so explicitly, so the agent doesn't invent a
   task-count column it cannot populate. (An optional count of the Phase
   Breakdown's enumerated work-items per phase is permitted where the draft
   listed them, labeled as plan items, never as tasks.)
3. **Open Questions** — reproduce the plan's Open Questions list verbatim
   (not summarized); these are exactly what the user weighs before approving.
4. **File pointer** — state the saved path (as today) and add an explicit
   invitation to open it in an editor or markdown preview for the full plan
   (Scope, Technical Approach, Complexity Tracking, etc.). Frame the
   terminal view as the decision-relevant skeleton and the file as the
   full-fidelity source.

The existing Approve / Revise / Stop `AskUserQuestion` gate is unchanged —
this plan touches only what is shown before that question, not the gate
itself. The instruction stays a summary-plus-pointer (scannable), not a
full inline dump of the plan (resolves the research doc's inline-vs-pointer
open question toward pointer).

## Phase Breakdown

Single phase — one focused SKILL.md edit plus verification.

### Phase 1: Rewrite step 10 and verify docs

- Rewrite `skills/ardd-plan/SKILL.md` step 10's presentation instruction per
  the four-element structure above, preserving the Approve/Revise/Stop gate,
  the saved-path note, and the pre-tasking honesty about task counts.
  `[artifacts: constitution]` (Principle I care — public-API-grade edit).
- Grep `docs/guides/core-loop.md` and `docs/reference/skills/ardd-plan.md`
  (and `docs/concepts.md`, `docs/index.md`) for any description of *how* the
  plan is presented at the checkpoint; update to match only if one exists.
  Run `scripts/lint-docs.sh` to confirm no skill-name references broke.
- Manually confirm the rewritten step reads correctly against a real drafted
  plan (this very plan file is a fixture): the Goal, a phase table, and Open
  Questions can all be produced verbatim from its sections.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| None | The change reduces agent latitude (freehand summary → bounded template) and introduces no new abstraction, script, or state. Net simplification under Principle VI. |

## Open Questions

- None blocking. The two questions the research doc raised are resolved in
  this plan: presentation stays summary-plus-pointer (not full inline), and
  `/ardd-status`/`/ardd-audit` are confirmed out of scope.
