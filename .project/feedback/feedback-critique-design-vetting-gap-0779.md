---
status: open      # open -> planned
created: 2026-07-12
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

_Source: a real sync-tab-scroll session (2026-07-12) where the assistant
twice recommended `/ardd-critique` as forward-looking design review of a
proposed change (full write-up:
`~/dev/sync-tab-scroll/.project/ardd-feedback-critique-gap-2026-07-12.md`),
expanded by a whole-catalog naming/consolidation review (user + fresh-eyes
Fable agent, both concurring). **Sequencing: everything here must land
before the first GitHub release is cut
(tasks-remote-install-source-18d3.md T008) — surface renames after v1.0.0
are breaking changes.**_

## Reconsidered

- [ ] F001 Rename the read-only/report-owner family so each skill names its
  question and its owned file: `ardd-critique` → **`ardd-audit`**
  (critique.md → audit.md), `ardd-analyze` → **`ardd-status`** (owns
  STATUS.md; description still leads with "cross-artifact consistency
  check" so the name doesn't undersell it), `ardd-verify` →
  **`ardd-defects`** (owns DEFECTS.md, which keeps its name; also dodges a
  real collision with the harness's built-in `/verify`), `ardd-sync` →
  **`ardd-tracker`** (SYNC.md → TRACKER.md — "sync" fails the same bar the
  other three failed). `ardd-lint` already correct. Rejected alternatives:
  drift, check, conform (verify); leaving sync as the lone unrenamed
  family member. Migrations rename target-side files
  (critique.md→audit.md, SYNC.md→TRACKER.md).

- [ ] F002 Rename the capture/action skills that lure wrongly:
  `ardd-feature` → **`ardd-backlog`** (its own first paragraph disclaims
  its name; **command rename only** — `.project/features/` and the
  `ardd-state.sh feature-*` subcommands keep their names: data model vs
  command surface), and `ardd-render` → **`ardd-diagram`** (states the
  object; taken because renames are free only pre-v1.0.0).

- [ ] F003 Fold `ardd-converge` into `ardd-implement` and delete it
  (Principle VII). Unique content to migrate: the
  reconcile-claimed-vs-actual preamble (genuine judgment, stays prose) and
  the gap-identification sweep. Trigger is mechanical inside implement: a
  tasks file at `in-progress` that no live worktree claims (`tasks-list.sh`
  × `inflight-worktrees.sh`) → **offer** the reconcile preamble
  (default-yes, never silent — it's an expensive sweep a deliberate pauser
  shouldn't pay unasked). Keep an explicit opt-in (e.g.
  `/ardd-implement --reconcile <file>`) for pointing at a `ready` file to
  sweep for hotfix-added never-tasked work. Document the pre-existing
  blind spot unchanged by the fold: an interrupted inline run on a plain
  branch is invisible from the default branch.

- [ ] F004 Fold `ardd-add-artifact` into `ardd-refine` and delete it
  (Principle VII). Verified: refine step 1 already creates a missing named
  artifact from the same `ardd-artifact-templates`; add-artifact's only
  unique content (~5 lines: conflict check, WORKFLOW.md row, CLAUDE.md
  registration note) moves into refine's create branch.

- [ ] F005 Merge `ardd-bootstrap` + `ardd-codify` into a single
  **`ardd-init`** that detects its mode (existing source files → codify's
  reverse-engineering path; greenfield → bootstrap's interview path, with
  an explicit override). Their steps 4–8 (constitution suggestions,
  workflow-field questions, WORKFLOW.md, STATUS.md, report) are
  near-verbatim duplicates that drift-risk each other. `new.sh`'s handoff
  prompts (`/ardd-bootstrap` / `/ardd-codify`) and all docs update in the
  same change.

## UX

- [ ] F006 `/ardd-research` widens to explicitly own **pre-artifact design
  vetting** alongside fact-finding: given a stated proposal, load current
  artifacts, apply the audit lens list *by reference* (one canonical
  list), and answer goals / challenges / which committed decisions it
  reverses / is-it-worth-it, in research's existing output shape (one-off
  doc, no lifecycle) whose closing section recommends
  `/ardd-backlog <slug>`, `/ardd-plan`, or drop. SKILL.md usage examples
  must include a proposal-vetting invocation (agents route on examples).
  One-sentence routing hint in `ardd-backlog` and `ardd-plan`:
  substantial or decision-reversing ideas get `/ardd-research` first.

- [ ] F007 Codify the naming + description system (CLAUDE.md conventions,
  applied to every skill description in the same change): report-owners
  are nouns named after the file they own (status/STATUS.md,
  defects/DEFECTS.md, audit/audit.md, tracker/TRACKER.md); lifecycle
  actions are imperative verbs whose argument is their object (plan,
  implement, refine, diagram, update, init); capture skills are named for
  the thing you hand them (feedback, backlog). Every description states,
  in order: object, data-flow direction, and — for no-input skills — an
  explicit "takes no X; for X use /ardd-Y" redirect clause.

## Bugs

- [ ] F008 Argument guards on the two no-input report skills, mirroring
  `/ardd-plan`'s argument disambiguation: `ardd-audit` rejects any
  argument that isn't an existing artifact name with a redirect to
  `/ardd-research <proposal>` (the documented misuse); `ardd-defects`
  rejects freeform arguments with a redirect to `/ardd-feedback` ("I found
  a defect" is an observation report, not a codebase survey request).
