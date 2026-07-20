---
status: open
created: 2026-07-20
plan: null
---

# Feedback

## Bugs
- [ ] F001 install.sh records `Source-Path: $SCRIPT_DIR` (install.sh:416) — a machine-specific absolute path like `/Users/<user>/.ardd/source` — into the committed `.project/ardd-version.md`, leaking the developer's username into every consumer repo's git history and to the whole internet for public repos (flagged by CodeRabbit on moui72/assisted-review#105); also internally inconsistent, since STATUS.md refers to the same location as the portable `~/.ardd/source`. Design options to weigh at plan time: (a) record any path under `$HOME` home-relative (`~/.ardd/source`), with every reader (`scripts/source-resolve.sh`, `scripts/ardd-update-check.sh`) expanding a leading `~`; (b) split the file so machine-local resolution state is gitignored while the version/commit/channel record stays committed; (c) drop `Source-Path` from the committed file entirely and re-derive it at `/ardd-update` time (it's re-recorded on every reinstall anyway). Whatever is chosen, sweep every other generated-and-committed file for the same absolute-path leak class.
- [ ] F003 /ardd-plan wrote a factually wrong count in a generated plan's own prose: "the four call sites currently gated on `glabAvailable()`" asserted in three places while the same document's change breakdown enumerated five (implementation correctly changed five). Generalizes: the plan skill restates in prose a count that is also derivable from an enumeration in the same file, and nothing reconciles them. Fix candidates: a plan-template/skill-prose convention "don't restate derivable counts" (likely sufficient), or an /ardd-lint check for count-vs-enumeration drift if the convention proves inadequate.

## UX
- [ ] F002 /ardd-update (and/or install.sh on re-install) should detect a legacy machine-specific absolute `Source-Path` in a consumer's `.project/ardd-version.md`, rewrite it to the portable form, and — since the absolute path is already in the consumer's git history — advise the user that repairing history (e.g. rewrite/squash before the repo is shared, or accept the leak if already public) is their call, with a brief recommendation.

## Reconsidered
- [ ] F004 Plan files' `T001–T00N` checklists duplicate the tasks file's and go permanently stale: /ardd-implement ticks and completes the tasks file but never touches the plan's checkboxes, so any reader (human or AI reviewer) sees a completed tasks file beside a plan showing zero progress and reports a false inconsistency. The undecided convention is whether a plan is a static historical record of what was decided (then it should not carry live-looking checkboxes — emit a plain list, or state "progress is tracked in the linked tasks file") or a live mirror of task state (then /ardd-implement must mirror ticks into it). Decide deliberately and make the artifact self-evidently that thing, reflected in the plan template (/ardd-plan's tasking half) and/or /ardd-implement.
