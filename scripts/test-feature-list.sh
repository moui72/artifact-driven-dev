#!/usr/bin/env sh
# Regression test for feature-list.sh: the deterministic feature-register
# pick list (slug, status, logged, one-line description; filtered to
# backlogged by default, --status/--all widen it).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIST="$SCRIPT_DIR/feature-list.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

F="$WORK/t/.project/features"; mkdir -p "$F"

mk() { # slug status logged description-line [why-line]
  {
    printf -- '---\nslug: %s\nstatus: %s\nlogged: %s\n---\n' "$1" "$2" "$3"
    printf -- '%s\n' "$4"
    if [ -n "${5:-}" ]; then printf -- 'Why: %s\n' "$5"; fi
  } > "$F/$1.md"
}

mk alpha-1111 backlogged 2026-07-01 "Alpha does a thing."
mk beta-2222 planned 2026-07-02 "Beta does another thing."
mk gamma-3333 tasked 2026-07-03 "Gamma does a third thing." "because reasons"
mk delta-4444 implemented 2026-07-04 "Delta does a fourth thing."

out="$(sh "$LIST" "$WORK/t")"
echo "$out" | grep -q "^alpha-1111	backlogged	2026-07-01	Alpha does a thing.\$" && ok "default filter: backlogged listed, tab-separated" || bad "default filter — got: $out"
echo "$out" | grep -q "beta-2222" && bad "default filter excludes planned" || ok "default filter excludes planned"
echo "$out" | grep -q "gamma-3333" && bad "default filter excludes tasked" || ok "default filter excludes tasked"
echo "$out" | grep -q "delta-4444" && bad "default filter excludes implemented" || ok "default filter excludes implemented"

out="$(sh "$LIST" --status planned,tasked "$WORK/t")"
echo "$out" | grep -q "beta-2222" && ok "--status widens to planned" || bad "--status planned,tasked missing beta — got: $out"
echo "$out" | grep -q "gamma-3333" && ok "--status widens to tasked" || bad "--status planned,tasked missing gamma — got: $out"
echo "$out" | grep -q "alpha-1111" && bad "--status planned,tasked should exclude backlogged" || ok "--status planned,tasked excludes backlogged"
echo "$out" | grep -q "delta-4444" && bad "--status planned,tasked should exclude implemented" || ok "--status planned,tasked excludes implemented"

out="$(sh "$LIST" --all "$WORK/t")"
for s in alpha-1111 beta-2222 gamma-3333 delta-4444; do
  echo "$out" | grep -q "$s" && ok "--all includes $s" || bad "--all missing $s — got: $out"
done

# Why: line must not leak into the description column
echo "$out" | grep -q "gamma-3333	tasked	2026-07-03	Gamma does a third thing.\$" && ok "Why: line excluded from description" || bad "Why: line leaked — got: $out"

# empty/no dir: silent success
mkdir -p "$WORK/empty/.project"
sh "$LIST" "$WORK/empty" >/dev/null 2>&1 && ok "no features dir -> exit 0 silent" || bad "no features dir -> exit 0"

out="$(sh "$LIST" "$WORK/empty")"
[ -z "$out" ] && ok "no features dir -> no output" || bad "no features dir -> no output — got: $out"

exit "$fail"
