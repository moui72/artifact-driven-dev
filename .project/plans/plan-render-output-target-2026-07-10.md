---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: render-output-target
created: 2026-07-10
features: []
surfaced-defects: []
---

# Plan — configurable `/ardd-render` output destination

## Goal

Let a project point each `/ardd-render` diagram at a file other than
`README.md`, so a README that must stay npm-clean can keep Mermaid out
while diagrams still render on GitHub.

## Scope

**Included**
- Per-artifact frontmatter that names the render destination (file, and
  optionally the section header) for that artifact's diagram.
- `/ardd-render` reads that config and upserts into the named file/section,
  defaulting to today's behavior (`README.md` + the config-table section)
  when absent.
- `lint-project.sh` schema extension for the new optional field(s) + fixtures
  and regression test in the same commit (repo rule: no unverified validator).
- Doc sync for the render destination now being configurable.

**Not included**
- Any change to `upsert-section.sh` — it already takes the target file as its
  first argument; nothing there is hardcoded.
- A general-purpose per-project config file or a constitution-frontmatter
  render map (considered and rejected below as over-surface for the need).
- Auto-migrating existing projects' diagrams out of README — this only adds
  the knob; moving a diagram is a per-project `/ardd-render` re-run.

Addresses feedback F001
(`feedback-render-output-target-configura-1d3b.md`; GitHub issue #2).

## Technical Approach

The only hardcoding is the literal `README.md` in `/ardd-render` step 6 and
the "README section" column of its config table. `upsert-section.sh <file>
<header>` is already fully parameterized, so the work is entirely in *where
the target comes from* and in the skill reading it.

Store the destination as **optional per-artifact frontmatter** on each
renderable artifact — the skill already loads the artifact's frontmatter in
step 2, and config living next to the thing rendered needs no new file or
global surface:

```yaml
# .project/artifacts/datamodel.md
render_target: docs/ARCHITECTURE.md   # optional; default README.md
render_section: Datamodel             # optional; default = config-table section
```

Resolution rules (preserve current behavior exactly when both absent):
- `render_target` absent → `README.md`; present → that path (relative to
  project root). The skill `mkdir -p`s the parent and creates the file empty
  if missing (generalizing step 5's "ensure README.md exists").
- `render_section` absent → the config table's section for that argument
  (`Datamodel` / `Infrastructure` / `UI`); present → that header text
  (without `##`).
- Bare `/ardd-render` (all types) already loops per artifact, so mixed
  destinations fall out for free — each artifact writes to its own target.

`upsert-section.sh` is unchanged; step 6 just passes the resolved file and
section instead of the literals.

The motivating "move everything to `docs/ARCHITECTURE.md`" case costs one
`render_target:` line per renderable artifact — explicit and local, at the
price of N edits rather than one global switch (see Open Questions).

## Phase Breakdown

**Phase 1 — Skill wiring (core, demonstrable increment).**
- `skills/ardd-render/SKILL.md`: teach step 2/5/6 to read `render_target` /
  `render_section` from the artifact frontmatter already loaded; resolve per
  the rules above; `mkdir -p` parent + create-empty the resolved target in
  step 5; pass resolved file+section to `upsert-section.sh` in step 6.
- Reframe the config table's "README section" column as "Default section"
  and note the default target is `README.md`.
- Update the skill's frontmatter `description` line (no longer "into
  README.md").
- *Demo:* an artifact with `render_target: docs/ARCHITECTURE.md` renders
  there; an artifact without it still renders into `README.md` byte-for-byte
  as before. [artifacts: none — code/skill change] (F001)

**Phase 2 — Schema + lint (depends on Phase 1 field names).**
- `scripts/lint-project.sh`: accept optional `render_target` (non-empty
  path string) and `render_section` (non-empty string) on artifact
  frontmatter; reject empty/malformed values.
- Add good/bad cases to `tests/fixtures/{good,bad}-project` and extend
  `scripts/test-lint-project.sh`; wire nothing new in CI (existing job runs
  it).
- *Demo:* lint passes on an artifact carrying the fields; a malformed value
  fails with a clear message.

**Phase 3 — Doc sync (depends on Phase 1).**
- `README.md` / `USAGE.md`: update the `/ardd-render` description to say the
  destination is configurable per artifact, with `README.md` the default.
- *Demo:* `scripts/lint-docs.sh` still green; docs describe the knob.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| _(none)_ | Per-artifact frontmatter adds no new file, script, or global config surface; `upsert-section.sh` is reused unchanged. Simplicity principle satisfied. |

## Open Questions

1. **Config granularity.** Per-artifact frontmatter (this plan) vs. a
   project-level default (e.g. a constitution-frontmatter render map) that
   artifacts override. Per-artifact keeps surface minimal but costs one edit
   per artifact for the "move all diagrams" case. Confirm per-artifact is
   acceptable, or ask for the hybrid (project default + per-artifact
   override) if the N-edit cost is unwelcome.
2. **Section configurability — YAGNI?** The motivating case only needs the
   *file*; section headers can stay fixed. Ship `render_section` too, or
   only `render_target` now and defer section until a project asks? Leaning
   file-only to keep the surface smallest; the feedback did mention "file +
   section," hence surfacing it.
3. **Path safety.** `render_target` is resolved relative to project root and
   the skill creates parent dirs — confirm no need to guard against absolute
   or `..`-escaping paths (a project editing its own artifacts is trusted;
   noting it rather than adding validation preemptively).

## Production Annotation Summary

None — no production shortcuts introduced.
