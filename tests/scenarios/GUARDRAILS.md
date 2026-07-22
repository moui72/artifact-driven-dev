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
7. Cwd safety for git mutations: before ANY git mutation these guardrails
   prescribe (`git remote remove origin`, `git init`, adding the fake
   bare origin), verify your current directory is inside `$SCRATCH`:

   ```sh
   case "$PWD" in "$SCRATCH"/*) ;; *) echo "cwd outside SCRATCH — stop"; exit 1 ;; esac
   ```

   If the check fails, STOP and report — never run the mutation and never
   "fix up" the cwd silently. Prefer structural forms that name the target
   repo explicitly over cwd-dependent invocations wherever possible:
   `git -C "$SCRATCH/<clone>" remote remove origin`,
   `git init "$SCRATCH/<project>"` — an absolute path can't hit the wrong
   repo when a prior `cd` failed or a subshell dropped you somewhere
   unexpected (this exact failure once removed the `origin` remote from a
   real checkout).
8. Any damage to a path outside `$SCRATCH` — however small, however
   recoverable — is an INCIDENT: report it immediately and verbatim in
   your report file (what command, what path, what changed), never
   silently repair it and move on.

## Interaction model (harness constraint, not a product bug)

9. You have NO `AskUserQuestion` tool. Every ArDD skill pause (init
   interview, plan approval checkpoint, delegation gate, push
   confirmation, next-step prompt) has a PRE-SCRIPTED ANSWER in your
   brief's "Scripted answers" section. When a skill reaches such a pause,
   treat the scripted answer as the user's selection and continue. Do not
   attempt the tool call. Do NOT report the tool's absence as a finding.
   If a pause arises with no scripted answer, take the skill's stated
   default, note it in your report, and continue.

## Progressive, durable reporting (hard requirement)

10. Your brief names a report file under the ArDD repo's
   `dev-notes/scenario-runs/<run-id>/`. Create it as your FIRST act,
   with a header (scenario id, date, your scratch path), and APPEND to it
   after every major step — never hold findings for one final write. If
   you die mid-run, the partial report is the deliverable.
11. Report format per finding: an `## Fnnn` heading, a one-line summary,
   `kind: bug | ux | docs | question`, the exact command/skill and
   observed vs expected, and file paths. End the report (if you get
   there) with a `## Verdict` section: pass/fail per checklist item in
   your brief, plus overall subjective quality notes.
12. **The report file is your position marker.** On any resume or
   continuation, your FIRST act is to re-read your report file and find
   the last completed `## Step N` section; resume at step N+1. Never
   re-verify or re-inspect a step already written up — its section is
   final. Write a step's report section IMMEDIATELY after completing it,
   before starting the next step. If the sandbox shows work has outrun
   the report (e.g. commits exist for a step with no report section),
   writing that missing section IS the next step, not more inspection.
13. **Bounded verification.** At most two inspection commands per
   checklist item when verifying. If you still can't reach a verdict,
   write the section anyway with `verdict: inconclusive` plus what you
   saw, and move on — never loop re-running commands whose output you've
   already seen this run. If you're about to stop without having reached
   the end, write everything you know to the report first, finish the
   `## Verdict` section (marking unreached items `not-reached`), then
   stop.

## Judgment calibration

12. Report what a real user would notice: misleading errors, prose/doc
    drift, silent behavior, stale output, awkward phrasing — not just
    hard failures. But distinguish clearly between defects and taste;
    mark pure-taste items `kind: ux` with a "subjective" note.
