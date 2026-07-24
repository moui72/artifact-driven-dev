---
topic: status-md-trim-prune-history
date: 2026-07-24
status: complete
---

# Research: Trimming/pruning STATUS.md update history

## Question

`/ardd-status`'s step-6 "prepend-and-preserve" rule makes `.project/STATUS.md`
grow without bound: every run prepends a new `_Updated:` block and preserves
all prior blocks verbatim. In long-running projects this file gets large (this
repo's is already **193 KB / 1937 lines / 6 blocks**, ~300 lines per block).
Should ArDD add a method to trim/prune older history to keep it slim — and if
so, how, without losing the durable re-entry chronology the file exists to
provide?

## Findings

### What the current design guarantees, and why

`ardd-status` SKILL.md step 6 ("Prepend-and-preserve") states each new
`_Updated:` entry is *"prepended as a new top block, and every prior
`_Updated:` block already in the file is preserved verbatim below it — never
summarized away, condensed, or replaced."* The stated rationale: STATUS.md is
*"the single re-entry point after any interruption"* — *"durable re-entry
chronology, not a point-in-time snapshot."* CLAUDE.md echoes single-writer
ownership: `/ardd-status` is STATUS.md's only writer.

The invariant bundles **two separable promises**:
1. **No lossy rewriting** — blocks are never summarized/condensed (which would
   need LLM judgment each run and could silently drop or distort re-entry
   facts). This is the promise that actually protects re-entry integrity.
2. **Unbounded retention** — *all* blocks stay in the live file forever. This
   is what causes the bulk, and it is the weaker of the two promises.

### The key observation that unblocks pruning

**STATUS.md is git-tracked and committed.** The full chronology is already
durably preserved in git history — `git log -p .project/STATUS.md` recovers
every block ever written, verbatim, with timestamps. So "durable chronology"
does **not** require unbounded length in the *live* file; durability comes
from version control, not from never deleting lines. The live file only needs
enough *recent* chronology for practical re-entry after an interruption.

This reframes the reversed decision narrowly: we keep promise #1 intact
(never summarize) and relax only promise #2 (retain everything), replacing it
with *retain the most recent N verbatim; older blocks are pruned but
recoverable from git.*

### Lens pass on the proposal

- **Simplicity** — a keep-last-N tail trim is simpler than the status quo's
  de-facto "grow forever," and far simpler than a summarize/condense variant.
  Favors a deterministic count-based cut, not judgment.
- **Failure modes** — the dangerous failure is pruning a block still needed
  for re-entry. Mitigated by (a) keeping a generous N of recent blocks, and
  (b) git recoverability. A trim must be **verbatim-preserving up to the cut**
  — never rewrite kept blocks. Deleting mid-file content risks corrupting the
  non-chronology header (artifact table / open-questions) if that lives
  outside the `_Updated:` blocks — the trim must target only the `_Updated:`
  chronology tail, never the head matter.
- **Standardness** — "keep last N, rely on VCS for the rest" is the ordinary
  way logs/changelogs are bounded; nothing reinvented.
- **Robustness/fragility** — must stay inside the single-writer boundary:
  only `/ardd-status` may prune, in the same write it already owns. A separate
  skill or hook touching STATUS.md would break ownership. Determinism
  (Principle II) argues the tail-cut itself should be a **script**
  (`status-prune.sh <file> --keep N`) with a fixture regression test, not
  free-hand LLM deletion — the count is mechanical, so it should not depend on
  LLM compliance.
- **DRYness** — the retention policy (N) should live in one place. A
  constitution frontmatter workflow field (e.g. `status_history_keep: <N>`,
  absent = unbounded, preserving today's behavior for existing installs) fits
  the existing `workflow_mode`/`next_step_prompt` pattern and keeps the number
  out of skill prose.
- **Semantics** — "prune" must mean *drop older verbatim blocks*, never
  *summarize*. Naming and prose must keep promise #1 explicit so a future edit
  doesn't slide into lossy condensation.
- **Proportionality** — at 193 KB the cost is real (re-read cost, context
  bloat, diff noise). A bounded default is proportionate; an archive-file
  scheme is over-engineered (see Rejected Alternatives).

### Decisions this reverses (and where they're recorded)

- `skills/ardd-status/SKILL.md` step 6 "Prepend-and-preserve" — the
  *unbounded-retention* clause specifically ("every prior block … preserved
  verbatim below it"). The *never-summarized* clause is **kept**.
- CLAUDE.md's "single-writer ownership" and "STATUS.md grows over time by
  design" note — the latter softens from "grows forever" to "grows, bounded to
  the last N verbatim blocks; older history lives in git."

Both are skill/product prose, not `.project/artifacts/` content, so there is no
artifact to `/ardd-refine` — the change lands in SKILL.md + CLAUDE.md, i.e. a
`feat:` skill-behavior change.

## Recommendation

**Worth doing — it's already backlogged (`status-md-trim-prune-history`);
design it with `/ardd-plan status-md-trim-prune-history`.** Concrete shape:

1. Add a deterministic `scripts/status-prune.sh <file> --keep <N>` that removes
   `_Updated:` blocks beyond the newest N, touching only the chronology tail
   (never head matter, never kept blocks), plus a fixture regression test —
   installed to `ardd-scripts` like the other target-side scripts.
2. Add a constitution workflow frontmatter field `status_history_keep: <N>`
   (absent = unbounded, so existing installs are unchanged), settable via
   `ardd-state.sh stamp`, asked once by `/ardd-init` and offerable via
   `/ardd-update --reconfigure` — same pattern as `workflow_mode`.
3. `/ardd-status` step 6 calls `status-prune.sh` after its prepend when the
   field is set, and the SKILL.md/CLAUDE.md prose is updated to the narrowed
   invariant: *recent N blocks preserved verbatim; older blocks pruned
   (recoverable from git), never summarized.*

The never-summarize promise stays intact; only unbounded retention is relaxed,
and git backstops recoverability.

## Rejected Alternatives

- **Summarize/condense old blocks in place** — reverses the *right* half of
  the invariant (the one protecting re-entry integrity), needs LLM judgment
  every run, non-deterministic, and can silently distort facts. Reject.
- **Archive old blocks to `.project/STATUS-archive.md`** — redundant with git
  (which already archives verbatim), adds a second file to keep consistent,
  and re-introduces bulk in a different filename. Reject unless a project is
  known not to commit `.project/` (not the ArDD assumption).
- **Age-based cap (drop blocks older than X days)** — coupling retention to
  wall-clock is fragile for bursty or dormant projects (a quiet week could
  leave one stale block; a busy day could evict everything). Count-based
  keep-last-N is steadier. Age could be a later option, not the default.
- **A separate `/ardd-prune` skill** — breaks single-writer ownership; the
  trim belongs inside STATUS.md's sole writer.

## Open Questions

- **Default N.** If `status_history_keep` is set, what's a sensible suggested
  value — 3? 5? — for the `/ardd-init` prompt? (Blocks are large, so even
  N=3 is a big cut here.)
- **Whether to prune on this repo (self-hosted).** This repo dogfoods its own
  `.project/`; adopting the field here would immediately slim its 193 KB file.
  Decide during planning whether to set it as part of the same change.
- **Head matter vs. chronology.** Confirm during design whether STATUS.md's
  non-`_Updated` sections (artifact table, open questions) are emitted as a
  stable head block or interleaved — the prune script's block boundary depends
  on it. (In this repo the file is effectively all `_Updated:` blocks, but the
  script must be robust to the documented structure.)
