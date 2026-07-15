---
status: planned
created: 2026-07-15
plan: plan-discovery-to-work-eager-captur-2026-07-15-156b.md
---

# Feedback

## UX
- [x] F001 Discovery limbo: after an /ardd-init context-dump session, foundational scope that couldn't be built in-session ends up documented in artifacts but nothing in the machinery ever turns it into an implementable plan — it strands there unless the user hand-runs /ardd-backlog. Observed in atelier: the whole projects-and-multiple-works concept is in artifacts with no register entry.
- [x] F002 Pivot limbo: after an /ardd-refine pivot, the new-capability delta is maximally salient in-session but refine's contract ends at the artifact write, so the user must explicitly backlog the new scope by hand. Observed in sync-tab-scroll: the no-auth → auth-for-catalogue-management pivot required hand-backlogging the catalogue-management parts.
- [x] F003 /ardd-defects is almost the artifact→register bridge (it diffs artifacts against the codebase) but frames every gap as drift/defect, which is wrong for greenfield unbuilt scope — a whole undocumented-in-code subsystem isn't a defect and would flood DEFECTS.md. Gaps of the "documented but never built" kind need routing toward the backlog instead.
