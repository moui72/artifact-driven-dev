# artifact-driven-dev — Project Status

_Updated: 2026-07-12 (ratchets MERGED — constitution v1.6.0; everything before
v1.0.0 is done: only the release arc T008–T010 remains). Keep this current as artifacts are refined and open
questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.6.0; `delegation: eager`, `merge_policy: auto`) | — |

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

None open — `feedback-pre-release-ratchets-4d67.md` (6 items, all accepted)
consumed by `plan-pre-release-ratchets-2026-07-12.md`.


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
2. ✅ **pre-release-ratchets** MERGED (`5a7b48a`, 7 commits): constitution
   **v1.6.0** (retired enum + present-truth semantics; pack semver policy —
   this changeset itself classifies MINOR; append-only migrations;
   committed-.ardd-applied); `Source-Commit:` structured field with
   prefix-match + prose fallback + owned-checkout fallback
   (`fallback=owned`, additive token); mint hex tokens for plan/research;
   unknown-enum version-skew hint; mktemp lint sentinel.
   `npx-skills-install` flipped `retired`; audit.md [Q] resolved.
3. ⏳ **remote-install-source T008–T010** (`tasks-remote-install-source-
   18d3.md` in-progress, 7/10): cut v1.0.0 with the release-notes file,
   repoint five consumers, retire the primary-stays-on-main mandate.

## Feature Backlog

2 backlogged · 0 planned · 1 tasked · 7 implemented · 1 retired — see
`.project/features/`. Backlogged:
`disposable-report-merge-driver`, `worktree-reap-and-fanout`.

## Audit

`.project/audit.md`: 4 open items (3 suggestions + 1 risk — smoke key);
the register-enum **[Q]** is resolved (present-truth + `retired`, v1.6.0).

## Recommended Next Step

Resume the release arc: `/ardd-implement` on
`tasks-remote-install-source-18d3.md` (7/10 — T008 cut v1.0.0 with
`docs/release-notes-v1.md`, T009 repoint five consumers, T010 retire the
primary-stays-on-main mandate; all three interactive). `main` holds many
unpushed commits plus the unpushed `pre-surface-cleanup` tag — T008's
release push carries them.
