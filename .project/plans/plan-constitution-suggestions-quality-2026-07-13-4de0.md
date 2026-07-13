---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: constitution-suggestions-quality   # the branch inline implementation would use; may never be created
created: 2026-07-13
features: []
surfaced-defects: []
---

# Plan: Constitution-suggestions catalog quality revision

## Goal

Revise `templates/constitution-suggestions.md` so the catalog better
encourages quality agent-written code in greenfield projects — fixing its
one self-containment defect, cutting weak entries, and adding entries that
target documented agent failure modes.

Source: `feedback-constitution-suggestions-quality-review-123a.md` (F001
bug + F002–F012, F014 reconsidered; F013 declined). Design calls settled
with the user: F008 folds into Test-First rather than standing alone; F010
is a standalone entry; F013 (secrets hygiene) is out.

## Scope

**In:** `templates/constitution-suggestions.md` (all edits), one prose sync
in `skills/ardd-init/SKILL.md` (line ~222 names "Pre-commit Enforcement" as
the named subsection — becomes "Deterministic Gates"), and a
reference-docs check for stale entry names.

**Out:** any change to `/ardd-init`'s filter/dedupe/present mechanics; any
change to already-installed targets' constitutions (the catalog is offered
only at constitution creation — existing installs are unaffected by
design); the declined F013 secrets entry.

## Technical Approach

Single-file prose revision, installed to targets via `install.sh` as
`ardd-constitution-data/constitution-suggestions.md` (source/target split:
the template is target-side content, edited source-side). Every new/reworded
entry must obey the catalog's existing self-containment rule and the new
header curation criterion (F014): target a real agent/contributor failure
mode, state a bright-line rule checkable at write time. No new
deterministic check ships — the catalog is LLM-consumed prose with no
schema; `lint-docs.sh` continues to cover skill-name references
(Constitution Principle V applies only to deterministic checks, none added
here). Template-prose edits are the documentation-shaped exception to
test-first.

## Phase Breakdown

### Phase 1 — Header + structural edits (F014, F002–F005)
- T: Add the curation criterion to the catalog header prose (F014).
- T: Remove Performance Budgets (F002), Component/Handler Reference
  Cleanup (F003), No Vendored Dependency With a Nested `.git` (F004).
- T: Move Production Annotations from Always-suggest to the
  portfolio/demo signal section, alongside Explicit Leniency Scoping,
  keeping both as separate entries (complementary, per F005).

### Phase 2 — Merges and rewording (F001, F006, F008)
- T: Merge Pre-commit Enforcement + CI Enforcement into one
  self-contained "Deterministic Gates" entry (F001); sync
  `skills/ardd-init/SKILL.md`'s "(or the named subsection, for Pre-commit
  Enforcement)" prose.
- T: Reword Single Source of State stack-neutrally (one owner per piece
  of state; no mutable objects threaded by reference), drop the
  project-specific rationale tail, and fix its section placement so the
  signal and section agree (F006).
- T: Fold "tests assert behavior, not implementation" into the
  Test-First entry's suggested text (F008) — a test must fail if the
  behavior it covers breaks; mock-asserting/implementation-mirroring
  tests don't satisfy the requirement.

### Phase 3 — New entries (F007, F009–F012)
- T: Add "Never Weaken a Failing Test" (Always) — F007.
- T: Add "No Silent Error Swallowing" (Always) — F009.
- T: Add "No Backwards-Compatibility Shims in Greenfield" (Always,
  standalone) — F010.
- T: Add "Dependencies Are Decisions" (signal: manifest exists) — F011.
- T: Add "Type-System Strictness" (signal: statically-typed language,
  adjacent to Named Types) — F012.

### Phase 4 — Verification
- T: Self-containment + curation-criterion review pass over the final
  catalog (every entry standalone, bright-line rule present, ordering
  note in the header still accurate) and run `./scripts/lint-docs.sh`;
  grep docs/skills for the removed/renamed entry names to catch stale
  references.

## Complexity Tracking

None — this plan removes more than it adds (21 entries → 20) and
introduces no new mechanism, script, or check. No deviations to justify
under Principle VI.

## Open Questions

None — the three judgment calls (F008 fold, F010 standalone, F013
decline) were settled during feedback negotiation.
