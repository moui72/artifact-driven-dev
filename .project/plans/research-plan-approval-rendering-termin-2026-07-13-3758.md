---
topic: Better plan presentation at the approval checkpoint — terminal vs. browser rendering
date: 2026-07-13
status: complete
---

# Research: Better Plan Presentation at the Approval Checkpoint

## Question

At `/ardd-plan`'s approval checkpoint (step 10), how should the plan be
shown to the user so approving it is an informed decision rather than a
keystroke? Two sub-questions were raised:

1. Can the plan be rendered *nicely in the terminal*?
2. Should ARDD offer *opt-in rendered-markdown browser viewing* of the plan?

Object classification: a **proposal to vet** (browser viewing) bundled with
a **question to investigate** (terminal rendering). Vetted against the
current `ardd-plan` skill and the constitution.

## Findings

### What the approval checkpoint does today

`ardd-plan` step 10 ("Approval checkpoint") instructs the agent to *"Present
a summary to the user — phases, key decisions, open questions"* as ordinary
model output, note the saved file path, then call `AskUserQuestion` with
Approve / Revise / Stop. The full plan already lives on disk as good
markdown at `.project/plans/plan-<slug>-<date>-<hex4>.md`.

Two things follow that matter for this question:

- **The terminal already renders markdown.** Claude Code displays model
  output outside tool use as GitHub-flavored markdown in the terminal —
  headers, **bold**, tables, ordered/unordered lists, task checkboxes, and
  fenced code all render. So "render nicely in the terminal" is not a
  missing *capability*; the renderer is already there and idiomatic.
- **The real gap is a lossy re-summary, not weak rendering.** Step 10 asks
  the agent to *re-summarize* the plan freehand. Its fidelity depends on the
  LLM, and it can drift from what the plan file actually says. The plan file
  itself is already well-structured markdown (Goal / Scope / Technical
  Approach / Phase Breakdown / Open Questions per step 8). So the highest-
  leverage improvement is to present the plan's real structure faithfully —
  a bolded Goal line, a phase table with task/dependency columns, and the
  verbatim Open Questions list — rather than a free-form paraphrase.

### The browser-viewing proposal, through the lenses

- **Standardness / Tool idioms (Principle VIII).** The "tool" that owns
  readable rendering here is Claude Code's own terminal markdown renderer —
  it already exists. More to the point, the plan is a real `.md` file on
  disk, and *every* editor (VS Code, JetBrains, Vim plugins, `glow`, a
  browser markdown extension) already offers a rendered preview of a local
  markdown file. A user who wants a browser-quality rendered view already
  has one, with zero ARDD mechanism, offline, and with the content never
  leaving their machine. Building a browser path reinvents a solved problem.

- **Failure modes / robustness.** The only mechanism ARDD could use for
  in-harness browser rendering is the `Artifact` tool, which *publishes the
  content to claude.ai* (default-private, but hosted, cacheable, indexable).
  Plans today never leave the developer's machine; routing plan bodies —
  which carry proprietary design detail for arbitrary consumer projects —
  through an external service is a real change in data handling, not a
  cosmetic one. That is exactly the kind of outward-facing action the
  harness says to confirm each time; baking it into an approval checkpoint
  that fires on every plan is the wrong default.

- **Portability / robustness (single-surface dependency).** ARDD is a skill
  pack installed via `install.sh` into arbitrary consumer projects and run
  mostly from the CLI — frequently over SSH, and (per working style) from a
  phone. The `Artifact` tool and a live browser aren't uniformly available
  across those surfaces, and in a plain terminal session an artifact URL is
  just a link the user must leave the session to open — it is not "in the
  terminal" and doesn't answer sub-question 1 at all. A skill's behavior
  must degrade cleanly on the lowest-common-denominator surface; a
  browser-first presentation doesn't.

- **Simplicity / YAGNI (Principle VI).** The motivating evidence is one
  user's felt friction at the checkpoint — not a demonstrated inadequacy of
  terminal markdown. Principle VI says introduce mechanism only once the
  need is unambiguous. Terminal markdown plus the on-disk file cover the
  need; a second rendering channel is speculative surface area.

- **No dead architecture (Principle VII).** A browser path that's rarely the
  active surface would be mechanism that mostly doesn't run — the kind of
  low-traffic branch VII exists to keep out.

### Reversed decisions

None. This proposal wouldn't reverse a recorded decision; the browser half
is simply declined on the grounds above. The terminal-presentation
improvement is fully compatible with step 10 as written (it refines the
"Present a summary" instruction, keeps the Approve/Revise/Stop gate intact,
and touches no state or frontmatter).

### Is it worth it?

- **Terminal presentation refinement: yes** — small, portable, no new
  dependency, and aimed squarely at the actual friction (lossy re-summary).
- **Browser viewing: no** — it externalizes plan content, depends on a
  surface-specific capability absent from the CLI/SSH/phone sessions ARDD
  targets, and duplicates the rendered-preview any editor already gives the
  on-disk `.md`. Fails VI and VIII; the escape hatch (open the file) is
  strictly better than the feature.

## Recommendation

**Two routes, one for each half:**

1. **Backlog the terminal-presentation refinement** —
   `/ardd-backlog improve /ardd-plan's approval checkpoint to present the
   plan's real structure (bolded Goal, a phase table with task-count and
   dependency columns, verbatim Open Questions) instead of a free-form
   re-summary, and explicitly point the user at the on-disk plan file for a
   full rendered preview in their editor`. It's a self-contained prose
   change to `ardd-plan` step 10 (and the parallel presentation moment in
   `/ardd-status`/`/ardd-audit` if worth aligning), well-understood enough
   that `/ardd-plan <slug>` can design it directly.

2. **Drop the opt-in browser-viewing idea.** Recorded here so the next
   person who proposes "render the plan in a browser" finds the reasoning:
   terminal markdown already renders the plan; the plan is a local `.md`
   file every editor previews offline with no ARDD mechanism; and the only
   in-harness browser path (`Artifact`) publishes plan content to claude.ai,
   which is an availability regression on CLI/SSH/phone surfaces and an
   externalization of otherwise-local design detail. If evidence later
   changes — e.g. a concrete request tied to a surface where the terminal
   renderer genuinely can't cope — reopen with that evidence per Principle VI.

## Rejected Alternatives

- **Make browser rendering the default at the checkpoint** — rejected:
  publishes content externally on every plan and breaks on non-browser
  surfaces. Worst option on both robustness and portability.
- **Write a standalone HTML render of the plan to disk and tell the user to
  open it** — rejected: produces a redundant artifact next to the `.md` that
  is already the source of truth, and editors already preview the `.md`.
  New mechanism for zero marginal capability (VI/VII).
- **Use `AskUserQuestion`'s `preview` field to show the plan** — rejected:
  previews are designed for comparing *between* options side by side, not
  for displaying one long document; a plan doesn't fit that shape, and the
  approval question is already a structured UI element without it.
- **Leave step 10 exactly as-is** — rejected only for the summary half: the
  free-form re-summary is the genuine friction, and refining it is cheap.

## Open Questions

- Should the refined presentation *inline* the plan's phase table, or stay a
  tight summary plus a "full plan at `<path>`" pointer? Lean summary+pointer
  to keep the checkpoint scannable — settle during `/ardd-plan` design.
- Do `/ardd-status` and `/ardd-audit` have the same freehand-summary
  friction at their own review moments, and is it worth aligning all three
  in one pass? Assess when planning the backlog item; don't presume yes.
