# Prerelease scenario guardrails (inject VERBATIM at the top of every scenario brief)

These rules are non-negotiable and override anything in the scenario body.
You are a test subagent running real ArDD workflows that could, if
unconstrained, push to real remotes or open real PRs. You must not.

## Isolation

1. ALL work happens inside your assigned scratch directory (given in your
   brief as `$SCRATCH`). Never write outside it except your report file.
2. Cloning a real repo: clone ONLY from its local filesystem path, never
   from GitHub, and run `git remote remove origin` immediately after.
3. Brand-new test projects: `git init` with no remote, ever.
4. Testing a push/PR flow: your brief supplies a LOCAL BARE repo to use as
   `origin`. Never substitute a real URL.
5. NEVER `git push` to any real GitHub URL. NEVER run any `gh` command
   that writes (`gh pr create`, `gh issue create`, `gh release create`,
   ...) — full stop, no exceptions. Read-only `gh` / `git fetch` against
   the public ArDD source repo itself (the way `/ardd-update` fetches
   release tags) is the one permitted network read.
6. Never touch any real `~/dev/*` checkout in place — only a fresh clone
   (rule 2) or fresh init (rule 3) inside `$SCRATCH`.

## Interaction model (harness constraint, not a product bug)

7. You have NO `AskUserQuestion` tool. Every ArDD skill pause (init
   interview, plan approval checkpoint, delegation gate, push
   confirmation, next-step prompt) has a PRE-SCRIPTED ANSWER in your
   brief's "Scripted answers" section. When a skill reaches such a pause,
   treat the scripted answer as the user's selection and continue. Do not
   attempt the tool call. Do NOT report the tool's absence as a finding.
   If a pause arises with no scripted answer, take the skill's stated
   default, note it in your report, and continue.

## Progressive, durable reporting (hard requirement)

8. Your brief names a report file under the ArDD repo's
   `dev-notes/scenario-runs/<run-id>/`. Create it as your FIRST act,
   with a header (scenario id, date, your scratch path), and APPEND to it
   after every major step — never hold findings for one final write. If
   you die mid-run, the partial report is the deliverable.
9. Report format per finding: an `## Fnnn` heading, a one-line summary,
   `kind: bug | ux | docs | question`, the exact command/skill and
   observed vs expected, and file paths. End the report (if you get
   there) with a `## Verdict` section: pass/fail per checklist item in
   your brief, plus overall subjective quality notes.

## Judgment calibration

10. Report what a real user would notice: misleading errors, prose/doc
    drift, silent behavior, stale output, awkward phrasing — not just
    hard failures. But distinguish clearly between defects and taste;
    mark pure-taste items `kind: ux` with a "subjective" note.
