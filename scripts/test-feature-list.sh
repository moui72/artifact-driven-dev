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

mk() { # slug status logged description-line [why-line] [epic]
  {
    printf -- '---\nslug: %s\nstatus: %s\nlogged: %s\n' "$1" "$2" "$3"
    if [ -n "${6:-}" ]; then printf -- 'epic: %s\n' "$6"; fi
    printf -- '---\n'
    printf -- '%s\n' "$4"
    if [ -n "${5:-}" ]; then printf -- 'Why: %s\n' "$5"; fi
  } > "$F/$1.md"
}

mk alpha-1111 backlogged 2026-07-01 "Alpha does a thing."
mk beta-2222 planned 2026-07-02 "Beta does another thing."
mk gamma-3333 tasked 2026-07-03 "Gamma does a third thing." "because reasons"
mk delta-4444 implemented 2026-07-04 "Delta does a fourth thing."

out="$(sh "$LIST" "$WORK/t")"
echo "$out" | grep -q "^alpha-1111	backlogged	2026-07-01	Alpha does a thing.	\$" && ok "default filter: backlogged listed, tab-separated" || bad "default filter — got: $out"
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
echo "$out" | grep -q "gamma-3333	tasked	2026-07-03	Gamma does a third thing.	\$" && ok "Why: line excluded from description" || bad "Why: line leaked — got: $out"

out="$(sh "$LIST" --all "$WORK/t")"
echo "$out" | grep -q "^alpha-1111	backlogged	2026-07-01	Alpha does a thing.	\$" && ok "epic column: empty for unset epic" || bad "epic column empty — got: $out"

# epic column: fifth tab-separated field, populated when set
mk epsilon-5555 backlogged 2026-07-05 "Epsilon does a fifth thing." "" epic-a
out="$(sh "$LIST" --all "$WORK/t")"
echo "$out" | grep -q "^epsilon-5555	backlogged	2026-07-05	Epsilon does a fifth thing.	epic-a\$" && ok "epic column: populated when set" || bad "epic column populated — got: $out"

mk zeta-6666 backlogged 2026-07-06 "Zeta does a sixth thing." "" epic-a
mk eta-7777 planned 2026-07-07 "Eta does a seventh thing." "" epic-b

out="$(sh "$LIST" --epic epic-a "$WORK/t")"
echo "$out" | grep -q "epsilon-5555" && ok "--epic epic-a includes epsilon-5555 (default backlogged filter)" || bad "--epic epic-a missing epsilon-5555 — got: $out"
echo "$out" | grep -q "zeta-6666" && ok "--epic epic-a includes zeta-6666 (default backlogged filter)" || bad "--epic epic-a missing zeta-6666 — got: $out"
echo "$out" | grep -q "eta-7777" && bad "--epic epic-a should exclude eta-7777 (different epic)" || ok "--epic epic-a excludes eta-7777"

out="$(sh "$LIST" --all --epic epic-a "$WORK/t")"
echo "$out" | grep -q "epsilon-5555" && ok "--all --epic epic-a includes epsilon-5555" || bad "--all --epic epic-a missing epsilon-5555 — got: $out"
echo "$out" | grep -q "zeta-6666" && ok "--all --epic epic-a includes zeta-6666" || bad "--all --epic epic-a missing zeta-6666 — got: $out"
echo "$out" | grep -q "eta-7777" && bad "--all --epic epic-a should exclude eta-7777 (different epic)" || ok "--all --epic epic-a excludes eta-7777"

out="$(sh "$LIST" --status planned,tasked --epic epic-b "$WORK/t")"
echo "$out" | grep -q "eta-7777" && ok "--status planned,tasked --epic epic-b includes eta-7777" || bad "--status+--epic composition — got: $out"

# empty/no dir: silent success
mkdir -p "$WORK/empty/.project"
sh "$LIST" "$WORK/empty" >/dev/null 2>&1 && ok "no features dir -> exit 0 silent" || bad "no features dir -> exit 0"

out="$(sh "$LIST" "$WORK/empty")"
[ -z "$out" ] && ok "no features dir -> no output" || bad "no features dir -> no output — got: $out"

exit "$fail"
