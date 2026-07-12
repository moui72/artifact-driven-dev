# artifact-driven-dev — Project Status

_Updated: 2026-07-12 (skill-surface cleanup MERGED — 14-skill surface live;
one step left before v1.0.0: the pre-release-ratchets plan, then the release
arc T008–T010). Keep this current as artifacts are refined and open
questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.5.0; `delegation: eager`, `merge_policy: auto`) | — |

## Open Questions

None in the artifact. One plan-scoped set remains, non-blocking
(`plan-quickstart-new-project-2026-07-09.md` — `gh repo create`; its
pin-a-tag question was answered by the release channel).

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-11 (sixth pass): the
behavioral-smoke-tier residue (`970d935b`, key unprovisioned). Two large
merges (background-by-default, skill-surface cleanup) post-date the sixth
pass; a `/ardd-defects` pass is due after v1.0.0 ships.

## Feedback

1 open — `feedback-pre-release-ratchets-4d67.md` (6 items from the 1.0
regret sweep: ardd-version.md structured Source-Commit + hash/path
hardening; pack semver + append-only-migrations policy [constitution];
register `retired` state + npx-skills-install flip [constitution]; lint
unknown-enum tolerance message; mint hex tokens for plan/research; lint
sentinel mktemp fix). Consume with `/ardd-plan
feedback-pre-release-ratchets-4d67.md` — must land before T008.

## Release arc (strictly sequenced)

1. ✅ **skill-surface-cleanup** MERGED (`996ef24`, 19 commits, single-merge
   discipline held): 17→**14** skills — audit/status/defects/tracker/
   backlog/diagram renames; converge→implement (Reconcile mode),
   add-artifact→refine, bootstrap+codify→init folds; research
   proposal-vetting; argument guards; cross-routing; tombstones (live-
   verified prune messages); migrations 0006–0008 (primary's critique.md →
   audit.md with all 5 open items intact); extended lint-docs (skill
   bodies, name==dirname, owned-filename gate); naming system codified in
   CLAUDE.md; `docs/release-notes-v1.md` ready for T008's `--notes-file`;
   signed rollback tag `pre-surface-cleanup` (unpushed).
2. ⏳ **pre-release-ratchets** — plan + implement the 6 feedback items
   (small; roughly one commit's worth).
3. ⏳ **remote-install-source T008–T010** (`tasks-remote-install-source-
   18d3.md` in-progress, 7/10): cut v1.0.0 with the release-notes file,
   repoint five consumers, retire the primary-stays-on-main mandate.

## Feature Backlog

2 backlogged · 0 planned · 1 tasked · 8 implemented — see
`.project/features/`. (`npx-skills-install` flips to `retired` when the
ratchets plan lands the new enum.) Backlogged:
`disposable-report-merge-driver`, `worktree-reap-and-fanout`.

## Audit

`.project/audit.md` (migrated from critique.md, 5 open items, checkboxes
intact): the register-enum **[Q]** is answered (present truth + `retired` —
rides the ratchets plan; mark it resolved when that lands); 3 suggestions +
1 risk (smoke key) remain to work from the checklist.

## Recommended Next Step

Run `/ardd-plan feedback-pre-release-ratchets-4d67.md` — the last gate
before the release arc resumes. `main` holds many unpushed commits and the
unpushed `pre-surface-cleanup` tag; push when ready.
