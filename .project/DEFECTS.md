# Defects

_Last verified: 2026-07-11 (sixth pass, post-render/principle-agnostic/eager-backgrounding merges)_

## constitution.md

- **Claim:** Behavioral smoke tests are required for state-mutating skill paths
  (Quality Standards, "Behavioral smoke tests").
  **Actual:** two scenarios exist (`.github/workflows/smoke.yml`:
  `/ardd-feature`→`/ardd-plan`, `/ardd-tasks`→`/ardd-implement`), but the
  `/ardd-converge`, `/ardd-feedback`, `/ardd-refine`, and `/ardd-sync`
  state-mutating paths still have none, and no scenario has ever executed —
  the `ANTHROPIC_API_KEY` secret is deliberately unprovisioned, so the job
  short-circuits at the "Check for API key" step. `/ardd-kickoff` mutates no
  state itself (it interviews, then hands off), so it isn't strictly in
  scope — but `/ardd-bootstrap`, which it invokes and which writes the whole
  of `.project/`, has never had a scenario either. Reduced-scope residue of
  an already-surfaced defect (identifier `970d935b` is in
  `plan-repo-critique-docs-2026-07-06.md`'s `surfaced-defects:`, so
  `/ardd-plan` will not re-prompt it) — expand scenarios as the harness
  matures, starting when the key is provisioned and the existing two are
  proven to run.
  **Location:** .github/workflows/smoke.yml:28
  **Severity:** drift (reduced scope; tracked, not re-promptable)

## Verified clean this pass — recent merges

The three efforts merged since the fifth pass introduce no new artifact↔code
drift; each was checked against the Quality Standards it touches:

- **`fold-to-main.sh`** (eager-backgrounding): parses clean under `dash -n`
  (no bashisms — the `local` grep hits are the English word in comments);
  `test-fold-to-main.sh` landed in the same commit (`1dbe49c`), consistent
  with the repo's test-with-impl pattern (Principle V); it has a CI job in
  `lint.yml` and is picked up by `hooks/pre-commit`'s `test-*.sh` glob; and
  `install.sh` ships it target-side (Principle IV — confirmed in this pass's
  reinstall output). No stale "on a branch → run inline" prose remains in
  `ardd-implement`/`ardd-converge` (Principle VII); `fold-to-main` is
  referenced by both.
- **principle-agnostic `/ardd-plan`** (steps 6 & 8): the Complexity Tracking
  and Production Annotation Summary sections are now gated on the
  constitution *declaring* the relevant principle. This removes, rather than
  adds, an assumption; it contradicts no constitution principle (VI is
  declared here, so this repo's own plans would still emit both sections).
- **render config** (`render_target`/`render_section`): `skills/ardd-render`
  reads both fields and `scripts/lint-project.sh` validates them
  (schema-of-record) — skill and validator agree.

## Cleared at the fifth pass, still clear

`b7d2252c` (the `/dev/tty` interactivity phrasing) and `f666274c` (the
source-checkout "cloning one if absent" overstatement) were closed by
`plan-defect-doc-drift-2026-07-09.md` (constitution v1.2.5); both remain
accurate against the current `constitution.md` body. The BSD-only `sed -i ''`
finding (`58bd7dd2`), cleared at the third pass, stays cleared.

## Spot-checks that passed

- **POSIX shell** (Quality Standards): `fold-to-main.sh` and its test parse
  clean under `dash -n`; the full `scripts/test-*.sh` set (26 scripts) is
  POSIX.
- **CI parity**: all 26 `scripts/test-*.sh` have a job in
  `.github/workflows/lint.yml` (including `test-fold-to-main.sh`); none
  missing.
- **Pre-commit glob rule**: `hooks/pre-commit` still discovers
  `scripts/test-*.sh` by glob (line 20), never an enumerated list.
- **Doc single-sourcing**: `gen-skill-docs.sh --check` in sync; `lint-docs.sh`
  clean — every `/ardd-*` named in `README.md`, `USAGE.md`, and `guides/*.md`
  resolves to a real skill.
- **Governance consistency**: footer `Version: 1.2.5`, the Sync Impact
  Report's `1.2.4 → 1.2.5`, and frontmatter `last_updated: 2026-07-09` agree
  (lint-enforced). The recent merges are skill/script changes, not
  constitution amendments, so no version bump was due.
- **Principle IV, two install targets**: `new.sh` remains source-side
  (`install.sh` never copies it); `fold-to-main.sh` and the render config are
  target-side and install correctly.
- **Feature register**: per-feature files under `.project/features/`, matching
  the 2026-07-06 standing decision.
- **Single-writer ownership**: `STATUS.md` written only by `/ardd-analyze`,
  `DEFECTS.md` only by `/ardd-verify`. No artifact body carries defect
  annotations.
- **No vendored dependencies**: none, and no nested `.git`.

## Note on what verification can and cannot catch

The one persistent defect is a scope gap in an already-surfaced item, not a
contradiction the automated suite could catch. `lint-project.sh` validates
frontmatter schemas; `lint-docs.sh` validates that `/ardd-*` names resolve;
neither reads a paragraph and notices it describes a code path that doesn't
exist. That gap is structural — `/ardd-verify` is the only check that closes
it, and it runs only when invoked.
