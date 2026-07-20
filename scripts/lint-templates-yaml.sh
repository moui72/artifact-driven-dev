#!/usr/bin/env sh
# Source-side check: every shipped YAML template and workflow must actually
# parse as YAML. Motivated by ff0c F002 — templates/ardd-badge-workflow.yml
# shipped with a column-0 heredoc inside a `run: |` block, which is invalid
# YAML that GitHub Actions rejects outright, and nothing here caught it.
# Parses templates/*.yml and .github/workflows/*.yml via python3+PyYAML
# (CI always has both); when python3 or PyYAML is unavailable locally,
# prints a clear skip notice and exits 0 — never a false failure.
# Usage: ./scripts/lint-templates-yaml.sh
# Exit 0 if clean (or skipped), 1 if any file fails to parse.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if ! command -v python3 >/dev/null 2>&1; then
  echo "lint-templates-yaml: skipped — python3 not available (CI runs it)."
  exit 0
fi
if ! python3 -c 'import yaml' 2>/dev/null; then
  echo "lint-templates-yaml: skipped — PyYAML not available (CI runs it)."
  exit 0
fi

fail=0
checked=0

for f in "$REPO_DIR"/templates/*.yml "$REPO_DIR"/.github/workflows/*.yml; do
  [ -f "$f" ] || continue
  checked=$((checked + 1))
  if err="$(python3 -c '
import sys, yaml
try:
    yaml.safe_load(open(sys.argv[1]))
except yaml.YAMLError as e:
    print(e)
    sys.exit(1)
' "$f" 2>&1)"; then
    :
  else
    echo "lint-templates-yaml: FAIL ${f#"$REPO_DIR"/}"
    printf '%s\n' "$err" | sed 's/^/  /'
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "lint-templates-yaml: clean — $checked YAML file(s) parse."
fi

exit "$fail"
