---
status: open      # open -> planned
created: 2026-07-03
plan: null
---

# Feedback

## Bugs
- [ ] `/ardd-plan` loads open feedback (`.project/feedback/feedback-*.md`) as planning input but never reads `.project/DEFECTS.md`, so drift findings from `/ardd-verify` sit unaddressed unless someone manually copies them into a feature or feedback item — no path from "defect logged" to "task planned" exists today. Fix: add a step to `/ardd-plan` (alongside its existing feedback-loading step) that reads `.project/DEFECTS.md`, presents any listed defects to the user, and — on confirmation — includes a fix task per accepted defect in the drafted plan. Since `DEFECTS.md` has no per-item status/checkbox (it's a full-overwrite report, unlike feedback files), plan needs its own way to track which defects were already surfaced, to avoid re-prompting on the same ones every run — decide the tracking mechanism alongside the actual `/ardd-plan` edit, not here.

## UX

## Reconsidered
