---
plan: plan-defect-doc-drift-2026-07-09.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-09
status: completed   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: reconcile prose with code

- [x] T001 [artifacts: constitution] [defect: b7d2252c] In
      `.project/artifacts/constitution.md`, Project Scope & Intent: the
      sentence "it **never blocks on a question it cannot ask** — when
      `/dev/tty` isn't readable it takes the safe default rather than hanging
      a pipeline forever" describes only the no-flag path. Reword so both
      paths are stated: with no flag and no usable tty, `new.sh` declines and
      prints next steps; with an explicit `--kickoff` and no usable tty it
      launches anyway on inherited stdin, because the user already answered
      and no question is pending. Keep "never block on a question it cannot
      ask" as the unifying rule — the `--kickoff` path satisfies it
      trivially. Bump the footer to v1.2.5, replace the Sync Impact Report
      (PATCH: corrects a description of already-shipped behavior; no
      principle, standard, or behavior changes), and stamp `last_updated` via
      `ardd-state.sh stamp` — never by hand. No test: prose, not a
      deterministic script.

- [x] T002 [defect: b7d2252c] In `README.md` (Quickstart, line ~149),
      replace "With no terminal to ask on — a scripted or CI run — it
      declines rather than hangs." That claim is flatly false when
      `--kickoff` is passed, and a reader could rely on it when scripting.
      Replace it, don't soften it: say that with no flag and no terminal it
      declines rather than hangs, and that `--kickoff` launches regardless.
      Verify with `./scripts/lint-docs.sh`.

- [x] T003 [artifacts: constitution] [defect: f666274c] In the same file,
      "`new.sh` converges by the most direct route available: it resolves a
      source checkout (cloning one if absent)" overstates. Only the owned
      `~/.ardd/source` is ever cloned; a `--source`/`$ARDD_SOURCE` path that
      doesn't exist is a hard error (exit 1). Tighten the clause. Sequence
      after T001 — same file, so not parallel.

- [x] T004 Re-run `./install.sh .` to refresh `.project/ardd-version.md`,
      then `./scripts/lint-docs.sh`, `./scripts/lint-project.sh`, and
      `./scripts/test-new.sh`. Then re-run `/ardd-verify`: both `b7d2252c`
      and `f666274c` must drop out of the regenerated `DEFECTS.md`. That
      regeneration is the only real proof the fix landed — no lint or test
      can detect prose that contradicts a shell function, which is exactly
      how this drift survived a fully green suite.
