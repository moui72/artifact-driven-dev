#!/usr/bin/env sh
# Regression test for lint-templates-yaml.sh: YAML-parse check over shipped
# templates/*.yml and .github/workflows/*.yml. Builds fixture repo trees in
# a temp dir — one with a valid workflow, one with the exact failure that
# motivated the check (ff0c F002): a column-0 heredoc body inside a
# `run: |` block scalar, which is invalid YAML.
# Like the script under test, this skips cleanly (exit 0, with a notice)
# when python3/PyYAML is unavailable locally — CI always has both.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LINT="$SCRIPT_DIR/lint-templates-yaml.sh"

if ! command -v python3 >/dev/null 2>&1 || ! python3 -c 'import yaml' 2>/dev/null; then
  echo "test-lint-templates-yaml: skipped — python3/PyYAML not available (CI runs it)."
  exit 0
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

make_fixture() { # $1=name -> prints fixture root with scripts/ + templates/
  f="$WORK/$1"
  mkdir -p "$f/scripts" "$f/templates" "$f/.github/workflows"
  cp "$LINT" "$f/scripts/lint-templates-yaml.sh"
  chmod +x "$f/scripts/lint-templates-yaml.sh"
  echo "$f"
}

valid_workflow() { # $1=path
  cat > "$1" <<'EOF'
name: valid
on:
  push:
    branches: [main]
jobs:
  a:
    runs-on: ubuntu-latest
    steps:
      - name: emit
        run: |
          cat > out.json <<JSON
          {
            "ok": true
          }
          JSON
EOF
}

broken_workflow() { # $1=path — column-0 heredoc inside a run: | block
  cat > "$1" <<'EOF'
name: broken
on: push
jobs:
  a:
    runs-on: ubuntu-latest
    steps:
      - name: emit
        run: |
          cat > out.json <<JSON
{
  "ok": false
}
JSON
EOF
}

# --- Case 1: all files valid -> exit 0, clean line ---
f="$(make_fixture case1)"
valid_workflow "$f/templates/good.yml"
valid_workflow "$f/.github/workflows/ci.yml"
if out="$("$f/scripts/lint-templates-yaml.sh")"; then
  ok "case1: valid fixtures exit 0"
else
  bad "case1: valid fixtures exit 0"
fi
case "$out" in
  *"clean"*) ok "case1: clean notice printed" ;;
  *) bad "case1: clean notice printed" ;;
esac

# --- Case 2: column-0 heredoc in templates/*.yml -> exit 1, file named,
# parser error shown ---
f="$(make_fixture case2)"
broken_workflow "$f/templates/bad-workflow.yml"
if out="$("$f/scripts/lint-templates-yaml.sh")"; then
  bad "case2: broken template exits 1"
else
  ok "case2: broken template exits 1"
fi
case "$out" in
  *"FAIL templates/bad-workflow.yml"*) ok "case2: failing file named" ;;
  *) bad "case2: failing file named"; printf '%s\n' "$out" ;;
esac
case "$out" in
  *"yaml"*|*"scanning"*|*"expected"*) ok "case2: parser error included" ;;
  *) bad "case2: parser error included"; printf '%s\n' "$out" ;;
esac

# --- Case 3: broken file in .github/workflows/ is caught too ---
f="$(make_fixture case3)"
valid_workflow "$f/templates/good.yml"
broken_workflow "$f/.github/workflows/bad.yml"
if "$f/scripts/lint-templates-yaml.sh" >/dev/null 2>&1; then
  bad "case3: broken workflow under .github/workflows exits 1"
else
  ok "case3: broken workflow under .github/workflows exits 1"
fi

# --- Case 4: no YAML files at all -> exit 0 (nothing to check) ---
f="$(make_fixture case4)"
rm -rf "$f/templates" "$f/.github"
if "$f/scripts/lint-templates-yaml.sh" >/dev/null; then
  ok "case4: no YAML files exits 0"
else
  bad "case4: no YAML files exits 0"
fi

exit "$fail"
