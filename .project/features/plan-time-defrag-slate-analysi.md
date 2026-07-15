---
slug: plan-time-defrag-slate-analysi
status: backlogged
logged: 2026-07-15
---

Plan-time 'defrag'/slate analysis: an advisory, recomputed-at-plan-time footprint analysis over open backlog items proposing session-optimized slates — bundles of items with overlapping code footprints (implement together, serially, in one plan) and pairwise-disjoint sets (separate tasks files for worktree fan-out).
Why: get maximum wallclock value from an implement session against a large backlog. Never stored in the register (computed/mechanical/ephemeral — distinct from the declared/semantic/durable epics-grouping-in-feature-regi); every footprint estimate grounded in actual greps of the codebase. Spec source: the 2026-07-15 prototype /ardd-research run in sync-tab-scroll (research-backlog-defrag-slate-analysis-2026-07-15-627c.md), whose key requirements: dependency ordering is a third axis beyond file overlap (overlap != parallelizable); grade footprint confidence and never place speculative-footprint items in parallel sets; read item status from the register directly, never STATUS.md counts; handle degenerate N=0/N=1 backlogs (the method may also apply within one epic-sized item).
Suggested first step: a second /ardd-research prototype pass against a genuinely large backlog — e.g. atelier after backlog-sweep-reconcile-from-a backfills its limbo scope into the register — to validate the cross-item case before codifying a /ardd-plan slate mode.
