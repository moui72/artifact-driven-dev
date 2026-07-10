---
status: planned      # open -> planned
created: 2026-07-09
plan: plan-launch-prompt-2026-07-09.md
---

# Feedback

## Bugs

None.

## UX

- [x] F001 `new.sh` should ask before it `exec`s `claude "/ardd-kickoff"`,
  rather than launching unconditionally. Two flags override the question:
  one to auto-accept (launch without asking) and one to auto-decline (install
  and print the next step — today's `--no-launch`). Absent a flag and with a
  usable terminal, ask. Absent a usable terminal, decline, as now.

## Reconsidered

- [x] F002 [artifacts: constitution] The constitution (v1.2.3, Project Scope
  & Intent) states that `new.sh` "must never prompt" because `curl | sh`
  hands it a pipe on stdin, and that it "reopens `/dev/tty` only for the
  terminal handoff." The premise doesn't support the conclusion: if the
  script can reopen `/dev/tty` to hand off to Claude Code, it can reopen it
  to `read` an answer. Prompting is available whenever `/dev/tty` is
  readable, which is precisely when launching is possible at all.

  What actually stays true, and is worth keeping as the real rule: `new.sh`
  never blocks on a question it cannot ask (no tty → take the safe default,
  never hang), and it still *refuses* rather than asks for the destructive
  cases — a non-empty target, or a `--source` that isn't an ARDD checkout.
  Those are refusals because writing into a directory the tool doesn't own is
  not a decision worth offering, not because stdin is a pipe.

  Scope of the reversal: the "never prompt" absolute becomes "never prompt
  where refusing is correct; never block when no tty exists." The launch
  handoff moves from unconditional to asked-by-default.
