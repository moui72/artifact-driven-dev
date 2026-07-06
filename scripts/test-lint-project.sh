#!/usr/bin/env sh
# Regression test for lint-project.sh: good-project must pass, bad-project
# must fail. Run from anywhere; paths are relative to this script.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
LINT="$REPO_DIR/scripts/lint-project.sh"
FIXTURES="$REPO_DIR/tests/fixtures"

fail=0

# Expected number of findings bad-project produces. Bump this in the same
# commit whenever a fixture case or lint rule changes the count — an exact
# assertion is what makes a test-first (red-then-green) rule addition provable.
EXPECTED_BAD_FINDINGS=21

if "$LINT" "$FIXTURES/good-project" > /tmp/lint-good.out 2>&1; then
  echo "ok: good-project passes"
else
  echo "FAIL: good-project should pass but didn't:"
  cat /tmp/lint-good.out
  fail=1
fi

if "$LINT" "$FIXTURES/bad-project" > /tmp/lint-bad.out 2>&1; then
  echo "FAIL: bad-project should fail but passed"
  fail=1
else
  bad_count="$(wc -l < /tmp/lint-bad.out | tr -d ' ')"
  if [ "$bad_count" -eq "$EXPECTED_BAD_FINDINGS" ]; then
    echo "ok: bad-project fails as expected ($bad_count findings)"
  else
    echo "FAIL: bad-project produced $bad_count findings, expected $EXPECTED_BAD_FINDINGS:"
    cat /tmp/lint-bad.out
    fail=1
  fi
fi

rm -f /tmp/lint-good.out /tmp/lint-bad.out
exit "$fail"
