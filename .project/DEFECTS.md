# Defects

_Last verified: 2026-07-09 (fourth pass — first to survey new.sh, /ardd-kickoff, and constitution v1.2.4)_

## constitution.md

- **Claim:** Behavioral smoke tests are required for state-mutating skill paths
  **Actual:** two scenarios exist (`.github/workflows/smoke.yml`:
  feature→plan, tasks→implement), but the `/ardd-converge`,
  `/ardd-feedback`, `/ardd-refine`, and `/ardd-sync` state-mutating paths
  still have none, and no scenario has ever executed — the
  `ANTHROPIC_API_KEY` secret is deliberately unprovisioned, so the jobs
  skip. Unchanged since the third pass except that the gap widened today:
  `quickstart-new-project` and `launch-prompt` added a skill
  (`/ardd-kickoff`) and a source-side script (`new.sh`) that no scenario
  exercises. `/ardd-kickoff` mutates no state itself (it interviews, then
  hands off), so it isn't strictly in scope — but `/ardd-bootstrap`, which
  it invokes and which writes the whole of `.project/`, has never had a
  scenario either. Reduced-scope residue of an already-surfaced defect
  (identifier 970d935b is in `plan-repo-critique-docs-2026-07-06.md`'s
  `surfaced-defects:`, so `/ardd-plan` will not re-prompt it) — expand
  scenarios as the harness matures, starting when the key is provisioned
  and the existing two are proven to run.
  **Location:** .github/workflows/smoke.yml:1
  **Severity:** drift (reduced scope; tracked, not re-promptable)

- **Claim:** `new.sh` "never blocks on a question it cannot ask — when
  `/dev/tty` isn't readable it takes the safe default rather than hanging a
  pipeline forever" (Project Scope & Intent, v1.2.4).
  **Actual:** the bound is stated unconditionally, but holds only on the
  *ask* path. With an explicit `--kickoff` and no readable `/dev/tty`,
  `launch()` does not take the safe default — it `exec`s
  `claude "/ardd-kickoff"` on inherited stdin, which under `curl | sh` is
  the pipe carrying the script's own source text. That is deliberate
  (declining a flag the user named by hand is worse than an odd session)
  and a code comment says so, but the artifact does not — and `README.md`'s
  Quickstart asserts the stronger claim outright: "With no terminal to ask
  on — a scripted or CI run — it declines rather than hangs." That sentence
  is false when `--kickoff` is passed. New this pass; introduced by today's
  `launch-prompt` work, and covered by `test-new.sh` case 10 (which passes
  precisely *because* the exec is reached with no tty present).
  **Location:** new.sh:191 (`launch()`); README.md Quickstart
  **Severity:** drift (artifact and README understate a real code path; the
  behavior is intended, the documented contract is wrong)

- **Claim:** `new.sh` "resolves a source checkout (cloning one if absent)"
  (Project Scope & Intent, v1.2.4).
  **Actual:** it clones only the checkout it owns at `~/.ardd/source`. A
  source named explicitly via `--source` or `$ARDD_SOURCE` that doesn't
  exist is a hard error (`Error: source checkout '<path>' does not exist.`,
  exit 1), never a clone target. The distinction is deliberate and stated
  two sentences later in the same artifact ("a checkout named via
  `--source` … belongs to the user"), so this is an imprecise clause, not a
  design mismatch.
  **Location:** new.sh:127
  **Severity:** cosmetic

## Cleared since the previous run

Nothing cleared this pass — the third pass's single open defect (smoke
coverage) remains open. The BSD-only `sed -i ''` finding (58bd7dd2), cleared
at the third pass, stays cleared.

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
  immediately by a commit restoring the passing state — exactly the
  documented emergency the Pre-commit Enforcement standard permits.
- **Pre-commit glob rule**: `hooks/pre-commit` still discovers
  `scripts/test-*.sh` by glob, never an enumerated list. `test-new.sh` was
  enforced the moment it existed.
- **CI parity**: all 25 `scripts/test-*.sh` have a job in
  `.github/workflows/lint.yml`; `new-project` landed alongside `test-new.sh`
  in the same commit.
- **Doc single-sourcing**: `gen-skill-docs.sh --check` in sync; `lint-docs.sh`
  clean — every `/ardd-*` named in `README.md`, `USAGE.md`, and `guides/*.md`
  resolves to a real skill, including `/ardd-kickoff`.
- **Governance consistency**: footer `Version: 1.2.4`, the Sync Impact
  Report's `1.2.3 → 1.2.4`, and frontmatter `last_updated: 2026-07-09` agree
  (lint-enforced).
- **Principle VII, no dead architecture**: the retired `--no-launch` left no
  alias or shim; it survives only in `test-new.sh` case 13, which asserts it
  now errors.
- **Feature register**: per-feature files under `.project/features/`, matching
  the 2026-07-06 standing decision. No `features.md` remains.
- **Single-writer ownership**: `STATUS.md` written only by `/ardd-analyze`,
  `DEFECTS.md` only by `/ardd-verify`. No artifact body carries defect
  annotations.
- **No vendored dependencies**: none, and no nested `.git`.
