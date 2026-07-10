---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: launch-prompt
created: 2026-07-09
features: []
surfaced-defects: []
---

# Plan — launch-prompt

## Goal

`new.sh` offers the Claude Code handoff instead of imposing it: with a usable
terminal it asks, `--kickoff` accepts in advance, `--no-kickoff` declines in
advance, and no terminal means decline rather than hang.

## Scope

**Included**

- Constitution v1.2.4 (already applied this run): the "never prompt" absolute
  is replaced by the two rules that actually hold.
- `new.sh` — a `read` from `/dev/tty`, `--kickoff`/`--no-kickoff` flags,
  `--no-launch` renamed.
- `scripts/test-new.sh` — cases for accept, decline, invalid-then-valid input,
  EOF, and no-tty. Written before the behavior (Principle V).
- Docs: `README.md`, `USAGE.md`, `guides/greenfield.md`, `CLAUDE.md`.

**Not included**

- Any change to the target/source refusals. They stay refusals; the
  constitution now says why (writing into an unowned directory is not a
  decision worth offering), rather than resting on the pipe-stdin argument.
- A prompt anywhere else in `new.sh`.

## Technical Approach

The prompt reads from `/dev/tty`, not stdin — under `curl | sh` stdin carries
the script's own source text. This is the same reopen the `exec` already
performs, which is precisely why the v1.2.3 "never prompt" rule was unsound.

Decision table, in precedence order:

| Condition | Behavior |
|---|---|
| `--kickoff` | launch, no question |
| `--no-kickoff` | print next steps, exit 0, no question |
| `/dev/tty` not readable | print next steps, exit 0 (never hang) |
| `claude` not on PATH | print next steps, exit 0 |
| otherwise | ask; default on bare Enter is yes |

`--kickoff` and `--no-kickoff` are mutually exclusive; passing both is a usage
error (exit 2) rather than a silent last-flag-wins.

**`--no-launch` is renamed, not aliased.** It shipped only on unpushed local
`main`, so it has no consumers. An alias would be dead compatibility surface
for a flag nobody has ever run (Principle VII: no dead architecture).

Reading the answer must not hang a pipeline. `read` sees EOF if `/dev/tty` is
readable but closed; treat EOF as decline, matching the no-tty default. An
unrecognized answer re-asks rather than guessing, but only a bounded number of
times — three, then decline — so a wedged tty can't loop forever.

Testing the prompt is possible without a real terminal: the tty is opened by
path inside the script, so a test can't inject one portably. Instead, factor
the decision into a `want_kickoff()` function whose tty read is the last step,
and exercise the flag/no-tty branches directly — which is where all the
regressions actually live. The interactive `read` itself stays covered by the
same argument as the `exec`: asserted by the negative (never reached when a
flag is present), confirmed in real use.

## Phase Breakdown

### Phase 1 — behavior, test-first

- **T001** `[artifacts: constitution]` Extend `scripts/test-new.sh`, red
  first. New cases: `--kickoff` with a poison `claude` exits 42 (proves the
  launch path is taken); `--no-kickoff` exits 0 without exec'ing it; both
  flags together exit 2; with no flags and stdin+tty unavailable, exit 0 and
  print the next step, never hang (guard with a timeout so a regression fails
  loudly instead of stalling CI); `--no-launch` is gone and now errors as an
  unknown option (exit 2).
- **T002** `[artifacts: constitution]` Implement in `new.sh` until T001
  passes: rename `--no-launch` → `--no-kickoff`, add `--kickoff`, add the
  mutual-exclusion usage error, and add the `/dev/tty` prompt with a
  bounded re-ask and EOF-means-decline.

### Phase 2 — docs

- **T003** Update `README.md` (Quickstart), `USAGE.md`, and
  `guides/greenfield.md` for the new flags and the asked-by-default handoff.
  `README.md`'s Quickstart currently asserts "`new.sh` never prompts" — that
  sentence is now false and must go.
- **T004** Update `CLAUDE.md`'s Architecture note, which currently records
  "it **cannot prompt**" as a standing constraint, and its Commands block's
  `new.sh` usage line.
- **T005** Re-run `./install.sh .` to refresh `.project/ardd-version.md`, then
  `./scripts/lint-docs.sh`, `./scripts/lint-project.sh`, `./scripts/test-new.sh`.

## Complexity Tracking

None. The prompt replaces an unconditional `exec` with a guarded one; no new
abstraction is introduced.

## Open Questions

None. Flag naming (`--kickoff`/`--no-kickoff`) and the rename-over-alias call
were both settled with the user before this plan was written.

## Production Annotation Summary

None.
