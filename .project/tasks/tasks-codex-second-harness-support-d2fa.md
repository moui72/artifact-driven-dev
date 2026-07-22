---
plan: plan-codex-second-harness-support-2026-07-22-4941.md
generated: 2026-07-22
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                     # (or -> abandoned, if superseded by a new tasks
                     # file generated for the same plan)
                     # completed is terminal — post-completion failures
                     # become new feedback (/ardd-feedback), never a
                     # status edit.
---

# Tasks

## Phase 1: Template and install.sh wiring, test-first

- [x] T001 Create `templates/AGENTS.md`: a short pointer file for OpenAI
  Codex's `AGENTS.md` convention. Content: state that `.project/` holds
  this project's durable ArDD workflow state (artifacts, plans, tasks,
  the feature register), point at `.project/README.md` (the reviewer
  guide already installed by `install.sh`) for how to read it, and state
  the `$ardd-*` invocation convention (Codex's exact-name invocation
  channel — every ArDD skill is invoked as `$ardd-<name>`, e.g.
  `$ardd-status`). Keep it short — a landing pointer, not a duplicate of
  the reviewer guide.
- [x] T002 Create `scripts/test-install-agents-md.sh` (new file, modeled on
  `scripts/test-install-harness.sh`'s structure: `set -e`, the
  `unset GIT_*` line, a `mktemp -d` work dir with `trap ... EXIT`, a local
  `git()` wrapper disabling gpgsign/hooksPath, an `ok`/`bad`/`fail`
  harness). Add three cases, all run against the current (pre-fix)
  `install.sh`, confirming they FAIL (red step — no AGENTS.md wiring
  exists yet):
  1. `./install.sh --harness codex <fresh-target>` where `<fresh-target>`
     has no `AGENTS.md` — assert `<fresh-target>/AGENTS.md` now exists
     and its content matches `templates/AGENTS.md` byte-for-byte.
  2. `./install.sh --harness codex <target>` where `<target>` already has
     an `AGENTS.md` with custom content — assert that file is
     byte-identical to its pre-install content (never clobbered) and that
     the install's stdout contains an advisory line naming `AGENTS.md`
     (mirror the `.github/badges/ardd-icon.svg` "(already exists, left
     untouched)" wording style at `install.sh` around line 780).
  3. `./install.sh --harness claude <fresh-target>` where `<fresh-target>`
     has no `AGENTS.md` — assert no `AGENTS.md` is written and no
     `AGENTS.md`-related line appears in stdout (Claude installs never
     touch this file).
  Make the script executable (`chmod +x`).
- [x] T003 In `install.sh`, add a never-clobber write/advisory block for
  `AGENTS.md`, gated on `[ "$HARNESS" = codex ]`, placed near the other
  never-clobber writes (the `.github/badges/ardd-icon.svg` block, around
  line 776, is the exact idiom to mirror): if `$TARGET/AGENTS.md` doesn't
  exist, `cp "$SCRIPT_DIR/templates/AGENTS.md" "$TARGET/AGENTS.md"` and
  print a `✓ AGENTS.md` confirmation line; if it does exist, print a
  `– AGENTS.md (already exists, left untouched)` advisory line instead.
  Nothing runs for `--harness claude`. Run
  `scripts/test-install-agents-md.sh` and confirm all three cases now
  PASS.

## Phase 2: Documentation

- [x] T004 [artifacts: constitution] In `docs/install.md`'s existing Codex
  section (alongside the current `--harness codex` documentation), add one
  line noting that a Codex install also writes `AGENTS.md` (never-clobber)
  pointing new sessions at `.project/README.md`'s reviewer guide and the
  `$ardd-*` invocation convention. No test requirement — this is a
  documentation-only change (constitution Principle V's exception for
  documentation-only changes).
