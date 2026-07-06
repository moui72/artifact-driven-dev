---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: status-vocab-lint-fixes
created: 2026-07-06
features: []
surfaced-defects: []
---

# Plan: status-vocabulary affordances + lint mention-vs-use precision

## Goal

Close the gaps that make downstream agents invent state — a documented
terminal-completion rule with pointed lint guidance for the three
invented statuses, and item-line-scoped tag parsing so prose mentions
stop tripping lint.

## Scope

**In:** all items of `feedback-status-vocabulary-gaps-50a5.md` (F001
decided 2026-07-06: **completed is terminal** — post-completion failures
are new work via feedback→plan; no reopen transition) and
`feedback-lint-mention-vs-use-462c.md`.

**Out:** any enum additions (deliberately — the decision is that the
existing vocabulary is right and the fixes are affordances/messages);
smoke-key promotion (standing thread).

## Technical Approach

Two small fronts. (1) Lint gains three pointed messages — unknown-status
guidance on tasks/feedback files steering to the sanctioned path, a
cross-schema hint for `superseded`-on-tasks, and (implicitly, via the
terminal rule) reopen guidance — plus prose in ardd-implement/
ardd-converge stating the terminal-completion rule where agents will
see it. (2) Lint's two bracket-tag checks (artifact reference,
placeholder name) restrict matching to checklist item lines. All lint
changes are test-first against fixtures (Principle V); prose edits are
the stated exception.

## Phase Breakdown

### Phase 1 — terminal-completion rule + status guidance [feedback 50a5]

- T-A (F001) State the rule in prose: ardd-implement (Rules section)
  and ardd-converge (reconcile step) — "a `completed` tasks file is
  terminal; work that later fails verification is *new work*: capture
  it with /ardd-feedback and plan it; never edit a completed file's
  status." Also add the rule as a one-line comment in ardd-tasks' file
  template status line.
- T-B (F001+F002) lint-project.sh pointed messages, test-first:
  - unknown tasks status that equals `reopened`* → "completed is
    terminal — capture post-completion failures with /ardd-feedback";
    (*match a bare `reopened` prefix, since the observed value carried
    an inline annotation)
  - `superseded` on a tasks file → "did you mean `abandoned`?
    `superseded` is a plan status";
  - `split` on a feedback file (F003) → "not a status — mark items
    individually; the file flips to planned when all are resolved."
  Bad fixtures for all three (red), EXPECTED_BAD_FINDINGS updated,
  message assertions like the placeholder-name one.
- T-C (F003) Verify the `split` reading against sync-tab-scroll's
  actual feedback-manual-verification-pass-4b3c.md before finalizing
  T-B's message wording — if that agent was doing something the
  per-item convention genuinely can't express, surface it to the user
  instead of assuming (per the feedback item's own caveat).

### Phase 2 — lint tag parsing scoped to item lines [feedback 462c]

- T-D (F001) Restrict both bracket-tag checks in lint-project.sh
  (artifact-reference + placeholder-name) to checklist item lines
  (`- [ ]`, `- [x]`, `- [-]` prefixes). Test-first: bad-project gains a
  body-prose line carrying a literal tag that must NOT be reported
  (assert the absence explicitly, not just the count) while the
  existing item-line violations keep asserting presence. Also remove
  the dodge-vocabulary contortions this repo's own .project files no
  longer need — optional sweep, only where wording got awkward.

## Complexity Tracking

| Deviation | Justification (Principle VI) |
|---|---|
| (none) | Message additions and a matching-scope narrowing inside the existing lint script |

## Open Questions

- [OPEN: T-C — does sync-tab-scroll's `split` usage reveal a need the
  per-item convention can't express? Resolved during implementation by
  reading the actual file.]

## Production Annotation Summary

- None anticipated.
