# /ardd-defects

_Tier: extension_

> Check artifacts against the actual codebase and record drift in .project/DEFECTS.md (its single writer); the next plan run offers each recorded defect as a fix task. Takes no observation input — report what you saw with /ardd-feedback instead.

<!-- generated:end — the header above is generated from skills/ardd-defects/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->

## Usage

```
/ardd-defects
```

**No arguments accepted.** It always runs its own full artifact-vs-code
pass; any argument (a bug you noticed, a file path) is redirected to
`/ardd-feedback` rather than silently ignored. Where `/ardd-status` checks
artifacts against each other (cheap, docs-only, frequent), this checks
them against what the code actually does (expensive — a codebase re-survey
on the order of `/ardd-init`'s). Run before major planning or
periodically, not as a routine post-refine step.

## Reads

- Every `.project/artifacts/*.md`
- The codebase, scoped to each artifact's claims: schemas and types for
  `datamodel`, sync/integration code for `infrastructure`, routes for
  `api`, components for `ui`, spot-checked practice for `constitution`

## Writes

- `.project/DEFECTS.md` — its single writer, **full overwrite every run**
  (a fixed defect silently drops out on the next pass; nobody has to
  remember to remove it). Each defect records the artifact, the specific
  claim, what the code actually does, file/line locations, and a severity
  (`cosmetic` / `drift` / `broken-contract`). A clean run still writes the
  file, in an explicit all-clear state — that's what distinguishes
  "checked, all clean" from "never checked."

Never writes into artifact bodies — artifacts describe intended design,
not a defect log.

## Consumption by /ardd-plan

Each defect gets a stable 8-char identifier (computed by
`defects-unsurfaced.sh` from its claim text). The next `/ardd-plan` run
offers every not-yet-surfaced entry as a fix task, exactly once —
declining is recorded too. `/ardd-plan defect:<id>` (or `defects`) pulls
declined entries back in.

## Behavior notes

- Ends by running `/ardd-status` so the defect summary line in
  `STATUS.md` isn't left stale.

## Related

- `/ardd-feedback` — where your own observations go
- `/ardd-status` — artifact-vs-artifact; never reads code
- [guides/checking.md](../../guides/checking.md) — the four checking
  skills compared
