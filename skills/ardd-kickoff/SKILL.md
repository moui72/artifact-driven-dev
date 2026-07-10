---
name: ardd-kickoff
tier: setup
description: "Greenfield first session: run the design conversation, then hand off to /ardd-bootstrap."
---

# /ardd-kickoff

The first session of a brand-new project. `/ardd-bootstrap`'s contract is to
seed `.project/artifacts/` **from conversation context** — but on a cold
first session, opened straight from the `new.sh` quickstart, there is no
conversation yet. This skill creates it: the design conversation from
`guides/greenfield.md` Step 1, conducted as an interview, ending in a
`/ardd-bootstrap` handoff.

**This skill never writes artifacts.** `/ardd-bootstrap` remains their sole
author. `/ardd-kickoff` only produces the conversation that bootstrap reads.

Not to be confused with `/ardd-codify` — that reverse-engineers artifacts
from an *existing* codebase, and needs no interview because the code is the
context. `/ardd-kickoff` is for when there is no code yet.

Skipping it is always fine: talking through the project in your own words and
then running `/ardd-bootstrap` yourself reaches the identical place. This
skill exists so a user who arrives via the quickstart with an empty directory
isn't staring at a blank prompt.

## Steps

1. **Guard: already bootstrapped?** List `.project/artifacts/`. If any `.md`
   file exists, this project has already been through bootstrap or codify —
   say so and stop, pointing at `/ardd-analyze` for a status check and
   `/ardd-refine <name>` to change an artifact. Do not interview; do not
   offer to overwrite.

2. **Guard: is the install complete?** If `.claude/skills/ardd-scripts/`
   doesn't exist, the skill files arrived without `install.sh` having run
   (the `npx skills add` path). Stop and point at `/ardd-setup`, which
   completes the install. Every later step of this workflow shells out to
   `ardd-scripts`, so continuing would fail on the first script call.

3. **Conduct the design interview.** Cover the seven topics below, roughly in
   order — data before infrastructure, since storage and sync strategy should
   follow the schema rather than constrain it. Ask about one topic at a time,
   in your own words, following up where an answer opens a real question.
   This is a conversation, not a form: skip what plainly doesn't apply (a CLI
   tool has no UI topic), and go deeper where the user has clearly already
   made decisions.

   | Topic | What you're trying to surface |
   |---|---|
   | What it does | The problem it solves, in a sentence or two |
   | Who uses it | Role, technical level, how often |
   | Data | Entities, where they come from, how they relate |
   | External integrations | APIs, third-party services, other systems |
   | Storage | SQL vs NoSQL, hosted vs embedded — and why |
   | Tech stack | Language, framework, hard constraints |
   | Principles | What the project won't compromise on |

   Use `AskUserQuestion` where the choice is genuinely discrete (storage
   engine, language, solo vs collaborative workflow) and plain conversation
   where it isn't ("what problem does this solve?" has no options list).

   **"I don't know yet" is a first-class answer.** Say so explicitly the
   first time the user hesitates. Carry every undecided item forward as an
   `[OPEN: <question>]` for bootstrap to record — an artifact that honestly
   admits an open question is worth more than one with an invented decision
   in it, and `/ardd-analyze` will surface which open items actually block
   planning. Never resolve an open question by picking something plausible.

   Do not propose constitution principles here. `/ardd-bootstrap` has a
   curated suggestion catalog (`ardd-constitution-data/`) that it filters
   against the artifacts it's about to create, and offers at the right
   moment. Duplicating that from memory produces worse suggestions and a
   confusing double-ask.

4. **Reflect the design back.** Summarize what you heard, grouped roughly the
   way artifacts will be (principles, data, infrastructure, interface), and
   list every `[OPEN: ...]` item you're carrying. Ask the user to confirm or
   correct it. This is the last cheap moment to fix a misunderstanding —
   after bootstrap it takes an `/ardd-refine` pass.

5. **Hand off to `/ardd-bootstrap`.** Invoke it by name. It reads this
   conversation as its context — which is precisely what steps 3 and 4 just
   built — decides which artifacts the project actually needs, offers its
   constitution suggestions, asks its `workflow_mode` and `next_step_prompt`
   questions, and writes `.project/`. Do not pre-empt any of that here.
