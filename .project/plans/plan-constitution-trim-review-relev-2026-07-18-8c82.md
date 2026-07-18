---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: constitution-trim-review-relev
created: 2026-07-18
features: [constitution-trim-review-relev]
surfaced-defects: []
---

# Plan: constitution-trim-review-relev

## Goal

Add a `--review` mode to `/ardd-refine constitution` that audits a target
project's existing `constitution.md` principle-by-principle, proposes
trimming any principle that is no longer relevant to the project or not
meaningfully load-bearing for guiding agent behavior on it, and applies
removals only after batched user confirmation.

## Scope

**In scope:**
- A new `--review` invocation form: `/ardd-refine constitution --review`.
- Per-principle relevance judgment against the target project's actual
  scope/stack (not a fixed rubric — this is the same kind of grounded
  judgment call `--slate` mode already uses for backlog defragging).
- A single batched confirmation step presenting every principle flagged for
  trimming before any file write, mirroring the existing
  batched-confirmation pattern already used elsewhere in this skill family
  (e.g. `/ardd-plan` step 3c's proposed-changes-then-confirm shape).
- Reuse of `/ardd-refine`'s existing constitution special-casing (step 4:
  version-bump semantics, Sync Impact Report, `last_updated`) for the
  resulting edit — a trim is a version-bump-worthy constitution change like
  any other.
- Doc updates: `docs/reference/skills/ardd-refine.md` (Usage, Writes,
  Behavior notes sections) and `USAGE.md`'s command table.

**Out of scope:**
- Any change to `/ardd-refine`'s existing no-argument or single-artifact
  modes — `--review` is strictly additive, a new mode alongside them.
- A new standalone skill — the feature description's own preferred framing
  (`/ardd-refine constitution --review`) fits this skill's established
  "refine an artifact" shape; no naming-system justification exists for a
  separate skill (it doesn't own a new report file, isn't a new lifecycle
  verb, and isn't a capture skill for new input).
- Automating the relevance judgment with a deterministic script — per
  Constitution Principle II, this is judgment ("does this principle still
  meaningfully guide agent behavior on this specific project"), not a pure
  function of file state, so it stays prose.
- Trimming any *other* artifact type (`datamodel`, `infrastructure`, etc.)
  — the feature request and its `Why:` are constitution-specific; other
  artifacts don't accumulate principles the same way.

## Technical Approach

`--review` is parsed as a mode flag on `/ardd-refine constitution`,
analogous to how `--from` and `--slate` are parsed as mode flags on
`/ardd-plan` in this same skill family — recognized before the normal
steps run, entering a distinct step sequence instead.

Sequence:
1. Load `constitution.md` (existing step 1 load, unchanged).
2. Enumerate every principle under `## Core Principles` (or whatever
   heading structure the project's constitution actually uses — mirror
   `/ardd-status`'s "act only on the principles the constitution actually
   declares" discipline; never assume a fixed principle set or count).
3. For each principle, ground a relevance judgment in the current
   project (`.project/artifacts/*.md`, and where useful a light grep of the
   codebase for whether the principle's subject matter still exists in the
   project) — not from the principle's own prose in isolation. Classify
   each as **keep** (still load-bearing) or **trim-candidate** (no longer
   relevant, or not meaningfully guiding agent behavior here), with a
   one-line rationale for each trim-candidate.
4. If zero principles are flagged, report that and stop — no write, no
   version bump, nothing to confirm.
5. Present the full trim-candidate list with rationale in one batched
   message and ask for confirmation — per-principle accept/decline
   (multi-select), never an all-or-nothing single yes/no, and never applied
   one at a time.
6. Apply confirmed removals to `constitution.md`, then run the existing
   constitution special-case handling (step 4 of the current skill: version
   bump — a trim is at least a MINOR-worthy removal under the project's
   existing bump semantics, since it removes governance surface — Sync
   Impact Report entry naming what was removed and why, `last_updated`
   stamp). Declined candidates are simply not mentioned again in this run's
   output; there is no persistent "declined trim" bookkeeping (unlike
   `/ardd-plan` defects, a re-review later is expected to re-derive its own
   judgment fresh each time, not consult a suppression list — trimming
   relevance can change project-to-project-state and shouldn't be
   permanently silenced).
7. Report which principles were trimmed (if any), the new constitution
   version, and recommend `/ardd-status` (existing terminal-handoff
   convention this skill family follows).

## Phase Breakdown

### Phase 1: Spec and implement `--review` mode in `skills/ardd-refine/SKILL.md`
Depends on: —
- T001: Add a `--review` usage line and mode description to
  `skills/ardd-refine/SKILL.md`'s top usage block, alongside the existing
  no-argument mode section — same doc location, parallel structure.
- T002: Write the `--review` step sequence (enumerate → judge → batch
  confirm → apply confirmed trims via existing constitution special-case
  handling → report), per the Technical Approach above.
- T003: Cross-reference the batched-confirmation shape explicitly against
  `/ardd-plan` step 3c so the two batched-confirm UIs in this skill family
  stay consistent in shape (list all candidates with rationale, single
  confirmation step, never one-at-a-time).

### Phase 2: Docs
Depends on: Phase 1
- T004: [artifacts: none] Update `docs/reference/skills/ardd-refine.md` —
  add `--review` to the Usage code block, note the new mode in Writes
  (constitution trim + version bump) and Behavior notes.
- T005: [artifacts: none] Update `USAGE.md`'s command table with a
  `--review` row alongside the existing `/ardd-refine` rows, matching its
  existing terse style.

### Phase 3: Verification
Depends on: Phase 2
- T006: Manually exercise `--review` against this repo's own
  `.project/artifacts/constitution.md` (dogfooding) — confirm the mode
  correctly enumerates all nine current principles, produces a defensible
  keep/trim judgment for each (expect mostly "keep" — this constitution
  was recently pruned by `constitution-suggestions-quality` work), and
  that the batched-confirmation step presents cleanly. This is a prose
  skill with no deterministic script to unit-test (Constitution Principle
  II — relevance judgment isn't a pure function of file state); a live
  dogfood run is this skill family's established verification substitute
  (matches how `--slate` mode was verified).

## Complexity Tracking

No deviations requiring justification — this is an additive mode on an
existing skill, following established patterns (`--slate`, `--from`) from
the same skill family.

## Open Questions

- [OPEN: Should a declined trim-candidate be re-surfaced on every future
  `--review` run, or should there be a lightweight suppression mechanism
  like `/ardd-plan`'s `surfaced-defects:` list? This plan takes the
  position that relevance judgment should re-derive fresh each time
  (project state changes are exactly what makes a principle newly
  irrelevant), but if repeated re-prompting on a stable "no, keep it"
  decision proves annoying in practice, a suppression list modeled on
  `surfaced-defects:` is the natural follow-up.]
- [OPEN: Should `--review` support any artifact type, or stay
  constitution-only? The feature request and its rationale are
  constitution-specific (principle accumulation via `/ardd-init`'s
  suggestion catalog); no evidence yet that other artifacts accumulate
  content the same way, so this plan scopes it narrowly and defers
  generalizing until a concrete need appears.]
