---
plan: plan-pre-release-ratchets-2026-07-12.md
generated: 2026-07-12
status: in-progress
---

# Tasks

## Phase 1: Constitution amendment

- [x] T001 [artifacts: constitution] Amend the constitution (v1.5.0 →
  v1.6.0, MINOR, one SIR, `last_updated` stamped via `ardd-state.sh
  stamp`): (a) the feature-register standing decision's enum becomes
  `backlogged|planned|tasked|implemented|retired` (`retired` = terminal:
  shipped then deliberately removed) with the semantics sentence "a
  feature's `status` asserts what is true of the system NOW, not what was
  once reached"; (b) the release-channel section gains the pack versioning
  policy — MAJOR = removed/renamed slash command or breaking script-output/
  schema change; MINOR = additive skill, knob, or schema-widening; PATCH =
  prose/fix — plus: migrations are append-only (never renumbered, renamed,
  or deleted — `.ardd-applied` keys by filename and any release must
  upgrade any older install), and `.ardd-applied` should be committed
  (uncommitted, every teammate re-runs migrations).

## Phase 2: Mechanical hardening (test-first throughout)

- [x] T002 [artifacts: constitution] Add `retired` to
  `FEATURE_STATUS_ENUM` in `scripts/lint-project.sh` AND the
  `implemented→retired` arc to `ardd-state.sh feature-flip` in the same
  commit (forward-only discipline otherwise unchanged; retired is
  terminal — no arc out of it). Test-first: bad-fixture case (invalid
  value still rejected; `retired` accepted; flip from `tasked` to
  `retired` refused; flip out of `retired` refused) red before
  implementation. Then `ardd-state.sh feature-flip npx-skills-install
  retired`, and mark the answered [Q] in `.project/audit.md` resolved
  (`- [x]` with a one-line note "resolved: present-truth + retired,
  constitution v1.6.0" — user-directed resolution per the audit
  resolution workflow).

- [x] T003 Harden `ardd-version.md`: `install.sh` writes a structured
  `Source-Commit: <full-sha>` line (prose `_Source: … @ <short>` stays,
  now decorative); `scripts/ardd-update-check.sh` and
  `scripts/source-resolve.sh` prefer `Source-Commit:` and compare by
  prefix match (handles short-vs-full and future width changes), fall
  back to the prose line for pre-1.0 files, and fall back to
  `${ARDD_HOME:-$HOME/.ardd}/source` when the recorded `Source-Path`
  doesn't exist on this machine (new outcome or reuse `source-missing`
  semantics — keep the key=value contract additive, never change existing
  keys' meaning). Test-first: regression cases for old-format-only file,
  new-format file, prefix match across widths, moved/missing
  `Source-Path` with and without an existing `~/.ardd/source`.

- [ ] T004 Three small fixes, one commit each or one combined commit,
  test-first: (a) `ardd-state.sh mint plan|research` keeps the date and
  gains the hex4 token — `plan-<slug>-<YYYY-MM-DD>-<hex4>.md` — updating
  the mint format comments and `test-ardd-state.sh` mint cases, with
  uniqueness across same-day calls asserted; (b) `lint-project.sh` unknown-enum messages append "…or
  written by a newer ARDD than this install — run /ardd-update"
  (test asserts the hint text); (c) `lint-project.sh`'s
  `.lint-project-failed` sentinel moves to `mktemp` + `trap` cleanup —
  no file ever written into the target root; add the interrupted-run
  fixture case (pre-seed a stale sentinel, assert a clean run exits 0).

## Phase 3: Close out

- [ ] T005 Docs: README/USAGE update-guidance sections mention the release
  semver policy in one sentence each where they describe `/ardd-update`;
  `install.sh`'s gitignore/output guidance notes `.ardd-applied` should be
  committed. Full pre-commit suite + extended lint-docs + `lint-project.sh`
  against live `.project/` green.
