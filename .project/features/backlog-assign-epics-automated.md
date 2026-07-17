---
slug: backlog-assign-epics-automated
status: backlogged
logged: 2026-07-17
---

An automated /ardd-backlog --assign-epics pass over the current feature register, open feedback, and DEFECTS.md that proposes epic: groupings for related items, batched for confirmation rather than applied silently.
Why: the epics-grouping-in-feature-regi feature added the epic field and manual by-epic views, but assigning epic values to existing/new items is still entirely manual — this closes that gap the same way the plan-time-defrag-slate-analysi feature's --slate mode automates footprint-based grouping, but for the coarser, declared/semantic epic dimension instead.

Origin: a manual epic-assignment sweep run against atelier's real 12-item
backlog (2026-07-17) confirmed no assignment tooling exists —
`plan-epics-grouping-in-feature-regi` explicitly scoped out any
recommendation/picker UI, shipping only the field, filter, and
`/ardd-status` breakdown.

What the manual process looked like (useful as a spec sketch for whoever
plans this):
1. Read every backlogged feature's status + description + `Why:` line
   (one grep/sed pass over `.project/features/*.md`).
2. Propose groupings by thematic clustering — in that run, 4 emerged
   cleanly: a shipping-format pair, a spellcheck-hardening trio, a
   looser "authoring surfaces" bucket, and a "platform hardening"
   bucket (one speculative item, LLM assistance, didn't obviously
   belong anywhere).
3. Present the grouping for approval before writing anything
   (`AskUserQuestion`) — options like "apply all" / a conservative
   partial subset / "let me adjust."
4. Apply `epic:` frontmatter directly to each feature file — no
   `/ardd-refine` path exists for register entries today, so this was
   hand-edited (frontmatter + the `logged:` anchor line).
5. Verify with `lint-project.sh` and `feature-list.sh --all`.
6. Re-run the `/ardd-status` by-epic breakdown and commit.

Pain points worth designing around:
- **No epic-suggestion skill exists.** This needs a fresh `/ardd-*`
  skill (e.g. `/ardd-epics`, or an `/ardd-backlog --group` mode) —
  neither `/ardd-plan` nor `/ardd-refine` targets feature-register
  frontmatter directly today.
- **Ambiguous fit is real.** Not every feature clusters cleanly (the
  LLM-assistance judgment call above). A sweep skill should surface
  low-confidence assignments distinctly, or leave them unassigned,
  rather than force every feature into a bucket.
- **No register-write path exists for `epic:` alone.** Whatever skill
  does this needs its own frontmatter-stamping mechanism, parallel to
  `ardd-state.sh stamp` for constitution fields — features aren't
  `/ardd-refine` targets.
- **Should be re-runnable, not one-shot.** As new features get
  backlogged individually via `/ardd-backlog`, there's currently no
  prompt to assign or reconsider epic membership — a sweep needs to
  handle "some already tagged, some new" incrementally, not just a
  cold full-backlog pass.
- **Confirmation-gated**, matching the rest of ArDD's mutating skills —
  should never auto-write `epic:` values without the user approving the
  grouping first (matches `/ardd-backlog --from-artifacts` and the
  register-flip exception in `/ardd-status`).
