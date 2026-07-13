# Which checking skill do I want?

Four skills check your project, at different layers. They don't overlap —
each answers a question the others can't.

| Skill | What it checks | Cost | When to run |
|---|---|---|---|
| [`/ardd-status`](../reference/skills/ardd-status.md) | Cross-artifact **consistency** — conflicts, gaps, draft artifacts, constitution violations, orphaned completion flips, in-flight work. LLM judgment. | Cheap | Before planning. Auto-runs as the final step of most state-changing skills. |
| [`/ardd-lint`](../reference/skills/ardd-lint.md) | **Structural** validity — frontmatter enums, required fields, `[artifacts: ...]` references, cross-file pointers. Deterministic, no LLM judgment. | Free | Anytime — especially after hand-editing anything in `.project/`. |
| [`/ardd-defects`](../reference/skills/ardd-defects.md) | Artifacts vs. the **actual codebase** — drift between what an artifact says and what the code does. | Expensive (codebase re-survey) | Periodically, or before major planning. |
| [`/ardd-audit`](../reference/skills/ardd-audit.md) | The **decisions themselves** — simplicity, failure modes, robustness, semantics. Challenges intent. | Moderate | When a design deserves pressure-testing, not just checking. |

## The shape of the split

Two axes separate them:

- **What's compared**: `/ardd-lint` and `/ardd-status` compare project
  files against *each other* (structure and meaning respectively);
  `/ardd-defects` compares them against the *code*; `/ardd-audit`
  compares them against *good judgment*.
- **Determinism**: `/ardd-lint` is a script and always says the same
  thing about the same files. The other three exercise LLM judgment and
  are worth re-running when context changes.

## Where each one's findings go

- `/ardd-status` → `STATUS.md` — the re-entry point; always names a
  recommended next step.
- `/ardd-lint` → terminal output only; it never writes.
- `/ardd-defects` → `DEFECTS.md` — each defect is offered as a fix task
  by the next `/ardd-plan` run, exactly once (pull a declined one back
  with `/ardd-plan defect:<id>`).
- `/ardd-audit` → `audit.md` — a working checklist you resolve directly
  (`[x]` done, `[-]` rejected), with a runnable `/ardd-refine` command on
  every concrete suggestion.

## What none of them do

None of these capture *your* observations from using the built thing —
that's `/ardd-feedback`. And none vet a *new idea* — that's
`/ardd-research`'s proposal mode.
