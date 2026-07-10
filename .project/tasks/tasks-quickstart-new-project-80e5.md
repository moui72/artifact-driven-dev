---
plan: plan-quickstart-new-project-2026-07-09.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-09
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: new.sh, test-first

- [x] T001 [artifacts: constitution] Write `scripts/test-new.sh` (POSIX `sh`,
      `set -e`) and confirm it fails before `new.sh` exists — constitution
      Principle V requires the red state first. Follow the existing
      throwaway-repo pattern in `scripts/test-install-worktreeinclude.sh`
      (temp dir under `mktemp -d`, trap-based cleanup, `git config
      user.email/user.name` locally so CI's bare runner can commit). Cases:
      (a) happy path — `ARDD_SOURCE=<this repo>` and `--no-launch`, target a
      fresh temp path; assert the target is a git work tree, and that
      `.claude/skills/ardd-scripts/lint-project.sh` and
      `.project/ardd-version.md` both exist; (b) target exists and is
      non-empty → exit status 1 and nothing written; (c) `ARDD_SOURCE` points
      at a directory that is not an ARDD checkout (no `install.sh`, no
      `skills/`) → exit status 1; (d) `--no-launch` never execs `claude` —
      assert by putting a poison `claude` on `PATH` that exits 42, and
      requiring exit 0. Hermetic: `ARDD_SOURCE` is always set, so no case
      reaches the network.

- [ ] T002 [artifacts: constitution] Implement `new.sh` at the repo root
      (POSIX `sh`, `#!/usr/bin/env sh`, `set -e`) until T001 passes. Usage:
      `new.sh [--no-launch] [--source <path>] <target-dir>`. Order is
      load-bearing: resolve source → `mkdir -p` + `git init` target → invoke
      `"$SRC/install.sh" "$TARGET"` → hand off. `install.sh` requires the
      target to exist and runs its gitignore guidance through `git -C
      "$TARGET" rev-parse`, so both the mkdir and the `git init` must precede
      it. Source resolution: `${ARDD_SOURCE:-$HOME/.ardd/source}`; clone
      `https://github.com/moui72/artifact-driven-dev` if absent; if present
      and it has `install.sh` + `skills/`, `git pull --ff-only` (on failure,
      warn and proceed with what's on disk); if present and it is NOT an ARDD
      checkout, refuse with exit 1. Refuse a non-empty target with exit 1.
      **Never prompt** — stdin is the `curl | sh` pipe (constitution, Project
      Scope & Intent, v1.2.3). Relay `install.sh` output verbatim. Handoff:
      unless `--no-launch`, if `command -v claude` succeeds and `/dev/tty` is
      readable, `cd "$TARGET"` and `exec claude "/ardd-kickoff" < /dev/tty`;
      otherwise print `cd <target> && claude "/ardd-kickoff"` and exit 0 —
      the install succeeded, so a nonzero exit would misreport it.

- [ ] T003 Add a `new-project` job to `.github/workflows/lint.yml` running
      `./scripts/test-new.sh`, with the `git config --global user.email/
      user.name` step the other git-touching jobs use. Do not add
      `test-new.sh` to any enumerated list — `hooks/pre-commit` discovers
      `scripts/test-*.sh` by glob, which is the constitution's Pre-commit
      Enforcement standard.

## Phase 2: /ardd-kickoff

- [ ] T004 [parallel] Write `skills/ardd-kickoff/SKILL.md`. Frontmatter:
      `name: ardd-kickoff`, `tier: setup`, and a `description:` — quote it if
      it contains a colon (the skills CLI's YAML parser silently drops
      unquoted-colon descriptions; `lint-docs.sh` enforces the presence of
      both fields). Steps: (1) guard — if any `.md` exists in
      `.project/artifacts/`, this project is already bootstrapped: stop and
      point at `/ardd-analyze`; (2) guard — if `.claude/skills/ardd-scripts/`
      is missing the install is incomplete: stop and point at `/ardd-setup`;
      (3) conduct the design interview over the seven topics in
      `guides/greenfield.md` Step 1 (what the system does, who uses it, data,
      external integrations, storage, tech stack, principles), one topic at a
      time, using `AskUserQuestion` where the choice is discrete; explicitly
      accept "don't know yet" and carry it forward as an `[OPEN: ...]` item
      rather than inventing a decision; (4) reflect the collected decisions
      back as a summary and get confirmation; (5) invoke `/ardd-bootstrap`,
      whose contract is to seed artifacts from conversation context — which
      this skill has just created. State plainly that `/ardd-kickoff` never
      writes artifacts itself; `/ardd-bootstrap` remains their sole author.
      No test: this is prose, not a deterministic script (constitution
      Principle V's documented exception).

- [ ] T005 Register `ardd-kickoff` in `scripts/gen-skill-docs.sh`'s
      `ORDER_setup`, between `ardd-setup` and `ardd-bootstrap`. Then run
      `./scripts/test-gen-skill-docs.sh` — if it asserts against a fixed
      skill set, update its fixture in the same commit.

## Phase 3: Docs and dogfood

- [ ] T006 Run `./scripts/gen-skill-docs.sh` to regenerate README's skill
      tables, then hand-add a `## Quickstart` section to `README.md` directly
      above `## Install`, showing the one-liner and naming what it does
      (creates the dir, `git init`, runs `install.sh`, opens
      `/ardd-kickoff`). Keep `## Install` intact beneath it — clone and npx
      remain supported channels. Verify with `./scripts/lint-docs.sh`, which
      requires every `/ardd-*` mentioned in docs to be a real skill.

- [ ] T007 Update `guides/greenfield.md` — lead with the quickstart as the
      front door, retain the existing manual Prerequisites path beneath it,
      and note that `/ardd-kickoff` performs Step 1's design conversation.
      Update `USAGE.md` to match. Re-run `./scripts/lint-docs.sh`.

- [ ] T008 Add `new.sh` and `scripts/test-new.sh` to `CLAUDE.md`'s Commands
      block, and record under Architecture that `new.sh` is source-side
      (fetched and run, never installed into a target) and converges onto
      `install.sh` by invoking it — never reimplementing it.

- [ ] T009 Update `install.sh`'s closing "Next steps for a new project"
      message to name `/ardd-kickoff` as step 1 for a brand-new project, with
      `/ardd-bootstrap` as what it leads into. Source-side change to
      user-facing output only; no install behavior changes.

- [ ] T010 Re-run `./install.sh .` to dogfood `ardd-kickoff` into this repo's
      own `.claude/skills/` and refresh `.project/ardd-version.md`. Then run
      `./scripts/lint-docs.sh`, `./scripts/lint-project.sh`, and
      `./scripts/test-new.sh` as a final gate.
