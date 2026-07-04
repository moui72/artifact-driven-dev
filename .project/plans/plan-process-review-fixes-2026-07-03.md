---
status: approved        # draft -> approved -> superseded
branch: process-review-fixes
created: 2026-07-03
features: []
---

# Plan: Process Review Fixes

## Goal

Resolve the 16 findings captured in
`feedback-process-review-findings-bd4c.md` (consistency/ease-of-use review +
multistream review + a DRY-focused pass), closing documentation gaps,
extending existing safety mechanisms to their uncovered callers, and adding
two new deterministic checks — without introducing any new abstractions.

## Scope

**In scope:** all 16 feedback items — 7 bugs, 9 UX items. All are
source-side (govern this repo's own skills/scripts/docs), none touch a
target project's `.project/` schema in a way that requires a migration.

**Not in scope:**
- Renaming `/ardd-feature` (feedback item suggests only a louder callout,
  not a rename — a rename would be a breaking change to every installed
  target and is disproportionate to the naming-confusion problem).
- Changing feedback's checkbox syntax to literally add a third glyph
  distinct from critique's `[-]` — the fix is documenting that feedback
  already uses the same 3-state convention in practice (`/ardd-plan` step 5
  already writes `[x]`/`[-]`), not inventing new syntax.
- Any change to `.claude/settings.json` or the `PostToolUse` hook —
  none of these findings touch hook-enforceable invariants beyond what's
  already covered.

## Technical Approach

Per constitution Principle II (Deterministic Checks Over Prose, Wherever
the Invariant Is Actually Checkable), two items in this plan (the
duplicate-slug-across-plans check and cross-worktree slug visibility) get
real script changes with tests; everything else is skill-prose or doc
clarity and stays prose, since it requires judgment (naming, framing,
cross-referencing) rather than being a pure function of file state.

Per Principle IV (Two Install Targets, Never Conflated): all touched files
are source-side (`skills/*/SKILL.md`, `scripts/*.sh`, `README.md`,
`USAGE.md`) — nothing here is target-side migration work.

## Phase Breakdown

### Phase 1 — Documentation & prose clarity (no test required; skill-prose/doc only)

1. `/ardd-codify`: add a WORKFLOW.md-generation step, reusing the skills-table
   content from `/ardd-bootstrap`'s template, closing the greenfield/existing-
   project asymmetry. [artifacts: none] (feedback: bug — codify WORKFLOW.md gap)
2. `/ardd-implement`: make the analyze auto-trigger explicit at its own
   completion step (step 7), matching `/ardd-converge`'s phrasing, instead of
   relying on the next-loop-iteration side effect. (feedback: bug — analyze
   auto-trigger inconsistency)
3. `USAGE.md`: add a comparison table distinguishing `/ardd-analyze`,
   `/ardd-lint`, `/ardd-verify`, `/ardd-critique`; add a one-line
   disambiguation cross-reference between `/ardd-feature` and
   `/ardd-featurize` in each of their own SKILL.md files. (feedback: UX —
   confusing near-duplicate skill names)
4. `scripts/lint-project.sh`: add a header comment noting that `critique.md`,
   `DEFECTS.md`, `SYNC.md`, `STATUS.md` are deliberately unvalidated (looser,
   informal schemas by design). (feedback: UX — lint coverage gap undocumented)
5. `/ardd-add-artifact`: add an explicit step naming which frontmatter fields
   must be set, matching `/ardd-codify` step 4's level of explicitness.
   (feedback: UX — add-artifact terseness)
6. `/ardd-feature`: add a louder one-line callout at the top of its SKILL.md
   stating it only logs a backlog entry — no artifact/design work happens
   here. (feedback: UX — feature naming overpromise)
7. `/ardd-feedback`: document that resolution uses the same 3-state
   convention as `critique.md` (`[ ]` open, `[x]` incorporated, `[-]`
   declined) — aligning the docs with what `/ardd-plan` step 5 already
   writes today. (feedback: UX — feedback/critique checkbox mismatch)
8. `scripts/project-lock.sh`: add a header sentence stating it provides no
   protection across `git worktree` checkouts (lock file lives inside each
   worktree's own `.project/`); add the same one-sentence caveat to
   README's worktree-relevant guidance. (feedback: UX — worktree blind spot
   undocumented)
9. `README.md` or `USAGE.md` (whichever already documents `.project/`
   layout): add a short "resolving `.project/` merge conflicts" note — take
   either side for single-writer report files and re-run the owning skill;
   resolve `features.md` textually (append-oriented) then run `/ardd-lint`.
   (feedback: UX — no merge-conflict guidance)
10. Frontmatter status-enum inline comments (e.g. `status: draft # draft ->
    approved -> superseded`) in `ardd-plan`, `ardd-tasks`, and any other
    skill carrying one: append "(schema-of-record: scripts/lint-project.sh)"
    so readers know where the authoritative enum list lives. (feedback: UX —
    enum-comment DRY / schema-of-record pointer)
11. `scripts/project-lock.sh`: add a header sentence documenting the
    caller-name convention ("callers pass their own skill name, e.g.
    `ardd-plan`, `ardd-tasks`, `ardd-implement`, `ardd-converge`") so a
    future skill adding lock support doesn't have to reverse-engineer it
    from existing callers. (feedback: UX — lock caller-name convention
    undocumented)

### Phase 2 — Extend `project-lock.sh` coverage to its two uncovered callers

12. `/ardd-feature`: add `project-lock.sh check ardd-feature` before its
    `features.md` read-modify-write, and `... touch ardd-feature` after —
    matching the existing pattern in `/ardd-plan`/`/ardd-tasks`/
    `/ardd-implement`/`/ardd-converge`. (feedback: bug — lock coverage gap)
13. `/ardd-sync`: same addition (`check ardd-sync` / `touch ardd-sync`)
    around its `features.md` writes in both push and pull phases. Also add
    a short note in `/ardd-sync`'s SKILL.md (near the push-dedup step)
    that `sync-slug-match.sh`'s dedup handles crash-retry idempotency, not
    true concurrent-run safety — the lock addition narrows but doesn't
    eliminate the residual external-system race, and that's a documented,
    known limitation, not a gap to silently paper over. (feedback: bug —
    lock coverage gap + sync race documentation)

No test required for phases 1–2: these invoke or document an
already-tested script (`test-project-lock.sh` already covers `check`/
`touch` behavior); the callers are new, not the mechanism.

### Phase 3 — Deterministic check: duplicate feature slug across two live plans

14. `scripts/lint-project.sh`: add a rule that flags when two
    non-`superseded` plans (`draft` or `approved`) both list the same slug
    in their `features:` frontmatter array — the pure-file-based signal that
    two branches independently planned the same feature. Follows the same
    style as the script's existing "approved plan but feature still
    backlogged" check.
    - **Test-first (Principle V):** add a fixture case to
      `tests/fixtures/bad-project/` (two plan files sharing a `features:`
      slug, both non-superseded) and a corresponding negative case to
      `tests/fixtures/good-project/` (same slug, but one plan is
      `superseded`). Confirm `test-lint-project.sh` fails against the new
      bad-fixture case before the rule is implemented, then passes once
      it's added. Update the expected-finding-count assertions accordingly.
    (feedback: bug — no duplicate-plan-slug lint rule)

### Phase 4 — Cross-worktree slug-in-flight visibility

15. `scripts/branch-info.sh`: extend it to enumerate other worktrees via
    `git worktree list --porcelain` and, for each one found, read its
    `.project/artifacts/features.md` directly to report any slug whose
    `Status` is already past `backlogged`. Output stays advisory data (e.g.
    an additional `worktrees=<path>:<branch>:<slugs-in-flight>` line or
    similar) — `branch-info.sh` itself makes no decisions.
    - **Test-first:** extend `test-branch-info.sh` with a case that sets up
      a second worktree (or a fixture directory standing in for one) with a
      `features.md` containing a `planned` slug, and asserts the new output
      surfaces it.
16. `/ardd-plan` step 3a: when looking up a targeted feature slug, also
    check the new worktree data from `branch-info.sh` and print an advisory
    (never blocking) if another worktree already has that slug past
    `backlogged`. (feedback: bug — no cross-worktree slug-in-flight
    detection; highest-value item in the original multistream review)

### Phase 5 — Drift-prevention comments on the triplicated branch-check prose

17. Add an explicit cross-reference comment to the "Check branch" step in
    each of `/ardd-plan`, `/ardd-tasks`, `/ardd-implement`'s SKILL.md files,
    noting the block must stay behaviorally identical across all three
    except for `/ardd-plan`'s documented extra slug-derivation logic — so an
    editor touching one is prompted to check the others. No test possible
    (this is prose-only guidance for future human/LLM editors, not a file-
    state invariant a script can check). (feedback: bug — branch-check
    prose drift)

## Complexity Tracking

None. No new abstractions are introduced — every phase either edits
existing skill prose, extends an already-tested script's coverage to new
callers, or adds one narrowly-scoped rule to the existing
`lint-project.sh`/`branch-info.sh` scripts.

## Open Questions

None — all 16 feedback items had a clear, single proposed fix with no
ambiguity requiring a design decision during planning.

## Production Annotation Summary

None. This plan touches only this repository's own skills, scripts, and
docs (source-side per Principle IV) — no production shortcuts are
introduced.
