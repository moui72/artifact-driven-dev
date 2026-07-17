---
status: open      # open -> planned
created: 2026-07-17
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Bugs
- [ ] F001 `new.sh`'s git-init guard (`new.sh:240`,
  `git -C "$TARGET" rev-parse --is-inside-work-tree`) walks UP the
  directory tree for any enclosing `.git` rather than checking whether
  `$TARGET` itself is a repo root. When the target is nested under an
  existing git-controlled directory (a monorepo subfolder, a
  dotfiles-managed home directory, any personal "projects" dir that's
  itself under version control), the check returns true, `git init` is
  silently skipped, and the new "project" folds into the outer repo
  instead — sharing its `.git`, branch, history, and remote. No
  "Initialized empty git repository" line prints, so there's no visible
  signal anything went wrong. Not specific to any test harness — hits
  any real user whose target path sits under an existing git work tree.
  Fix direction: check `[ -e "$TARGET/.git" ]` or compare
  `git -C "$TARGET" rev-parse --show-toplevel` against `$TARGET`, rather
  than `--is-inside-work-tree`. Found by `/prerelease-sweep smoke`
  (S1-F001, run 2026-07-17-1d42).

## UX
- [ ] F002 `ardd-update-check.sh` reports `behind installed=<x>
  latest-release=<y>` purely from tag-equality — no ancestry check. For
  a dev-mode source checkout (`Source-Path` naming a live,
  unreleased-ahead checkout) that is actually *ahead* of the latest
  release tag, it still says "behind," and `/ardd-status`'s prose
  template reuses the same "ArDD update available — run /ardd-update"
  line, which would actually regress the target if followed (observed:
  127 commits' worth of regression in the run that found this). Found
  by `/prerelease-sweep smoke` (S7-F001, run 2026-07-17-1d42).
