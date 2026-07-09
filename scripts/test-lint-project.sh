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
EXPECTED_BAD_FINDINGS=28

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
  # placeholder artifact names get the pointed message, not the generic one
  if grep -q "placeholder artifact name" /tmp/lint-bad.out; then
    echo "ok: placeholder tag gets pointed message"
  else
    echo "FAIL: placeholder tag gets pointed message"
    fail=1
  fi
  # invented statuses get pointed messages, replacing the generic
  # "not in {enum}" report (the exact findings count above proves each is
  # one finding, not two)
  if grep -q "completed is terminal" /tmp/lint-bad.out; then
    echo "ok: 'reopened' tasks status gets pointed terminal-completion message"
  else
    echo "FAIL: 'reopened' tasks status gets pointed terminal-completion message"
    fail=1
  fi
  if grep -q "did you mean 'abandoned'" /tmp/lint-bad.out; then
    echo "ok: 'superseded' tasks status gets pointed plan-status message"
  else
    echo "FAIL: 'superseded' tasks status gets pointed plan-status message"
    fail=1
  fi
  if grep -q "mark items individually" /tmp/lint-bad.out; then
    echo "ok: 'split' feedback status gets pointed per-item message"
  else
    echo "FAIL: 'split' feedback status gets pointed per-item message"
    fail=1
  fi
  # next_step_prompt is optional but, when present, must be exactly
  # true/false — bad-project's 'yes' must be flagged with the allowed values
  if grep -q "next_step_prompt 'yes' not in {true false}" /tmp/lint-bad.out; then
    echo "ok: invalid next_step_prompt value reported with allowed values"
  else
    echo "FAIL: invalid next_step_prompt value reported with allowed values"
    fail=1
  fi
  # bracket-tag checks are scoped to checklist item lines: a tag mentioned
  # in body prose (tasks-foo-aaaa.md's trailing paragraph) must NOT be
  # reported, while the item-line violations above still are.
  if grep -q "prose-only-mention" /tmp/lint-bad.out; then
    echo "FAIL: body-prose bracket-tag must not be reported"
    fail=1
  else
    echo "ok: body-prose bracket-tag is not reported"
  fi
  if grep -q "references 'nonexistent'" /tmp/lint-bad.out; then
    echo "ok: item-line bracket-tag violation still reported"
  else
    echo "FAIL: item-line bracket-tag violation still reported"
    fail=1
  fi
fi

rm -f /tmp/lint-good.out /tmp/lint-bad.out
exit "$fail"
