# Constitution Suggestions

A catalog of well-known, battle-tested principles/standards that
`/ardd-init` offers — never assumes — when a project's
`constitution.md` is first created. Order is deterministic and becomes the
numbering order for accepted Core Principles (in the order presented here,
after any principles already synthesized from conversation or inferred from
code).

Each entry's **Suggested text** is self-contained: no reference to other
principles by number, and no reference to other catalog entries by name.
Any entry can be accepted while its neighbors are rejected — wording must
not depend on a sibling being present.

Signals are read from what the invoking skill already knows: which
artifacts are being created (`/ardd-init` step 3 / its codebase survey, step
3), and stack/framework facts already established (the conversation on the
greenfield path, the codebase survey on the existing-codebase path). When a signal is ambiguous,
treat it as met — bias toward offering, not toward filtering out.

---

## Always suggest

### Test-First Development
**Section:** Core Principle
**Signal:** Always
**Suggested text:** Every code change is preceded by a test that exercises the behavior being added or changed, written and confirmed to fail before any implementation code is written. A task without a test requirement is the exception (a pure research/decision task, or a documentation-only change), not the default.
**Rationale:** Writing the test first documents intent before implementation bias sets in, and catches regressions immediately rather than after the fact. Without an explicit principle, skills and contributors tend to assume a testing discipline informally until a gap in coverage surfaces the hard way.

### Simplicity / YAGNI
**Section:** Core Principle
**Signal:** Always
**Suggested text:** Complexity must be justified. Default to the simplest solution that satisfies the requirement; introduce an abstraction only once duplication across three or more concrete cases makes it unambiguous. Do not design for hypothetical future requirements.
**Rationale:** Premature abstraction is harder to remove than to add, and speculative flexibility usually guesses wrong about what actually changes later.

### No Dead Architecture
**Section:** Core Principle
**Signal:** Always
**Suggested text:** When an approach is replaced, the old approach is deleted in the same change — not archived in place, not left "for reference" in a directory that no longer reflects reality. Documentation describes only what is actually true of the current codebase.
**Rationale:** Leftover dead code and stale docs actively mislead the next reader (human or agent) into building on or trusting something that no longer applies.

### Check Library Idioms Before Building Custom Mechanism
**Section:** Core Principle
**Signal:** Always
**Suggested text:** Before implementing a custom mechanism to solve a problem in a concern already owned by a depended-on library, check whether that library already has a built-in, idiomatic way to solve it. Reaching for a hand-built solution without checking first is surfaced as a question before being built, not discovered as duplicated work later.
**Rationale:** Hand-built mechanisms that duplicate a library's own built-in behavior create a maintenance burden and a recurring class of bugs where the custom logic and the library's internal assumptions drift out of sync.

### Production Annotations
**Section:** Core Principle
**Signal:** Always
**Suggested text:** Any implementation decision that would be unsafe, impractical, or architecturally wrong in a real production system is annotated at the point of use, under a `## Production Annotations` heading in the relevant artifact — never as inline prose elsewhere — describing what the shortcut does and what the correct production approach would be.
**Rationale:** Reviewers and future contributors should see that a shortcut was a deliberate, understood tradeoff — not an oversight — and know where to look to find every one of them.

---

## Signal: a backend/service exists (`infrastructure.md` and/or `datamodel.md` present)

### Observability
**Section:** Core Principle
**Signal:** `infrastructure.md` or `datamodel.md` is among the artifacts being created
**Suggested text:** Non-trivial operations emit structured, machine-readable log events, including outcome (success/failure) and identifiers sufficient to reproduce an error without a debugger attached.
**Rationale:** Silent failures in a running service erode trust and turn debugging into guesswork; structured logs make failures visible before a user has to report them.

### Migrations Required for Schema Changes
**Section:** Core Principle
**Signal:** `datamodel.md` is among the artifacts being created, and persistent storage is implied
**Suggested text:** Changes to the persisted data shape are made through a migration, never by hand-editing data in place or relying on an ORM's implicit sync in an environment with real data.
**Rationale:** Ungoverned schema drift between environments is one of the most common sources of "works locally, breaks in staging/production" failures.

### Single Source of State
**Section:** Core Principle
**Signal:** `infrastructure.md` and/or `ui.md` describe a client or server runtime with meaningful in-memory state
**Suggested text:** Application state lives in one reactive store per runtime. Shared mutable objects threaded by reference between modules, as a substitute for the store, are not permitted; modules that need to see the same state read from and write through the store.
**Rationale:** Hand-rolled shared-state objects produce non-obvious data flow and require a comment justifying the workaround instead of just using the store that already exists for this purpose.

---

## Signal: a statically-typed language is in play

### Named Types Over Inline Duplication
**Section:** Core Principle
**Signal:** The project uses a statically-typed language (e.g. TypeScript, a typed ORM schema)
**Suggested text:** A type used in more than one place is a named, exported type with a single source of truth — not independently retyped at each usage site, even when the inline shapes happen to match today.
**Rationale:** Structurally identical inline types give the type system no way to flag a future divergence; a shared name is what keeps two usage sites in sync as one of them changes.

---

## Signal: an API surface exists (`api.md` being created, or routes/RPC observed)

### RESTful Conventions
**Section:** Quality Standard
**Signal:** `api.md` describes an HTTP API that is resource-oriented (not GraphQL/RPC/WebSocket-only)
**Suggested text:** API resources are addressed by noun-based, resource-oriented URLs; HTTP methods carry the verb. Endpoints that don't fit this shape are the documented exception, not the default pattern.
**Rationale:** Consistent resource addressing makes an API's surface predictable to a new caller without needing to read every endpoint's documentation individually.

### Consistent Error Shape Across Endpoints
**Section:** Quality Standard
**Signal:** `api.md` is among the artifacts being created
**Suggested text:** Every endpoint returns errors in one consistent shape (status code plus a machine-readable code and human-readable message), regardless of which handler produced the error.
**Rationale:** Callers otherwise have to special-case error handling per endpoint, and inconsistent shapes are a common source of client-side bugs that only surface on the error path.

### API Versioning Strategy
**Section:** Quality Standard
**Signal:** `api.md` describes a public or externally-consumed API
**Suggested text:** Breaking changes to a public endpoint's request or response shape ship under a new version rather than mutating the existing one in place; the versioning scheme is stated explicitly.
**Rationale:** Without a stated strategy, the first breaking change forces an ad hoc decision under time pressure instead of following a rule agreed on in advance.

---

## Signal: a UI exists (`ui.md` being created)

### Baseline Accessibility
**Section:** Quality Standard
**Signal:** `ui.md` is among the artifacts being created
**Suggested text:** UI is reasonably usable without a mouse or perfect vision: logical tab order, readable contrast, labeled form controls. Full WCAG 2.1 AA compliance is a separate, explicit decision — state here whether this project requires it or is scoped to this baseline only.
**Rationale:** Baseline accessibility costs little when designed in from the start and is expensive to retrofit; naming the bar explicitly avoids an unstated assumption in either direction.

### Performance Budgets for User-Observable Operations
**Section:** Quality Standard
**Signal:** `ui.md` is among the artifacts being created
**Suggested text:** Any user-observable operation where latency matters (page load, a real-time update, a search result) has a stated performance budget, defined per feature when the operation is added.
**Rationale:** Without a stated budget, performance regressions are only caught after a user notices, rather than checked against an agreed threshold as the feature ships.

### Component/Handler Reference Cleanup Across Framework Lifecycle Hooks
**Section:** Quality Standard
**Signal:** `ui.md` names a reactive framework (React, Vue, Svelte, Alpine, or similar)
**Suggested text:** Component or handler references that must survive across the framework's lifecycle hooks are documented at the point of definition — not left as a bare comment warning a future reader not to break them.
**Rationale:** A framework's lifecycle boundaries are exactly where hard-to-diagnose state bugs accumulate; documenting the constraint at its source is cheaper than rediscovering it during a refactor.

---

## Signal: project frames itself as portfolio/demo/internal

### Explicit Leniency Scoping
**Section:** Project Scope note
**Signal:** Project Scope & Intent frames this as a portfolio, demo, or internal-only project
**Suggested text:** This project's scope licenses specific, named leniencies (state exactly which: e.g. authentication, authorization, production hardening) that would be unacceptable in a deployed system. These leniencies do not lower the bar on code quality, architecture, testing, or engineering judgment elsewhere.
**Rationale:** Naming the leniency explicitly prevents it from silently expanding to cover corners it was never meant to excuse.

---

## Signal: pre-commit tooling is plausible (npm/node, or any stack with linters + type-checkers)

### Pre-commit Enforcement
**Section:** Quality Standard subsection
**Signal:** The project uses a language/stack with linting and/or type-checking tools available
**Suggested text:** A pre-commit hook runs lint, type-check, and the test suite, in that order, before a commit is accepted. Bypassing the hook is prohibited except in a documented emergency, and any bypass is followed immediately by a commit that re-establishes the passing state.
**Rationale:** Automated pre-commit gates catch regressions at the cheapest possible point — before they reach the branch — rather than relying on discipline alone.

### CI Enforcement
**Section:** Quality Standard subsection
**Signal:** The project uses a language/stack with linting and/or type-checking tools available
**Suggested text:** The same lint, type-check, and test suite required by the pre-commit hook also run in CI on every push and pull request, and a failing run blocks merge. CI is the actual gate of record; the pre-commit hook is a local convenience that catches the same issues earlier and does not substitute for it, since a hook can be skipped, uninstalled, or never configured on a given clone.
**Rationale:** A pre-commit hook only enforces discipline on machines where it's installed and not bypassed; CI is what actually guarantees nothing failing reaches the merged branch.

---

## Lower-priority hygiene (still ask — cheap, rarely rejected)

### Manifest/Script Hygiene
**Section:** Quality Standard
**Signal:** A package manifest exists (`package.json`, `pyproject.toml`, etc.)
**Suggested text:** A manifest's declared name, dependencies, and scripts match the actual package and files on disk. A stale script entry or unused dependency is treated as a bug, not background noise.
**Rationale:** Stale manifest entries are cheap to introduce and easy to ignore, but they mislead the next person who trusts the manifest as documentation of what actually runs.

### No Vendored Dependency With a Nested `.git`
**Section:** Quality Standard
**Signal:** Always (cheap to ask regardless of stack)
**Suggested text:** No vendored third-party code carries its own nested `.git` directory. If a dependency must be vendored, its provenance is recorded in a README note and it is committed as plain files, or added as a real git submodule.
**Rationale:** A silently nested `.git` directory breaks tooling that assumes one repository root and obscures where the vendored code actually came from.

### Dispatch Surfaces Decomposed by Concern
**Section:** Core Principle
**Signal:** The project has (or will have) a message/event dispatcher, router, or similar central switch (e.g. a WebSocket handler, a reducer, a command router)
**Suggested text:** A dispatcher over many message/event types routes to named handler functions, one per type, each independently readable without scrolling through unrelated cases. Duplicated logic across cases is extracted, not copy-pasted.
**Rationale:** A single large switch statement over many cases is where duplicated logic and hard-to-follow control flow accumulate fastest as a project grows.

### Bootstrap/Entry Files Wire Dependencies Only
**Section:** Core Principle
**Signal:** The project has a service or app entry point (e.g. a server `index.ts`, a CLI `main.py`)
**Suggested text:** Application entry points are limited to reading config, constructing dependencies, and starting the app. Business logic, transport glue, and persistence concerns each live in their own module with a single responsibility, imported by the entry point — never defined inline in it.
**Rationale:** Entry-point files that accumulate inline logic over time become the one file everyone is afraid to touch, because it mixes unrelated concerns with no internal boundaries.
