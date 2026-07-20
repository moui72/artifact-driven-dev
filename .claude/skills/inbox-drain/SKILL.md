---
name: inbox-drain
description: >-
  Source-side only (never installed to consumers). Drain this repo's
  out-of-band capture inbox (~/dev/.ardd-data/inbox/<repo>/, written by the
  user's `inbox` zsh function) by routing each item through the ArDD skill
  named on its first line — /ardd-feedback or /ardd-backlog — then deleting
  the drained file. Use when the user says "drain the inbox", "check the
  inbox", or invokes /inbox-drain.
---

# /inbox-drain

Drain the out-of-band capture inbox for **this repo**. The inbox exists so
the user can capture feedback and feature ideas (from another terminal, or
while the main session is busy) without running an ArDD skill at capture
time; this skill is the time-shifted other half of that hand-off.

The inbox never becomes a second source of truth — it is a queue that
empties into the existing ArDD machinery. All shaping, classification,
register writes, and dedup happen inside the routed skill, exactly as if
the user had invoked it directly with the item's text.

## Item format (capture-side convention)

- Directory: `$ARDD_INBOX_DIR` if set, else `~/dev/.ardd-data/inbox/`,
  then a subdirectory named after the repo (the basename of the repo's
  toplevel — for this repo, `artifact-driven-dev`).
- Files: `i-<timestamp>-<pid>-<rand>.md`. Filenames carry no meaning.
- Line 1 names the target skill (`/ardd-feedback` or `/ardd-backlog`);
  the rest is raw prose. Items are schema-free by design — do not lint
  them, and do not expect frontmatter.

## Steps

1. **Locate this repo's inbox.** Resolve the directory per the format
   above (repo name = `basename "$(git rev-parse --show-toplevel)"`).
   If the directory is missing or empty, report "inbox empty" and stop —
   this skill never creates inbox directories or files.

2. **List pending items.** Read every `*.md` in the directory. Present a
   one-line summary per item (target skill from line 1, first ~10 words
   of the body, file mtime). If any item's line 1 does not name a known
   skill, note that — its routing gets decided in step 3, not guessed
   silently.

3. **Confirm the drain plan — one batched prompt.** Via AskUserQuestion
   (multiSelect on), list every item with its proposed routing; the user
   deselects any to skip this run. For items with no (or an unknown)
   line-1 skill, propose a routing by judgment — a bug/UX observation →
   `/ardd-feedback`, a new-capability idea → `/ardd-backlog` — and mark
   it "(inferred)" in the option label so the user can veto it. Skipped
   items stay in the inbox untouched.

4. **Route each accepted item.** For each, invoke the target skill with
   the item's body (everything after line 1) as its input, and let it run
   to completion — including any prompts it raises (e.g.
   `/ardd-feedback`'s re-file-to-backlog confirmation). The routed skill
   owns all writes; this skill writes nothing under `.project/` itself.

   Process items one at a time, oldest first. If a routed skill run
   fails or is abandoned mid-way, leave that item's file in place and
   continue to the next — a file still in the inbox is the signal it has
   not been drained.

5. **Delete each drained file** — only after its routed skill run
   completed (for `/ardd-feedback`: the feedback file is written; for
   `/ardd-backlog`: the register entry exists). Deletion is what marks an
   item done; there is no processed/ archive, deliberately — the routed
   skill's output *is* the durable record.

6. **Report.** Item count drained by target skill, items skipped or
   failed (still in the inbox), and the files the routed skills produced.
   The routed skills' own terminal `/ardd-status` handoff covers the
   status refresh — run it once at the end, not once per item.

## Non-goals

- Never installed into target projects (`install.sh` doesn't touch
  `.claude/skills/` in this repo) — same source-side placement as
  `docs-sweep` and `scenario-sweep`. If dogfooding proves the pattern
  out, generalizing into ArDD proper goes through `/ardd-research`
  first.
- Never drains another repo's subdirectory — items for other repos are
  drained from a session in that repo.
- Never edits an inbox item's content. If an item is wrong, the user
  fixes or deletes it; this skill only routes or skips.
