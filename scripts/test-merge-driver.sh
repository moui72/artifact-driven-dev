#!/usr/bin/env sh
# End-to-end behavior regression test for the disposable-report merge
# driver: in a throwaway repo carrying the install.sh-shipped
# .project/.gitattributes (report files marked merge=ours), two branches
# editing .project/STATUS.md divergently must
#   (a) with `merge.ours.driver true` configured: merge cleanly, keeping
#       the current branch's version — "take either side without
#       deliberation" as git mechanism; and
#   (b) WITHOUT the driver configured: fall back to git's normal text
#       merge — a real conflict (degradation pinned: nothing gets worse
#       than the interactive take-either-side rule that already covers it).

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Throwaway fixture repos under $WORK — no signing, no user hooks.
git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# Build a fixture repo whose main and side branches carry divergent
# .project/STATUS.md edits, with the real installed .gitattributes.
make_fixture() { # $1=dir
  mkdir -p "$1"
  git -C "$1" init -q -b main
  ( cd "$REPO_ROOT" && sh "$INSTALL_SH" "$1" ) >/dev/null
  printf 'base report\n' > "$1/.project/STATUS.md"
  git -C "$1" add -A
  git -C "$1" commit -q -m base
  git -C "$1" checkout -q -b side
  printf 'side version\n' > "$1/.project/STATUS.md"
  git -C "$1" commit -qam side-edit
  git -C "$1" checkout -q main
  printf 'main version\n' > "$1/.project/STATUS.md"
  git -C "$1" commit -qam main-edit
}

# --- Case A: driver configured -> clean merge, ours (main's) version kept ---
repo="$WORK/with-driver"
make_fixture "$repo"
git -C "$repo" config merge.ours.driver true

if git -C "$repo" merge -q --no-edit side >/dev/null 2>&1; then
  ok "caseA: divergent STATUS.md merge completes cleanly with driver configured"
else
  bad "caseA: divergent STATUS.md merge completes cleanly with driver configured"
fi

content="$(cat "$repo/.project/STATUS.md")"
if [ "$content" = "main version" ]; then
  ok "caseA: current branch's version kept (ours)"
else
  bad "caseA: current branch's version kept (got: $content)"
fi

if git -C "$repo" diff --quiet && git -C "$repo" diff --cached --quiet; then
  ok "caseA: worktree clean after merge (no unresolved paths)"
else
  bad "caseA: worktree clean after merge (no unresolved paths)"
fi

# --- Case B: driver NOT configured -> normal text merge, real conflict ---
repo="$WORK/without-driver"
make_fixture "$repo"

if git -C "$repo" merge -q --no-edit side >/dev/null 2>&1; then
  bad "caseB: merge without driver must fail with a conflict"
else
  ok "caseB: merge without driver exits nonzero (conflict)"
fi

if grep -q '^<<<<<<<' "$repo/.project/STATUS.md"; then
  ok "caseB: conflict markers present (normal text-merge degradation)"
else
  bad "caseB: conflict markers present (normal text-merge degradation)"
fi

git -C "$repo" merge --abort 2>/dev/null || true

exit "$fail"
