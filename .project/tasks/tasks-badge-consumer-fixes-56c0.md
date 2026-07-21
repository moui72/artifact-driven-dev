---
plan: plan-badge-consumer-fixes-2026-07-21-1c50.md
generated: 2026-07-21
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: ssh-alias autodetect (F001, red-first)

- [x] T001 Add a red-first case to
  `scripts/test-install-version-badge.sh`: fixture repo with remote
  `github-ardd:example-owner/example-repo.git` (scp-style ssh-config
  alias — no `://`, host token not `git@github.com`), README present,
  `ARDD_VERSION_BADGE=1` install — assert the printed snippet's
  endpoint URL and the written workflow carry
  `example-owner/example-repo` and the real branch, with zero
  placeholder residue. Confirm it FAILS against current install.sh
  (falls to placeholders). Land per the repo's documented red-first
  shell-test convention (document in the commit body).
- [x] T002 Generalize install.sh's badge-section remote parsing: any
  remote matching `<token>:<path>` where `<token>` contains no `://`
  is scp-style — take `<path>`, strip a trailing `.git`, and read
  `<owner>/<repo>` from its last two segments, regardless of the host
  token (an ssh-config alias parses identically to
  `git@github.com:`). Keep the https branch and the placeholder
  fallback for genuinely unparseable remotes unchanged. T001's case
  plus the full `test-install-version-badge.sh` suite and
  `scripts/lint-templates-yaml.sh` green.

## Phase 2: confirm-with-diff posture (F002, prose)

- [x] T003 [parallel] Revise the never-edit-README posture at the
  three badge prose sites, one consistent shape: full statement in
  `templates/badge.md` — the printed snippet is suggestion-only at the
  script level (install.sh never edits a README), AND an agent
  relaying the suggestion should OFFER to apply the edit: present the
  exact diff (the snippet with its markers, replacing any stale badge
  block) and ask before writing — a confirm-with-diff gate, never a
  refusal that waits for an override. Terse echoes in install.sh's
  badge-section output text and `skills/ardd-update/SKILL.md`'s
  suggestion-relay step. `lint-docs.sh` green; adjust any
  `test-install-version-badge.sh` output assertions the wording change
  breaks.
- [ ] T004 [parallel] Add the alias-remote variant to
  `tests/scenarios/S9.md`: case 2's setup gains a note to use an
  scp-style alias remote (`github-ardd:example-owner/example-repo.git`)
  in at least one badged case and assert coordinates still fill (brief
  edits ride the fix plan, per the sweep convention). Keep the brief's
  house style; `lint-docs.sh` green.
