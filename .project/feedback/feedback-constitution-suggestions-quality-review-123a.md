---
status: planned      # open -> planned
created: 2026-07-13
plan: plan-constitution-suggestions-quality-2026-07-13-4de0.md
---

# Feedback

Source: review of `templates/constitution-suggestions.md`, goal: better
encourage quality agent-written code in greenfield projects.

## Bugs
- [x] F001 The CI Enforcement entry's suggested text references "the pre-commit hook" (templates/constitution-suggestions.md:154), violating the catalog's own self-containment rule (lines 10-13): accepting CI while rejecting Pre-commit leaves dangling constitution text. Fix by merging Pre-commit + CI into one Deterministic Gates entry (preferred) or rewording CI to stand alone.

## Reconsidered
- [x] F002 Remove the Performance Budgets entry (templates/constitution-suggestions.md:119) — agents can't measure a budget, "defined per feature when added" is process overhead that never changes generated code, and in greenfield it's speculative in exactly the way the YAGNI entry warns against.
- [x] F003 Remove the Component/Handler Reference Cleanup entry (templates/constitution-suggestions.md:125) — a memorialized single-project bug, too niche for a catalog slot, and the suggested text is hard to parse ("documented at the point of definition — not left as a bare comment").
- [x] F004 Remove the No Vendored Dependency With a Nested .git entry (templates/constitution-suggestions.md:167) — near-zero greenfield relevance (agents essentially never vendor deps), and "cheap to ask" undersells the permanent context tax of an accepted entry.
- [x] F005 Move Production Annotations (templates/constitution-suggestions.md:49) out of Always-suggest to the portfolio/demo signal section alongside Explicit Leniency Scoping — it presumes shortcuts are being taken, which mainly holds for portfolio/demo/internal projects; the two entries are complementary (scoping names the categories, annotations mark the point of use) and could merge.
- [x] F006 Reword Single Source of State (templates/constitution-suggestions.md:71) stack-neutrally: the text presumes "a reactive store" exists, the rationale's tail ("…instead of just using the store that already exists") is leftover project-specific prose, and its signal mentions ui.md while the entry sits in the backend section — fix the section placement too.
- [x] F007 Add catalog entry: never weaken a failing test to reach green (Always) — deleting, skipping, or loosening an assertion to get green is prohibited without explicit callout; the fix is to the code or, with stated justification, a deliberately changed expectation. The enforcement teeth Test-First currently lacks.
- [x] F008 Add catalog entry: tests assert behavior, not implementation (Always, or fold into Test-First) — a test must fail if the behavior it covers breaks; a test that only mirrors the implementation or asserts on its own mocks doesn't satisfy the test-first requirement.
- [x] F009 Add catalog entry: no silent error swallowing (Always) — a caught error is either recovered from meaningfully or re-raised; catch-and-continue with only a log line is a documented exception, not a pattern.
- [x] F010 Add catalog entry: no backwards-compatibility shims in greenfield (Always, or fold into No Dead Architecture as a second sentence) — no wrapper functions, `_v2` suffixes, or re-export layers "for compatibility" in code with zero external consumers.
- [x] F011 Add catalog entry: dependencies are decisions (signal: manifest exists) — adding a dependency is an explicit decision surfaced in the plan, not a default; prefer the standard library and dependencies already present.
- [x] F012 Add catalog entry: type-system strictness (signal: statically-typed language, pairs with Named Types) — strict mode on; `any`, unchecked casts, and suppression comments each require adjacent justification.
- [-] F013 Add catalog entry: secrets/config hygiene (Always; weaker candidate, fine to decline) — no credentials in source, config through environment.
- [x] F014 Add the curation criterion to the catalog's header prose: an entry earns a slot only if it (a) targets a failure mode agents/contributors actually exhibit, and (b) states a bright-line rule checkable at write time — so future additions get filtered the way the self-containment rule already filters phrasing.
