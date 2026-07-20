---
plan: plan-amend-path-policy-2026-07-20-3c72.md
generated: 2026-07-20
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Codify the factual-corrections exemption (F001)

- [ ] T001 Add a "Correcting a skill-written file" subsection to
  `templates/dot-project-readme.md` (best placed after the "Static
  historical records" section) carrying the canonical rule text from the
  plan's Technical Approach: factual corrections — content wrong on the
  page that re-decides nothing (mis-cited file/symbol, stale path, typo,
  wrong quotation) — may be hand-edited in place in any skill-written
  file's body prose; the exemption never covers frontmatter `status`
  fields, checkboxes, or lifecycle state (script-mutated via
  `ardd-state.sh` only), and never covers decisions, scope, or
  classifications (those go through `/ardd-feedback`, `/ardd-refine`, or
  a new plan). Keep it to one tight paragraph matching the guide's
  existing tone. No test task (prose change; `lint-docs.sh` covers
  reference validity).
- [ ] T002 [parallel] Soften the frozen-forever phrasing in both skills
  that state it: in `skills/ardd-feedback/SKILL.md` (the "Planned
  feedback files are not edited further" sentence in its Consumption
  section) and `skills/ardd-plan/SKILL.md` (the same sentence at the end
  of its step 4), append a clause noting factual corrections (citations,
  paths, symbol names, typos) are exempt and may be fixed in place —
  decisions and item content still never change. One sentence each; do
  not restate the full rule.
- [ ] T003 [parallel] Echo the exemption where reviewers and
  contributors read: `docs/reference/project-files.md` (alongside its
  existing hand-edit/single-writer guidance), `README.md` (the section
  stating the no-hand-edit/single-writer discipline — the "Concurrency
  and `.project/` merge conflicts" area), and source-side `CLAUDE.md`
  (one clause on the single-writer ownership list noting the
  factual-corrections exemption with a pointer to the reviewer guide as
  canonical home). Keep each echo to 1–2 sentences pointing at the
  canonical rule, never a second full statement that can drift.

## Phase 2: Citation-rot sweep (F002)

- [ ] T004 Sweep `skills/*/SKILL.md` and `templates/artifacts/*.md` for
  prose that instructs the agent to record a code location (start from
  `grep -rn 'file/l\|line number\|file/location\|location reference'
  skills/ templates/` and read around each hit — at minimum
  `/ardd-feedback`'s tagging step, `/ardd-defects`' claim-recording, and
  `/ardd-audit`'s findings). Switch each instruction to prefer
  `path + symbol name` (function, script name, section heading) with
  line numbers allowed only as a supplementary hint, mirroring the
  plan's rationale: symbol citations are self-healing and shrink the
  factual-error class the Phase 1 exemption exists to correct. Leave
  script-emitted output formats untouched — this is prose-instruction
  guidance only.
- [ ] T005 Verify: run `./scripts/lint-docs.sh` (green) and
  `./scripts/lint-project.sh .` (green), then re-run `./install.sh .` so
  this repo's own installed reviewer guide (`.project/README.md`) picks
  up the T001 change; confirm the new subsection is present in the
  regenerated file.
