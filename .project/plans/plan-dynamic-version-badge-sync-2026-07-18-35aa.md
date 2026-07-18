---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: dynamic-version-badge-sync
created: 2026-07-18
features: [dynamic-version-badge-sync]
surfaced-defects: []
---

# Plan: dynamic-version-badge-sync

## Goal

Let `install.sh` optionally install a dynamic "ArDD version" README badge
into a target project — a shields.io endpoint-badge JSON file plus a
GitHub Action that keeps it in sync with `.project/ardd-version.md` —
replacing the current single static-only badge suggestion with a
two-badge pair (static "built with ArDD" + dynamic version).

## Scope

**In scope:**
- A new opt-in mechanism for `install.sh` to write the badge-sync
  workflow (`.github/workflows/ardd-badge.yml`) and seed JSON
  (`.github/badges/ardd-version.json`) into a target project, offered
  the same way the existing static badge suggestion is offered (a
  printed suggestion, but this time backed by real installable files
  rather than paste-only text) — gated by a new opt-in env var
  (`ARDD_VERSION_BADGE=1`, mirroring the existing `ARDD_CHANNEL` env-var
  convention already used for channel selection), **not** a new
  interactive prompt. `install.sh` has no CLI flag parser today (only a
  positional `TARGET`) and is invoked non-interactively from `new.sh`,
  `test-new.sh`, and CI — adding an interactive prompt here would
  reintroduce exactly the "never blocks on a question it cannot ask"
  hazard the constitution already documents for `new.sh`'s tty
  discipline. An env var sidesteps that entirely: present but unset by
  default, explicit opt-in when set, no tty interaction required.
- The workflow logic itself: on a push that changes
  `.project/ardd-version.md`, read `Source-Ref:` (or `Source-Commit:`
  when no tag is recorded) and `Channel:` from that file, and regenerate
  `.github/badges/ardd-version.json` in shields.io's
  [endpoint-badge JSON schema](https://shields.io/badges/endpoint-badge),
  committing the change if the JSON actually differs (never an empty
  commit).
- A seed JSON written at install time reflecting the version recorded by
  *this* install run (so the badge is correct immediately, before the
  first sync workflow run).
- A two-badge README snippet (static "built with ArDD" + dynamic version
  badge reading the JSON via a `dynamic/json` shields.io badge URL)
  offered alongside the file-writing, replacing the current
  single-static-badge snippet in `templates/badge.md` when the
  version-badge opt-in is active (the plain static-only snippet remains
  the default/unopted-in offering — this plan never forces the dynamic
  badge on every install).

**Out of scope:**
- Making the dynamic badge the default, unconditional offering — the
  static-only badge stays the default suggestion; the dynamic pair is
  strictly opt-in via the new env var.
- `install.sh` gaining a general CLI flag parser — this plan uses an env
  var specifically to avoid that scope creep; a future flag-parser
  refactor (if ever needed for unrelated reasons) is not this plan's
  concern.
- The open question from the feature's `Why:` line (whether the sync
  workflow should also fire directly off `/ardd-update`'s own commit,
  not just watch `ardd-version.md` via a separate Action) is addressed
  by Technical Approach below, not deferred — since watching the file
  the workflow *always* changes (regardless of whether the commit came
  from `/ardd-update`, a manual edit, or anything else) already covers
  every case a commit-message-based trigger would, with less coupling to
  `/ardd-update`'s exact commit-message wording. Firing off the commit
  message directly is explicitly rejected below, not left open.
- Editing `assisted-review`'s already-hand-built badge plumbing to
  consume this new capability — that's a separate follow-up for that
  consumer project, not part of installing the capability itself.

## Technical Approach

**Env-var opt-in, not a flag or a prompt.** `install.sh` already reads
`ARDD_CHANNEL` from the environment for the two-channel decision (v1.8.0)
— `ARDD_VERSION_BADGE` (unset/`0`/`1`, validated the same way
`ARDD_CHANNEL` is: an unrecognized value is a refusal, not a silent
guess) follows the identical pattern. This is deliberately *not* a new
interactive `AskUserQuestion`-style prompt: `install.sh` is a plain POSIX
`sh` script invoked non-interactively by `new.sh`, `test-new.sh`, and CI,
and has no tty-prompt discipline built in (unlike `new.sh`'s carefully
tty-gated kickoff prompt) — adding one here would be new surface area
this plan doesn't need to open.

**File-writing vs. paste-only.** The existing static badge suggestion
only ever *prints* a snippet — `install.sh` never touches a target's
README (Constitution: "install.sh never modifies a target's README").
This plan preserves that rule for the README itself (the two-badge
snippet is still print-only, for the user to paste), but the
*supporting files* (`.github/workflows/ardd-badge.yml`,
`.github/badges/ardd-version.json`) are genuinely new files in a
directory `install.sh` doesn't already manage — written only when
`ARDD_VERSION_BADGE=1`, and only if they don't already exist (idempotent
re-install, same posture as the skills-copy step) — never overwriting a
target's hand-customized version of either file on a re-run.

**Workflow trigger: watch `ardd-version.md`, not `/ardd-update`'s commit
message.** Rejecting the "fire off `/ardd-update`'s commit" option from
the feature's open question: any process that changes
`.project/ardd-version.md` — `/ardd-update`, a manual edit, a future
tool — needs the badge to stay in sync, and a path-filtered
(`paths: ['.project/ardd-version.md']`) GitHub Actions trigger already
covers all of them uniformly. Keying off `/ardd-update`'s specific commit
message would only handle the subset of updates that went through that
one skill, add a hidden coupling between the workflow's trigger logic and
that skill's exact commit-message format, and buy nothing the path filter
doesn't already give for free. One extra CI hop (the workflow run itself)
is the accepted cost — it's asynchronous and doesn't block the user's own
push.

**JSON generation.** Parse `Source-Ref:` (preferred — the human-readable
tag) falling back to a short `Source-Commit:` prefix when no tag is
recorded (dev-mode/no-releases-yet installs), and `Channel:`, from
`.project/ardd-version.md` — same `sed`-based read style
`install.sh`/`ardd-update-check.sh`/`source-resolve.sh` already use for
that file, reused here rather than reinvented. Emit shields.io's
documented endpoint-badge JSON shape (`schemaVersion`, `label`,
`message`, optionally `color`).

## Phase Breakdown

### Phase 1: Workflow + seed JSON templates
Depends on: —
- T001: Create `templates/ardd-badge-workflow.yml` — the GitHub Actions
  workflow template: triggers on push paths-filtered to
  `.project/ardd-version.md`; parses `Source-Ref:`/`Source-Commit:` and
  `Channel:` via the shared `sed` read pattern; regenerates
  `.github/badges/ardd-version.json` in shields.io endpoint-badge schema;
  commits only if the JSON actually changed (never an empty commit).
- T002: Create `templates/ardd-badge.json` — the seed JSON template (a
  placeholder shape `install.sh` fills in with the current install's
  actual version at write time, per T004).
- T003: [parallel] Update `templates/badge.md` — add the two-badge
  variant (static "built with ArDD" + dynamic version badge reading
  `.github/badges/ardd-version.json` via a shields.io `dynamic/json`
  badge URL) as an alternate snippet alongside the existing single
  static badge, clearly labeled as the version accompanying the
  `ARDD_VERSION_BADGE=1` opt-in.

### Phase 2: `install.sh` wiring
Depends on: Phase 1
- T004: Add `ARDD_VERSION_BADGE` env-var validation to `install.sh`
  (unset/`0`/`1` only — an unrecognized value is a refusal, mirroring the
  existing `ARDD_CHANNEL` validation block), and extend the existing
  "built with ArDD badge" suggestion section: when `ARDD_VERSION_BADGE=1`
  and the two target files don't already exist, write
  `.github/workflows/ardd-badge.yml` (from T001's template) and
  `.github/badges/ardd-version.json` (from T002's template, filled in
  with the current run's actual `Source-Ref`/`Source-Commit` and
  `Channel`) into the target, then print the two-badge snippet
  (T003) instead of the single static one. When unset (the default),
  behavior is byte-for-byte unchanged from today.
- T005: Manually verify a real `ARDD_VERSION_BADGE=1 ./install.sh
  <fixture-target>` run writes both files with correct content matching
  that fixture's actual recorded version, and that a plain
  `./install.sh <fixture-target>` (unset) writes neither file and prints
  the unchanged static-only snippet — confirming the opt-in is genuinely
  inert by default.

### Phase 3: Regression test
Depends on: Phase 2
- T006 [artifacts: none] Create `scripts/test-install-version-badge.sh`
  — a new narrow fixture-based regression test, mirroring this repo's
  existing per-concern install test pattern (`test-install-gitattributes.sh`,
  `test-install-manifest-complete.sh`, `test-install-prune.sh`,
  `test-install-worktreeinclude.sh`), asserting: (a) an
  `ARDD_VERSION_BADGE=1` install case creates both new files with the
  fixture's actual version baked into the JSON; (b) a re-install case
  confirms a hand-edited `ardd-version.json`/`ardd-badge.yml` is left
  untouched (idempotent, never clobbered); (c) the default (unset) path's
  existing badge-suggestion behavior is unchanged byte-for-byte from
  before this plan. Add its CI job to `.github/workflows/lint.yml` in
  the same commit (this repo's stated rule: a new deterministic check
  ships with both its regression test and CI wiring together — the
  exact convention `feedback-ci-migration-tests-unwired-37ee.md` caught
  a violation of).

## Complexity Tracking

No deviations requiring justification — this reuses `install.sh`'s
existing env-var opt-in pattern (`ARDD_CHANNEL`) rather than introducing
a new mechanism, and reuses the existing `.project/ardd-version.md`
`sed`-read style already shared across three other scripts.

## Open Questions

- [OPEN: Should the workflow template (T001) also handle the
  no-Source-Ref case (dev-mode / pre-first-release installs) by falling
  back to a distinct badge message like "dev" rather than a raw commit
  prefix, for readability? Resolve at implementation time by checking
  what `ardd-update-check.sh`'s existing no-Source-Ref handling already
  displays, for consistency.]
- [OPEN: Does the seed JSON (T002/T004) need `install.sh` to also detect
  and warn if a target's repo has no GitHub remote (making the badge
  URL meaningless)? The existing static badge suggestion doesn't check
  this either — likely fine to inherit that same "suggestion, not
  validation" posture, but flagging for confirmation at implementation
  time rather than silently assuming.]
