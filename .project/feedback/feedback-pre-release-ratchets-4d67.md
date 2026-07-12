---
status: open      # open -> planned
created: 2026-07-12
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

_Source: pre-1.0 "ratchet test" review (fresh-eyes Fable agent, 2026-07-12):
what is cheap to change today and painful after consumers pin `v1.0.0`.
Verdict was "no blocker," but F001–F003 are do-before-release. **Sequencing:
consume after `plan-skill-surface-cleanup` merges, land before
`tasks-remote-install-source-18d3.md` T008 cuts the release.** User
decisions already made: register `status` asserts PRESENT truth (not
reached-once); full scope accepted._

## Bugs

- [ ] F001 `ardd-version.md` is machine-parsed prose with unstable short
  hashes. `ardd-update-check.sh` scrapes the installed commit from the
  human sentence (`_Source: artifact-driven-dev @ <hash>`), so any wording
  tweak breaks update detection in every installed target; both writer and
  checker use `rev-parse --short`, whose width auto-widens with repo growth
  → guaranteed eventual false "behind" on string equality; `Source-Path:`
  is a committed per-machine absolute path that churns between teammates in
  collaborative mode. Fix before any consumer commits the v1 format: add a
  structured `Source-Commit: <full-sha>` line (prose line stays
  decorative), compare by prefix match in `ardd-update-check.sh` and
  `source-resolve.sh`, and both fall back to `~/.ardd/source` when the
  recorded `Source-Path` doesn't exist on this machine. Regression tests
  updated in the same commit (test-first).

- [ ] F002 `lint-project.sh` writes its `.lint-project-failed` sentinel
  into the target root; an interrupted run leaves it behind and the next
  clean run exits 1 with zero findings. Use `mktemp` + `trap` cleanup
  instead. Fixture test for the interrupted-run case.

## Reconsidered

- [ ] F003 Feature-register semantics decided: `status` asserts **present
  truth**. Add terminal `retired` to `FEATURE_STATUS_ENUM` in
  `lint-project.sh` and a `feature-flip implemented→retired` arc in
  `ardd-state.sh` (forward-only discipline otherwise unchanged); flip
  `npx-skills-install` to `retired` (the channel was removed 2026-07-11 —
  the register currently asserts a falsehood). Amend the constitution's
  feature-register standing decision (enum + semantics sentence — the
  decision text is the schema's contract; MINOR or PATCH per governance
  judgment). This resolves the open **[Q]** in the audit checklist
  (formerly critique.md — post-cleanup it lives at `.project/audit.md`;
  mark it resolved there, as the user, when landing this).
  [artifacts: constitution]

- [ ] F004 Pack-level versioning policy is unstated. Add to the
  constitution (release-channel decision's section): what MAJOR/MINOR/PATCH
  mean for a *pack release tag* (removed/renamed slash command = MAJOR;
  additive skill/schema-widening = MINOR; prose/fix = PATCH); migrations
  are **append-only** — never renumbered, renamed, or deleted, because
  `.ardd-applied` keys by filename and any release must upgrade any older
  install; `.ardd-applied` should be committed (collaborative mode:
  uncommitted means every teammate re-runs migrations — also state this in
  install.sh's gitignore guidance if applicable). [artifacts: constitution]

## UX

- [ ] F005 Unknown-enum tolerance: `lint-project.sh`'s unknown-enum-value
  message gains "…or written by a newer ARDD than this install — run
  /ardd-update" so newer-schema files in a team repo read as a version-skew
  hint, not just corruption. (Policy: schema-widening releases are MINOR;
  the message is the 1.0-compatible mechanism; a real Schema-Version marker
  is explicitly deferred post-1.0.)

- [ ] F006 `ardd-state.sh mint` inconsistency: plan/research filenames are
  `<slug>-<YYYY-MM-DD>` (same-day supersede-and-replan of one feature
  collides) while tasks/feedback carry a hex4 token. Give plan/research the
  same hex token (convention freezes at 1.0 — filenames are
  cross-referenced from feature `plan:`/`tasks:` fields). Update
  `test-ardd-state.sh` mint cases in the same commit.
