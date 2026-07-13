---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: docs-review-findings
created: 2026-07-13
features: []
surfaced-defects: []
---

# Plan: docs-review system findings

## Goal

Resolve the five system-level findings from the 2026-07-13 four-agent
documentation review (`feedback-docs-review-findings-f868.md`): three
skill-prose defects, the undocumented `retired` register status, and the
overdue removal of the "(formerly ardd-X)" description suffixes.

## Scope

- **In:** prose fixes inside `skills/ardd-feedback/SKILL.md` and
  `skills/ardd-status/SKILL.md`; documenting `retired`'s semantics in the
  user-facing enum reference (and the validator's comment block);
  removing the "(formerly ardd-X)" suffix from six skills' `description:`
  frontmatter and regenerating every generated doc surface.
- **Out:** any behavior change to any skill or script; the doc-side
  review findings (already landed in the docs-rewrite commit); the
  fold-note clauses "(absorbs ardd-converge)" / "(absorbs
  ardd-add-artifact)" — those describe current routing, not a rename, and
  stay.

## Technical Approach

All changes are prose/frontmatter-only — PATCH-level under the pack-semver
policy (no command is added, removed, or renamed; no script/schema
contract changes). The suffix removal (F005) resolves the feedback's
open decision as **drop now**: the one-release-cycle courtesy window
after v1.0.0 has passed, `install.sh` still prunes legacy skill dirs with
pointed messages regardless, and `docs/guides/from-spec-kit.md` preserves
the analyze→status style mapping for newcomers. Description edits must
respect the lint-docs colon rule (quoted values) and the description
formula (object → data-flow → redirect clause). Every generated surface
(README Skills table, `docs/reference/skills/*` headers + index,
`templates/WORKFLOW.md`) is regenerated via `scripts/gen-skill-docs.sh`,
never hand-edited — its `--check` plus the full suite gate the commit via
the pre-commit hook.

`retired` (F004) is documented, not redesigned: the semantics already
enforced by `ardd-state.sh` ("shipped then deliberately removed";
entered only from `implemented`; terminal; manual flip — no skill
automates removal decisions) get stated in
`docs/reference/project-files.md`'s enum section and echoed as a comment
beside `FEATURE_STATUS_ENUM` in `scripts/lint-project.sh`.

## Phase Breakdown

### Phase 1: skill-prose fixes (F001–F003)

Independent one-file edits; no ordering constraints.

- Align `skills/ardd-feedback/SKILL.md`'s "Consumption by /ardd-plan"
  section with the negotiation-time bookkeeping `/ardd-plan` step 4
  actually performs (F001).
- Fix the doubled "Delegated Delegated" and collapse the duplicated
  `/ardd-refine` entry in the canonical auto-run list in
  `skills/ardd-status/SKILL.md` (F002, F003).

### Phase 2: document `retired` (F004)

- Add the semantics to `docs/reference/project-files.md`'s feature-register
  enum row/notes; add a one-line comment at
  `scripts/lint-project.sh`'s `FEATURE_STATUS_ENUM`.

### Phase 3: drop the "(formerly ardd-X)" suffixes (F005)

Ordered after nothing, but its regeneration step must run after the
frontmatter edits.

- Remove the suffix from the `description:` of the six carriers
  (`ardd-audit`, `ardd-backlog`, `ardd-defects`, `ardd-diagram`,
  `ardd-status`, `ardd-tracker`).
- Run `scripts/gen-skill-docs.sh`; verify `--check`, `lint-docs.sh`, and
  the full test suite stay green.

## Complexity Tracking

No deviations — every change is a prose/comment/frontmatter edit inside
existing files; no new mechanism, file, or check is introduced
(Principle VI satisfied trivially; Principle V untriggered since no
deterministic check changes behavior).

## Open Questions

None. (F005's drop-vs-extend decision is resolved as "drop now" in this
plan; revise at the checkpoint to override.)
