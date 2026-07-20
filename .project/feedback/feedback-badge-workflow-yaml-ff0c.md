---
status: open      # open -> planned
created: 2026-07-20
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Bugs
- [ ] F001 `templates/ardd-badge-workflow.yml` is not valid YAML — GitHub
  Actions rejects it, so anyone following the badge guidance gets a
  workflow that never runs. Cause (confirmed at line 52-53): the heredoc
  writing the badge JSON puts its body and terminator at column 0, which
  ends the enclosing `run: |` block scalar (`YAMLParseError
  MULTILINE_IMPLICIT_KEY` at line 53). Verified fix: indent the heredoc
  body AND the `JSON` terminator to the block scalar's indentation — YAML
  strips the common indentation before the shell sees the script, so the
  JSON still lands at column 0 and the terminator still matches; with
  that change the file parses and the extracted `run` script produces the
  expected badge JSON against a real `.project/ardd-version.md`. A
  corrected copy already exists in moui72/assisted-review and can be
  upstreamed.

## UX
- [ ] F002 Sweep every other shipped template (and any heredoc embedded
  in YAML this repo generates) for the same column-0-heredoc mistake —
  it is invisible until something actually parses the file, so add a
  YAML-parse check for shipped `*.yml` templates to the deterministic
  lint layer if feasible.
- [ ] F003 The badge workflow triggers on any push touching
  `.project/ardd-version.md`, including feature branches, where it
  commits and pushes badge JSON onto whatever branch triggered it. Add
  `branches: [main]` and a manual `workflow_dispatch` trigger — safer and
  easier to test.
- [ ] F004 The workflow's sync commit spends a full consumer-CI run
  validating a one-line JSON change — consider `[skip ci]` in its commit
  message.
