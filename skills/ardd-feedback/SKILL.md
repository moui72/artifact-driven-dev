# /ardd-feedback

Capture feedback from manually inspecting the running implementation — bugs,
UX issues, or decisions you've reconsidered. Unlike `/ardd-critique` (Claude
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

   Split compound notes into separate items. Don't invent items the user
   didn't raise.

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

5. **Report** the item count by category and the file path, noting that
   `/ardd-plan` will pick this up automatically. Then run `/ardd-analyze` now
   to reflect the open feedback count in `STATUS.md`.

## Consumption by /ardd-plan

`/ardd-plan` globs `.project/feedback/feedback-*.md` for `status: open` and
loads them as planning input alongside artifacts. Items tagged with an
artifact produce artifact-revision tasks (tagged
`[artifacts: name]`, same convention as any other plan task — no separate
mechanism in `/ardd-tasks` or `/ardd-implement`); untagged items produce
ordinary code-change tasks.

Each item's checkbox uses the same 3-state resolution convention as
`critique.md`: `[ ]` open (not yet resolved), `[x]` incorporated into the
plan, `[-]` declined (an override the user chose not to take). `/ardd-plan`
step 5 already writes these marks as it processes each item — feedback shares
the convention rather than inventing its own.

Once the plan is approved, `/ardd-plan` flips
each consumed feedback file to `status: planned` and stamps `plan:` with its
own filename. Planned feedback files are not edited further — they're the
historical record of what prompted the plan.
