#!/usr/bin/env sh
# Regression test for hooks/pre-commit's aggregation/short-circuit logic:
# exits 0 when all check scripts pass, stops at (and names) the first one
# that fails, and never runs anything after it. Uses stub scripts standing
# in for the real ones, since those already have their own regression
# tests — this only proves the hook's own control flow.

set -e

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

exit "$fail"
