#!/usr/bin/env sh
# Regression test for release-notes.sh (feature: changelog-from-github-releases).
#
# Hermetic: `gh` is stubbed with a fixture script that ignores its
# arguments and prints canned JSON, so this never hits the real GitHub API
# and never touches this repo's own docs/release-notes.md — the script
# under test always runs with cwd inside a mktemp -d fixture repo.
#
# Pins: multiple releases render newest-first (the fixture JSON is already
# newest-first, matching gh's own release-list order, and no case here
# fabricates an out-of-order payload — the script does no re-sorting of
# its own, so this proves it preserves API order rather than scrambling
# it); a release body containing Markdown table/list content passes
# through unescaped; zero releases produces a valid (near-empty) file
# rather than erroring.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UNDER_TEST="$SCRIPT_DIR/release-notes.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# A stub `gh` on PATH ahead of the real one — `gh api --paginate
# repos/{owner}/{repo}/releases` prints whatever fixture JSON the test
# case wrote to $WORK/gh-releases.json, ignoring all its arguments (so
# it never needs to be a faithful gh double, just this call).
mkdir -p "$WORK/bin"
cat > "$WORK/bin/gh" <<'EOF'
#!/usr/bin/env sh
if [ "$1" = "api" ]; then
  cat "GH_FIXTURE_PATH/gh-releases.json"
  exit "$(cat "GH_FIXTURE_PATH/gh-exit-code" 2>/dev/null || echo 0)"
fi
echo "stub gh: unexpected invocation: $*" >&2
exit 1
EOF
sed -i.bak "s#GH_FIXTURE_PATH#$WORK#g" "$WORK/bin/gh" && rm -f "$WORK/bin/gh.bak"
chmod +x "$WORK/bin/gh"
export PATH="$WORK/bin:$PATH"

REPO="$WORK/repo"
mkdir -p "$REPO"

run_under_test() { # cwd = $REPO
  set +e
  out="$(cd "$REPO" && sh "$UNDER_TEST" 2>&1)"
  status=$?
  set -e
}

# --- Case 1: multiple releases render newest-first, bodies pass through
# unescaped (Markdown table + list content in one body) ---
cat > "$WORK/gh-releases.json" <<'EOF'
[
  {
    "tag_name": "v1.2.0",
    "published_at": "2026-07-20T00:00:00Z",
    "draft": false,
    "body": "- item one\n- item two\n\n| a | b |\n|---|---|\n| 1 | 2 |"
  },
  {
    "tag_name": "v1.1.0",
    "published_at": "2026-07-01T00:00:00Z",
    "draft": false,
    "body": "first body"
  }
]
EOF
rm -f "$WORK/gh-exit-code"
run_under_test
[ "$status" -eq 0 ] \
  && ok "case1: exit 0" \
  || { bad "case1: expected exit 0, got $status"; printf '%s\n' "$out" | sed 's/^/    /'; }
[ "$out" = "docs/release-notes.md" ] \
  && ok "case1: prints only the output path" \
  || bad "case1: got '$out'"
OUT="$REPO/docs/release-notes.md"
[ -f "$OUT" ] || bad "case1: docs/release-notes.md not written"
first_heading_line="$(grep -n '^## ' "$OUT" | head -1)"
case "$first_heading_line" in
  *"## v1.2.0") ok "case1: newest release (v1.2.0) heading comes first" ;;
  *) bad "case1: expected v1.2.0 heading first, got '$first_heading_line'" ;;
esac
grep -q '^## v1.1.0' "$OUT" \
  && ok "case1: older release (v1.1.0) heading present" \
  || bad "case1: v1.1.0 heading missing"
grep -q '^| a | b |$' "$OUT" \
  && ok "case1: Markdown table content passes through unescaped" \
  || bad "case1: table content missing or escaped"
grep -q '^- item one$' "$OUT" \
  && ok "case1: Markdown list content passes through unescaped" \
  || bad "case1: list content missing or escaped"
grep -q '^# ArDD release notes$' "$OUT" \
  && ok "case1: top-level title present" \
  || bad "case1: top-level title missing"

# --- Case 2: zero releases -> a valid (near-empty) file, not an error ---
echo '[]' > "$WORK/gh-releases.json"
run_under_test
[ "$status" -eq 0 ] \
  && ok "case2: zero releases exits 0" \
  || { bad "case2: expected exit 0, got $status"; printf '%s\n' "$out" | sed 's/^/    /'; }
[ -f "$OUT" ] \
  && ok "case2: file still written" \
  || bad "case2: file not written"
grep -q '^# ArDD release notes$' "$OUT" \
  && ok "case2: title present with no releases" \
  || bad "case2: title missing"
! grep -q '^## ' "$OUT" \
  && ok "case2: no release headings when there are no releases" \
  || bad "case2: unexpected release heading with zero releases"

# --- Case 3: gh failure (auth/rate-limit) -> non-zero exit, clear message ---
echo 'API rate limit exceeded' > "$WORK/gh-releases.json"
echo 1 > "$WORK/gh-exit-code"
run_under_test
[ "$status" -ne 0 ] \
  && ok "case3: gh failure propagates non-zero exit" \
  || bad "case3: expected non-zero exit, got $status"
case "$out" in
  *"release-notes:"*) ok "case3: failure message is clearly attributed" ;;
  *) bad "case3: got '$out'" ;;
esac
rm -f "$WORK/gh-exit-code"

# --- Case 4: idempotent full re-render — running twice with the same
# fixture produces byte-identical output ---
cat > "$WORK/gh-releases.json" <<'EOF'
[{"tag_name": "v2.0.0", "published_at": "2026-07-21T00:00:00Z", "draft": false, "body": "only release"}]
EOF
run_under_test
first_render="$(cat "$OUT")"
run_under_test
second_render="$(cat "$OUT")"
[ "$first_render" = "$second_render" ] \
  && ok "case4: re-render is idempotent (byte-identical)" \
  || bad "case4: re-render differs across runs"

if [ "$fail" -eq 0 ]; then
  echo "test-release-notes: all cases pass"
else
  echo "test-release-notes: FAILURES above" >&2
  exit 1
fi
