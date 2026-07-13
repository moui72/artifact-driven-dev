# /ardd-feedback

_Tier: core_

> Capture bugs/UX/reconsidered decisions from inspecting the implementation, for the next plan to consume — new-capability ideas belong in /ardd-backlog instead.

<!-- generated:end — the header above is generated from skills/ardd-feedback/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-feedback <freeform notes>
/ardd-feedback            # then paste/describe everything in one message
```

This is *you* reporting what you found by actually using the built thing —
distinct from `/ardd-audit`, which is Claude challenging artifact decisions
on paper. Dump everything in one pass; the skill classifies, splits
compound notes, and never invents items you didn't raise.

## Reads

- Your notes; artifacts as needed for tagging

## Writes

- `.project/feedback/feedback-<slug>-<hex>.md` — one file per invocation
  (filename minted via `ardd-state.sh mint feedback <slug>`), frontmatter
  `status: open`, items grouped by category with stable IDs numbered
  across the whole file:

  ```markdown
  ## Bugs
  - [ ] F001 <item> [artifacts: <name>]
  ## UX
  - [ ] F002 <item>
  ## Reconsidered
  - [ ] F003 <item> [artifacts: <name>]
  ```

- `.project/features/<slug>.md` — only for items reclassified as new
  capabilities that you accept re-filing (see below)

## Behavior notes

- Items are classified **Bug** / **UX** / **Reconsidered** / **New
  capability**. New-capability items don't belong in feedback — they're
  offered for re-filing to the feature register in ONE batched
  multi-select prompt (never N sequential ones). Declined items stay in
  the feedback file; your judgment is final for the run.
- **Reconsidered** items are checked against the artifacts: if the
  reversed decision is recorded in one, the item is tagged
  `[artifacts: <name>]` — that tag is what makes `/ardd-plan` treat it as
  a decision reversal needing an explicit confirmation and an
  artifact-revision task, not just a code change.
- IDs (`F001`, …) are how `/ardd-plan`'s bookkeeping addresses items;
  they're never renumbered after writing.
- Ends by running `/ardd-status` to reflect the open feedback count.

## Consumption by /ardd-plan

The next `/ardd-plan` run loads every `status: open` feedback file (or
just the ones named as scope arguments). Each item's checkbox uses a
3-state convention: `[ ]` open, `[x]` incorporated into the plan, `[-]`
declined. Once every item is resolved, the file flips to
`status: planned` with a `plan:` pointer to the consuming plan — a
historical record, never edited again.

## Related

- `/ardd-backlog` — new capabilities
- `/ardd-audit` — Claude pressure-testing decisions, rather than you
  reporting observations
