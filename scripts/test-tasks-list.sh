#!/usr/bin/env sh
# Regression test for tasks-list.sh: the deterministic tasks-file pick
# list (status, checkbox progress, plan binding; abandoned excluded
# unless --all).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIST="$SCRIPT_DIR/tasks-list.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

T="$WORK/t/.project/tasks"; mkdir -p "$T"

mk() { # file status checked unchecked
  {
    printf -- '---\nplan: plan-%s.md\ngenerated: 2026-07-06\nstatus: %s\n---\n# Tasks\n' "$1" "$2"
    i=0; while [ $i -lt "$3" ]; do i=$((i+1)); printf -- '- [x] T%03d done\n' "$i"; done
    j="$3"; k=0; while [ $k -lt "$4" ]; do k=$((k+1)); j=$((j+1)); printf -- '- [ ] T%03d todo\n' "$j"; done
  } > "$T/tasks-$1.md"
}
mk alpha-1111 ready 0 3
mk beta-2222 in-progress 2 2
mk gamma-3333 completed 4 0
mk delta-4444 abandoned 1 1

out="$(sh "$LIST" "$WORK/t")"
echo "$out" | grep -q "tasks-alpha-1111.md	ready	0/3	plan-alpha-1111.md" && ok "ready file listed with progress + plan" || bad "ready file listed — got: $out"
echo "$out" | grep -q "tasks-beta-2222.md	in-progress	2/4	plan-beta-2222.md" && ok "in-progress progress correct" || bad "in-progress progress — got: $out"
echo "$out" | grep -q "tasks-gamma-3333.md	completed	4/4" && ok "completed listed" || bad "completed listed — got: $out"
echo "$out" | grep -q "delta" && bad "abandoned excluded by default" || ok "abandoned excluded by default"

out="$(sh "$LIST" --all "$WORK/t")"
echo "$out" | grep -q "tasks-delta-4444.md	abandoned	1/2" && ok "--all includes abandoned" || bad "--all includes abandoned — got: $out"

# empty/no dir: silent success
mkdir -p "$WORK/empty/.project"
sh "$LIST" "$WORK/empty" >/dev/null 2>&1 && ok "no tasks dir -> exit 0 silent" || bad "no tasks dir -> exit 0"

exit "$fail"
