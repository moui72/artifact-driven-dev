---
plan: plan-launch-prompt-2026-07-09.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-09
status: completed   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: behavior, test-first

- [x] T001 [artifacts: constitution] Extend `scripts/test-new.sh` and confirm
      the new cases fail first (Principle V). Update every existing case that
      passes `--no-launch` to `--no-kickoff`. Add: (a) `--kickoff` with the
      poison `claude` on PATH exits 42 — the inverse of the existing case 4,
      and the only positive proof the launch path is reachable; (b)
      `--no-kickoff` with the poison on PATH exits 0 and prints the
      `/ardd-kickoff` next step; (c) `--kickoff --no-kickoff` together exit 2
      (usage), not last-flag-wins; (d) `--no-launch` is now an unknown option,
      exit 2; (e) no flags, `claude` absent from PATH → exit 0, prints next
      steps, does not hang. Wrap case (e) in a timeout guard so a regression
      that blocks on a `read` fails the suite instead of stalling CI forever.

- [x] T002 [artifacts: constitution] Implement in `new.sh` until T001 passes.
      Rename `--no-launch` to `--no-kickoff` (rename, not alias — it shipped
      only on unpushed local `main`, so an alias would be dead compatibility
      surface, Principle VII). Add `--kickoff`. Passing both is a usage error,
      exit 2. Replace the unconditional `exec` with a guarded one, in this
      precedence order: `--kickoff` → launch; `--no-kickoff` → print next
      steps, exit 0; `claude` not on PATH → print, exit 0; `/dev/tty` not
      readable → print, exit 0 (never hang a pipeline); otherwise ask on
      `/dev/tty`, bare Enter meaning yes. Read the answer from `/dev/tty`, not
      stdin — under `curl | sh` stdin carries this script's own source text.
      Treat EOF as decline. Re-ask on an unrecognized answer at most three
      times, then decline, so a wedged terminal can't loop forever.

## Phase 2: docs

- [x] T003 Update `README.md`, `USAGE.md`, and `guides/greenfield.md` for the
      new flags and the asked-by-default handoff. `README.md`'s Quickstart
      currently asserts "`new.sh` never prompts — under `curl | sh` its stdin
      is the pipe carrying the script itself, so there's nothing to read an
      answer from"; that claim is now false and must be replaced, not softened
      — say instead that it asks on `/dev/tty`, and that it still *refuses*
      (never asks) on a non-empty target or a bad `--source`. Verify with
      `./scripts/lint-docs.sh`.

- [x] T004 Update `CLAUDE.md`: the Architecture note currently records "it
      **cannot prompt** (its stdin is the `curl` pipe …)" as a standing
      constraint — replace with the two rules from constitution v1.2.4 (refuse
      where an unowned directory is at stake; never block on a question that
      can't be asked). Update the `new.sh` usage line in the Commands block to
      show `[--kickoff|--no-kickoff]`.

- [x] T005 Re-run `./install.sh .` to refresh `.project/ardd-version.md`, then
      run `./scripts/lint-docs.sh`, `./scripts/lint-project.sh`, and
      `./scripts/test-new.sh` as a final gate.
