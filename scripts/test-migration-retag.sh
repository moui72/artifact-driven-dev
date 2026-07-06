#!/usr/bin/env sh
# Regression test for migrations/0004-retag-features-refs.sh: rewrites
# bracket-tags naming the removed `features` artifact in tasks/feedback
# files — drops `features` from multi-name tags, removes the whole tag
# when it named only `features`, leaves every other tag untouched.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MIG="$(dirname "$SCRIPT_DIR")/migrations/0004-retag-features-refs.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

T="$WORK/t/.project"
mkdir -p "$T/tasks" "$T/feedback"
cat > "$T/tasks/tasks-x-aaaa.md" <<'EOF'
---
plan: plan-x.md
generated: 2026-07-06
status: completed
---
# Tasks
- [x] T001 [artifacts: features] Update the register entry
- [x] T002 [artifacts: datamodel, features] Touch both
- [x] T003 [artifacts: datamodel] Unrelated, must survive
- [x] T004 No tag at all
EOF
cat > "$T/feedback/feedback-y-bbbb.md" <<'EOF'
---
status: planned
created: 2026-07-06
plan: plan-x.md
---
# Feedback
- [x] F001 Something [artifacts: features]
- [x] F002 Something else [artifacts: features, ui]
EOF

sh "$MIG" "$WORK/t" >/dev/null

TF="$T/tasks/tasks-x-aaaa.md"; FF="$T/feedback/feedback-y-bbbb.md"
grep -q 'T001 Update the register entry' "$TF" && ok "solo tag removed entirely" || bad "solo tag removed entirely — $(grep T001 "$TF")"
grep -q 'T002 \[artifacts: datamodel\] Touch both' "$TF" && ok "features dropped from multi-tag" || bad "features dropped from multi-tag — $(grep T002 "$TF")"
grep -q 'T003 \[artifacts: datamodel\] Unrelated' "$TF" && ok "unrelated tag survives" || bad "unrelated tag survives"
grep -q 'F001 Something$' "$FF" && ok "feedback solo tag removed" || bad "feedback solo tag removed — $(grep F001 "$FF")"
grep -q 'F002 Something else \[artifacts: ui\]' "$FF" && ok "feedback multi-tag keeps ui" || bad "feedback multi-tag keeps ui — $(grep F002 "$FF")"

# idempotent second run
cp "$TF" "$WORK/first.txt"
sh "$MIG" "$WORK/t" >/dev/null
diff -q "$TF" "$WORK/first.txt" >/dev/null && ok "idempotent" || bad "idempotent"

# no .project/tasks or feedback: no-op success
mkdir -p "$WORK/empty/.project"
sh "$MIG" "$WORK/empty" >/dev/null && ok "empty project no-op" || bad "empty project no-op"

exit "$fail"
