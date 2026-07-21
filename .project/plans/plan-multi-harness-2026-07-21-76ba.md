---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: multi-harness
created: 2026-07-21
features: [multi-harness-install-metadata]
surfaced-defects: []
---

# Plan: Multi-harness install metadata + post-codex-merge feedback batch

## Goal

Make dual Claude+Codex installs first-class — shared `.project/` install
metadata represents the full installed harness set, never just the
last-run harness — and clear the five open feedback files that
accumulated around the codex-foundation merge (docs drift, dev-mode
channel record, scenario-guardrails cwd safety, plan-checkpoint prompt
sequencing, pre-commit hook P90).

## Scope

**In:** the `multi-harness-install-metadata` feature (constitution
v1.13.0 standing decision, applied this run); all 12 items across the
five feedback files bound to this plan (28d0, 878c, 5f18, a91e, 1e7b).
**Out:** the full `codex-second-harness-support` feature (its own draft
plan, `plan-codex-second-harness-support-2026-07-15-f837.md`, still
gated on the live chaining smoke test); any per-harness adapter system
(constitution forbids at two harnesses); parallelizing the pre-commit
hook's worst case (P90-only per the accepted criterion).

## Technical Approach

Per the constitution's Multi-harness install section (v1.13.0):
single-source, install-time transformation, no forked prose. Harness
metadata lands in `.project/ardd-version.md` as a `Harnesses:` line
(comma-separated, e.g. `claude,codex`; absent = `claude`, preserving old
files) with preserve-on-reinstall semantics — `install.sh` reads any
existing line, unions the invoking harness in, and rewrites the rest of
the file for the invoking harness only. The reviewer guide
(`templates/dot-project-readme.md` output) gains harness-neutral
wording listing every installed root. The dev-mode reinstall fix (878c
F002) rides the same `install.sh` write path: when resolution is
`channel=dev`, record `Channel: dev` (and drop `Source-Ref`) rather
than leaving a stale `beta`. `scripts/lint-project.sh` /
`ardd-update-check.sh` stay tolerant of both old and new files.
Hook P90 uses staged-path scoping per feedback 1e7b's investigated
design (pattern table + generic `test-X.sh`→`scripts/X.sh` rule +
fail-safe run-all fallbacks + `ARDD_HOOK_ALL=1`). All deterministic
changes are test-first (Principle V); doc/prose-only tasks are the
declared exception.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

### Phase 1 — Harness metadata in install.sh (feature + 878c F002/F003)
Depends on: nothing.
- Red-first cases in `scripts/test-install-harness.sh`: `Harnesses:`
  recorded for claude-only, codex-only, and dual installs in both
  orders; reinstall preserves the sibling harness; both skill trees
  intact after dual install; dev-mode reinstall records `Channel: dev`
  with no `Source-Ref`.
- Implement in `install.sh`: union-write `Harnesses:`, harness-neutral
  reviewer-guide roots, dev-mode channel record; keep
  `ardd-update-check.sh`/`source-resolve.sh` parsing compatible
  (absent line = claude, old files keep working).
- Bounded gitignore/`.worktreeinclude` guidance per installed harness
  root (`.agents/skills/ardd-*/` alongside `.claude/skills/ardd-*/`),
  never broader (Principle III).

### Phase 2 — Pre-commit hook staged-path scoping (1e7b F001)
Depends on: nothing (parallel-safe with Phase 1 except both touch no
shared files).
- Extend `scripts/test-hooks-pre-commit.sh` with marker-stub routing
  cases first: `.project/`-only → lint-project only; single script →
  its test only; unmapped path/empty staged list → all;
  `ARDD_HOOK_ALL=1` → all.
- Implement scoping in `hooks/pre-commit` per the pattern-table design
  (POSIX sh).

### Phase 3 — Docs drift (28d0 F001–F003)
Depends on: Phase 1 (documents the `--harness` flag's final recorded
metadata shape).
- Rewrite `docs/reference/skills/ardd-update.md` step 4 body: harness
  preservation/verify behavior; confirm-with-diff posture replacing
  "your README is never edited".
- Document `install.sh --harness codex` in `docs/install.md`; add a
  USAGE.md routing line.

### Phase 4 — Skill-prose and scenario hardening (5f18, a91e, 878c F001/F004/F005)
Depends on: nothing.
- `tests/scenarios/GUARDRAILS.md`: cwd-inside-`$SCRATCH` verification
  before any prescribed git mutation, structural `-C`/absolute-path
  forms, explicit incident-reporting rule.
- `skills/ardd-plan/SKILL.md` step 10: explicit "two separate prompts —
  preview presented before the approval question" clause.
- `tests/scenarios/S2.md`: name/prepare a genuinely never-ArDD clone
  source (or clean the daily-huddle fixture).
- `tests/scenarios/S7.md`: post-install reviewer-guide presence check.
- One-line collaborative-mode scaffold note in
  `skills/ardd-init/SKILL.md` and `skills/ardd-backlog/SKILL.md`.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| Pre-commit pattern table (special-cases 5 check families) | The generic `test-X.sh`→`scripts/X.sh` rule can't express multi-subject couplings (`install.sh` ↔ `test-install-*`); table is bounded and fail-safe (unmapped → run all) |

## Open Questions

- `Harnesses:` line vs. a separate per-harness manifest file: this plan
  chooses the single line (YAGNI at two harnesses); revisit only if a
  third harness materializes or per-harness source refs diverge in
  practice.
