---
status: open      # open -> planned
created: 2026-07-21
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

From a real consumer update session (yet-another-rank-games,
v1.0.2 → v1.0.3, 2026-07-21).

## Bugs
- [ ] F001 The badge coordinate autodetect (install.sh badge section's
  OWNER/REPO/BRANCH fill from the target's git remote) doesn't handle
  SSH host aliases: yarg's remote is
  `github-ardd:moui72/yet-another-rank-games.git` — an ssh-config alias
  shape, neither the https nor the `git@github.com:` form the fill
  recognizes. Resolve such aliases — e.g. take the `<path>` part of any
  `<host-token>:<owner>/<repo>[.git]` scp-style remote regardless of
  the host token, and/or consult `ssh -G <alias>` / git `insteadOf`
  rules — instead of falling back to placeholders. Regression: extend
  `scripts/test-install-version-badge.sh` with an ssh-alias-remote
  fixture; S9 gains an alias-remote variant next time the badge
  file-set changes.

## Reconsidered
- [ ] F002 The badge flow's never-edit-README posture, as agents read
  it, is overly assertive: in the yarg session the consuming agent
  refused the README badge paste outright ("I won't touch the README
  per the skill's badge rule") until the user explicitly overrode it —
  leaving committed machinery dormant and costing an extra turn.
  Revise the posture across the badge surface (install.sh
  badge-section output prose, `/ardd-update`'s suggestion-relay prose,
  `templates/badge.md`): the AGENT relaying the suggestion may offer
  the edit — present the exact diff (snippet replacing the stale
  badge, markers included) and ASK whether to apply it, a
  confirm-with-diff gate rather than refusal-until-overridden.
  Unchanged: install.sh ITSELF stays suggestion-only — the shell
  script never edits a README.
