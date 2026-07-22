---
status: planned
created: 2026-07-22
plan: plan-b860-2026-07-22-e518.md
---

# Feedback

## Bugs
- [x] F001 `new.sh`'s `launch()` function (`new.sh:346-357`) `exec`s the
  handoff tool directly (`exec "$handoff_tool" "$handoff_cmd"`) without
  redirecting stdin — deliberately, per the function's own comment, since
  Claude Code checks `process.stdin.isTTY && process.stdout.isTTY` and
  falls back to opening `/dev/tty` itself when that check fails. Reported
  live: installing Codex support (`--harness codex`) into a real project
  (assisted-review) via `curl | sh`, the kickoff prompt (`ask_kickoff`,
  correctly read from `/dev/tty`) was answered yes, then `launch()`'s
  `exec codex '$ardd-status'` failed immediately with `Error: stdin is
  not a terminal` — under `curl | sh`, stdin at that point is the EOF'd
  curl pipe, and Codex apparently has no equivalent isTTY-checked
  `/dev/tty` fallback the way Claude Code does; it just requires stdin to
  already be a real terminal and errors out otherwise. The comment above
  `launch()` documents the Claude-Code-specific reasoning in detail but
  the function applies the identical `exec` pattern to both harnesses —
  the Codex case was never independently verified against Codex's actual
  stdin behavior. Needs either a Codex-specific stdin redirect (e.g.
  `< /dev/tty` or `<> /dev/tty`, whichever Codex's own CLI actually
  expects — verify empirically, don't guess) or documented/tested
  no-launch fallback behavior for Codex under a piped invocation, mirroring
  the care already given to the Claude Code case.
