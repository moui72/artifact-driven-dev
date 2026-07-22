#!/usr/bin/env sh
# Regression test for hooks/pre-commit's aggregation/short-circuit logic:
# exits 0 when all check scripts pass, stops at (and names) the first one
# that fails, and never runs anything after it. Uses stub scripts standing
# in for the real ones, since those already have their own regression
# tests — this only proves the hook's own control flow.

set -e

# This test runs *inside* the real pre-commit hook, where git exports
# GIT_INDEX_FILE/GIT_DIR/... pointing at the real repository — without this
# unset, the routing fixture's git init/add/reset below would mutate the
# real index mid-commit (learned the hard way: a fixture .project/x.md got
# committed in place of the intended changes).
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
HOOK_SRC="$REPO_DIR/hooks/pre-commit"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/scripts"
cp "$HOOK_SRC" "$WORK/pre-commit-under-test"
chmod +x "$WORK/pre-commit-under-test"

stub() {
  # $1 = script name, $2 = exit code
  cat > "$WORK/scripts/$1" <<EOF
#!/usr/bin/env sh
exit $2
EOF
  chmod +x "$WORK/scripts/$1"
}

fail=0

# --- Case 1: all pass -> hook exits 0 ---
stub lint-docs.sh 0
stub lint-project.sh 0
stub lint-templates-yaml.sh 0
stub test-lint-project.sh 0
stub test-branch-info.sh 0
stub test-completion-flip-check.sh 0
stub test-sibling-tasks-complete.sh 0
stub test-sync-slug-match.sh 0
stub test-sync-label-decision.sh 0
stub test-sync-divergence.sh 0
stub test-project-lock.sh 0
stub test-hook-lint-on-write.sh 0
if (cd "$WORK" && sh ./pre-commit-under-test > /tmp/hook-case1.out 2>&1); then
  echo "ok: all-pass case exits 0"
else
  echo "FAIL: all-pass case should exit 0:"
  cat /tmp/hook-case1.out
  fail=1
fi
rm -f /tmp/hook-case1.out

# --- Case 2: a mid-list script fails -> hook stops there and names it ---
stub lint-docs.sh 0
stub lint-project.sh 0
stub lint-templates-yaml.sh 0
stub test-lint-project.sh 0
stub test-branch-info.sh 1
stub test-completion-flip-check.sh 0
stub test-sibling-tasks-complete.sh 0
stub test-sync-slug-match.sh 0
stub test-sync-label-decision.sh 0
stub test-sync-divergence.sh 0
stub test-project-lock.sh 0
stub test-hook-lint-on-write.sh 0
out="$(cd "$WORK" && sh ./pre-commit-under-test 2>&1)" && rc=0 || rc=$?
if [ "$rc" -eq 0 ]; then
  echo "FAIL: failing case should exit non-zero"
  fail=1
elif ! printf '%s' "$out" | grep -q "test-branch-info.sh"; then
  echo "FAIL: failure output should name test-branch-info.sh, got: $out"
  fail=1
else
  echo "ok: failing case stops and names test-branch-info.sh"
fi

# --- Case 3: first script fails -> later scripts never run ---
rm -f "$WORK/ran-marker"
stub lint-docs.sh 1
stub lint-project.sh 0
stub lint-templates-yaml.sh 0
cat > "$WORK/scripts/test-lint-project.sh" <<EOF
#!/usr/bin/env sh
touch "$WORK/ran-marker"
exit 0
EOF
chmod +x "$WORK/scripts/test-lint-project.sh"
stub test-branch-info.sh 0
stub test-completion-flip-check.sh 0
stub test-sibling-tasks-complete.sh 0
stub test-sync-slug-match.sh 0
stub test-sync-label-decision.sh 0
stub test-sync-divergence.sh 0
stub test-project-lock.sh 0
stub test-hook-lint-on-write.sh 0
(cd "$WORK" && sh ./pre-commit-under-test > /dev/null 2>&1) || true
if [ -f "$WORK/ran-marker" ]; then
  echo "FAIL: short-circuit case should stop before test-lint-project.sh, but it ran"
  fail=1
else
  echo "ok: short-circuit case stops before later scripts run"
fi

# --- Case 4: a test script the hook never enumerated is still enforced ---
# This is the glob's whole point (constitution v1.1.0): a brand-new
# scripts/test-*.sh must be picked up with no hook edit. Make everything
# pass except a never-before-seen test script, and expect the hook to fail
# naming it.
stub lint-docs.sh 0
stub lint-project.sh 0
stub lint-templates-yaml.sh 0
stub test-lint-project.sh 0
stub test-branch-info.sh 0
stub test-completion-flip-check.sh 0
stub test-sibling-tasks-complete.sh 0
stub test-sync-slug-match.sh 0
stub test-sync-label-decision.sh 0
stub test-sync-divergence.sh 0
stub test-project-lock.sh 0
stub test-hook-lint-on-write.sh 0
stub test-zzz-brand-new.sh 1
out="$(cd "$WORK" && sh ./pre-commit-under-test 2>&1)" && rc=0 || rc=$?
if [ "$rc" -eq 0 ]; then
  echo "FAIL: unenumerated-test case should exit non-zero"
  fail=1
elif ! printf '%s' "$out" | grep -q "test-zzz-brand-new.sh"; then
  echo "FAIL: failure output should name test-zzz-brand-new.sh, got: $out"
  fail=1
else
  echo "ok: glob enforces a test script the hook never enumerated"
fi

# --- Cases 5-9: staged-path scoping (1e7b F001) ---
# In a real git repo, the hook scopes which checks run by the staged path
# list: a .project/-only commit runs only lint-project.sh; a staged
# scripts/X.sh runs its scripts/test-X.sh; an unmapped staged path, an
# empty staged list, or ARDD_HOOK_ALL=1 fail-safe to running everything.
# Marker-file stubs record which checks actually ran.

FIX="$WORK/routing"
mkdir -p "$FIX/scripts"
( cd "$FIX" && git -c commit.gpgsign=false init -q && git config core.hooksPath /dev/null )
cp "$HOOK_SRC" "$FIX/pre-commit-under-test"
chmod +x "$FIX/pre-commit-under-test"

mstub() { # $1 = script name -> stub that records it ran
  cat > "$FIX/scripts/$1" <<EOF
#!/usr/bin/env sh
touch "$FIX/ran-$1"
exit 0
EOF
  chmod +x "$FIX/scripts/$1"
}
mstub lint-docs.sh
mstub lint-project.sh
mstub test-branch-info.sh
mstub test-new.sh
# Subject files the generic test-X.sh -> scripts/X.sh rule needs on disk.
printf '#!/usr/bin/env sh\n' > "$FIX/scripts/branch-info.sh"
printf '#!/usr/bin/env sh\n' > "$FIX/new.sh"
mkdir -p "$FIX/.project" "$FIX/.github"
# T005-T007 subjects/stubs: needed here (not just before cases 10-13) so
# the RUN_ALL fail-safe cases (7-9, below) also see them on disk. No
# on-disk subject files needed for test-lint-project.sh/
# test-hook-lint-on-write.sh — their check_needed cases use staged_matches
# directly (dedicated case branches, not the generic test-X.sh rule), so
# nothing checks for scripts/lint-project.sh or scripts/hook-lint-on-write.sh
# on disk; writing plain stand-ins for them here would only risk clobbering
# the mstub lint-project.sh marker above (scripts/lint-project.sh is both
# a real check and, incidentally, that other subject's name).
mstub lint-templates-yaml.sh
mstub test-lint-project.sh
mstub test-hook-lint-on-write.sh
# REGRESSION_SUITE member with no scripts/X.sh subject — needed on disk so
# the FAILSAFE cases (7, 13 below) can actually run it.
mstub test-hooks-pre-commit.sh
# Representative unpaired test (no scripts/migration-*.sh subject exists —
# migrations live under migrations/, not scripts/) — proves the
# install/migration family is scoped to its mapped paths, not fail-safe-run
# on every unrelated commit.
mstub test-migration-critique-to-audit.sh
mkdir -p "$FIX/.github/workflows" "$FIX/templates" "$FIX/tests/fixtures" \
  "$FIX/dev-notes" "$FIX/tests/scenarios" "$FIX/migrations"

reset_markers() { rm -f "$FIX"/ran-*; ( cd "$FIX" && git reset -q ) ; }
ran()  { [ -f "$FIX/ran-$1" ]; }
run_hook() { ( cd "$FIX" && sh ./pre-commit-under-test > /dev/null 2>&1 ) }

# Case 5 (a): .project/-only commit -> only lint-project.sh runs.
reset_markers
echo x > "$FIX/.project/x.md"
( cd "$FIX" && git add .project/x.md )
run_hook || true
if ran lint-project.sh && ! ran lint-docs.sh && ! ran test-branch-info.sh && ! ran test-new.sh; then
  echo "ok: staged .project/ runs only lint-project.sh"
else
  echo "FAIL: staged .project/ runs only lint-project.sh (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi

# Case 6 (b): staged scripts/branch-info.sh -> its test runs, test-new does not.
reset_markers
( cd "$FIX" && git add scripts/branch-info.sh )
run_hook || true
if ran test-branch-info.sh && ! ran test-new.sh; then
  echo "ok: staged scripts/branch-info.sh runs test-branch-info.sh, not test-new.sh"
else
  echo "FAIL: staged scripts/branch-info.sh runs test-branch-info.sh, not test-new.sh (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi

# Case 7 (c): unmapped staged path -> FAILSAFE runs only the curated
# regression suite (lint-docs.sh, lint-project.sh, lint-templates-yaml.sh,
# test-hooks-pre-commit.sh) — paired tests with no bearing on the staged
# path (test-branch-info.sh, test-new.sh) do NOT run.
reset_markers
echo x > "$FIX/.github/x"
( cd "$FIX" && git add .github/x )
run_hook || true
if ran lint-docs.sh && ran lint-project.sh && ran lint-templates-yaml.sh \
  && ran test-hooks-pre-commit.sh && ! ran test-branch-info.sh && ! ran test-new.sh; then
  echo "ok: unmapped staged path fail-safes to the regression suite only"
else
  echo "FAIL: unmapped staged path fail-safes to the regression suite only (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi

# Case 8 (d): empty staged list -> RUN_ALL (the full suite, not just the
# regression suite) — distinct from FAILSAFE, kept maximally safe since
# nothing about the diff is known at all.
reset_markers
run_hook || true
if ran lint-docs.sh && ran lint-project.sh && ran test-branch-info.sh && ran test-new.sh; then
  echo "ok: empty staged list runs the full suite"
else
  echo "FAIL: empty staged list runs the full suite (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi

# Case 9 (e): ARDD_HOOK_ALL=1 -> RUN_ALL (the full suite) regardless of
# staged paths — the explicit override, distinct from FAILSAFE.
reset_markers
( cd "$FIX" && git add .project/x.md )
( cd "$FIX" && ARDD_HOOK_ALL=1 sh ./pre-commit-under-test > /dev/null 2>&1 ) || true
if ran lint-docs.sh && ran lint-project.sh && ran test-branch-info.sh && ran test-new.sh; then
  echo "ok: ARDD_HOOK_ALL=1 overrides scoping and runs every check"
else
  echo "FAIL: ARDD_HOOK_ALL=1 overrides scoping and runs every check (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi

# --- Cases 10-13: pre-commit scoping expansion (T005-T007, feature
# pre-commit-hook-scoping-expans) — lint-templates-yaml.sh wired into the
# check loop, tests/fixtures/ mapped to test-lint-project.sh +
# test-hook-lint-on-write.sh, and a set of no-check subject paths that
# nothing in the suite reads. (Subject files/stubs for these were added
# to $FIX above, alongside the rest of the fixture bootstrap.)

# Case 10 (a): staging a .github/workflows/*.yml or templates/* path runs
# lint-templates-yaml.sh but not the full suite.
reset_markers
echo x > "$FIX/.github/workflows/x.yml"
( cd "$FIX" && git add .github/workflows/x.yml )
run_hook || true
if ran lint-templates-yaml.sh && ! ran lint-docs.sh && ! ran test-branch-info.sh; then
  echo "ok: staged .github/workflows/*.yml runs lint-templates-yaml.sh, not the full suite"
else
  echo "FAIL: staged .github/workflows/*.yml runs lint-templates-yaml.sh, not the full suite (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi
reset_markers
echo x > "$FIX/templates/x.yml"
( cd "$FIX" && git add templates/x.yml )
run_hook || true
if ran lint-templates-yaml.sh && ! ran lint-docs.sh && ! ran test-branch-info.sh; then
  echo "ok: staged templates/* runs lint-templates-yaml.sh, not the full suite"
else
  echo "FAIL: staged templates/* runs lint-templates-yaml.sh, not the full suite (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi

# Case 11 (b): staging a tests/fixtures/* path runs test-lint-project.sh
# and test-hook-lint-on-write.sh but not the full suite.
reset_markers
echo x > "$FIX/tests/fixtures/x"
( cd "$FIX" && git add tests/fixtures/x )
run_hook || true
if ran test-lint-project.sh && ran test-hook-lint-on-write.sh && ! ran lint-docs.sh && ! ran test-branch-info.sh; then
  echo "ok: staged tests/fixtures/* runs test-lint-project.sh + test-hook-lint-on-write.sh, not the full suite"
else
  echo "FAIL: staged tests/fixtures/* runs test-lint-project.sh + test-hook-lint-on-write.sh, not the full suite (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi

# Case 12 (c): staging only a no-check-subject path runs no checks at all
# (fast exit) — CLAUDE.md, dev-notes/*, tests/scenarios/*, mkdocs.yml,
# .gitignore, .worktreeinclude.
for no_check_path in CLAUDE.md dev-notes/x tests/scenarios/x mkdocs.yml .gitignore .worktreeinclude; do
  reset_markers
  # Content "no-check-content" rather than a bare "x" — a real .gitignore
  # among these paths must not, as a side effect, gitignore every other
  # fixture path literally named "x" used elsewhere in this file.
  echo no-check-content > "$FIX/$no_check_path"
  ( cd "$FIX" && git add "$no_check_path" )
  run_hook || true
  if ! ran lint-docs.sh && ! ran lint-project.sh && ! ran test-branch-info.sh \
    && ! ran test-new.sh && ! ran lint-templates-yaml.sh \
    && ! ran test-lint-project.sh && ! ran test-hook-lint-on-write.sh \
    && ! ran test-hooks-pre-commit.sh; then
    echo "ok: staged $no_check_path runs no checks (fast exit)"
  else
    echo "FAIL: staged $no_check_path runs no checks (fast exit) (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
    fail=1
  fi
  # Undo any incidental effect of that path's own content before the next
  # iteration/case (the .gitignore case is the one that matters).
  rm -f "$FIX/$no_check_path"
  ( cd "$FIX" && git reset -q ) 2>/dev/null || true
done

# Case 13 (d): a scripts/*.sh change with no matching scripts/test-*.sh on
# disk still triggers FAILSAFE (regression suite only, not the full suite,
# and not any unrelated paired test).
reset_markers
echo '#!/usr/bin/env sh' > "$FIX/scripts/orphan-script.sh"
( cd "$FIX" && git add scripts/orphan-script.sh )
run_hook || true
if ran lint-docs.sh && ran lint-project.sh && ran lint-templates-yaml.sh \
  && ran test-hooks-pre-commit.sh && ! ran test-branch-info.sh && ! ran test-new.sh; then
  echo "ok: an untested scripts/*.sh change fail-safes to the regression suite only"
else
  echo "FAIL: an untested scripts/*.sh change fail-safes to the regression suite only (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi
rm -f "$FIX/scripts/orphan-script.sh"

# --- Cases 14-15: tightened paired-test scoping (feedback after
# pre-commit-hook-scoping-expans) — a test-X.sh with no scripts/X.sh
# subject on disk (migrations, install family, ...) is scoped to an
# explicit path mapping, never fail-safe-run just because its subject file
# doesn't exist; and a paired test-X.sh no longer runs on an unrelated
# staged path just because it was once the generic-rule default.

# Case 14 (a): staging migrations/* runs the install/migration family
# (represented here by test-migration-critique-to-audit.sh) but not
# unrelated paired tests (test-branch-info.sh, test-new.sh) or the
# regression suite's lint-docs.sh/test-hooks-pre-commit.sh — this is a
# mapped path, not a FAILSAFE.
reset_markers
echo x > "$FIX/migrations/0099-example.sh"
( cd "$FIX" && git add migrations/0099-example.sh )
run_hook || true
if ran test-migration-critique-to-audit.sh && ! ran test-branch-info.sh \
  && ! ran test-new.sh && ! ran lint-docs.sh && ! ran test-hooks-pre-commit.sh; then
  echo "ok: staged migrations/* runs the install/migration family, nothing else"
else
  echo "FAIL: staged migrations/* runs the install/migration family, nothing else (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi

# Case 15 (b): a paired test (test-branch-info.sh <-> scripts/branch-info.sh)
# does NOT run just because some other, unrelated paired test's subject
# changed — no more "unknown subject, run it anyway" cross-contamination.
reset_markers
( cd "$FIX" && git add new.sh )
run_hook || true
if ran test-new.sh && ! ran test-branch-info.sh && ! ran test-migration-critique-to-audit.sh; then
  echo "ok: a paired test runs only for its own subject, never another paired test's"
else
  echo "FAIL: a paired test runs only for its own subject, never another paired test's (ran: $(cd "$FIX" && ls ran-* 2>/dev/null))"
  fail=1
fi

exit "$fail"
