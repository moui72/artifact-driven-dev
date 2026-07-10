#!/usr/bin/env sh
# Regression test for new.sh — the curl-to-sh quickstart entry point.
#
# new.sh's contract (constitution v1.2.3, Project Scope & Intent):
#   - it is an *acquisition* channel that converges onto install.sh by
#     invoking it, never reimplementing any part of it;
#   - it runs on a pipe (`curl … | sh`), so it must NEVER prompt — every
#     place an interactive installer would ask, new.sh refuses;
#   - it only ever clones/pulls the source checkout it owns
#     (~/.ardd/source). A source handed to it via --source/$ARDD_SOURCE is
#     the user's, and is read but never mutated.
#
# That last rule is what makes this test hermetic: every case pins
# $ARDD_SOURCE at this repo, so no case clones, pulls, or otherwise reaches
# the network.
#
# The TTY handoff (`exec claude "/ardd-kickoff" < /dev/tty`) is deliberately
# not exercised end-to-end: whether /dev/tty is readable differs between a
# developer's terminal and CI's runner, so a test that execs would either
# hijack the developer's terminal or pass vacuously in CI. Instead, case 4
# proves the negative that matters — with --no-launch, `claude` is never
# executed, asserted with a poison `claude` on PATH that would exit 42.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NEW_SH="$REPO_ROOT/new.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Throwaway fixture repos under $WORK — no signing, and none of the invoking
# user's global core.hooksPath hooks should fire against them.
git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# Every invocation gets stdin from /dev/null. If new.sh ever grows a `read`,
# it sees EOF and misbehaves visibly here rather than hanging CI forever.
# Captured output lands in the global $out — never on stdout, or a caller
# redirecting stdout would silently swallow the ok:/FAIL: lines too.
run_new() { # run_new <expected-exit> <label> [args...]
  expected="$1"; label="$2"; shift 2
  set +e
  out="$(ARDD_SOURCE="$REPO_ROOT" sh "$NEW_SH" "$@" </dev/null 2>&1)"
  status=$?
  set -e
  if [ "$status" -ne "$expected" ]; then
    bad "$label: expected exit $expected, got $status"
    printf '%s\n' "$out" | sed 's/^/    /'
    return 0
  fi
  ok "$label: exit $expected"
}

# --- Case 1: happy path — fresh target, explicit source, no launch ---
target="$WORK/case1/proj"
run_new 0 "case1: fresh target installs" --no-launch "$target"

if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ok "case1: target is a git work tree"
else
  bad "case1: target is not a git work tree"
fi

[ -f "$target/.claude/skills/ardd-scripts/lint-project.sh" ] \
  && ok "case1: ardd-scripts installed" \
  || bad "case1: ardd-scripts missing"

[ -f "$target/.claude/skills/ardd-bootstrap/SKILL.md" ] \
  && ok "case1: skills installed" \
  || bad "case1: skills missing"

[ -f "$target/.project/ardd-version.md" ] \
  && ok "case1: ardd-version.md recorded" \
  || bad "case1: ardd-version.md missing"

# The whole point of converging on install.sh: its non-skill reference dirs
# exist, which an npx-style copy of SKILL.md files alone would never produce.
[ -f "$target/.claude/skills/ardd-artifact-templates/constitution.md" ] \
  && ok "case1: artifact templates installed (install.sh really ran)" \
  || bad "case1: artifact templates missing"

# --- Case 2: existing non-empty target is refused, and nothing is written ---
target="$WORK/case2/proj"
mkdir -p "$target"
echo "pre-existing" > "$target/README.md"

run_new 1 "case2: non-empty target refused" --no-launch "$target"
[ -d "$target/.claude" ] \
  && bad "case2: refused but still wrote .claude/" \
  || ok "case2: nothing written on refusal"
[ -f "$target/README.md" ] \
  && ok "case2: pre-existing content untouched" \
  || bad "case2: pre-existing content clobbered"

# --- Case 3: a source path that isn't an ARDD checkout is refused ---
notardd="$WORK/case3/notardd"
mkdir -p "$notardd"
: > "$notardd/some-file"
target="$WORK/case3/proj"

set +e
out="$(ARDD_SOURCE="$notardd" sh "$NEW_SH" --no-launch "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 1 ] \
  && ok "case3: non-ARDD source refused (exit 1)" \
  || bad "case3: expected exit 1, got $status"
[ -d "$target/.claude" ] \
  && bad "case3: refused but still installed" \
  || ok "case3: nothing installed from a bad source"

# --- Case 4: --no-launch never executes claude ---
# A poison `claude` earlier on PATH exits 42. If new.sh execs it, this run's
# exit status becomes 42 (exec replaces the shell) and the case fails.
bin="$WORK/bin"
mkdir -p "$bin"
cat > "$bin/claude" <<'POISON'
#!/usr/bin/env sh
exit 42
POISON
chmod +x "$bin/claude"

target="$WORK/case4/proj"
set +e
out="$(PATH="$bin:$PATH" ARDD_SOURCE="$REPO_ROOT" sh "$NEW_SH" --no-launch "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case4: --no-launch did not exec claude" \
  || bad "case4: expected exit 0, got $status (42 means claude was exec'd)"

# It must still tell the user how to start the session by hand.
printf '%s' "$out" | grep -q '/ardd-kickoff' \
  && ok "case4: prints the /ardd-kickoff next step" \
  || bad "case4: never mentions /ardd-kickoff"

# --- Case 5: an existing *empty* directory is fine, not a refusal ---
target="$WORK/case5/proj"
mkdir -p "$target"
run_new 0 "case5: existing empty dir accepted" --no-launch "$target"
[ -f "$target/.project/ardd-version.md" ] \
  && ok "case5: installed into empty dir" \
  || bad "case5: nothing installed"

# --- Case 6: a directory holding only .git is "empty enough" ---
# `git init` then the quickstart is a natural order; refusing it would be a
# papercut. Only non-.git entries make a target non-empty.
target="$WORK/case6/proj"
mkdir -p "$target"
git init -q "$target"
run_new 0 "case6: git-init'd but otherwise empty dir accepted" --no-launch "$target"
[ -f "$target/.project/ardd-version.md" ] \
  && ok "case6: installed into git-only dir" \
  || bad "case6: nothing installed"

# --- Case 7: --source is equivalent to $ARDD_SOURCE, and never mutates it ---
before="$(git -C "$REPO_ROOT" rev-parse HEAD)"
target="$WORK/case7/proj"
set +e
out="$(sh "$NEW_SH" --no-launch --source "$REPO_ROOT" "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case7: --source accepted" \
  || bad "case7: expected exit 0, got $status"
[ -f "$target/.project/ardd-version.md" ] \
  && ok "case7: installed via --source" \
  || bad "case7: nothing installed via --source"
after="$(git -C "$REPO_ROOT" rev-parse HEAD)"
[ "$before" = "$after" ] \
  && ok "case7: user-provided source checkout not mutated" \
  || bad "case7: source checkout HEAD moved ($before -> $after)"

# --- Case 8: missing target argument is a usage error, not a silent no-op ---
set +e
out="$(ARDD_SOURCE="$REPO_ROOT" sh "$NEW_SH" --no-launch </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 2 ] \
  && ok "case8: missing target exits 2 (usage)" \
  || bad "case8: expected exit 2, got $status"

if [ "$fail" -eq 0 ]; then
  echo "test-new: all cases pass"
else
  echo "test-new: FAILURES above" >&2
  exit 1
fi
