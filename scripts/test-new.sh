#!/usr/bin/env sh
# Regression test for new.sh — the curl-to-sh quickstart entry point.
#
# new.sh's contract (constitution v1.2.4, Project Scope & Intent):
#   - it is an *acquisition* channel that converges onto install.sh by
#     invoking it, never reimplementing any part of it;
#   - it REFUSES rather than asks wherever writing into a directory it doesn't
#     own is at stake (a non-empty target; a --source that isn't an ArDD
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
# hang (every case runs under with_timeout). The harness prompt follows the
# same rule: no tty preserves the historical Claude default.

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

[ -f "$target/.claude/skills/ardd-init/SKILL.md" ] \
  && ok "case1: skills installed" \
  || bad "case1: skills missing"

[ -f "$target/.project/ardd-version.md" ] \
  && ok "case1: ardd-version.md recorded" \
  || bad "case1: ardd-version.md missing"

grep -qxF 'Harness: claude' "$target/.project/ardd-version.md" \
  && ok "case1: no-tty default records Claude harness" \
  || bad "case1: no-tty default records Claude harness"

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

# --- Case 3: a source path that isn't an ArDD checkout is refused ---
notardd="$WORK/case3/notardd"
mkdir -p "$notardd"
: > "$notardd/some-file"
target="$WORK/case3/proj"

set +e
out="$(ARDD_SOURCE="$notardd" sh "$NEW_SH" --no-kickoff "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 1 ] \
  && ok "case3: non-ArDD source refused (exit 1)" \
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
printf '%s' "$out" | grep -q '/ardd-init' \
  && ok "case4: prints the /ardd-init next step" \
  || bad "case4: never mentions /ardd-init"

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
printf '%s' "$out" | grep -q '/ardd-init' \
  && ok "case12: still prints the /ardd-init next step" \
  || bad "case12: never mentions /ardd-init"

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

# --- Case 14: launch()'s exec is redirected correctly per harness ---
# Static, because the failure is invisible without a real tty. Claude Code
# uses process.stdin only when `stdin.isTTY && stdout.isTTY`, else it opens
# /dev/tty read-write itself. `exec claude … < /dev/tty` passes that check
# with a read-only fd, so the TUI paints but accepts no keystrokes; `<>`
# exits — so its branch must stay unredirected. Codex has no such fallback
# at all: it errors immediately without a real terminal on stdin (confirmed
# empirically: `echo "" | codex '...' </dev/null` reproduces
# `Error: stdin is not a terminal`), so its branch must use `<> /dev/tty`.
# CI has no tty to reproduce either behavior live, so guard both source
# lines instead.
claude_exec_line=$(grep -n 'exec "\$handoff_tool" "\$handoff_cmd" ;;' "$NEW_SH" || true)
codex_exec_line=$(grep -n 'exec "\$handoff_tool" "\$handoff_cmd" <> /dev/tty' "$NEW_SH" || true)
echo "$claude_exec_line" | grep -q '/dev/tty' \
  && bad "case14: Claude Code launch exec redirects stdin — will ignore keystrokes" \
  || ok "case14: Claude Code launch exec leaves stdin alone"
[ -n "$codex_exec_line" ] \
  && ok "case14: Codex launch exec redirects stdin via <> /dev/tty" \
  || bad "case14: Codex launch exec missing <> /dev/tty redirect"

# --- Case 15: --existing installs into a populated project (guard inverted) ---
# The existing-project mode accepts a non-empty target — that is the whole
# point. The explicit --existing flag is the consent that case 2 withholds by
# default; pre-existing content must survive untouched.
target="$WORK/case15/proj"
mkdir -p "$target/src"
git init -q "$target"
echo "my real project" > "$target/README.md"
echo "code" > "$target/src/main.py"
run_new 0 "case15: --existing accepts a populated project" --no-kickoff --existing "$target"
[ -f "$target/.project/ardd-version.md" ] \
  && ok "case15: ArDD installed into existing project" \
  || bad "case15: nothing installed"
{ [ -f "$target/src/main.py" ] && grep -q "code" "$target/src/main.py"; } \
  && ok "case15: pre-existing content untouched" \
  || bad "case15: pre-existing content clobbered"

# --- Case 16: --existing hands off to /ardd-init (mode detection lives in
# the skill now — bootstrap/codify merged at v1.0.0). A populated project
# with no .project/ still gets /ardd-init; the skill detects the existing
# codebase and takes its reverse-engineering path.
target="$WORK/case16/proj"
mkdir -p "$target"; git init -q "$target"; echo x > "$target/f"
set +e
out="$(ARDD_SOURCE="$REPO_ROOT" sh "$NEW_SH" --no-kickoff --existing "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case16: --existing exits 0" \
  || bad "case16: expected exit 0, got $status"
# Grep new.sh's *own* handoff line specifically — `claude "/ardd-init"` — not
# a bare skill name: install.sh's generic next-steps blurb mentions /ardd-init
# in prose too, so only the `claude "…"` invocation form distinguishes
# new.sh's handoff from install.sh's output.
printf '%s' "$out" | grep -q 'claude "/ardd-init"' \
  && ok "case16: handoff points at /ardd-init" \
  || bad "case16: handoff does not point at /ardd-init"
printf '%s' "$out" | grep -q 'claude "/ardd-bootstrap"\|claude "/ardd-codify"' \
  && bad "case16: handoff still points at a pre-merge setup skill" \
  || ok "case16: no pre-merge setup-skill handoff"

# --- Case 17: --existing on a missing directory is refused (use plain mode) ---
# Existing mode requires a real, populated project; a non-existent path means
# the user wants new-project mode instead — refuse rather than create it.
target="$WORK/case17/does-not-exist"
run_new 1 "case17: --existing on a missing dir refused" --no-kickoff --existing "$target"
[ -d "$target" ] \
  && bad "case17: refused but created the dir" \
  || ok "case17: nothing created on refusal"

# --- Case 18: --existing defaults its target to the current directory ---
# `cd my-project && curl … | sh -s -- --existing` is the natural invocation
# from inside an existing project, so a missing target argument is not a usage
# error in this mode — it means "here".
target="$WORK/case18/proj"
mkdir -p "$target"; git init -q "$target"; echo x > "$target/f"
set +e
out="$( (cd "$target" && ARDD_SOURCE="$REPO_ROOT" sh "$NEW_SH" --no-kickoff --existing </dev/null) 2>&1 )"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case18: --existing with no target defaults to cwd" \
  || bad "case18: expected exit 0, got $status"
[ -f "$target/.project/ardd-version.md" ] \
  && ok "case18: installed into cwd" \
  || bad "case18: nothing installed into cwd"

# --- Cases 19–22: release-channel pinning of the owned checkout ---
# new.sh must move the checkout it owns (~/.ardd/source) to the latest
# semver release tag after refreshing it, tolerate offline refreshes, note
# a source with no releases, and keep --source/$ARDD_SOURCE dev-mode:
# used exactly as given, never mutated. Hermetic: $HOME is pinned into the
# temp dir so the "owned" path never leaves it, and the owned checkout is
# always pre-seeded from a local fixture origin — no case may reach the
# clone-from-GitHub path.

# A fixture origin that is a fully installable ArDD checkout, tagged so
# that lexical ordering would pick the wrong release (v1.10.0 > v1.9.0).
FIXORIGIN="$WORK/fix-origin"
mkdir -p "$FIXORIGIN"
cp -R "$REPO_ROOT/skills" "$REPO_ROOT/templates" "$REPO_ROOT/scripts" "$REPO_ROOT/migrations" "$FIXORIGIN/"
cp "$REPO_ROOT/install.sh" "$FIXORIGIN/"
( cd "$FIXORIGIN" && git init -q -b main && git add -A && git commit -q -m one )
git -C "$FIXORIGIN" tag v1.9.0
( cd "$FIXORIGIN" && printf 'marker\n' > release-marker && git add -A && git commit -q -m two )
git -C "$FIXORIGIN" tag v1.10.0

# --- Case 19: owned checkout is refreshed and pinned to the latest tag ---
FAKEHOME="$WORK/home19"
mkdir -p "$FAKEHOME/.ardd"
git clone -q "$FIXORIGIN" "$FAKEHOME/.ardd/source"
git -C "$FAKEHOME/.ardd/source" checkout -q v1.9.0   # stale, detached at an old release
target="$WORK/case19/proj"
set +e
out="$(with_timeout 60 env HOME="$FAKEHOME" ARDD_SOURCE= \
  sh "$NEW_SH" --no-kickoff "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case19: owned-source install exits 0" \
  || { bad "case19: expected exit 0, got $status"; printf '%s\n' "$out" | sed 's/^/    /'; }
[ "$(git -C "$FAKEHOME/.ardd/source" describe --exact-match --tags 2>/dev/null)" = "v1.10.0" ] \
  && ok "case19: owned checkout moved to latest release (v1.10.0 > v1.9.0)" \
  || bad "case19: owned checkout not at v1.10.0"
grep -q '^Source-Ref: v1.10.0$' "$target/.project/ardd-version.md" 2>/dev/null \
  && ok "case19: install recorded Source-Ref v1.10.0" \
  || bad "case19: Source-Ref v1.10.0 not recorded"

# --- Case 20: no releases tagged -> default branch, noted, still installs ---
FIXORIGIN2="$WORK/fix-origin-notags"
mkdir -p "$FIXORIGIN2"
cp -R "$REPO_ROOT/skills" "$REPO_ROOT/templates" "$REPO_ROOT/scripts" "$REPO_ROOT/migrations" "$FIXORIGIN2/"
cp "$REPO_ROOT/install.sh" "$FIXORIGIN2/"
( cd "$FIXORIGIN2" && git init -q -b main && git add -A && git commit -q -m one )
FAKEHOME="$WORK/home20"
mkdir -p "$FAKEHOME/.ardd"
git clone -q "$FIXORIGIN2" "$FAKEHOME/.ardd/source"
target="$WORK/case20/proj"
set +e
out="$(with_timeout 60 env HOME="$FAKEHOME" ARDD_SOURCE= \
  sh "$NEW_SH" --no-kickoff "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case20: no-tags source still installs" \
  || bad "case20: expected exit 0, got $status"
printf '%s' "$out" | grep -qi 'no releases' \
  && ok "case20: notes that no releases exist" \
  || bad "case20: no-releases note missing"
[ "$(git -C "$FAKEHOME/.ardd/source" branch --show-current)" = "main" ] \
  && ok "case20: owned checkout stays on the default branch" \
  || bad "case20: owned checkout left the default branch"

# --- Case 21: offline refresh warns and proceeds with existing state ---
FAKEHOME="$WORK/home21"
mkdir -p "$FAKEHOME/.ardd"
git clone -q "$FIXORIGIN" "$FAKEHOME/.ardd/source"
git -C "$FAKEHOME/.ardd/source" remote set-url origin "$WORK/gone-remote"
target="$WORK/case21/proj"
set +e
out="$(with_timeout 60 env HOME="$FAKEHOME" ARDD_SOURCE= \
  sh "$NEW_SH" --no-kickoff "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case21: offline refresh still installs" \
  || bad "case21: expected exit 0, got $status"
[ "$(git -C "$FAKEHOME/.ardd/source" describe --exact-match --tags 2>/dev/null)" = "v1.10.0" ] \
  && ok "case21: pinned from existing (already-cloned) tags" \
  || bad "case21: not pinned to v1.10.0 from existing state"

# --- Case 22: a --source/$ARDD_SOURCE checkout with tags is never moved ---
# Dev-mode: the user's checkout is used exactly as given — no fetch, no
# tag checkout — even though releases exist in it.
DEVSRC="$WORK/case22/dev-src"
mkdir -p "$WORK/case22"
git clone -q "$FIXORIGIN" "$DEVSRC"
dev_head="$(git -C "$DEVSRC" rev-parse HEAD)"
target="$WORK/case22/proj"
set +e
out="$(with_timeout 60 env ARDD_SOURCE="$DEVSRC" \
  sh "$NEW_SH" --no-kickoff "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case22: dev-mode source installs" \
  || bad "case22: expected exit 0, got $status"
[ "$(git -C "$DEVSRC" rev-parse HEAD)" = "$dev_head" ] \
  && ok "case22: dev-mode source HEAD untouched" \
  || bad "case22: dev-mode source HEAD moved"
[ "$(git -C "$DEVSRC" branch --show-current)" = "main" ] \
  && ok "case22: dev-mode source still on its branch (not detached at a tag)" \
  || bad "case22: dev-mode source was detached/moved to a tag"

# --- Cases 23–27: the beta channel (--beta) and channel recording --------
# Two-channel decision (constitution v1.8.0): --beta selects the latest
# tag among stable+prerelease (versionsort.suffix=-beta. — a newer stable
# beats an older beta, the pinned ordering trap) and records
# `Channel: beta` in the target's ardd-version.md via $ARDD_CHANNEL;
# without it everything stays stable, recorded as `Channel: stable`.

# --- Case 23: default install records Channel: stable ---
target="$WORK/case23/proj"
run_new 0 "case23: default install succeeds" --no-kickoff "$target"
grep -q '^Channel: stable$' "$target/.project/ardd-version.md" 2>/dev/null \
  && ok "case23: Channel: stable recorded by default" \
  || bad "case23: Channel: stable not recorded"

# --- Case 24: --beta pins the owned checkout to the latest prerelease ---
FIXORIGIN3="$WORK/fix-origin-beta"
mkdir -p "$FIXORIGIN3"
cp -R "$REPO_ROOT/skills" "$REPO_ROOT/templates" "$REPO_ROOT/scripts" "$REPO_ROOT/migrations" "$FIXORIGIN3/"
cp "$REPO_ROOT/install.sh" "$FIXORIGIN3/"
( cd "$FIXORIGIN3" && git init -q -b main && git add -A && git commit -q -m one )
git -C "$FIXORIGIN3" tag v1.10.0
( cd "$FIXORIGIN3" && printf 'beta1\n' > beta-marker && git add -A && git commit -q -m two )
git -C "$FIXORIGIN3" tag v1.10.1-beta.1

FAKEHOME="$WORK/home24"
mkdir -p "$FAKEHOME/.ardd"
git clone -q "$FIXORIGIN3" "$FAKEHOME/.ardd/source"
target="$WORK/case24/proj"
set +e
out="$(with_timeout 60 env HOME="$FAKEHOME" ARDD_SOURCE= \
  sh "$NEW_SH" --no-kickoff --beta "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case24: --beta install exits 0" \
  || { bad "case24: expected exit 0, got $status"; printf '%s\n' "$out" | sed 's/^/    /'; }
[ "$(git -C "$FAKEHOME/.ardd/source" describe --exact-match --tags 2>/dev/null)" = "v1.10.1-beta.1" ] \
  && ok "case24: owned checkout pinned to the prerelease" \
  || bad "case24: owned checkout not at v1.10.1-beta.1"
grep -q '^Channel: beta$' "$target/.project/ardd-version.md" 2>/dev/null \
  && ok "case24: Channel: beta recorded" \
  || bad "case24: Channel: beta not recorded"
grep -q '^Source-Ref: v1.10.1-beta.1$' "$target/.project/ardd-version.md" 2>/dev/null \
  && ok "case24: Source-Ref records the beta tag" \
  || bad "case24: Source-Ref v1.10.1-beta.1 not recorded"

# --- Case 25: without --beta the same source still pins stable ---
FAKEHOME="$WORK/home25"
mkdir -p "$FAKEHOME/.ardd"
git clone -q "$FIXORIGIN3" "$FAKEHOME/.ardd/source"
target="$WORK/case25/proj"
set +e
out="$(with_timeout 60 env HOME="$FAKEHOME" ARDD_SOURCE= \
  sh "$NEW_SH" --no-kickoff "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case25: stable install from a beta-tagged source exits 0" \
  || bad "case25: expected exit 0, got $status"
[ "$(git -C "$FAKEHOME/.ardd/source" describe --exact-match --tags 2>/dev/null)" = "v1.10.0" ] \
  && ok "case25: prerelease invisible without --beta (pinned v1.10.0)" \
  || bad "case25: owned checkout not at v1.10.0"

# --- Case 26: the ordering trap — a newer stable beats the older beta ---
( cd "$FIXORIGIN3" && printf 'stable\n' >> beta-marker && git add -A && git commit -q -m three )
git -C "$FIXORIGIN3" tag v1.10.1
FAKEHOME="$WORK/home26"
mkdir -p "$FAKEHOME/.ardd"
git clone -q "$FIXORIGIN3" "$FAKEHOME/.ardd/source"
target="$WORK/case26/proj"
set +e
out="$(with_timeout 60 env HOME="$FAKEHOME" ARDD_SOURCE= \
  sh "$NEW_SH" --no-kickoff --beta "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case26: --beta with a newer stable exits 0" \
  || bad "case26: expected exit 0, got $status"
[ "$(git -C "$FAKEHOME/.ardd/source" describe --exact-match --tags 2>/dev/null)" = "v1.10.1" ] \
  && ok "case26: newer stable beats older beta (ordering trap)" \
  || bad "case26: owned checkout not at v1.10.1 ($(git -C "$FAKEHOME/.ardd/source" describe --exact-match --tags 2>/dev/null))"

# --- Case 27: --beta with a dev-mode source — never moved, channel still recorded ---
DEVSRC27="$WORK/case27/dev-src"
mkdir -p "$WORK/case27"
git clone -q "$FIXORIGIN3" "$DEVSRC27"
dev_head="$(git -C "$DEVSRC27" rev-parse HEAD)"
target="$WORK/case27/proj"
set +e
out="$(with_timeout 60 env ARDD_SOURCE="$DEVSRC27" \
  sh "$NEW_SH" --no-kickoff --beta "$target" </dev/null 2>&1)"
status=$?
set -e
[ "$status" -eq 0 ] \
  && ok "case27: --beta with dev-mode source exits 0" \
  || bad "case27: expected exit 0, got $status"
[ "$(git -C "$DEVSRC27" rev-parse HEAD)" = "$dev_head" ] \
  && ok "case27: dev-mode source untouched under --beta" \
  || bad "case27: dev-mode source HEAD moved"
grep -q '^Channel: beta$' "$target/.project/ardd-version.md" 2>/dev/null \
  && ok "case27: Channel: beta recorded even in dev-mode" \
  || bad "case27: Channel: beta not recorded"

# --- Case 28: documented stable curl base is the release branch (static) ---
# Under beta-on-push, main explicitly serves the beta channel, so the
# stable acquisition URL must name the release branch — which only the
# docs/messages move to; resolution itself still goes through tags in
# ~/.ardd/source, so new.sh keeps working while the branch doesn't exist
# yet. Static, like case 14: there is no network here to exercise a URL.
grep -q 'artifact-driven-dev/release/new.sh' "$NEW_SH" \
  && ok "case28: stable curl base documents the release branch" \
  || bad "case28: no release-branch curl base documented in new.sh"
grep -qi 'beta' "$NEW_SH" \
  && ok "case28: new.sh documents the beta channel" \
  || bad "case28: new.sh never mentions the beta channel"

# --- Case 29: a target nested under an existing git-controlled directory
# still gets its own isolated repo, not the enclosing repo's identity ---
# new.sh:240's guard used `git -C "$TARGET" rev-parse --is-inside-work-tree`,
# which is true for ANY directory nested under an existing .git, not just
# $TARGET being a repo root itself — so a target under an already-git-
# controlled directory (e.g. a scratch dir inside the user's dotfiles repo)
# silently skipped `git init` and the target ended up sharing the outer
# repo's history/remote instead of getting its own. [feedback: F001]
outer="$WORK/case29/outer"
mkdir -p "$outer"
git -C "$outer" init --quiet
git -C "$outer" commit --quiet --allow-empty -m "outer repo root commit"
target="$outer/nested/proj"

run_new 0 "case29: nested target installs" --no-kickoff "$target"

if [ -e "$target/.git" ]; then
  ok "case29: nested target has its own .git"
else
  bad "case29: nested target has no own .git — inherited the outer repo"
fi

outer_toplevel="$(git -C "$outer" rev-parse --show-toplevel 2>/dev/null || true)"
target_toplevel="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$target_toplevel" ] && [ "$target_toplevel" != "$outer_toplevel" ]; then
  ok "case29: nested target is its own repo top-level"
else
  bad "case29: nested target's repo top-level is the outer repo ($target_toplevel vs $outer_toplevel)"
fi

# --- Case 30: --harness codex routes acquisition through install.sh's
# Codex harness and prints a shell-safe Codex handoff command ---
target="$WORK/case30/proj"
run_new 0 "case30: --harness codex installs" --no-kickoff --harness codex "$target"
[ -f "$target/.agents/skills/ardd-init/SKILL.md" ] \
  && ok "case30: Codex skills installed under .agents" \
  || bad "case30: Codex skills missing"
[ ! -d "$target/.claude/skills" ] \
  && ok "case30: Codex acquisition does not create .claude skills" \
  || bad "case30: Codex acquisition created .claude skills"
grep -qxF 'Harness: codex' "$target/.project/ardd-version.md" \
  && ok "case30: ardd-version records Codex harness" \
  || bad "case30: ardd-version records Codex harness"
printf '%s' "$out" | grep -F -q "codex '\$ardd-init'" \
  && ok 'case30: next step prints shell-safe codex $ardd-init command' \
  || bad 'case30: next step prints shell-safe codex $ardd-init command'

# --- Case 31: --harness=codex form is accepted ---
target="$WORK/case31/proj"
run_new 0 "case31: --harness=codex installs" --no-kickoff --harness=codex "$target"
grep -qxF 'Harness: codex' "$target/.project/ardd-version.md" \
  && ok "case31: --harness= form records Codex harness" \
  || bad "case31: --harness= form records Codex harness"

# --- Case 32: unknown harness is refused before install ---
target="$WORK/case32/proj"
run_new 2 "case32: unknown harness refused" --no-kickoff --harness nope "$target"
[ -d "$target/.claude" ] || [ -d "$target/.agents" ] \
  && bad "case32: usage error still installed skills" \
  || ok "case32: nothing installed for unknown harness"

if [ "$fail" -eq 0 ]; then
  echo "test-new: all cases pass"
else
  echo "test-new: FAILURES above" >&2
  exit 1
fi
