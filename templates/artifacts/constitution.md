<!--
SYNC IMPACT REPORT
==================
Version change: (none) → 1.0.0
Added sections: all (initial)
-->

---
name: constitution
status: draft
last_updated: YYYY-MM-DD
---

# [PROJECT NAME] Constitution

## Project Scope & Intent

[Describe the project's purpose, audience, and any context that licenses
specific leniencies (e.g., demo/portfolio, internal tool, production system).]

## Core Principles

### I. [PRINCIPLE NAME]

[Description and rationale.]

### II. [PRINCIPLE NAME]

[Description and rationale.]

### III. [PRINCIPLE NAME]

[Description and rationale.]

## Quality Standards

- [Standard 1 — e.g., a testing paradigm if you have one: TDD (red-green),
  test-after, coverage threshold, or no automated-testing requirement.
  `/ardd-plan` and `/ardd-implement` follow whatever is declared here rather
  than assuming a default — state it explicitly if it matters to you.]
- [Standard 2]

## Development Workflow

1. [Step 1]
2. [Step 2]
3. Any artifact documenting a known production shortcut or gap (a deliberate
   simplification, an unintentional gap awaiting future work, etc.) does so
   under a `## Production Annotations` heading — not inline prose elsewhere
   in the artifact — so `/ardd-plan`'s Production Annotation Summary step and
   `/ardd-audit` can rely on a single, consistent place to find them.

## Governance

This constitution supersedes all other practices documented in the repository.
Amendments require:

1. A written rationale explaining why the current principle is insufficient.
2. An updated Sync Impact Report (prepended as an HTML comment).
3. Version increment per semantic versioning: MAJOR for principle removal or
   redefinition; MINOR for new principle or material expansion; PATCH for
   clarifications or wording fixes.
4. `last_updated` date updated in frontmatter.

**Version**: 1.0.0 | **Ratified**: YYYY-MM-DD | **Last Amended**: YYYY-MM-DD
