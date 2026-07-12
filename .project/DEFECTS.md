# Defects

_Last verified: 2026-07-12 (seventh pass — post-v0.9.0: background-by-default,
remote-install-source, skill-surface cleanup, pre-release ratchets, and the
release arc all verified against the tree)_

## constitution.md

- **Claim:** Behavioral smoke tests are required for state-mutating skill
  paths (Quality Standards, "Behavioral smoke tests").
  **Actual:** two scenarios exist and were updated to the renamed surface
  (`.github/workflows/smoke.yml`: `/ardd-backlog`→`/ardd-plan`,
  `/ardd-plan --from`→`/ardd-implement`), but no scenario has ever
  executed — `ANTHROPIC_API_KEY` remains deliberately unprovisioned, so the
  job short-circuits at its key check. And the state-mutating surface has
  grown past the two scenarios: `/ardd-implement --reconcile` (new
  Reconcile mode), `/ardd-feedback` (incl. cross-routing re-files),
  `/ardd-refine`, `/ardd-tracker`, `/ardd-init` (both modes), and
  `/ardd-update`'s backfill-asks have none. Successor to the sixth pass's
  `970d935b` entry with post-rename names and the wider gap — the claim/
  actual text changed, so `defects-unsurfaced.sh` will (correctly) re-offer
  this at the next `/ardd-plan`: the scope grew, and it deserves a fresh
  accept/decline.
  **Location:** .github/workflows/smoke.yml:28
  **Severity:** drift (standard stated but never exercised; scope gap widening)

## Verified clean this pass

The four efforts merged since the sixth pass were each checked against the
Quality Standards and standing decisions they touch:

- **Release channel + versioning policy (v1.5.0–v1.7.0):** `new.sh` invokes
  `install.sh` and pins the latest release for the owned checkout
  (`pin_release`, new.sh:151); `/ardd-update` resolves via
  `source-resolve.sh` with dev-mode warned; offline resolution falls back
  with a warning (test-source-resolve offline case); migrations 0001–0008
  form an unbroken append-only sequence; `.ardd-applied` guidance printed by
  install.sh; `ardd-version.md` carries structured `Source-Commit` with
  prose fallback (producer + parser tests). The retirement claim ("every
  known consumer repointed as of v0.9.0") verified live this run:
  all five consumers report `up-to-date` at the v0.9.0 commit.
- **Workflow knobs:** `delegation`/`merge_policy` enum-enforced in
  lint-project.sh (with the version-skew hint); `ardd-state.sh stamp`
  accepts both; this repo dogfoods `eager`+`auto` and both behaviors were
  exercised live (unprompted delegation; unprompted clean merges).
- **Surface renames/folds:** frontmatter `name:`==dirname enforced by the
  extended lint-docs; smoke.yml scenarios, templates, WORKFLOW.md, and
  install.sh prune tombstones all use the 14-skill surface; single-writer
  files renamed with data preserved (audit.md checkbox counts intact in
  this repo and both consumers that had critique.md data).
- **Test-first floor:** every new deterministic script added since the
  sixth pass (`release.sh`, `source-resolve.sh`, migrations 0006–0008, the
  lint-docs extensions, mint/sentinel/enum changes) has a fixture-based
  regression test added in the same commit, and `hooks/pre-commit` picks
  all of them up by glob.

## Note on what verification can and cannot catch

This pass verifies the constitution's *checkable* claims against the tree.
Skill *behavior* (does `/ardd-init` actually seed good artifacts?) is the
smoke tier's job — which is exactly the one standard still unexercised
(the defect above).
