---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: badge-consumer-fixes
created: 2026-07-21
features: []
surfaced-defects: []
---

# Plan: Badge consumer fixes — ssh-alias autodetect + confirm-with-diff posture

## Goal

Make the badge coordinate autodetect parse scp-style SSH host-alias
remotes, and revise the badge surface's never-edit-README posture so a
consuming agent offers the README edit behind a confirm-with-diff gate
instead of refusing until overridden.

## Scope

**In:** install.sh's OWNER/REPO fill parsing `<host-token>:<owner>/
<repo>[.git]` regardless of host token (feedback `ea66` F001, red-first
fixture); the posture revision across the badge prose surface —
install.sh badge-section output, `/ardd-update`'s suggestion-relay
prose, `templates/badge.md` (`ea66` F002).

**Out:** `ssh -G`/`insteadOf` resolution (the path part alone yields
owner/repo — host resolution adds machinery with no coordinate value);
any change to install.sh's own suggestion-only contract (the script
still never edits a README).

Also **in**: a small S9 brief edit adding the alias-remote variant to
case 2's setup — brief edits land via the fix plan, per the sweep
convention.

## Technical Approach

- **F001**: the remote parser currently recognizes https and
  `git@github.com:` shapes. Generalize the scp-style branch: any remote
  matching `<token>:<path>` where `<token>` has no `://` is scp-style —
  take `<path>`, strip `.git`, and read `<owner>/<repo>` from its last
  two segments. Host token is irrelevant to coordinates, so an
  ssh-config alias (`github-ardd:moui72/yarg.git`) parses identically
  to `git@github.com:moui72/yarg.git`. Placeholder fallback remains for
  genuinely unparseable remotes. Red-first fixture in
  `test-install-version-badge.sh`.
- **F002**: reword the three prose sites from "never edit the README /
  paste this yourself" to: the printed snippet stays suggestion-only at
  the script level, AND an agent relaying it should offer to apply the
  edit — showing the exact diff (snippet with markers replacing any
  stale badge) and asking before writing. One consistent sentence
  shape at all three sites, stated once fully in `templates/badge.md`
  and echoed tersely in install.sh output and `/ardd-update` prose.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

**Phase 1 — F001 (red-first).**
- ssh-alias fixture case in `test-install-version-badge.sh`, confirmed
  red; then the generalized scp-style parse in install.sh; suite green.

**Phase 2 — F002 (prose, parallel-safe with Phase 1 apart from
install.sh).**
- Posture revision at the three sites; `lint-docs.sh` green.

## Open Questions

- None. (The badge file-set changes here, so `/scenario-sweep S9` —
  with an alias-remote variant added to the brief in the same batch —
  is the natural post-merge check; per standing convention that brief
  edit rides the fix plan.)
