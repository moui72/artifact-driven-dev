---
status: approved
branch: pre-release-ratchets
created: 2026-07-12
---

# Plan: pre-release ratchet hardening

_Consumes `feedback-pre-release-ratchets-4d67.md` (F001–F006, all accepted;
both Reconsidered overrides user-confirmed). The last gate before
`tasks-remote-install-source-18d3.md` T008 cuts `v1.0.0` — every item here
is cheap now and a compatibility shim forever after._

## Goal

Harden the interfaces v1.0.0 freezes — the committed `ardd-version.md`
format, the feature-register enum and its semantics, filename minting, and
the stated versioning policy — before any consumer pins a release.

## Scope

**In:** the six feedback items exactly (structured `Source-Commit`,
prefix-match comparison, `~/.ardd/source` fallback; `retired` register state
+ `npx-skills-install` flip + audit-checklist resolution; constitution
amendment for pack semver + append-only migrations + committed
`.ardd-applied`; unknown-enum version-skew message; hex tokens for
plan/research minting; lint sentinel via mktemp/trap).

**Out:** a real `Schema-Version` marker (explicitly deferred post-1.0 —
F005's message is the 1.0-compatible mechanism); `new.sh` URL/flag surface
(accepted as-is); anything touching the paused release tasks file.

## Technical Approach

One constitution amendment (v1.5.0 → v1.6.0, MINOR — material expansion of
the release-channel decision plus an amendment to the feature-register
standing decision) carries both policy items; every mechanical change lands
test-first in the same commit as its schema-of-record update (the
`retired` enum enters `lint-project.sh` and `ardd-state.sh` together —
CLAUDE.md's same-commit rule). `ardd-version.md` gains fields additively:
old files without `Source-Commit` still parse via the existing prose line
(the fallback keeps pre-1.0 installs updatable), new files carry both.
Filename minting changes only future filenames — existing cross-references
are untouched. Work is small enough for a single delegated run; normal
eager-merge applies (no multi-phase exposure — nothing here renames a file
a consumer holds open).

## Phase Breakdown

### Phase 1 — Constitution amendment (F003 + F004)
1. Amend the constitution: feature-register standing decision gains
   `retired` (terminal; enum `backlogged|planned|tasked|implemented|retired`)
   and the semantics sentence ("status asserts present truth"); the
   release-channel section gains the pack versioning policy (MAJOR =
   removed/renamed command or breaking script/schema change; MINOR =
   additive skill/schema-widening; PATCH = prose/fix), append-only
   migrations rule, and committed-`.ardd-applied` guidance. One SIR,
   v1.6.0, `last_updated` stamped.

### Phase 2 — Mechanical hardening (test-first throughout)
2. `retired` in `lint-project.sh`'s enum + `ardd-state.sh feature-flip
   implemented→retired` arc (same commit); fixtures + tests; flip
   `npx-skills-install` to `retired`; mark the audit checklist's answered
   [Q] resolved in `.project/audit.md` (user-directed resolution).
3. `ardd-version.md` hardening: `install.sh` writes `Source-Commit:
   <full-sha>`; `ardd-update-check.sh` + `source-resolve.sh` prefer it
   (prefix match), fall back to the prose line, and fall back to
   `~/.ardd/source` when `Source-Path` doesn't exist; regression tests for
   old-format, new-format, moved-path cases.
4. `ardd-state.sh mint` hex tokens for plan/research; unknown-enum message
   gains the version-skew hint; lint sentinel → mktemp/trap; tests for all
   three.

### Phase 3 — Close out
5. Docs touch-up where the policy is user-facing (README/USAGE update
   guidance, install.sh gitignore note re `.ardd-applied`), full suite +
   lint green.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| Dual-format `ardd-version.md` parsing (structured field + prose fallback) | Pre-1.0 installs already committed the prose-only format; the fallback is the compatibility shim that lets them update into the new format instead of breaking. |

## Open Questions

None — both judgment calls (semantics, scope) were made at feedback time.
