#!/usr/bin/env sh
# Regression test for release.sh — the release-cutting entry point.
#
# release.sh's contract (constitution, release-channel standing decision):
# cutting a release is the deliberate act that publishes skill changes to
# consumers, so every refusal must hold before the irreversible steps run.
# It refuses when: the version argument isn't vX.Y.Z, the working tree is
# dirty, HEAD is off the default branch, the tag already exists, or the
# pre-commit suite is absent/failing. `--dry-run` stops after validation.
#
# The tag/push/`gh release` block itself is deliberately untested: it is
# thin by design, needs the signing key and network, and neither exists in
# CI. What IS pinned statically is that the tag command stays SSH-signed
# (the T001 checkpoint decision) — same source-line guard pattern as
# test-new.sh case 14.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RELEASE="$REPO_ROOT/scripts/release.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Throwaway fixture repos under $WORK — no signing, no user hooks.
git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# mkrepo <path> [hook-exit] — a fixture repo on main with one commit and a
# stub hooks/pre-commit exiting with [hook-exit] (default 0). release.sh
# runs the repo's own pre-commit suite, so the stub stands in for it.
mkrepo() {
  _hook_exit="${2:-0}"
  mkdir -p "$1/hooks"
  printf 'content\n' > "$1/file.txt"
  printf '#!/usr/bin/env sh\nexit %s\n' "$_hook_exit" > "$1/hooks/pre-commit"
  chmod +x "$1/hooks/pre-commit"
  ( cd "$1" && git init -q -b main && git add -A && git commit -q -m init )
}

run_release() { # run_release <repo> [args...]
  _repo="$1"; shift
  set +e
  out="$( (cd "$_repo" && sh "$RELEASE" "$@") 2>&1 )"
  status=$?
  set -e
}

# --- Case 1: happy dry-run passes every validation and stops ---
R="$WORK/case1"; mkrepo "$R"
run_release "$R" --dry-run v1.0.0
[ "$status" -eq 0 ] \
  && ok "case1: clean repo dry-run exits 0" \
  || { bad "case1: expected exit 0, got $status"; printf '%s\n' "$out" | sed 's/^/    /'; }
printf '%s' "$out" | grep -qi 'dry-run' \
  && ok "case1: reports dry-run stop" \
  || bad "case1: no dry-run marker in output"
git -C "$R" rev-parse -q --verify refs/tags/v1.0.0 >/dev/null \
  && bad "case1: dry-run created the tag" \
  || ok "case1: dry-run created no tag"

# --- Case 2: bad version format refused (before anything else) ---
R="$WORK/case2"; mkrepo "$R"
for v in 1.0.0 v1.0 v1.0.0-rc1 release-1 v1.2.3.4; do
  run_release "$R" --dry-run "$v"
  [ "$status" -eq 1 ] \
    && ok "case2: '$v' refused" \
    || bad "case2: '$v' expected exit 1, got $status"
done
run_release "$R" --dry-run
[ "$status" -eq 2 ] \
  && ok "case2: missing version is a usage error (exit 2)" \
  || bad "case2: missing version expected exit 2, got $status"

# --- Case 3: dirty working tree refused ---
R="$WORK/case3"; mkrepo "$R"
printf 'drift\n' >> "$R/file.txt"
run_release "$R" --dry-run v1.0.0
[ "$status" -eq 1 ] \
  && ok "case3: dirty tree refused" \
  || bad "case3: expected exit 1, got $status"
printf '%s' "$out" | grep -qi 'clean' \
  && ok "case3: refusal names the dirty tree" \
  || bad "case3: refusal does not mention cleanliness"

# --- Case 4: off the default branch refused ---
R="$WORK/case4"; mkrepo "$R"
git -C "$R" checkout -q -b feature
run_release "$R" --dry-run v1.0.0
[ "$status" -eq 1 ] \
  && ok "case4: off-default refused" \
  || bad "case4: expected exit 1, got $status"
printf '%s' "$out" | grep -qi 'default branch' \
  && ok "case4: refusal names the default branch" \
  || bad "case4: refusal does not mention the default branch"

# --- Case 5: existing tag refused ---
R="$WORK/case5"; mkrepo "$R"
git -C "$R" tag v1.0.0
run_release "$R" --dry-run v1.0.0
[ "$status" -eq 1 ] \
  && ok "case5: duplicate tag refused" \
  || bad "case5: expected exit 1, got $status"
printf '%s' "$out" | grep -qi 'exist' \
  && ok "case5: refusal names the existing tag" \
  || bad "case5: refusal does not mention existence"

# --- Case 6: failing pre-commit suite refused ---
R="$WORK/case6"; mkrepo "$R" 1
run_release "$R" --dry-run v1.0.0
[ "$status" -eq 1 ] \
  && ok "case6: failing suite refused" \
  || bad "case6: expected exit 1, got $status"

# --- Case 7: missing pre-commit suite refused, never skipped ---
R="$WORK/case7"; mkrepo "$R"
rm "$R/hooks/pre-commit"
git -C "$R" add -A && git -C "$R" commit -q -m drop-hook
run_release "$R" --dry-run v1.0.0
[ "$status" -eq 1 ] \
  && ok "case7: missing suite refused (never silently skipped)" \
  || bad "case7: expected exit 1, got $status"

# --- Case 8: the tag command stays SSH-signed (static guard) ---
# The signing key and network don't exist in CI, so the live tag step can't
# run here; pin the source line instead (T001 checkpoint: tags ARE signed).
# Join backslash continuations first — the tag command is written multi-line.
sed -e ':a' -e '/\\$/{N;s/\\\n//;ba' -e '}' "$RELEASE" \
  | grep -E 'git .*gpg\.format=ssh.*tag -s' >/dev/null \
  && ok "case8: tag command is SSH-signed" \
  || bad "case8: tag command is not SSH-signed (gpg.format=ssh + tag -s)"

if [ "$fail" -eq 0 ]; then
  echo "test-release: all cases pass"
else
  echo "test-release: FAILURES above" >&2
  exit 1
fi
