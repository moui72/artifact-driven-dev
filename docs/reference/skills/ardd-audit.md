# /ardd-audit

_Tier: extension_

> Challenge artifact decisions — simplicity, failure modes, robustness, semantics — and write the findings checklist to .project/audit.md. Takes no proposal input — vet new ideas with /ardd-research instead.

<!-- generated:end — the header above is generated from skills/ardd-audit/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-audit             # audit all artifacts
/ardd-audit <name>      # audit one artifact
```

The only legal argument is the name of an existing artifact. A proposal,
an idea, a "what if we…" is redirected to `/ardd-research` (whose
proposal-vetting mode applies these same lenses to a *hypothetical*
change) — this skill audits only decisions already recorded. Unlike
`/ardd-status` (consistency and completeness), it asks whether the
decisions themselves are *good*.

## Reads

- `.project/artifacts/*.md` (scoped or all) and the feature register
- The existing `.project/audit.md`, if any — open items are reported and
  you choose: keep working the checklist, refresh one artifact's section,
  or regenerate the full report. Artifacts updated since the last audit
  are flagged as potentially stale findings.

## The lenses

Every artifact is worked through seven critical lenses: **simplicity**
(what could be removed?), **failure modes** (what breaks off the happy
path?), **standardness** (are conventions being reinvented?),
**robustness/fragility** (what couples what?), **DRYness** (what goes out
of sync first?), **semantics** (do names mean what they say?), and
**proportionality** (over-engineered for scope? under-specified where
mistakes are expensive?).

## Writes

- `.project/audit.md` — its single writer. Findings are a working
  checklist, classified:
  - **[S] Suggestion** — a concrete change, always with a runnable
    `/ardd-refine <artifact> <tight directive>` (or `/ardd-backlog`)
    command
  - **[Q] Question** — needs your input; the trade-off stated
  - **[R] Risk** — a fragility worth acknowledging even without a change

## Resolution workflow

You work the checklist directly in the file: `[ ]` open, `[x]` resolved,
`[-]` rejected/deferred (optionally with a note). The next `/ardd-audit`
run reads those marks and reports accordingly. Findings are deliberately
not softened — you can reject a wrong finding; you can't act on one never
raised.

## Behavior notes

- Adoption: an install predating the v1.0.0 rename may still have the
  legacy `critique.md` file; the skill renames it to `audit.md` and
  continues.
- The report is one sentence — the file is the deliverable.

## Related

- `/ardd-research` — vets *proposed* changes with the same lenses
- `/ardd-refine` — where accepted suggestions get applied
- [guides/checking.md](../../guides/checking.md) — the four checking
  skills compared
