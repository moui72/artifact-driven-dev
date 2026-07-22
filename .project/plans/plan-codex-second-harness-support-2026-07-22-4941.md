---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: codex-second-harness-support       # the branch inline implementation would use; may never be created (see step 1)
created: 2026-07-22
features: [codex-second-harness-support]
surfaced-defects: []
---

# Plan: codex-second-harness-support (closeout)

## Goal

Close out the `codex-second-harness-support` feature: ship the one
remaining scoped gap — optional Codex `AGENTS.md` guidance — and flip the
feature's register status to reflect that the rest of its scope has
already shipped under other feature slugs.

## Scope

This is a **closeout plan**, not a fresh port. An audit against the
superseded 2026-07-15 draft plan's (`plan-codex-second-harness-support-
2026-07-15-f837.md`, now `superseded`) five-phase breakdown found nearly
everything already shipped, under other feature slugs, since that draft was
written:

- `install.sh --harness codex` (`.agents/skills/` layout, `$` invocation
  sigil, `--harness` validation) — shipped.
- `new.sh --harness codex` (interactive `ask_harness` prompt, `/dev/tty`
  discipline, pass-through to `install.sh`) — shipped, documented in
  `docs/install.md` (feature `new-sh-codex-docs`).
- The `/ardd-*` → `$ardd-*` invocation-sigil rewrite in installed skill
  prose (`install_skill_file()`'s codex-only `sed` pass) — shipped
  (feature `35f6`, merged 2026-07-22).
- `.worktreeinclude` gitignored-file copy handling, per-harness bounded —
  shipped (feature `multi-harness-install-metadata`, implemented
  2026-07-21).
- The constitution's "Multi-harness install" section (Project Scope &
  Intent, around line 403) accurately documents the current five-clause
  substitution set and the dual-install standing decision — no correction
  needed; it was speculative-but-since-caught-up, not currently
  overstating anything.
- A live Codex chaining/smoke test — the old plan's own "mandatory first
  implementation task" — already ran: `dev-notes/scenario-runs/
  2026-07-22-c0de/` is a real Codex CLI scenario sweep against an
  installed target, and its findings are already captured as
  `feedback-codex-scenario-sweep-findings-2eee.md` (all 3 items marked
  `[-]` declined into a different, unrelated plan earlier today — they
  remain untracked-by-any-plan and are explicitly **not** re-opened by
  this plan; re-filing them is a separate decision for whoever wants them
  actioned).

**In scope (the one real gap):**
- A `templates/AGENTS.md` template (Codex's convention for repo-root
  agent guidance) and `install.sh` wiring: on a `--harness codex` install,
  write it to `$TARGET/AGENTS.md` only if that file doesn't already exist
  (never-clobber, same idiom as `templates/ardd-icon.svg` →
  `.github/badges/ardd-icon.svg`); if `AGENTS.md` already exists, print an
  advisory pointing at the template instead of writing anything — never
  overwrite a consumer's existing agent guidance (constitution's own
  stated constraint on this exact item, Project Scope & Intent line
  ~421-422).
- A regression test (`scripts/test-install-agents-md.sh`) covering both
  branches: fresh-write on a `--harness codex` install with no existing
  `AGENTS.md`, and the never-clobber/advisory path when one already
  exists. A `--harness claude` install never writes or mentions
  `AGENTS.md` (Claude doesn't use this convention) — a third case the
  test also covers.
- A one-line mention in `docs/install.md`'s existing Codex section.

**Out of scope:**
- Any change to the already-shipped install/sigil/worktreeinclude/docs
  behavior above — it's done and tested, not touched here.
- Shipping a Codex hook (explicitly deferred in the constitution's
  Multi-harness section; a separately scoped decision, unchanged).
- Re-opening or re-scoping the 3 declined codex-scenario-sweep feedback
  items — out of scope for this plan.

## Technical Approach

Follow the exact never-clobber file-write idiom `install.sh` already uses
for `.github/badges/ardd-icon.svg` (around line 776): a plain `[ ! -f
"$TARGET/AGENTS.md" ]` guard, `cp` on the write branch, and a `"(already
exists, left untouched)"` advisory line on the skip branch — no new
posture, no snippet/confirm-with-diff machinery (that idiom exists for
mid-*existing*-file edits like the README badge marker; `AGENTS.md` either
doesn't exist yet, in which case a full-file copy is safe, or it does, in
which case nothing is written at all). Gate the whole block on `[
"$HARNESS" = codex ]` — this is Codex-specific guidance, never written
for a `--harness claude` install.

`templates/AGENTS.md`'s content: a short pointer file, mirroring
`templates/dot-project-readme.md`'s framing but for Codex's own
convention — explains that `.project/` is the durable ArDD state,
points at `.project/README.md` (the reviewer guide, already installed)
for how to read it, and states the `$ardd-*` invocation convention
(Codex's exact-name invocation channel, per the constitution's
already-documented substitution #5). Not a duplicate of the reviewer
guide — a short landing pointer to it, since `AGENTS.md` is where Codex
looks first.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

### Phase 1: Template and install.sh wiring, test-first
- Write `templates/AGENTS.md` (the short pointer file described above).
- Add a red-first fixture case to `scripts/test-install-agents-md.sh`
  (new file) asserting: (a) a `--harness codex` install into a target
  with no `AGENTS.md` writes one matching the template; (b) a
  `--harness codex` install into a target with an existing `AGENTS.md`
  leaves it byte-identical and prints the advisory instead; (c) a
  `--harness claude` install never writes or mentions `AGENTS.md` at
  all, regardless of whether one exists. Confirm all three fail against
  current `install.sh` (no such wiring exists yet).
- Add the never-clobber write/advisory block to `install.sh` (codex-only,
  same idiom as the `ardd-icon.svg` block). Confirm the fixture cases now
  pass.

### Phase 2: Documentation
Depends on Phase 1 (docs describe shipped behavior).
- Add a one-line mention of the `AGENTS.md` guidance to `docs/install.md`'s
  existing Codex section, alongside the existing `--harness codex`
  documentation.

## Complexity Tracking

No deviations — this reuses the codebase's existing never-clobber
file-write idiom (`ardd-icon.svg`) wholesale; nothing here needs
justifying beyond it.

## Open Questions

- None. The scope is narrow and the idiom to follow is already fully
  precedented in the codebase.
