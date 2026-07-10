#!/usr/bin/env sh
# Regression test for new.sh — the curl-to-sh quickstart entry point.
#
# new.sh's contract (constitution v1.2.4, Project Scope & Intent):
#   - it is an *acquisition* channel that converges onto install.sh by
#     invoking it, never reimplementing any part of it;
#   - it REFUSES rather than asks wherever writing into a directory it doesn't
#     own is at stake (a non-empty target; a --source that isn't an ARDD
#     checkout) — those aren't decisions worth offering;
#   - it NEVER BLOCKS on a question it cannot ask: no readable /dev/tty means
#     take the safe default (decline the launch), never hang;
#   - it only ever clones/pulls the source checkout it owns
#     (~/.ardd/source). A source handed to it via --source/$ARDD_SOURCE is
#     the user's, and is read but never mutated.
#
# That last rule is what makes this test hermetic: every case pins
# $ARDD_SOURCE at this repo, so no case clones, pulls, or otherwise reaches
# the network.
#
# The interactive prompt itself (`read … < /dev/tty`) is deliberately not
# exercised: /dev/tty is opened by path inside the script, so no portable test
# can inject one — and whether it's readable differs between a developer's
# terminal and CI's runner. What IS exercised is every branch that decides
# whether to reach that read at all, which is where regressions actually live:
# --kickoff reaches the exec (case 10, poison claude exits 42), --no-kickoff
# does not (case 4), a missing `claude` does not (case 12), and none of them
# hang (every case runs under with_timeout).

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

# Portable timeout guard. macOS ships no timeout(1), and new.sh now reads an
# answer from /dev/tty — a regression that reads from the wrong descriptor
# would stall CI forever rather than failing it. Runs the command in the
# background, polls for up to $1 seconds, then kills it and returns 124
# (timeout(1)'s convention for "timed out").
with_timeout() { # with_timeout <seconds> <cmd...>
  secs="$1"; shift
  "$@" & _pid=$!
  _waited=0
  while kill -0 "$_pid" 2>/dev/null; do
    if [ "$_waited" -ge "$secs" ]; then
      kill -9 "$_pid" 2>/dev/null
      wait "$_pid" 2>/dev/null
      return 124
    fi
    sleep 1
    _waited=$((_waited + 1))
  done
  wait "$_pid"
}

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
run_new 0 "case1: fresh target installs" --no-kickoff "$target"

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

run_new 1 "case2: non-empty target refused" --no-kickoff "$target"
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
out="$(ARDD_SOURCE="$notardd" sh "$NEW_SH" --no-kickoff "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 1 ] \
  && ok "case3: non-ARDD source refused (exit 1)" \
  || bad "case3: expected exit 1, got $status"
[ -d "$target/.claude" ] \
  && bad "case3: refused but still installed" \
  || ok "case3: nothing installed from a bad source"

# --- Case 4: --no-kickoff never executes claude ---
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
out="$(PATH="$bin:$PATH" ARDD_SOURCE="$REPO_ROOT" sh "$NEW_SH" --no-kickoff "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case4: --no-kickoff did not exec claude" \
  || bad "case4: expected exit 0, got $status (42 means claude was exec'd)"

# It must still tell the user how to start the session by hand.
printf '%s' "$out" | grep -q '/ardd-kickoff' \
  && ok "case4: prints the /ardd-kickoff next step" \
  || bad "case4: never mentions /ardd-kickoff"

# --- Case 5: an existing *empty* directory is fine, not a refusal ---
target="$WORK/case5/proj"
mkdir -p "$target"
run_new 0 "case5: existing empty dir accepted" --no-kickoff "$target"
[ -f "$target/.project/ardd-version.md" ] \
  && ok "case5: installed into empty dir" \
  || bad "case5: nothing installed"

# --- Case 6: a directory holding only .git is "empty enough" ---
# `git init` then the quickstart is a natural order; refusing it would be a
# papercut. Only non-.git entries make a target non-empty.
target="$WORK/case6/proj"
mkdir -p "$target"
git init -q "$target"
run_new 0 "case6: git-init'd but otherwise empty dir accepted" --no-kickoff "$target"
[ -f "$target/.project/ardd-version.md" ] \
  && ok "case6: installed into git-only dir" \
  || bad "case6: nothing installed"

# --- Case 7: --source is equivalent to $ARDD_SOURCE, and never mutates it ---
before="$(git -C "$REPO_ROOT" rev-parse HEAD)"
target="$WORK/case7/proj"
set +e
out="$(sh "$NEW_SH" --no-kickoff --source "$REPO_ROOT" "$target" </dev/null 2>&1)"
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
out="$(ARDD_SOURCE="$REPO_ROOT" sh "$NEW_SH" --no-kickoff </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 2 ] \
  && ok "case8: missing target exits 2 (usage)" \
  || bad "case8: expected exit 2, got $status"

# --- Case 9: the target check runs before source resolution ---
# Ordering matters for real: with no --source and no $ARDD_SOURCE, resolving
# the source *clones* ~/.ardd/source over the network. A typo'd target must
# be rejected before that cost is paid. Assert it by making both inputs bad
# and requiring the *target* complaint to be the one that surfaces.
target="$WORK/case9/proj"
mkdir -p "$target"
echo "occupied" > "$target/file.txt"
set +e
out="$(ARDD_SOURCE="$notardd" sh "$NEW_SH" --no-kickoff "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 1 ] \
  && ok "case9: refused (exit 1)" \
  || bad "case9: expected exit 1, got $status"
printf '%s' "$out" | grep -q 'not empty' \
  && ok "case9: target checked before source (target error wins)" \
  || bad "case9: source resolved before the target was validated"

# --- Case 10: --kickoff reaches the exec ---
# The positive counterpart to case 4. With the poison `claude` on PATH, an
# exec replaces the shell and the run exits 42. Anything else means the launch
# path was never taken — which would make case 4's "never exec'd" assertion
# vacuous, since it would pass whether or not new.sh could launch at all.
target="$WORK/case10/proj"
set +e
with_timeout 60 env PATH="$bin:$PATH" ARDD_SOURCE="$REPO_ROOT" \
  sh "$NEW_SH" --kickoff "$target" </dev/null >/dev/null 2>&1
status=$?
set -e
case "$status" in
  42)  ok "case10: --kickoff exec'd claude" ;;
  124) bad "case10: timed out — new.sh is blocking on a read" ;;
  *)   bad "case10: expected exit 42 (exec'd claude), got $status" ;;
esac

# --- Case 11: --kickoff and --no-kickoff together are a usage error ---
# Not last-flag-wins: silently guessing which of two contradictory intents the
# user meant is worse than making them say.
target="$WORK/case11/proj"
set +e
with_timeout 60 env ARDD_SOURCE="$REPO_ROOT" \
  sh "$NEW_SH" --kickoff --no-kickoff "$target" </dev/null >/dev/null 2>&1
status=$?
set -e
[ "$status" -eq 2 ] \
  && ok "case11: contradictory flags exit 2 (usage)" \
  || bad "case11: expected exit 2, got $status"
[ -d "$target/.claude" ] \
  && bad "case11: usage error but still installed" \
  || ok "case11: nothing installed on a usage error"

# --- Case 12: no flags, no `claude` on PATH -> print next steps, never hang ---
# The prompt must not be reached when there's nothing to launch. A minimal
# PATH keeps any real `claude` out of scope; the timeout catches a read that
# blocks on the wrong descriptor.
emptybin="$WORK/emptybin"
mkdir -p "$emptybin"
target="$WORK/case12/proj"
set +e
out="$(with_timeout 60 env PATH="$emptybin:/usr/bin:/bin" ARDD_SOURCE="$REPO_ROOT" \
  sh "$NEW_SH" "$target" </dev/null 2>&1)"
status=$?
set -e
case "$status" in
  0)   ok "case12: missing claude -> exit 0, no prompt" ;;
  124) bad "case12: timed out — prompted (or read) with no claude to launch" ;;
  *)   bad "case12: expected exit 0, got $status" ;;
esac
printf '%s' "$out" | grep -q '/ardd-kickoff' \
  && ok "case12: still prints the /ardd-kickoff next step" \
  || bad "case12: never mentions /ardd-kickoff"

# --- Case 13: --no-launch is gone, not silently accepted ---
# It shipped only on unpushed local main, so it was renamed rather than
# aliased. A stale invocation must fail loudly, not install with a surprise
# launch because an unknown flag was ignored.
target="$WORK/case13/proj"
set +e
with_timeout 60 env ARDD_SOURCE="$REPO_ROOT" \
  sh "$NEW_SH" --no-launch "$target" </dev/null >/dev/null 2>&1
status=$?
set -e
[ "$status" -eq 2 ] \
  && ok "case13: retired --no-launch exits 2 (unknown option)" \
  || bad "case13: expected exit 2, got $status"

# --- Case 14: the launch exec never redirects Claude Code's stdin ---
# Static, because the failure is invisible without a real tty: Claude Code uses
# process.stdin only when `stdin.isTTY && stdout.isTTY`, else it opens /dev/tty
# read-write itself. `exec claude … < /dev/tty` passes that check with a
# read-only fd, so the TUI paints but accepts no keystrokes; `<>` exits. CI has
# no tty to reproduce either, so guard the source line instead.
grep -n 'exec claude' "$NEW_SH" | grep -q '/dev/tty' \
  && bad "case14: launch exec redirects stdin — Claude Code will ignore keystrokes" \
  || ok "case14: launch exec leaves stdin alone"

if [ "$fail" -eq 0 ]; then
  echo "test-new: all cases pass"
else
  echo "test-new: FAILURES above" >&2
  exit 1
fi
