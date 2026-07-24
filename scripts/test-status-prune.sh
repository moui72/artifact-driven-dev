#!/usr/bin/env sh
# Regression test for scripts/status-prune.sh. Builds throwaway STATUS.md
# fixtures in a temp dir — never touches this repo's real .project/STATUS.md.
set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PRUNE="$SCRIPT_DIR/status-prune.sh"

fail=0
check() { # <label> <condition-already-evaluated: "ok"/"no">
  if [ "$2" = ok ]; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi
}

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# A fixture with head matter + `n` prepend-ordered blocks (block n = newest).
make_fixture() { # <path> <n>
  path="$1"; n="$2"
  { printf '# Project Status\n\nsome head matter line\n\n'
    i="$n"
    while [ "$i" -ge 1 ]; do printf '_Updated: block %s body_\n\n' "$i"; i=$((i - 1)); done
  } > "$path"
}

# --- Case 1: more-than-N -> tail cut, head + kept blocks byte-identical ---
F="$TMP/more.md"; make_fixture "$F" 5
head -n "$(grep -n '^_Updated:' "$F" | sed -n '3p' | cut -d: -f1 | xargs -I{} expr {} - 1)" "$F" > "$TMP/expected-more.md"
out=$("$PRUNE" "$F" --keep 2)
echo "$out" | grep -q '^removed=3$' && check "more-than-N: removed=3 reported" ok || check "more-than-N: removed=3 reported" no
echo "$out" | grep -q '^kept=2$' && check "more-than-N: kept=2 reported" ok || check "more-than-N: kept=2 reported" no
[ "$(grep -c '^_Updated:' "$F")" = 2 ] && check "more-than-N: 2 blocks remain" ok || check "more-than-N: 2 blocks remain" no
grep -q '^# Project Status$' "$F" && check "more-than-N: head matter preserved" ok || check "more-than-N: head matter preserved" no
cmp -s "$F" "$TMP/expected-more.md" && check "more-than-N: kept region byte-identical to head+newest-2" ok || check "more-than-N: kept region byte-identical to head+newest-2" no
grep -q 'block 5 body' "$F" && check "more-than-N: newest block kept" ok || check "more-than-N: newest block kept" no
grep -q 'block 1 body' "$F" && check "more-than-N: oldest block dropped" no || check "more-than-N: oldest block dropped" ok

# --- Case 2: exactly-N -> no-op ---
F="$TMP/exact.md"; make_fixture "$F" 3
cp "$F" "$TMP/exact-orig.md"
out=$("$PRUNE" "$F" --keep 3)
echo "$out" | grep -q '^removed=0$' && check "exactly-N: removed=0" ok || check "exactly-N: removed=0" no
cmp -s "$F" "$TMP/exact-orig.md" && check "exactly-N: file untouched" ok || check "exactly-N: file untouched" no

# --- Case 3: fewer-than-N -> no-op ---
F="$TMP/fewer.md"; make_fixture "$F" 2
cp "$F" "$TMP/fewer-orig.md"
out=$("$PRUNE" "$F" --keep 10)
echo "$out" | grep -q '^removed=0$' && check "fewer-than-N: removed=0" ok || check "fewer-than-N: removed=0" no
cmp -s "$F" "$TMP/fewer-orig.md" && check "fewer-than-N: file untouched" ok || check "fewer-than-N: file untouched" no

# --- Case 4: head matter with no blocks at all -> no-op, head intact ---
F="$TMP/nohdr.md"; printf '# Only head\n\nno chronology here\n' > "$F"
cp "$F" "$TMP/nohdr-orig.md"
out=$("$PRUNE" "$F" --keep 3)
echo "$out" | grep -q '^blocks=0$' && check "no-blocks: blocks=0" ok || check "no-blocks: blocks=0" no
cmp -s "$F" "$TMP/nohdr-orig.md" && check "no-blocks: file untouched" ok || check "no-blocks: file untouched" no

# --- Case 5: bad keep (zero / negative / non-integer) -> refuse, file untouched ---
F="$TMP/bad.md"; make_fixture "$F" 4; cp "$F" "$TMP/bad-orig.md"
for badval in 0 -1 abc 2.5; do
  if "$PRUNE" "$F" --keep "$badval" >/dev/null 2>&1; then
    check "bad-keep '$badval': refused (nonzero exit)" no
  else
    check "bad-keep '$badval': refused (nonzero exit)" ok
  fi
done
"$PRUNE" "$F" --keep 0 2>&1 | grep -q '^reason=bad-keep$' && check "bad-keep: reason=bad-keep" ok || check "bad-keep: reason=bad-keep" no
cmp -s "$F" "$TMP/bad-orig.md" && check "bad-keep: file untouched" ok || check "bad-keep: file untouched" no

# --- Case 6: missing file -> refuse ---
if "$PRUNE" "$TMP/does-not-exist.md" --keep 2 >/dev/null 2>&1; then
  check "missing-file: refused" no
else
  check "missing-file: refused" ok
fi
"$PRUNE" "$TMP/does-not-exist.md" --keep 2 2>&1 | grep -q '^reason=not-a-file$' && check "missing-file: reason=not-a-file" ok || check "missing-file: reason=not-a-file" no

# --- Case 7: usage errors (no keep, no file, extra positional) ---
F="$TMP/usage.md"; make_fixture "$F" 3
if "$PRUNE" "$F" >/dev/null 2>&1; then rc=0; else rc=$?; fi
[ "$rc" -eq 2 ] && check "usage: missing --keep exits 2" ok || check "usage: missing --keep exits 2" no
if "$PRUNE" --keep 2 >/dev/null 2>&1; then rc=0; else rc=$?; fi
[ "$rc" -eq 2 ] && check "usage: missing file exits 2" ok || check "usage: missing file exits 2" no
if "$PRUNE" "$F" extra --keep 2 >/dev/null 2>&1; then rc=0; else rc=$?; fi
[ "$rc" -eq 2 ] && check "usage: extra positional exits 2" ok || check "usage: extra positional exits 2" no

# --- Case 8: --keep=N equals form works ---
F="$TMP/eq.md"; make_fixture "$F" 5
"$PRUNE" "$F" --keep=1 >/dev/null
[ "$(grep -c '^_Updated:' "$F")" = 1 ] && check "--keep=N form: 1 block remains" ok || check "--keep=N form: 1 block remains" no

if [ "$fail" -eq 0 ]; then
  echo "test-status-prune: all cases pass"
else
  echo "test-status-prune: FAILURES above"
  exit 1
fi
