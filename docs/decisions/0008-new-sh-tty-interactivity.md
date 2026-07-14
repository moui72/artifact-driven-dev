# 0008 — `new.sh`'s `/dev/tty` interactivity rules

_Recorded 2026-07-14 (events 2026-07-11 through 2026-07-13). Source-repo
history only._

`new.sh` runs via `curl | sh`, which hands it a pipe on stdin — not a
terminal. An earlier phrasing (v1.2.3 of the constitution) inferred from
that alone that the script "must never prompt." The inference was
unsound: a script that can reopen `/dev/tty` to hand off to Claude Code
can just as well reopen it to `read` an answer. Stdin being a pipe says
nothing about whether `/dev/tty` itself is readable.

Two rules replaced the absolute, and both still hold:

- **Refuses rather than asks**, wherever writing into a directory it
  doesn't own is at stake — a non-empty target in new-project mode, or a
  `--source` that isn't an ArDD checkout. These aren't decisions worth
  offering; the script declines instead of prompting for permission to
  proceed somewhere it shouldn't.
- **Never blocks on a question it cannot ask.** Between the two bounds
  above, `new.sh` may prompt — and does, once: the Claude Code handoff is
  offered on `/dev/tty`, with `--kickoff`/`--no-kickoff` to answer in
  advance.

The second rule is about *pending questions*, not about the terminal, and
getting that distinction wrong produced a real regression (v1.2.4). The
correct behavior splits on whether a question is actually pending:

- **No flag, no readable `/dev/tty`** — there is a question (whether to
  hand off to Claude Code) and no way to put it. `new.sh` takes the safe
  default: declines the launch, prints the command to start the session
  by hand, and exits 0. The install itself succeeded; reporting otherwise
  would misreport it.
- **Explicit `--kickoff`, no readable `/dev/tty`** — there is no pending
  question at all; the user answered it on the command line. `new.sh`
  launches anyway, on inherited stdin. Declining a flag someone named by
  hand would be worse than an odd session.

v1.2.4 compressed both cases into "when `/dev/tty` isn't readable, take
the safe default" — true only of the first case. That phrasing silently
broke the `--kickoff`-with-unreadable-`/dev/tty` path and must not be
reintroduced.

**Three implementation traps**, each cause of real debugging time:

1. `[ -r /dev/tty ]` tests permission bits and passes even on a CI
   runner with no controlling terminal at all — the actual `open` then
   fails with `ENXIO`. Use a real open (`tty_ok()`), not a permission
   check.
2. Every branch that decides whether to reach the `read` prompt must be
   covered by a timeout guard in the test suite, or a regression stalls
   CI instead of failing it cleanly.
3. The `/dev/tty` discipline for the `read` prompt must **not** extend to
   the final `exec` that launches Claude Code — the two have opposite
   requirements. Claude Code's TUI only reads `process.stdin` when both
   `stdin.isTTY && stdout.isTTY`; otherwise it opens `/dev/tty` `r+`
   itself. `exec claude … < /dev/tty` would hand it a *read-only* fd that
   still passes the `isTTY` check — the TUI paints, then silently ignores
   every keystroke. (`<> /dev/tty`, read-write, makes it exit instead of
   hanging silently.) An EOF'd pipe on stdin is the case Claude Code
   already handles correctly, so `launch()` must leave stdin alone rather
   than redirecting it. No tty exists in CI to catch a regression here,
   so `scripts/test-new.sh` case 14 guards the `exec` line statically.

The standing rules (refuses-rather-than-asks;
never-blocks-on-a-question-it-cannot-ask) are recorded in
`constitution.md`'s Project Scope & Intent, which points here for the
full narrative.
