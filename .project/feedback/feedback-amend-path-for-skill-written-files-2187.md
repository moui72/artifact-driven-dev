---
status: planned
created: 2026-07-20
plan: plan-amend-path-policy-2026-07-20-3c72.md
---

# Feedback

## UX
- [x] F001 No sanctioned path to amend a skill-written file whose content is
  factually wrong. Concrete case: `/ardd-feedback` wrote
  `.project/feedback/feedback-head-sha-drafted-vs-fetched-co-a9d9.md`; a code
  reviewer correctly noted its F001 cited the wrong source location; the file
  was `status: open` and unconsumed, yet no skill could fix it —
  `/ardd-feedback` only creates, `/ardd-refine` targets
  `.project/artifacts/`. Only option was hand-editing a skill-owned file,
  which the workflow discipline forbids. Generalizes to plans and tasks
  files: factual corrections (citations, paths, symbol names) that re-decide
  nothing have no home. Resolve one of two ways — explicitly exempt factual
  corrections from the no-hand-edit rule (decisions/scope stay covered), or
  add an amend path (`--amend <file>` on the writing skill, or an
  `ardd-state.sh` operation). Either way, state the rule somewhere an agent
  will read it; today the rule is silent and downstream agents must guess.
- [x] F002 Skills that write file/line citations into skill-owned files are
  writing content guaranteed to rot. Cheaper complement to F001: prefer
  citing symbol names over line numbers wherever skills emit code
  references.
