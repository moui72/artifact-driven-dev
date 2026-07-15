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
EXPECTED_BAD_FINDINGS=35

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
  # delegation / merge_policy are optional constitution workflow fields
  # (absent = ask); when present they must be in their enums — bad-project's
  # 'sometimes' / 'yolo' must be flagged with the allowed values
  if grep -q "delegation 'sometimes' not in {eager ask inline}" /tmp/lint-bad.out; then
    echo "ok: invalid delegation value reported with allowed values"
  else
    echo "FAIL: invalid delegation value reported with allowed values"
    fail=1
  fi
  if grep -q "merge_policy 'yolo' not in {auto ask}" /tmp/lint-bad.out; then
    echo "ok: invalid merge_policy value reported with allowed values"
  else
    echo "FAIL: invalid merge_policy value reported with allowed values"
    fail=1
  fi
  # update_check_max_age_days is optional (absent = never fetch); when
  # present it must be a positive integer — bad-project's '0' must be
  # flagged with the field name and the allowed shape
  if grep -q "update_check_max_age_days '0' is not a positive integer" /tmp/lint-bad.out; then
    echo "ok: invalid update_check_max_age_days value reported with allowed shape"
  else
    echo "FAIL: invalid update_check_max_age_days value reported with allowed shape"
    fail=1
  fi
  # render_target / render_section are optional per-artifact overrides; when
  # present they must be non-empty. bad-project's datamodel.md has both empty.
  if grep -q "render_target is present but empty" /tmp/lint-bad.out; then
    echo "ok: empty render_target reported"
  else
    echo "FAIL: empty render_target reported"
    fail=1
  fi
  if grep -q "render_section is present but empty" /tmp/lint-bad.out; then
    echo "ok: empty render_section reported"
  else
    echo "FAIL: empty render_section reported"
    fail=1
  fi
  # renderability is a property (declares diagram_type), not a fixed name-list.
  # An empty diagram_type is a non-empty-when-present violation, like the other
  # optional render fields; bad-project's datamodel.md has it empty.
  if grep -q "diagram_type is present but empty" /tmp/lint-bad.out; then
    echo "ok: empty diagram_type reported"
  else
    echo "FAIL: empty diagram_type reported"
    fail=1
  fi
  # diagram_status is required once diagram_type is present. bad-project's
  # infrastructure.md declares diagram_type but no diagram_status.
  if grep -q "required when diagram_type is present" /tmp/lint-bad.out; then
    echo "ok: missing diagram_status (with diagram_type) reported"
  else
    echo "FAIL: missing diagram_status (with diagram_type) reported"
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

# --- unknown-enum messages carry the version-skew hint ---
# An unrecognized status may be a typo, or a file written by a newer ArDD
# than this install — the message must say so and point at /ardd-update.
if grep -q "status 'shipped' not in {.*} (or written by a newer ArDD than this install — run /ardd-update)" /tmp/lint-bad.out; then
  echo "ok: unknown-enum message carries version-skew hint"
else
  echo "FAIL: unknown-enum message carries version-skew hint"
  fail=1
fi
# the pointed invented-status messages stay pointed, no hint bolted on
if grep -q "completed is terminal.*run /ardd-update" /tmp/lint-bad.out; then
  echo "FAIL: pointed messages must not gain the version-skew hint"
  fail=1
else
  echo "ok: pointed messages keep their own text"
fi

# --- a stale .lint-project-failed sentinel never poisons a clean run ---
# (an interrupted pre-mktemp run could leave one in the target root; the
# sentinel now lives in mktemp space and the root file is ignored)
STALEWORK="$(mktemp -d)"
cp -R "$FIXTURES/good-project/." "$STALEWORK/"
echo 1 > "$STALEWORK/.lint-project-failed"
if "$LINT" "$STALEWORK" > /tmp/lint-stale.out 2>&1; then
  echo "ok: stale sentinel ignored — clean run exits 0"
else
  echo "FAIL: stale sentinel ignored — clean run exits 0:"
  cat /tmp/lint-stale.out
  fail=1
fi
# and a run never writes a sentinel into the target root at all
rm -f "$STALEWORK/.lint-project-failed"
"$LINT" "$STALEWORK" > /dev/null 2>&1 || true
if [ -f "$STALEWORK/.lint-project-failed" ]; then
  echo "FAIL: no sentinel file written into the target root"
  fail=1
else
  echo "ok: no sentinel file written into the target root"
fi
rm -rf "$STALEWORK" /tmp/lint-stale.out

# --- Sync Impact Report version-arrow parsing accepts ASCII "->" the same
# as the Unicode "→" (redrive-695b/F001): an ASCII arrow must not silently
# fail to extract sir_ver and produce a misleading "targets version ''"
# report when the footer version genuinely matches. ---
ARROWWORK="$(mktemp -d)"
cp -R "$FIXTURES/good-project/." "$ARROWWORK/"
sed -i.bak 's/Version change: 1.0.0 → 1.1.0 (MINOR)/Version change: 1.0.0 -> 1.1.0 (MINOR)/' \
  "$ARROWWORK/.project/artifacts/constitution.md"
rm -f "$ARROWWORK/.project/artifacts/constitution.md.bak"
if "$LINT" "$ARROWWORK" > /tmp/lint-arrow.out 2>&1; then
  echo "ok: ASCII '->' arrow accepted identically to '→'"
else
  echo "FAIL: ASCII '->' arrow accepted identically to '→':"
  cat /tmp/lint-arrow.out
  fail=1
fi
rm -rf "$ARROWWORK" /tmp/lint-arrow.out

rm -f /tmp/lint-good.out /tmp/lint-bad.out
exit "$fail"
