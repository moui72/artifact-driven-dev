# Defects

_Last verified: 2026-07-09 (fifth pass, post-defect-doc-drift)_

## constitution.md

- **Claim:** Behavioral smoke tests are required for state-mutating skill paths
  **Actual:** two scenarios exist (`.github/workflows/smoke.yml`:
  feature→plan, tasks→implement), but the `/ardd-converge`,
  `/ardd-feedback`, `/ardd-refine`, and `/ardd-sync` state-mutating paths
  still have none, and no scenario has ever executed — the
  `ANTHROPIC_API_KEY` secret is deliberately unprovisioned, so the jobs
  skip. `/ardd-kickoff` mutates no state itself (it interviews, then hands
  off), so it isn't strictly in scope — but `/ardd-bootstrap`, which it
  invokes and which writes the whole of `.project/`, has never had a
  scenario either. Reduced-scope residue of an already-surfaced defect
  (identifier 970d935b is in `plan-repo-critique-docs-2026-07-06.md`'s
  `surfaced-defects:`, so `/ardd-plan` will not re-prompt it) — expand
  scenarios as the harness matures, starting when the key is provisioned
  and the existing two are proven to run.
  **Location:** .github/workflows/smoke.yml:1
  **Severity:** drift (reduced scope; tracked, not re-promptable)

## Cleared since the previous run

Both defects opened by the fourth pass are closed, by
`plan-defect-doc-drift-2026-07-09.md` (constitution v1.2.5):

- `b7d2252c` — the interactivity bound stated "when `/dev/tty` isn't
  readable it takes the safe default" unconditionally, while `launch()`
  execs anyway under `--kickoff`. The artifact now separates the
  pending-question case (no flag, no tty → decline, exit 0) from the
  answered-in-advance case (`--kickoff`, no tty → launch on inherited
  stdin), and names the collapsed v1.2.4 phrasing so it isn't restored.
  `README.md`'s flatly false "it declines rather than hangs" is replaced
  with a qualified statement. Neither `new.sh` nor its tests changed —
  the code was right and the prose was wrong.
- `f666274c` — "cloning one if absent" now reads "cloning `~/.ardd/source`,
  the one checkout it owns, if that is absent; a `--source` or
  `$ARDD_SOURCE` path that doesn't exist is a hard error, never a clone
  target."

The BSD-only `sed -i ''` finding (58bd7dd2), cleared at the third pass,
stays cleared.

## Spot-checks that passed

- **POSIX shell** (Quality Standards): `new.sh` and `scripts/test-new.sh`
  both parse clean under `dash -n`; no `[[`, `local`, `function`, `==`, or
  herestrings. 25 test scripts, all POSIX.
- **Principle IV, two install targets**: `new.sh` is source-side as claimed —
  `install.sh` never references or copies it. `skills/ardd-kickoff/SKILL.md`
  is target-side and installs correctly.
- **Principle V, test-first**: `new.sh` was preceded by a red
  `scripts/test-new.sh` (commit f911ada), as was the
  `--kickoff`/`--no-kickoff` change (commit 3b5d937). Both red states were
  committed with `--no-verify` and a stated reason, each followed
  immediately by a commit restoring the passing state — the documented
  emergency the Pre-commit Enforcement standard permits. This plan's tasks
  were prose-only and carry the standard's stated exception.
- **Pre-commit glob rule**: `hooks/pre-commit` still discovers
  `scripts/test-*.sh` by glob, never an enumerated list.
- **CI parity**: all 25 `scripts/test-*.sh` have a job in
  `.github/workflows/lint.yml`.
- **Doc single-sourcing**: `gen-skill-docs.sh --check` in sync; `lint-docs.sh`
  clean — every `/ardd-*` named in `README.md`, `USAGE.md`, and `guides/*.md`
  resolves to a real skill.
- **Governance consistency**: footer `Version: 1.2.5`, the Sync Impact
  Report's `1.2.4 → 1.2.5`, and frontmatter `last_updated: 2026-07-09` agree
  (lint-enforced).
- **Principle VII, no dead architecture**: the retired `--no-launch` left no
  alias or shim; it survives only in `test-new.sh` case 13, which asserts it
  now errors.
- **Feature register**: per-feature files under `.project/features/`, matching
  the 2026-07-06 standing decision.
- **Single-writer ownership**: `STATUS.md` written only by `/ardd-analyze`,
  `DEFECTS.md` only by `/ardd-verify`. No artifact body carries defect
  annotations.
- **No vendored dependencies**: none, and no nested `.git`.

## Note on what verification can and cannot catch

Both defects closed this pass were prose contradicting a shell function,
through a fully green lint and test suite. `lint-project.sh` validates
frontmatter schemas; `lint-docs.sh` validates that `/ardd-*` names resolve.
Neither can read a paragraph and notice it describes a code path that doesn't
exist. That gap is structural, not an oversight — `/ardd-verify` is the only
check that closes it, and it runs only when invoked.
