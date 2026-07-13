# /ardd-research

_Tier: extension_

> Targeted investigation or proposal vetting, written to .project/plans/ — one-off output with no lifecycle; substantial or decision-reversing ideas get vetted here before they reach the backlog or a plan.

<!-- generated:end — the header above is generated from skills/ardd-research/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-research <topic>                 # investigate a question
/ardd-research proposal: <the idea>    # vet a proposed change
```

Two modes, classified from the input: a *question to investigate* (library
options, API behavior, an algorithm) runs a normal investigation; a
*proposal to vet* (a change to how the system should work — anything
substantial, architecture-shaped, or reversing a committed decision)
additionally applies `/ardd-audit`'s critical lenses to the idea itself.

The line for decision reversals: a reversal you're **already sure about**
goes straight to `/ardd-feedback` (planning confirms it explicitly); one
you **still need to convince yourself of** gets vetted here first, and the
research doc's recommendation routes it onward.

## Reads

- Relevant `.project/artifacts/*.md` — decided things aren't
  re-investigated; proposals are evaluated against what the system
  actually is today
- Whatever the investigation needs: code, URLs, library docs

## Writes

- `.project/plans/research-<slug>-<date>-<hex>.md` (filename minted via
  `ardd-state.sh mint research`) — Question, Findings, Recommendation,
  Rejected Alternatives, Open Questions

## The output has no lifecycle

Nothing reads a research doc back automatically. If the recommendation is
a standing decision, fold it into the relevant artifact with
`/ardd-refine`; if it surfaces backlog-worthy scope, log it with
`/ardd-backlog`. In proposal-vetting mode the Recommendation closes with
exactly one of three routes:

- **`/ardd-backlog <description>`** — worth doing; log it and design it
  later via `/ardd-plan <slug>`
- **`/ardd-plan`** — worth doing now and well-enough understood to plan
  directly
- **drop** — with the reasoning stated, so the next person with the same
  idea finds it

## Related

- `/ardd-audit` — the same lenses, applied to decisions already recorded
- `/ardd-refine` — where standing decisions actually get captured
