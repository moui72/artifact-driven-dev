---
plan: plan-b860-2026-07-22-e518.md
generated: 2026-07-22
status: in-progress
---

# Tasks

## Phase 1: Fix and pin the launch redirect
- [x] T001 In `new.sh`'s `launch()` function, branch the `exec` call on
      `$harness`: Claude Code keeps the current unredirected `exec
      "$handoff_tool" "$handoff_cmd"` exactly as-is; add a `codex` branch
      that runs `exec "$handoff_tool" "$handoff_cmd" <> /dev/tty`
      (read-write redirect — Codex has no `isTTY`-checked `/dev/tty`
      fallback of its own, unlike Claude Code, so it needs stdin
      explicitly connected to a real terminal). Update the function's
      header comment to explain both branches side by side: Claude
      Code's existing reasoning (redirecting would pass its `isTTY`
      check but be silently ignored for keystrokes) plus Codex's new
      reasoning (no fallback logic at all — errors immediately without a
      real terminal on stdin). **Verify live, in a real terminal, that
      `codex '$ardd-status'` (or `$ardd-init`) actually launches
      correctly with this redirect** — this cannot be tested from a
      non-interactive/CI environment (no controlling tty), so a passing
      automated check alone does not confirm the fix; the empirical
      terminal check is the actual verification, per the plan's Open
      Questions.
- [x] T002 Update `test-new.sh` case 14 (currently asserts the single
      shared exec line never contains `/dev/tty`) to instead assert two
      things statically, mirroring the existing "no live tty in CI, grep
      the source line" discipline: the Claude Code branch's exec line
      contains no `/dev/tty` redirect, and the Codex branch's exec line
      does contain `<> /dev/tty`. Keep the comment explaining why this
      stays a static source-grep rather than a live invocation. Run
      `./scripts/test-new.sh` and confirm it passes.
