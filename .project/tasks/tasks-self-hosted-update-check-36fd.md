---
plan: plan-self-hosted-update-check-2026-07-08.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-08
status: completed   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                     # completed is terminal — post-completion failures
                     # become new feedback (/ardd-feedback), never a
                     # status edit.
---

# Tasks

Test-first (constitution Principle V): T001's fixture cases land red
before the guard is implemented. T002 is doc-only (stated exception).

## Phase 1

- [x] T001 Add a self-hosted guard to `scripts/ardd-update-check.sh`:
  after resolving Source-Path and before comparing tips, compare
  `git -C <source> rev-parse --show-toplevel` against
  `git -C <target> rev-parse --show-toplevel` (resolved toplevels,
  NEVER string paths); when equal, print `self-hosted commit=<installed>`
  and exit 0. Test-first in `scripts/test-ardd-update-check.sh`: two new
  cases red then green — (a) a target whose recorded Source-Path is the
  target repo itself; (b) a symlink to the target recorded as
  Source-Path, proving the toplevel comparison beats string compare.
  All six existing outcome cases stay green.
- [x] T002 [parallel] `skills/ardd-analyze/SKILL.md`: add `self-hosted`
  to the silent outcomes alongside `no-version-file`, `no-source-path`,
  and `up-to-date`. lint-docs green.
- [x] T003 Live verification: run `./scripts/ardd-update-check.sh .`
  (source copy — the installed copy refreshes at the post-merge
  reinstall) against this repo; expect `self-hosted commit=<x>` instead
  of the perpetual `behind` reading. Record the observed line as a note
  on this task. [verified 2026-07-08: observed `self-hosted commit=b046c2a`]
