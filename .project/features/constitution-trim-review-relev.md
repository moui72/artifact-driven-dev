---
slug: constitution-trim-review-relev
status: backlogged
logged: 2026-07-17
---

An agent-driven review mode (e.g. /ardd-refine constitution --review, or a similarly-named /ardd-* invocation) that audits a project's existing constitution.md principle-by-principle and proposes trimming any that are not actually relevant to the project or meaningfully load-bearing for guiding agents toward better code quality on it, batched for confirmation before anything is removed.
Why: constitutions accumulate principles over time (via /ardd-init's suggestion catalog and later /ardd-refine passes), and there's currently no skill that looks back over the accumulated set and asks whether each one still earns its place — only ones that add or reword principles. A trimming pass is the missing complement, especially for a project whose scope or stack has narrowed since principles were adopted.
