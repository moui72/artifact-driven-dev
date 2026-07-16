#!/usr/bin/env sh
# NOTE: despite the "test-" prefix (kept for this repo's existing
# glob-discovered pre-commit/CI naming convention), this file is itself a
# check script, not a test of another script — it mirrors scripts/lint-project.sh
# and scripts/lint-docs.sh in that respect. It also carries fixture-based
# self-tests (like this repo's other test-*.sh files) proving its own
# detection logic works, then ends with a real-repo assertion that doubles
# as the actual CI/pre-commit check.
#
# What it checks: every script name referenced by a `.claude/skills/*/SKILL.md`
# (via a literal `ardd-scripts/<name>.sh` path) or by install.sh's own
# `chmod +x` argument list is the "expected" set of scripts that should ship
# to a target project. install.sh's `cp ... scripts/<name>.sh ...` lines are
# the "actual" set. Anything expected but not actually copied is a packaging
# gap (the F001 class of bug this exists to prevent a repeat of).
#
# Usage: ./scripts/test-install-manifest-complete.sh
# Exit 0 if clean (fixtures behave as expected AND the real repo has no gap),
# 1 otherwise.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# check_manifest <repo-dir>: prints missing script names (one per line) to
# stdout, exits 0 if none missing, 1 if any are missing.
check_manifest() {
  repo="$1"
  expected="$(
    { grep -rho 'ardd-scripts/[A-Za-z0-9_-]*\.sh' "$repo"/skills/*/SKILL.md 2>/dev/null \
        | sed 's#.*/##';
      grep -o '"\$ARDD_SCRIPTS_DIR/[A-Za-z0-9_-]*\.sh"' "$repo/install.sh" 2>/dev/null \
        | sed 's#.*/##; s#\.sh".*#.sh#'; } | sort -u
  )"
  actual="$(
    grep -o 'scripts/[A-Za-z0-9_-]*\.sh"' "$repo/install.sh" 2>/dev/null \
      | sed 's#scripts/##; s#"##' | sort -u
  )"
  actual_sp="$(echo "$actual" | tr '\n' ' ')"
  missing=""
  for name in $expected; do
    case " $actual_sp " in
      *" $name "*) ;;
      *) missing="$missing $name" ;;
    esac
  done
  missing="$(echo "$missing" | sed 's/^ *//')"
  if [ -n "$missing" ]; then
    for m in $missing; do echo "$m"; done
    return 1
  fi
  return 0
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# --- Fixture 1: incomplete manifest -> reports the missing script ---
F1="$WORK/incomplete"
mkdir -p "$F1/skills/ardd-foo" "$F1/skills/ardd-bar"
cat > "$F1/skills/ardd-foo/SKILL.md" <<'EOF'
---
name: ardd-foo
description: Uses foo-tool.
---
Run `.claude/skills/ardd-scripts/foo-tool.sh` for the deterministic part.
EOF
cat > "$F1/skills/ardd-bar/SKILL.md" <<'EOF'
---
name: ardd-bar
description: Uses bar-tool.
---
Run `.claude/skills/ardd-scripts/bar-tool.sh` too.
EOF
cat > "$F1/install.sh" <<'EOF'
#!/usr/bin/env sh
cp "$SCRIPT_DIR/scripts/bar-tool.sh" "$ARDD_SCRIPTS_DIR/bar-tool.sh"
chmod +x "$ARDD_SCRIPTS_DIR/bar-tool.sh"
EOF

if out1="$(check_manifest "$F1" 2>&1)"; then rc1=0; else rc1=$?; fi
if [ "$rc1" -ne 0 ] && echo "$out1" | grep -qx 'foo-tool.sh'; then
  ok "fixture: incomplete manifest reports the missing script by name"
else
  bad "fixture: incomplete manifest should report foo-tool.sh missing — got rc=$rc1 out=$out1"
fi
if echo "$out1" | grep -qx 'bar-tool.sh'; then
  bad "fixture: incomplete manifest should NOT report bar-tool.sh (it is installed) — got: $out1"
else
  ok "fixture: incomplete manifest does not report the already-installed script"
fi

# --- Fixture 2: complete manifest -> reports nothing ---
F2="$WORK/complete"
mkdir -p "$F2/skills/ardd-foo" "$F2/skills/ardd-bar"
cp "$F1/skills/ardd-foo/SKILL.md" "$F2/skills/ardd-foo/SKILL.md"
cp "$F1/skills/ardd-bar/SKILL.md" "$F2/skills/ardd-bar/SKILL.md"
cat > "$F2/install.sh" <<'EOF'
#!/usr/bin/env sh
cp "$SCRIPT_DIR/scripts/foo-tool.sh" "$ARDD_SCRIPTS_DIR/foo-tool.sh"
cp "$SCRIPT_DIR/scripts/bar-tool.sh" "$ARDD_SCRIPTS_DIR/bar-tool.sh"
chmod +x "$ARDD_SCRIPTS_DIR/foo-tool.sh" "$ARDD_SCRIPTS_DIR/bar-tool.sh"
EOF

if out2="$(check_manifest "$F2" 2>&1)"; then rc2=0; else rc2=$?; fi
if [ "$rc2" -eq 0 ] && [ -z "$out2" ]; then
  ok "fixture: complete manifest reports nothing"
else
  bad "fixture: complete manifest should report nothing — got rc=$rc2 out=$out2"
fi

# --- Real-repo assertion: this actual repo currently has no known gap ---
if real_out="$(check_manifest "$REPO_DIR" 2>&1)"; then real_rc=0; else real_rc=$?; fi
if [ "$real_rc" -eq 0 ] && [ -z "$real_out" ]; then
  ok "real repo: no missing scripts in install.sh's manifest"
else
  bad "real repo: install.sh is missing a script install.sh manifest for: $real_out"
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "test-install-manifest-complete: all cases pass"
