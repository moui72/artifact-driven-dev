---
status: planned      # open -> planned
created: 2026-07-21
plan: plan-changelog-precommit-2026-07-21-b716.md
---

# Feedback

## Bugs
- [x] F001 `templates/badge-shieldcn.md`'s split/pair snippets ship a
  `PLACEHOLDER` token for the `logo` query param instead of a real
  base64-encoded icon, because shieldcn.dev's `dynamic/json` badge type's
  logo-parameter shape was never verified against shieldcn.dev's own docs
  during the `badge-style-variant-option` implementation run — it's
  unconfirmed whether it accepts a base64
  `data:image/svg+xml;base64,...` URI the way shields.io's `/endpoint`
  does. The icon itself is already decided — `templates/ardd-icon.svg`
  (the same icon this repo uses as its favicon and as the shields.io
  `logoSvg` field elsewhere) — so this is purely a param-syntax
  verification gap, not an open icon-choice question. Fix direction:
  confirm shieldcn.dev's `dynamic/json` logo param against its actual
  docs/source (or a test render), then replace the `PLACEHOLDER` token
  in `templates/badge-shieldcn.md` with the real base64-encoded
  `templates/ardd-icon.svg` value (same recipe already used for the
  shields.io form: `base64 < templates/ardd-icon.svg`), and remove the
  header-comment caveat once confirmed. Until fixed, the static-only
  shieldcn shape (grounded in this repo's own working `README.md:13`
  badge) is the only one safe to trust as-is — the split/pair shapes
  should not reach a real consumer with the placeholder still in place.

- [x] F002 A delegated worktree for the `badge-style-variant-option`
  implementation run was missing `.agents/skills/scenario-sweep/`
  (gitignored source-side content present in the primary checkout),
  causing an initial `scripts/test-install-harness.sh` failure on
  unrelated Codex-entrypoint assertions until the subagent manually
  copied the file over to unblock the pre-commit hook. `install.sh`'s
  `.worktreeinclude` handling currently ensures coverage for
  `.claude/skills/ardd-*/` (so Claude Code copies those gitignored files
  into every new worktree) but has no equivalent entry for
  `.agents/skills/scenario-sweep/` — the same class of gap, just for a
  different gitignored source-side path. Fix direction: extend whatever
  writes/checks `.worktreeinclude` (`install.sh`, per CLAUDE.md's
  architecture notes) to also ensure
  `.agents/skills/scenario-sweep/` is covered, mirroring the existing
  `.claude/skills/ardd-*/` pattern — same bounded-pattern discipline
  (never broader than the specific path needed).
