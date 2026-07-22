---
status: approved
branch: new-sh-codex-docs
created: 2026-07-21
features: []
surfaced-defects: []
---

# Plan: document new.sh's Codex harness support

## Goal

Document `new.sh --harness claude|codex` in `docs/install.md` so a reader
following that page's existing `new.sh` coverage can discover its Codex
support without already knowing to check `new.sh --help` or the source.

## Scope

**In scope:**
- A `new.sh`-specific mention of `--harness claude|codex` near
  `docs/install.md`'s existing `new.sh` coverage (the Quickstart /
  existing-project sections and their `--kickoff`/`--beta`/`--source`
  flag documentation) — covering the flag itself, the interactive
  `ask_harness` prompt behavior when no flag is given (3 tries, falls
  back to `claude` on no clear answer or no tty), and that it's passed
  straight through to `install.sh --harness "$harness"`.
- A cross-reference from that new mention to the existing "Codex CLI:
  `install.sh --harness codex`" section, so a reader isn't left
  wondering what choosing `codex` actually does.

**Out of scope:**
- Any change to `new.sh`'s or `install.sh`'s actual behavior — this is a
  documentation-only fix for a real, already-working code path.
- `USAGE.md`'s existing `install.sh --harness codex` routing line already
  exists and needs no change; this plan only touches `docs/install.md`'s
  `new.sh`-specific coverage.

## Technical Approach

`docs/install.md`'s Quickstart section (`## Quickstart: a brand-new
project`, docs/install.md:7) and its existing-project sibling already
document `new.sh` flag-by-flag (`--kickoff`/`--no-kickoff`, the
refuse-rather-than-ask behavior). Add `--harness claude|codex` to that
same flag-documentation style, right alongside where `--kickoff`/`--beta`
are already covered — not a new top-level section, since the existing
"Codex CLI: `install.sh --harness codex`" section (docs/install.md:103)
already covers the harness concept itself in depth; `new.sh`'s job is
narrower — noting it exposes the same choice at acquisition time, with a
link forward to that section for the full Codex behavior/caveats.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

- **Phase 1: Document `new.sh --harness`** — add the flag documentation
  and cross-reference to `docs/install.md`.

## Open Questions

None — this is a straightforward documentation addition to an
already-decided, already-working code path.
