---
status: approved     # draft -> approved -> superseded
branch: ardd-state-determinism
created: 2026-07-06
features: []
---

# Plan: scripted state mutations, deterministic helpers, behavioral smoke test

## Goal

Move every deterministic state mutation and computation currently
performed by LLM prose into tested scripts, legitimized by two
constitution amendments, and prove skill behavior with a first CI
behavioral smoke scenario.

## Scope

**In:** the entirety of `feedback-repo-critique-6ad1.md` (all items
user-confirmed 2026-07-06): the features.md format decision; constitution
amendments (Principle II extended to mutations; Quality Standards
behavioral-test tier); `ardd-state.sh`; `defects-unsurfaced.sh`;
`tasks-list.sh`; `upsert-section.sh`; a constitution
governance-consistency check in `lint-project.sh`; an `/ardd-plan`
feedback-file scope argument; one CI behavioral smoke scenario; recorded
mechanization non-goals.

**Out:** everything in `feedback-repo-critique-docs-ca1d.md` (docs
tiering, archaeology strip, four-artifact demotion, naming,
frontmatter-description generation) — that file feeds its own plan and
was not consumed by this run.

## Technical Approach

All new scripts are **target-side** (installed by `install.sh` into
`.claude/skills/ardd-scripts/`, per Principle IV) except the
`lint-project.sh` governance check, which ships inside the existing
target-side lint script. Every script/subcommand lands with a
fixture-based regression test and CI job in the same commit
(Principle V; the glob-based pre-commit hook picks tests up
automatically). Skills shrink to judgment-plus-invocation: prose decides
*when*, `ardd-state.sh` does the *writing* and validates before every
write. When a skill's prose edit changes a shared field's handling,
every other skill touching that field is checked in the same commit
(Development Workflow rule 2).

Sequencing constraint honored throughout: the features.md format
decision (Phase 0) precedes `ardd-state.sh` design (Phase 1), because
the script embeds the parser/writer for whichever format wins.

## Phase Breakdown

### Phase 0 — decisions and governance (no code)

- T-A **Record the features.md format decision** [artifacts: constitution]
  (feedback item 1 — **DECIDED 2026-07-06: per-feature files**,
  `.project/features/<slug>.md` with real frontmatter, replacing the
  single-file `· `-separated register; rationale: merge and parse
  robustness win over single-file glanceability, especially for
  collaborative mode and tracker sync). This task records the decision
  in the constitution and specifies the per-feature frontmatter schema
  (slug, status, logged, plan, tasks, gh-issue, plus description/Why
  body) as input to T-C's parser and the `lint-project.sh` enum update.
  A generated index (or `tasks-list.sh`-style enumeration) replaces the
  single-file overview where skills need a register-wide view.
- T-B **Amend the constitution** [artifacts: constitution] (feedback
  items 2 and 5, both user-confirmed): one amendment, one MINOR bump
  (v1.1.0 → v1.2.0), Sync Impact Report prepended. Two changes:
  (1) Principle II retitled/extended — deterministic state *mutations*,
  not just checks, get scripts; prose decides when, scripts write.
  (2) Quality Standards gains a behavioral-test tier: fixture-project
  smoke scenarios running skills headlessly and asserting on file
  outcomes, required for at least the state-mutating skill paths.

### Phase 1 — ardd-state.sh (depends on Phase 0)

- T-C **Build `ardd-state.sh`** with subcommands, each validating file
  state before writing (feedback item 3; consolidated audit scope):
  - `slug` / `mint` — kebab-sanitization, ~30-char truncation, hex
    token, filename minting (replaces prose rules in seven skills)
  - `plan-flip <file> approved|superseded`
  - `tasks-flip <file> <status>`, `task-check <file> <task-id>`,
    `next-task <file>`
  - `feedback-mark <file> <item-id> x|-`, `feedback-planned <file> <plan>`
    — items are addressed by **stable IDs** (decided 2026-07-06: feedback
    items gain short IDs like `F001`, mirroring task IDs; line numbers
    rejected as merge-fragile). `ardd-feedback`'s file template gains the
    ID prefix; existing feedback files are all `planned` and need no
    migration.
  - `feature-flip <slug> <status>`, `feature-create`, `feature-field`
    (per-feature files per T-A's decided format; parser/writer targets
    `.project/features/<slug>.md` frontmatter, not the legacy line format)
  - `stamp <artifact> last_updated|diagram_status`
  Fixture tests (good + bad cases per subcommand) + CI job, same commit.
- T-D **Ship it**: add to `install.sh`'s copied-scripts set; verify
  `.worktreeinclude` coverage (already `.claude/skills/ardd-*/`).
- T-D2 **Migration `migrations/000N-per-feature-files.sh`**: split an
  existing `features.md` register into `.project/features/<slug>.md`
  files (parsing the legacy `· `-separated metadata line one final
  time), idempotent, recorded in `.ardd-applied` per the existing
  migration mechanism. Fixture test with a legacy features.md. Update
  `lint-project.sh` to validate the new per-feature schema and stop
  expecting the single-file format.
- T-E **Rewire the skills** to invoke subcommands instead of hand-editing
  (ardd-plan, ardd-tasks, ardd-implement, ardd-converge, ardd-feature,
  ardd-feedback, ardd-refine, ardd-sync, ardd-research, ardd-featurize).
  **Big-bang confirmed 2026-07-06** — all skills rewired in this plan,
  no phased trailing; acceptable at this stage of the project's life
  cycle. One commit per coherent field-group so cross-skill consistency
  is reviewable. Update `lint-project.sh` in the same commit if any
  enum/shape changes; note in each SKILL.md that transitions are
  script-performed.

### Phase 2 — sibling deterministic helpers (independent of each other; parallelizable after Phase 1's test scaffolding exists, and T-F/T-G/T-H don't strictly need Phase 1 at all)

- T-F **`defects-unsurfaced.sh`** (feedback item 4): reads DEFECTS.md,
  hashes descriptions, unions all plans' `surfaced-defects:` lists,
  prints unsurfaced id+description pairs. Edit ardd-plan step 5 to call
  it and keep only the ask-the-user half. Tests + CI.
- T-G **`tasks-list.sh`** (feedback item 7a): glob/status/exclude-
  abandoned/checkbox-progress/plan-binding pick-list; rewire
  ardd-implement step 1, ardd-converge step 1, ardd-tasks step 1.
  Tests + CI.
- T-H **`upsert-section.sh`** (feedback item 7b): find-header/replace-
  until-next-`##`/append README surgery; rewire ardd-render step 6
  (Mermaid content generation stays prose). Tests + CI.
- T-I **Constitution governance check in `lint-project.sh`** (feedback
  item 7c): footer Version/Last Amended vs frontmatter `last_updated`
  vs Sync Impact Report version consistency. Good/bad fixtures.

### Phase 3 — ardd-plan feedback scoping (skill edit only)

- T-J **Add optional feedback-file argument(s) to `/ardd-plan`**
  (feedback item 6): scopes step 5's glob to the named file(s); unnamed
  open files are neither presented nor marked. Update the skill's usage
  line and USAGE.md's one-line description. (No script, no enum change;
  lint untouched.)

### Phase 4 — behavioral smoke test (soft-depends on Phase 1: assertions target script-driven state)

- T-K **Fixture project + CI smoke scenario** (feedback item 5 build
  half): a minimal target project fixture; CI job runs headless
  `claude -p` through one state-mutating flow (candidate:
  `/ardd-feature` then `/ardd-plan <slug>` — cheapest flow that flips
  real state) and asserts file outcomes via `lint-project.sh` plus
  explicit checks: expected files exist, statuses correct,
  single-writer files untouched. **CI logistics decided 2026-07-06**:
  trigger only on pull requests touching `skills/**` (path filter);
  written now but the `ANTHROPIC_API_KEY` secret is deliberately NOT
  provisioned yet, so the job is `continue-on-error: true` with a
  skip-fast guard when the secret is absent — expected to no-op/fail
  until the key is added. Promotion to required = provision the secret
  and drop `continue-on-error`, annotated in the workflow file.

### Phase 5 — bookkeeping

- T-L **Record mechanization non-goals** (feedback item 8): add the
  audited not-worth-scripting list (critique-staleness compare,
  STATUS.md count assembly, sync `gh` glue, `core.bare` one-liner,
  judgment steps) as a short note in CLAUDE.md so they stop resurfacing.

## Complexity Tracking

| Deviation | Justification (Principle VI) |
|---|---|
| `ardd-state.sh` as a multi-subcommand dispatcher rather than N tiny scripts | The subcommands share the frontmatter/features.md parser; the duplication threshold is long since met (slug rules alone appear in 7 skills; features.md parsing in 3) |
| Four new scripts in one plan | Each replaces existing prose duplication, not hypothetical need; each carries its own fixture test per Principle V |

## Open Questions

None — the three drafted open questions (features.md format, smoke-test
CI logistics, feedback-item addressing) were all resolved by the user on
2026-07-06 and are baked into T-A, T-K, and T-C respectively.

## Production Annotation Summary

- T-K lands as `continue-on-error: true` with the `ANTHROPIC_API_KEY`
  secret deliberately unprovisioned — annotate the workflow file with
  the promotion condition (provision secret, drop continue-on-error).
