---
status: open      # open -> planned
created: 2026-07-19
plan: null
---

# Feedback

Source: Fable coverage audit of `tests/prerelease/scenarios/` vs recently
shipped surfaces (2026-07-19). All items are scenario-brief extensions —
no new S-files recommended.

## UX
- [ ] F001 Extend S1 with dynamic-badge coverage (write only after the in-flight `dynamic-badge-discoverability` branch merges, so the brief tests the fixed behavior): add a fake GitHub `origin` remote (no push), run install with `ARDD_VERSION_BADGE=1`, verify the printed snippet carries real owner/repo/branch (not `OWNER/REPO/BRANCH` placeholders), verify a re-run with markers present does not reprint the snippet, verify the default (unset) output mentions the opt-in, and verify a hand-planted wrong `github/v/release` badge inside markers draws the advisory. Why: the feature failed in the field precisely because nothing ever exercised its consumer-visible output — zero sweep coverage today.
- [ ] F002 Extend S8 with Work Queue / parallel-matrix consumer-visible checks (S8 already has the two-ready-files precondition): before delegation, run /ardd-status and verify the Work Queue section's verdicts (`independent` for the two files; `features: []` reads `none`, never `unknown`) and that the fan-out multi-select picker shows the matrix annotations; during flight, verify a same-file ready-vs-claimed pair reads `claimed`. Why: two real bugs (d06a F002/F003) came from this script and its only durable pin is shell-test level.
- [ ] F003 Extend S5 (smoke) with the bare /ardd-plan target picker: with two backlogged features present, a bare /ardd-plan must present the multi-select plannable-inputs pick (scripted answer: select one). One prompt of cost; covers a brand-new interactive surface on the highest-traffic path.
- [ ] F004 Extend S7 (smoke) with /ardd-status --view: run it, verify the summary/in-flight/next-step output, and verify STATUS.md content/mtime is untouched — single-writer discipline in a read-only mode is the actual regression risk.
- [ ] F005 Extend S7 (full-annotated) with /ardd-refine constitution --review against the consumer's lived-in constitution: judge that trim proposals are project-specific and batched for confirmation, never auto-applied. Lower priority, but zero coverage and high blast radius (it proposes removing constitution content).
- [ ] F006 Systemic: S3's "dispatcher names the most-recently-shipped features" mechanism gives new surfaces exactly one sweep of coverage, then they silently age out when something newer ships (Work Queue, bare-plan picker, rejected/subsumed all got only d06a's ad-hoc pass). Add a standing rule to the prerelease-sweep skill (or tests/prerelease/README.md): any recent-feature stress that produces a real accepted finding graduates into a durable scenario-brief step in the next coverage pass.
