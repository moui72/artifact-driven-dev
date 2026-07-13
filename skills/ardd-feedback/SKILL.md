---
name: ardd-feedback
tier: core
description: "Capture bugs/UX/reconsidered decisions from inspecting the implementation, for the next plan to consume — new-capability ideas belong in /ardd-backlog instead."
---

# /ardd-feedback

Capture feedback from manually inspecting the running implementation — bugs,
UX issues, or decisions you've reconsidered. Unlike `/ardd-audit` (Claude
challenging artifact decisions on paper), this is you reporting what you
found by actually looking at the thing. Feedback is organized into a
per-invocation file that `/ardd-plan` later consumes.

Usage: `/ardd-feedback <freeform notes>`, or run bare and paste/describe your
notes in the next message.

## Steps

1. **Collect the raw notes.** If notes were included in the invocation, use
   them. Otherwise ask the user to paste or describe what they found — do not
   interview category-by-category; let them dump everything in one pass.

2. **Classify each item** into one of:
   - **Bug** — implementation doesn't do what was intended
   - **UX** — works as intended but the experience should change
   - **Reconsidered** — a prior decision (yours or an artifact's) no longer
     holds
   - **New capability** — not a problem with existing behavior at all, but
     something the system doesn't do yet. These belong in the feature
     register (`/ardd-backlog`'s territory), not a feedback file — see the
     re-file step below.

   Split compound notes into separate items. Don't invent items the user
   didn't raise.

   **Re-file new-capability items — one batched confirmation.** If any
   items classified as new capabilities exist, present them in ONE grouped
   prompt (AskUserQuestion, multiSelect on) listing every re-file
   candidate, with per-item accept/decline inside it — never N sequential
   prompts. For each accepted item: derive a slug
   (`.claude/skills/ardd-scripts/ardd-state.sh slug "<item>"`), create the
   register entry (`printf '%s\n' "<description>" | ardd-state.sh
   feature-create <slug>`), and omit the item from the feedback file
   written in step 4. Declined items stay in the feedback file under the
   closest existing category (the user has said it isn't a feature — treat
   their judgment as final for this run).

3. **Tag each item** with the artifact(s) it touches, if identifiable (e.g.
   `[artifacts: ui]`), and a file/location reference if the user gave one.
   Leave untagged if genuinely unclear — don't force a guess.

   For **Reconsidered** items specifically, check whether the reversed
   decision is recorded in an artifact. If so, tag it — this is what tells
   `/ardd-plan` the item needs an artifact-revision task, not just a code
   change.

4. **Write** the feedback file. Choose `<slug>` (the current branch name
   or a short topic slug — sanitize either via
   `.claude/skills/ardd-scripts/ardd-state.sh slug "<text>"`), then mint
   the filename deterministically:

   ```
   .claude/skills/ardd-scripts/ardd-state.sh mint feedback <slug>
   ```

   Write to `.project/feedback/<that filename>`:

   ```yaml
   ---
   status: open      # open -> planned
   created: YYYY-MM-DD
   plan: null        # set to the consuming plan's filename once planned
   ---

   # Feedback

   ## Bugs
   - [ ] F001 <item> [artifacts: <name>]

   ## UX
   - [ ] F002 <item>

   ## Reconsidered
   - [ ] F003 <item> [artifacts: <name>]
   ```

   Every item gets a stable ID — `F001`, `F002`, … — numbered
   sequentially across the whole file (not per section). These IDs are
   how `/ardd-plan`'s bookkeeping addresses items
   (`ardd-state.sh feedback-mark <file> <id> <x|->`), so they must be
   unique within the file and never renumbered after writing.

5. **Report** the item count by category (including any items re-filed to
   the feature register in step 2) and the file path, noting that
   `/ardd-plan` will pick this up automatically. Then run `/ardd-status` now
   to reflect the open feedback count in `STATUS.md`.

## Consumption by /ardd-plan

`/ardd-plan` globs `.project/feedback/feedback-*.md` for `status: open` and
loads them as planning input alongside artifacts. Items tagged with an
artifact produce artifact-revision tasks (tagged
`[artifacts: name]`, same convention as any other plan task — no separate
mechanism in `/ardd-plan`'s tasking half or `/ardd-implement`); untagged items produce
ordinary code-change tasks.

Each item's checkbox uses the same 3-state resolution convention as
`audit.md`: `[ ]` open (not yet resolved), `[x]` incorporated into the
plan, `[-]` declined (an override the user chose not to take). `/ardd-plan`
step 4 already writes these marks as it processes each item — feedback shares
the convention rather than inventing its own.

Feedback bookkeeping finishes at `/ardd-plan`'s step-4 negotiation —
before the approval checkpoint, not once the plan is approved: as each
item's accept/decline decision lands, `/ardd-plan` marks it
(`ardd-state.sh feedback-mark`), and once every item in a file is
resolved it flips the file to `status: planned` and stamps `plan:` with
the minted plan filename in one validated step
(`ardd-state.sh feedback-planned`). A file with unresolved items stays
`open` — `feedback-planned` refuses it — and a later `/ardd-plan` run
picks up the remainder. Planned feedback files are not edited further —
they're the historical record of what prompted the plan.
