---
plan: plan-constitution-suggestions-quality-2026-07-13-4de0.md
generated: 2026-07-13
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

All edits target `templates/constitution-suggestions.md` unless stated.
Every new or reworded entry must obey the catalog's self-containment rule
(no reference to sibling entries by name or number — any entry acceptable
while its neighbors are rejected) and, once T001 lands, the header's
curation criterion. Template prose has no test suite; T012 is the
verification gate.

## Phase 1: Header + structural edits

- [x] T001 Add the curation criterion to the catalog's header prose (after the self-containment paragraph, before the Signals paragraph): an entry earns a slot only if it (a) targets a failure mode agents/contributors actually exhibit, and (b) states a bright-line rule checkable at the moment code is written — aspirational statements with no checkable moment don't qualify. (F014)
- [x] T002 [parallel] Delete three entries wholesale: "Performance Budgets for User-Observable Operations" (UI section), "Component/Handler Reference Cleanup Across Framework Lifecycle Hooks" (UI section), and "No Vendored Dependency With a Nested `.git`" (Lower-priority hygiene section). Remove each entry's full block (heading through Rationale); leave section headings in place if other entries remain under them. (F002, F003, F004)
- [x] T003 Move the "Production Annotations" entry out of "Always suggest" into the "Signal: project frames itself as portfolio/demo/internal" section, after Explicit Leniency Scoping, keeping both as separate entries. Change its Signal line from "Always" to match that section's signal (Project Scope & Intent frames this as a portfolio, demo, or internal-only project). Suggested text and Rationale stay as they are. (F005)

## Phase 2: Merges and rewording

- [x] T004 Merge "Pre-commit Enforcement" and "CI Enforcement" into one entry, "Deterministic Gates" (Section: Quality Standard subsection; Signal unchanged: stack with lint/type-check tooling available), in the same catalog position. Suggested text must be self-contained and cover: lint, type-check, and test suite run in CI on every push/PR with a failing run blocking merge (CI is the gate of record); the same checks run in a local pre-commit hook as an earlier, cheaper catch that never substitutes for CI (a hook can be skipped or never installed); hook bypass only in a documented emergency, immediately followed by a commit re-establishing the passing state. Merge the two Rationales into one. (F001)
- [x] T005 Sync `skills/ardd-init/SKILL.md` step 5's apply bullet (~line 222): "(or the named subsection, for Pre-commit Enforcement)" → "(or the named subsection, for Deterministic Gates)". Grep the rest of skills/ and docs/ for "Pre-commit Enforcement" and "CI Enforcement" to catch any other stale reference. (F001)
- [x] T006 Reword "Single Source of State" stack-neutrally: each piece of shared application state has one owning module/store per runtime; other modules read from and write through that owner, never by threading shared mutable objects between modules by reference. Drop the rationale's project-specific tail ("…instead of just using the store that already exists for this purpose") in favor of a neutral statement (hand-rolled shared-state objects produce non-obvious data flow and untraceable mutation). Resolve the section/signal mismatch: keep it in the backend/service section with the signal reworded to match ("infrastructure.md or ui.md describes a runtime with meaningful in-memory state" is fine — the section intro line must not claim backend-only). (F006)
- [x] T007 Fold behavior-not-implementation into the "Test-First Development" entry's Suggested text: add that a test must fail if the behavior it covers breaks — a test that merely mirrors the implementation or only asserts that its own mocks were called does not satisfy this requirement. Extend the Rationale with one sentence on vacuous tests. Keep the entry self-contained and its existing text otherwise intact. (F008)

## Phase 3: New entries

- [x] T008 [parallel] Add "Never Weaken a Failing Test" to "Always suggest" (Section: Core Principle, Signal: Always), after Test-First Development. Suggested text: when a test fails, the fix is to the code or — with stated justification — a deliberately changed expectation; deleting, skipping, or loosening an assertion to reach a passing state is prohibited unless explicitly called out and justified in the change. Rationale: quietly weakened tests convert a failing suite into false confidence; the suite only means anything if red can't be resolved by lowering the bar. (F007)
- [ ] T009 [parallel] Add "No Silent Error Swallowing" to "Always suggest" (Section: Core Principle, Signal: Always). Suggested text: a caught error is either recovered from meaningfully (the operation can genuinely continue) or re-raised/propagated; catch-and-continue with only a log line — or nothing — is a documented, per-site exception, never a default pattern. Rationale: swallowed errors turn failures into silent corruption discovered far from their cause. (F009)
- [ ] T010 [parallel] Add "No Backwards-Compatibility Shims in Greenfield" to "Always suggest" (Section: Core Principle, Signal: Always). Suggested text: code with no external consumers carries no compatibility indirection — no wrapper functions preserving an old signature, no `_v2`-style parallel names, no re-export layers "for compatibility"; when a signature or module changes, every call site is updated in the same change. Rationale: compatibility shims in never-shipped code are pure debt — they accumulate immediately and protect no one. (F010)
- [ ] T011 [parallel] Add two signal-gated entries: (a) "Dependencies Are Decisions" (Section: Quality Standard; Signal: a package manifest exists — place in the Lower-priority hygiene section next to Manifest/Script Hygiene): adding a dependency is an explicit, surfaced decision, not a default — prefer the standard library and dependencies already present; a new dependency is named in the plan/change description with what it's for. Rationale: dependency sprawl is easy to add and expensive to audit or remove. (b) "Type-System Strictness" (Section: Core Principle; Signal: statically-typed language — place in the statically-typed section adjacent to Named Types Over Inline Duplication): the strictest practical compiler settings are on from the start; escape hatches (`any`-equivalents, unchecked casts, suppression comments) each require an adjacent justification at the use site. Rationale: escape hatches added under pressure silently disable the type system exactly where it was needed most. (F011, F012)

## Phase 4: Verification

- [ ] T012 Review pass over the final catalog: every entry self-contained (no sibling references by name or number — including the new/merged ones), every entry meets the T001 curation criterion, header's ordering/numbering prose still accurate, section intro lines match the entries under them, and entry count is 20. Run `./scripts/lint-docs.sh` (must pass). Grep skills/, docs/, README.md, USAGE.md, CONTRIBUTING.md for the removed/renamed entry names ("Performance Budgets", "Component/Handler Reference Cleanup", "No Vendored Dependency", "Pre-commit Enforcement", "CI Enforcement") — zero stale references outside docs/decisions (exempt) and .project/ history files.
