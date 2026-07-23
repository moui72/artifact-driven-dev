#!/usr/bin/env sh
# Regression test for ardd-state.sh — the deterministic state-mutation
# dispatcher (constitution Principle II: prose decides when, scripts
# write). Each subcommand gets good + bad cases against throwaway
# .project/ fixtures under a temp dir.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE="$SCRIPT_DIR/ardd-state.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()   { echo "ok: $1"; }
bad()  { echo "FAIL: $1"; fail=1; }

# assert_exit <label> <expected-exit> <actual-exit>
assert_exit() {
  [ "$3" -eq "$2" ] && ok "$1" || bad "$1 — expected exit $2, got $3"
}
# assert_grep <label> <pattern> <file-or-string-mode:file> <target>
assert_file_grep() {
  if grep -q "$2" "$3"; then ok "$1"; else bad "$1 — pattern '$2' not in $3"; fi
}

# --- Case: no arguments prints usage and exits 2 ---
set +e
out="$(sh "$STATE" 2>&1)"; rc=$?
set -e
assert_exit "no-args exits 2" 2 "$rc"
case "$out" in
  *usage*|*Usage*) ok "no-args prints usage" ;;
  *) bad "no-args prints usage — got: $out" ;;
esac

# --- Case: unknown subcommand exits 2 ---
set +e
out="$(sh "$STATE" no-such-subcommand 2>&1)"; rc=$?
set -e
assert_exit "unknown subcommand exits 2" 2 "$rc"

# --- slug: kebab sanitization ---
assert_eq() { [ "$3" = "$2" ] && ok "$1" || bad "$1 — expected '$2', got '$3'"; }

assert_eq "slug: simple"      "add-user-auth" "$(sh "$STATE" slug 'Add User Auth')"
assert_eq "slug: punctuation" "fix-api-v2-parsing" "$(sh "$STATE" slug 'fix: API/v2 (parsing!)')"
assert_eq "slug: collapse runs + trim edges" "a-b" "$(sh "$STATE" slug '--a---b--')"
long="$(sh "$STATE" slug 'this is a very long feature description that keeps going and going')"
[ "${#long}" -le 30 ] && ok "slug: truncated to <=30" || bad "slug: truncated to <=30 — got ${#long} chars: $long"
case "$long" in *-) bad "slug: no trailing dash after truncation — got '$long'" ;; *) ok "slug: no trailing dash after truncation" ;; esac
set +e
sh "$STATE" slug '' >/dev/null 2>&1; rc=$?
set -e
assert_exit "slug: empty input exits 2" 2 "$rc"
set +e
sh "$STATE" slug '!!!' >/dev/null 2>&1; rc=$?
set -e
assert_exit "slug: no alphanumerics exits 1" 1 "$rc"

# --- mint: filename minting ---
today="$(date +%Y-%m-%d)"
p1="$(sh "$STATE" mint plan auth-flow)"
case "$p1" in
  plan-auth-flow-$today-[0-9a-f][0-9a-f][0-9a-f][0-9a-f].md) ok "mint plan: date + 4-hex token" ;;
  *) bad "mint plan: date + 4-hex token — got '$p1'" ;;
esac
p2="$(sh "$STATE" mint plan auth-flow)"
[ "$p1" != "$p2" ] && ok "mint plan: unique across same-day calls" || bad "mint plan: unique across same-day calls — got '$p1' twice"
t1="$(sh "$STATE" mint tasks auth-flow)"
case "$t1" in
  tasks-auth-flow-[0-9a-f][0-9a-f][0-9a-f][0-9a-f].md) ok "mint tasks: slug + 4-hex" ;;
  *) bad "mint tasks: slug + 4-hex — got '$t1'" ;;
esac
t2="$(sh "$STATE" mint tasks auth-flow)"
[ "$t1" != "$t2" ] && ok "mint tasks: tokens unique across calls" || bad "mint tasks: tokens unique across calls — got '$t1' twice"
f1="$(sh "$STATE" mint feedback repo-critique)"
case "$f1" in
  feedback-repo-critique-[0-9a-f][0-9a-f][0-9a-f][0-9a-f].md) ok "mint feedback: slug + 4-hex" ;;
  *) bad "mint feedback: slug + 4-hex — got '$f1'" ;;
esac
r1="$(sh "$STATE" mint research sqlite-fts)"
case "$r1" in
  research-sqlite-fts-$today-[0-9a-f][0-9a-f][0-9a-f][0-9a-f].md) ok "mint research: date + 4-hex token" ;;
  *) bad "mint research: date + 4-hex token — got '$r1'" ;;
esac
r2="$(sh "$STATE" mint research sqlite-fts)"
[ "$r1" != "$r2" ] && ok "mint research: unique across same-day calls" || bad "mint research: unique across same-day calls — got '$r1' twice"
set +e
sh "$STATE" mint nope x >/dev/null 2>&1; rc=$?
set -e
assert_exit "mint: unknown kind exits 2" 2 "$rc"
set +e
sh "$STATE" mint plan 'Not A Slug!' >/dev/null 2>&1; rc=$?
set -e
assert_exit "mint: rejects non-kebab slug" 1 "$rc"

# --- plan-flip ---
PLANS="$WORK/p1/.project/plans"; mkdir -p "$PLANS"
cat > "$PLANS/plan-x-2026-07-06.md" <<'EOF'
---
status: draft        # draft -> approved -> superseded
branch: x
created: 2026-07-06
---
# Plan
EOF
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" approved
assert_file_grep "plan-flip: draft->approved" "^status: *approved" "$PLANS/plan-x-2026-07-06.md"
assert_file_grep "plan-flip: trailing comment preserved" "# draft -> approved -> superseded" "$PLANS/plan-x-2026-07-06.md"
set +e
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" approved >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: same-state is a no-op success" 0 "$rc"
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" superseded >/dev/null
assert_file_grep "plan-flip: approved->superseded" "^status: *superseded" "$PLANS/plan-x-2026-07-06.md"
set +e
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" approved >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: superseded->approved refused" 1 "$rc"
set +e
sh "$STATE" plan-flip "$PLANS/no-such-plan.md" approved >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: missing file refused" 1 "$rc"
printf '# no frontmatter\n' > "$PLANS/plan-bad-2026-07-06.md"
set +e
sh "$STATE" plan-flip "$PLANS/plan-bad-2026-07-06.md" approved >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: missing status field refused" 1 "$rc"
set +e
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" bogus >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: unknown target status usage error" 2 "$rc"

# --- tasks-flip: completed refuses unchecked tasks ---
TASKS="$WORK/p1/.project/tasks"; mkdir -p "$TASKS"
TF_UNCHECKED="$TASKS/tasks-y-cd34.md"
cat > "$TF_UNCHECKED" <<'EOF'
---
plan: plan-x-2026-07-06.md
generated: 2026-07-06
status: in-progress   # generating -> ready -> in-progress -> completed
---
# Tasks
## Phase 1
- [x] T001 First task
- [ ] T002 Second task, still open
EOF
set +e
sh "$STATE" tasks-flip "$TF_UNCHECKED" completed >/dev/null 2>&1; rc=$?
set -e
assert_exit "tasks-flip: completed refuses with unchecked tasks" 1 "$rc"
assert_file_grep "tasks-flip: refused, status unchanged" "^status: *in-progress" "$TF_UNCHECKED"
sh "$STATE" task-check "$TF_UNCHECKED" T002 >/dev/null
sh "$STATE" tasks-flip "$TF_UNCHECKED" completed >/dev/null
assert_file_grep "tasks-flip: completed succeeds once all tasks checked" "^status: *completed" "$TF_UNCHECKED"

# --- tasks-flip / task-check / next-task ---
TF="$TASKS/tasks-x-ab12.md"
cat > "$TF" <<'EOF'
---
plan: plan-x-2026-07-06.md
generated: 2026-07-06
status: generating   # generating -> ready -> in-progress -> completed
---
# Tasks
## Phase 1
- [ ] T001 [artifacts: constitution] First task
- [ ] T002 [parallel] Second task
EOF
sh "$STATE" tasks-flip "$TF" ready >/dev/null
assert_file_grep "tasks-flip: generating->ready" "^status: *ready" "$TF"
set +e
sh "$STATE" tasks-flip "$TF" completed >/dev/null 2>&1; rc=$?
set -e
assert_exit "tasks-flip: ready->completed refused (skips in-progress)" 1 "$rc"
sh "$STATE" tasks-flip "$TF" in-progress >/dev/null
assert_file_grep "tasks-flip: ready->in-progress" "^status: *in-progress" "$TF"

nt="$(sh "$STATE" next-task "$TF")"
case "$nt" in
  *T001*) ok "next-task: finds first unchecked" ;;
  *) bad "next-task: finds first unchecked — got '$nt'" ;;
esac
sh "$STATE" task-check "$TF" T001 >/dev/null
assert_file_grep "task-check: T001 checked" "^- \[x\] T001 " "$TF"
set +e
sh "$STATE" task-check "$TF" T001 >/dev/null 2>&1; rc=$?
set -e
assert_exit "task-check: already-checked is no-op success" 0 "$rc"
set +e
sh "$STATE" task-check "$TF" T099 >/dev/null 2>&1; rc=$?
set -e
assert_exit "task-check: unknown task ID refused" 1 "$rc"

# --- task-check: colon-suffixed checkbox format gets a diagnostic message
# (F004), not the generic not-found one ---
CFILE="$WORK/colon-tasks.md"
printf -- '- [ ] T001: do the colon-suffixed thing\n' > "$CFILE"
set +e
out="$(sh "$STATE" task-check "$CFILE" T001 2>&1)"; rc=$?
set -e
assert_exit "task-check: colon-suffixed format refused" 1 "$rc"
case "$out" in
  *"found 'T001'"*"not in the expected"*)
    ok "task-check: colon-suffixed format gets the specific diagnostic message" ;;
  *)
    bad "task-check: colon-suffixed format gets the specific diagnostic message — got: $out" ;;
esac
case "$out" in
  *"no unchecked task"*)
    bad "task-check: colon-suffixed format should not use the old generic message" ;;
  *) : ;;
esac

nt="$(sh "$STATE" next-task "$TF")"
case "$nt" in
  *T002*) ok "next-task: advances to T002" ;;
  *) bad "next-task: advances to T002 — got '$nt'" ;;
esac
sh "$STATE" task-check "$TF" T002 >/dev/null
set +e
sh "$STATE" next-task "$TF" >/dev/null 2>&1; rc=$?
set -e
assert_exit "next-task: exit 1 when all complete" 1 "$rc"
sh "$STATE" tasks-flip "$TF" completed >/dev/null
assert_file_grep "tasks-flip: in-progress->completed" "^status: *completed" "$TF"
set +e
sh "$STATE" tasks-flip "$TF" abandoned >/dev/null 2>&1; rc=$?
set -e
assert_exit "tasks-flip: completed->abandoned refused" 1 "$rc"

# --- feedback-mark / feedback-planned ---
FB="$WORK/p1/.project/feedback"; mkdir -p "$FB"
FF="$FB/feedback-x-cd34.md"
cat > "$FF" <<'EOF'
---
status: open      # open -> planned
created: 2026-07-06
plan: null        # set to the consuming plan's filename once planned
---
# Feedback
## Bugs
- [ ] F001 Thing is broken [artifacts: constitution]
## UX
- [ ] F002 Thing is confusing
EOF
sh "$STATE" feedback-mark "$FF" F001 x >/dev/null
assert_file_grep "feedback-mark: F001 -> [x]" "^- \[x\] F001 " "$FF"
sh "$STATE" feedback-mark "$FF" F002 - >/dev/null
assert_file_grep "feedback-mark: F002 -> [-]" "^- \[-\] F002 " "$FF"
set +e
sh "$STATE" feedback-mark "$FF" F002 x >/dev/null 2>&1; rc=$?
set -e
assert_exit "feedback-mark: re-marking a resolved item refused" 1 "$rc"
set +e
sh "$STATE" feedback-mark "$FF" F009 x >/dev/null 2>&1; rc=$?
set -e
assert_exit "feedback-mark: unknown item refused" 1 "$rc"

FF2="$FB/feedback-y-ef56.md"
sed 's/status: open/status: open/' "$FF" > "$FF2"   # copy, all items resolved
sh "$STATE" feedback-planned "$FF2" plan-x-2026-07-06.md >/dev/null
assert_file_grep "feedback-planned: status flipped" "^status: *planned" "$FF2"
assert_file_grep "feedback-planned: plan stamped" "^plan: plan-x-2026-07-06.md" "$FF2"
cat > "$FF" <<'EOF'
---
status: open
created: 2026-07-06
plan: null
---
- [ ] F001 Unresolved item
EOF
set +e
sh "$STATE" feedback-planned "$FF" plan-x-2026-07-06.md >/dev/null 2>&1; rc=$?
set -e
assert_exit "feedback-planned: refused while items unresolved" 1 "$rc"

# --- feature-create / feature-flip / feature-field (CWD-relative .project/) ---
FPROJ="$WORK/p2"; mkdir -p "$FPROJ/.project"
( cd "$FPROJ" && printf 'Adds dark mode.\nWhy: users asked.\n' | sh "$STATE" feature-create dark-mode >/dev/null )
FEAT="$FPROJ/.project/features/dark-mode.md"
[ -f "$FEAT" ] && ok "feature-create: file created" || bad "feature-create: file created — missing $FEAT"
assert_file_grep "feature-create: slug field" "^slug: dark-mode" "$FEAT"
assert_file_grep "feature-create: backlogged" "^status: backlogged" "$FEAT"
assert_file_grep "feature-create: logged date" "^logged: $(date +%Y-%m-%d)" "$FEAT"
assert_file_grep "feature-create: body from stdin" "Adds dark mode." "$FEAT"
set +e
( cd "$FPROJ" && printf '' | sh "$STATE" feature-create dark-mode ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-create: duplicate slug refused" 1 "$rc"

# feature-create: confirmation prints the resolved absolute path written [feedback: F002]
fcout="$( cd "$FPROJ" && printf 'Adds night mode.\n' | sh "$STATE" feature-create night-mode )"
case "$fcout" in
  *" /"*/.project/features/night-mode.md*) ok "feature-create: confirmation prints resolved absolute path" ;;
  *) bad "feature-create: confirmation prints resolved absolute path — got: $fcout" ;;
esac

( cd "$FPROJ" && sh "$STATE" feature-flip dark-mode planned >/dev/null )
assert_file_grep "feature-flip: backlogged->planned" "^status: planned" "$FEAT"
set +e
( cd "$FPROJ" && sh "$STATE" feature-flip dark-mode implemented ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-flip: skipping stages refused" 1 "$rc"
set +e
( cd "$FPROJ" && sh "$STATE" feature-flip no-such-slug tasked ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-flip: unknown slug refused" 1 "$rc"

# retired: terminal, reachable only from implemented (constitution v1.6.0)
( cd "$FPROJ" && printf 'Old channel.\n' | sh "$STATE" feature-create old-channel >/dev/null )
RFEAT="$FPROJ/.project/features/old-channel.md"
( cd "$FPROJ" && sh "$STATE" feature-flip old-channel planned >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip old-channel tasked >/dev/null )
set +e
( cd "$FPROJ" && sh "$STATE" feature-flip old-channel retired ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-flip: tasked->retired refused" 1 "$rc"
assert_file_grep "feature-flip: still tasked after refusal" "^status: tasked" "$RFEAT"
( cd "$FPROJ" && sh "$STATE" feature-flip old-channel implemented >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip old-channel retired >/dev/null )
assert_file_grep "feature-flip: implemented->retired" "^status: retired" "$RFEAT"
set +e
( cd "$FPROJ" && sh "$STATE" feature-flip old-channel implemented ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-flip: out of retired refused" 1 "$rc"
assert_file_grep "feature-flip: retired is terminal" "^status: retired" "$RFEAT"

# rejected / subsumed: two new terminal states (constitution v1.12.0).
# rejected: reachable only from backlogged or planned, never from tasked
# (rejection is a pre-work decision only). subsumed: reachable from
# backlogged, planned, OR tasked (absorption can be noticed late).
( cd "$FPROJ" && printf 'Rejected idea.\n' | sh "$STATE" feature-create rejected-a >/dev/null )
RAFEAT="$FPROJ/.project/features/rejected-a.md"
( cd "$FPROJ" && sh "$STATE" feature-flip rejected-a rejected >/dev/null )
assert_file_grep "feature-flip: backlogged->rejected" "^status: rejected" "$RAFEAT"
set +e
( cd "$FPROJ" && sh "$STATE" feature-flip rejected-a planned ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-flip: rejected is terminal (refuses outbound)" 1 "$rc"
assert_file_grep "feature-flip: still rejected after refusal" "^status: rejected" "$RAFEAT"

( cd "$FPROJ" && printf 'Rejected idea 2.\n' | sh "$STATE" feature-create rejected-b >/dev/null )
RBFEAT="$FPROJ/.project/features/rejected-b.md"
( cd "$FPROJ" && sh "$STATE" feature-flip rejected-b planned >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip rejected-b rejected >/dev/null )
assert_file_grep "feature-flip: planned->rejected" "^status: rejected" "$RBFEAT"

( cd "$FPROJ" && printf 'Subsumed idea a.\n' | sh "$STATE" feature-create subsumed-a >/dev/null )
SAFEAT="$FPROJ/.project/features/subsumed-a.md"
( cd "$FPROJ" && sh "$STATE" feature-flip subsumed-a subsumed >/dev/null )
assert_file_grep "feature-flip: backlogged->subsumed" "^status: subsumed" "$SAFEAT"
set +e
( cd "$FPROJ" && sh "$STATE" feature-flip subsumed-a implemented ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-flip: subsumed is terminal (refuses outbound)" 1 "$rc"
assert_file_grep "feature-flip: still subsumed after refusal" "^status: subsumed" "$SAFEAT"

( cd "$FPROJ" && printf 'Subsumed idea b.\n' | sh "$STATE" feature-create subsumed-b >/dev/null )
SBFEAT="$FPROJ/.project/features/subsumed-b.md"
( cd "$FPROJ" && sh "$STATE" feature-flip subsumed-b planned >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip subsumed-b subsumed >/dev/null )
assert_file_grep "feature-flip: planned->subsumed" "^status: subsumed" "$SBFEAT"

( cd "$FPROJ" && printf 'Subsumed idea c.\n' | sh "$STATE" feature-create subsumed-c >/dev/null )
SCFEAT="$FPROJ/.project/features/subsumed-c.md"
( cd "$FPROJ" && sh "$STATE" feature-flip subsumed-c planned >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip subsumed-c tasked >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip subsumed-c subsumed >/dev/null )
assert_file_grep "feature-flip: tasked->subsumed" "^status: subsumed" "$SCFEAT"

# illegal transitions into rejected/subsumed from implemented
( cd "$FPROJ" && printf 'Implemented thing.\n' | sh "$STATE" feature-create impl-thing >/dev/null )
IFEAT="$FPROJ/.project/features/impl-thing.md"
( cd "$FPROJ" && sh "$STATE" feature-flip impl-thing planned >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip impl-thing tasked >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip impl-thing implemented >/dev/null )
set +e
( cd "$FPROJ" && sh "$STATE" feature-flip impl-thing rejected ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-flip: implemented->rejected refused" 1 "$rc"
set +e
( cd "$FPROJ" && sh "$STATE" feature-flip impl-thing subsumed ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-flip: implemented->subsumed refused" 1 "$rc"

# asymmetry: tasked->rejected is NOT a legal edge (only tasked->subsumed is)
( cd "$FPROJ" && printf 'Tasked thing.\n' | sh "$STATE" feature-create tasked-thing >/dev/null )
TFEAT="$FPROJ/.project/features/tasked-thing.md"
( cd "$FPROJ" && sh "$STATE" feature-flip tasked-thing planned >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip tasked-thing tasked >/dev/null )
set +e
( cd "$FPROJ" && sh "$STATE" feature-flip tasked-thing rejected ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-flip: tasked->rejected refused (asymmetry with subsumed)" 1 "$rc"
assert_file_grep "feature-flip: still tasked after asymmetry refusal" "^status: tasked" "$TFEAT"

# --- feature-flip tasked->implemented completion cross-check (F003) ---
# A feature bound to a tasks file via `tasks:` frontmatter must not flip
# tasked->implemented unless that tasks file is status: completed.
mkdir -p "$FPROJ/.project/tasks"
( cd "$FPROJ" && printf 'Adds widgets.\n' | sh "$STATE" feature-create widget-panel >/dev/null )
WFEAT="$FPROJ/.project/features/widget-panel.md"
( cd "$FPROJ" && sh "$STATE" feature-flip widget-panel planned >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip widget-panel tasked >/dev/null )
WTASKS="$FPROJ/.project/tasks/tasks-widget-panel-aaaa.md"
cat > "$WTASKS" <<'EOF'
---
plan: plan-widget-panel-2026-07-06.md
generated: 2026-07-06
status: in-progress
---
- [ ] T001 do the thing
EOF
( cd "$FPROJ" && sh "$STATE" feature-field widget-panel tasks tasks-widget-panel-aaaa.md >/dev/null )
set +e
out="$( cd "$FPROJ" && sh "$STATE" feature-flip widget-panel implemented 2>&1 )"; rc=$?
set -e
assert_exit "feature-flip: tasked->implemented refused, tasks file not completed" 1 "$rc"
assert_file_grep "feature-flip: still tasked after refusal (bound tasks incomplete)" "^status: tasked" "$WFEAT"
case "$out" in
  *tasks-widget-panel-aaaa.md*in-progress*) ok "feature-flip: refusal names the tasks file and its actual status" ;;
  *) bad "feature-flip: refusal names the tasks file and its actual status — got: $out" ;;
esac
sed -i.arddbak 's/^status: in-progress/status: completed/' "$WTASKS" && rm -f "$WTASKS.arddbak"
( cd "$FPROJ" && sh "$STATE" feature-flip widget-panel implemented >/dev/null )
assert_file_grep "feature-flip: tasked->implemented succeeds once tasks file is completed" "^status: implemented" "$WFEAT"

# A feature with no tasks: field flips freely (no regression).
( cd "$FPROJ" && printf 'No tasks binding.\n' | sh "$STATE" feature-create no-binding >/dev/null )
NBFEAT="$FPROJ/.project/features/no-binding.md"
( cd "$FPROJ" && sh "$STATE" feature-flip no-binding planned >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip no-binding tasked >/dev/null )
( cd "$FPROJ" && sh "$STATE" feature-flip no-binding implemented >/dev/null )
assert_file_grep "feature-flip: no tasks: field flips freely to implemented" "^status: implemented" "$NBFEAT"

( cd "$FPROJ" && sh "$STATE" feature-field dark-mode plan plan-dark-mode-2026-07-06.md >/dev/null )
assert_file_grep "feature-field: plan added" "^plan: plan-dark-mode-2026-07-06.md" "$FEAT"
( cd "$FPROJ" && sh "$STATE" feature-field dark-mode plan plan-other-2026-07-07.md >/dev/null )
assert_file_grep "feature-field: plan replaced" "^plan: plan-other-2026-07-07.md" "$FEAT"
n="$(grep -c '^plan:' "$FEAT")"
[ "$n" -eq 1 ] && ok "feature-field: no duplicate keys" || bad "feature-field: no duplicate keys — found $n plan: lines"
( cd "$FPROJ" && sh "$STATE" feature-field dark-mode gh_issue 42 >/dev/null )
assert_file_grep "feature-field: gh_issue added" "^gh_issue: 42" "$FEAT"
set +e
( cd "$FPROJ" && sh "$STATE" feature-field dark-mode owner bob ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-field: unknown key usage error" 2 "$rc"

( cd "$FPROJ" && sh "$STATE" feature-field dark-mode epic epic-ui >/dev/null )
assert_file_grep "feature-field: epic added" "^epic: epic-ui" "$FEAT"
( cd "$FPROJ" && sh "$STATE" feature-field dark-mode epic epic-onboarding >/dev/null )
assert_file_grep "feature-field: epic replaced" "^epic: epic-onboarding" "$FEAT"
n="$(grep -c '^epic:' "$FEAT")"
[ "$n" -eq 1 ] && ok "feature-field: epic no duplicate keys" || bad "feature-field: epic no duplicate keys — found $n epic: lines"
set +e
( cd "$FPROJ" && sh "$STATE" feature-field dark-mode bogus xyz ) >/dev/null 2>&1; rc=$?
set -e
assert_exit "feature-field: unrecognized key (bogus) still refused" 2 "$rc"

# --- stamp ---
ART="$WORK/p2/.project/artifacts"; mkdir -p "$ART"
AF="$ART/datamodel.md"
cat > "$AF" <<'EOF'
---
name: datamodel
status: stable
last_updated: 2026-07-01
---
# Datamodel
EOF
sh "$STATE" stamp "$AF" last_updated 2026-07-06 >/dev/null
assert_file_grep "stamp: last_updated replaced" "^last_updated: 2026-07-06" "$AF"

# stamp: confirmation prints the resolved absolute path of <file>, even
# when <file> is given as a relative path [feedback: F002]
stout="$( cd "$ART" && sh "$STATE" stamp datamodel.md last_updated 2026-07-07 )"
case "$stout" in
  *" /"*/.project/artifacts/datamodel.md*) ok "stamp: confirmation prints resolved absolute path" ;;
  *) bad "stamp: confirmation prints resolved absolute path — got: $stout" ;;
esac

set +e
sh "$STATE" stamp "$AF" last_updated 'not-a-date' >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: bad date refused" 1 "$rc"
sh "$STATE" stamp "$AF" diagram_status stale >/dev/null
assert_file_grep "stamp: diagram_status added into frontmatter" "^diagram_status: stale" "$AF"
fmend="$(grep -n '^---$' "$AF" | sed -n 2p | cut -d: -f1)"
dsline="$(grep -n '^diagram_status:' "$AF" | cut -d: -f1)"
[ "$dsline" -lt "$fmend" ] && ok "stamp: added inside frontmatter" || bad "stamp: added inside frontmatter — line $dsline vs closing --- at $fmend"
set +e
sh "$STATE" stamp "$AF" diagram_status bogus >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: bad diagram_status refused" 2 "$rc"
set +e
sh "$STATE" stamp "$AF" name other >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: unknown key usage error" 2 "$rc"

# stamp: trailing extra argument must be rejected as a usage error, not
# silently dropped [feedback: feedback-ardd-state-stamp-silent-extra-args-1625.md F001]
set +e
stout="$(sh "$STATE" stamp "$AF" last_updated 2026-07-06 extra-arg 2>&1)"; rc=$?
set -e
assert_exit "stamp: extra trailing argument rejected" 2 "$rc"
case "$stout" in
  *"extra-arg"*) ok "stamp: extra-argument error names the unexpected argument" ;;
  *) bad "stamp: extra-argument error names the unexpected argument — got: $stout" ;;
esac

# stamp next_step_prompt — boolean-validated, add + replace
CF="$ART/constitution.md"
cat > "$CF" <<'EOF'
---
status: stable
last_updated: 2026-07-01
workflow_mode: solo
---
# Constitution
EOF
sh "$STATE" stamp "$CF" next_step_prompt true >/dev/null
assert_file_grep "stamp: next_step_prompt set true" "^next_step_prompt: true" "$CF"
fmend="$(grep -n '^---$' "$CF" | sed -n 2p | cut -d: -f1)"
nspline="$(grep -n '^next_step_prompt:' "$CF" | cut -d: -f1)"
[ "$nspline" -lt "$fmend" ] && ok "stamp: next_step_prompt inside frontmatter" || bad "stamp: next_step_prompt inside frontmatter — line $nspline vs closing --- at $fmend"
sh "$STATE" stamp "$CF" next_step_prompt false >/dev/null
assert_file_grep "stamp: next_step_prompt replaced with false" "^next_step_prompt: false" "$CF"
[ "$(grep -c '^next_step_prompt:' "$CF")" = "1" ] && ok "stamp: next_step_prompt no duplicate keys" || bad "stamp: next_step_prompt no duplicate keys"
set +e
sh "$STATE" stamp "$CF" next_step_prompt auto >/dev/null
assert_file_grep "stamp: next_step_prompt accepts auto" "^next_step_prompt: auto" "$CF"
sh "$STATE" stamp "$CF" next_step_prompt yes >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: bad next_step_prompt refused" 2 "$rc"

# stamp delegation / merge_policy — enum-validated, add + replace
sh "$STATE" stamp "$CF" delegation eager >/dev/null
assert_file_grep "stamp: delegation set eager" "^delegation: eager" "$CF"
fmend="$(grep -n '^---$' "$CF" | sed -n 2p | cut -d: -f1)"
dline="$(grep -n '^delegation:' "$CF" | cut -d: -f1)"
[ "$dline" -lt "$fmend" ] && ok "stamp: delegation inside frontmatter" || bad "stamp: delegation inside frontmatter — line $dline vs closing --- at $fmend"
sh "$STATE" stamp "$CF" delegation inline >/dev/null
assert_file_grep "stamp: delegation replaced with inline" "^delegation: inline" "$CF"
[ "$(grep -c '^delegation:' "$CF")" = "1" ] && ok "stamp: delegation no duplicate keys" || bad "stamp: delegation no duplicate keys"
set +e
sh "$STATE" stamp "$CF" delegation sometimes >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: bad delegation refused" 2 "$rc"
sh "$STATE" stamp "$CF" merge_policy auto >/dev/null
assert_file_grep "stamp: merge_policy set auto" "^merge_policy: auto" "$CF"
sh "$STATE" stamp "$CF" merge_policy ask >/dev/null
assert_file_grep "stamp: merge_policy replaced with ask" "^merge_policy: ask" "$CF"
[ "$(grep -c '^merge_policy:' "$CF")" = "1" ] && ok "stamp: merge_policy no duplicate keys" || bad "stamp: merge_policy no duplicate keys"
set +e
sh "$STATE" stamp "$CF" merge_policy yolo >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: bad merge_policy refused" 2 "$rc"

# stamp plan_preview — enum-validated, add + replace [feedback: F001]
sh "$STATE" stamp "$CF" plan_preview always-browser >/dev/null
assert_file_grep "stamp: plan_preview set always-browser" "^plan_preview: always-browser" "$CF"
fmend="$(grep -n '^---$' "$CF" | sed -n 2p | cut -d: -f1)"
pline="$(grep -n '^plan_preview:' "$CF" | cut -d: -f1)"
[ "$pline" -lt "$fmend" ] && ok "stamp: plan_preview inside frontmatter" || bad "stamp: plan_preview inside frontmatter — line $pline vs closing --- at $fmend"
sh "$STATE" stamp "$CF" plan_preview ask >/dev/null
assert_file_grep "stamp: plan_preview replaced with ask" "^plan_preview: ask" "$CF"
[ "$(grep -c '^plan_preview:' "$CF")" = "1" ] && ok "stamp: plan_preview no duplicate keys" || bad "stamp: plan_preview no duplicate keys"
set +e
sh "$STATE" stamp "$CF" plan_preview sometimes >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: bad plan_preview refused" 2 "$rc"

# stamp plan_preview_editor — non-empty template containing {path}
sh "$STATE" stamp "$CF" plan_preview_editor "code {path}" >/dev/null
assert_file_grep "stamp: plan_preview_editor set code {path}" "^plan_preview_editor: code {path}" "$CF"
set +e
sh "$STATE" stamp "$CF" plan_preview_editor "" >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: empty plan_preview_editor refused" 2 "$rc"
set +e
sh "$STATE" stamp "$CF" plan_preview_editor "code" >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: plan_preview_editor missing {path} refused" 2 "$rc"

# stamp workflow_mode — enum-validated, add + replace [feedback: feedback-stamp-workflow-mode-ca7d F001]
sh "$STATE" stamp "$CF" workflow_mode solo >/dev/null
assert_file_grep "stamp: workflow_mode set solo" "^workflow_mode: solo" "$CF"
fmend="$(grep -n '^---$' "$CF" | sed -n 2p | cut -d: -f1)"
wline="$(grep -n '^workflow_mode:' "$CF" | cut -d: -f1)"
[ "$wline" -lt "$fmend" ] && ok "stamp: workflow_mode inside frontmatter" || bad "stamp: workflow_mode inside frontmatter — line $wline vs closing --- at $fmend"
sh "$STATE" stamp "$CF" workflow_mode collaborative >/dev/null
assert_file_grep "stamp: workflow_mode replaced with collaborative" "^workflow_mode: collaborative" "$CF"
[ "$(grep -c '^workflow_mode:' "$CF")" = "1" ] && ok "stamp: workflow_mode no duplicate keys" || bad "stamp: workflow_mode no duplicate keys"
set +e
werr="$(sh "$STATE" stamp "$CF" workflow_mode bogus 2>&1 >/dev/null)"; rc=$?
set -e
assert_exit "stamp: bad workflow_mode refused" 2 "$rc"
case "$werr" in
  *"workflow_mode must be solo|collaborative"*) ok "stamp: bad workflow_mode error names legal values" ;;
  *) bad "stamp: bad workflow_mode error names legal values — got: $werr" ;;
esac

# stamp update_check_max_age_days — positive-integer-validated, add + replace
sh "$STATE" stamp "$CF" update_check_max_age_days 7 >/dev/null
assert_file_grep "stamp: update_check_max_age_days set 7" "^update_check_max_age_days: 7" "$CF"
fmend="$(grep -n '^---$' "$CF" | sed -n 2p | cut -d: -f1)"
uline="$(grep -n '^update_check_max_age_days:' "$CF" | cut -d: -f1)"
[ "$uline" -lt "$fmend" ] && ok "stamp: update_check_max_age_days inside frontmatter" || bad "stamp: update_check_max_age_days inside frontmatter — line $uline vs closing --- at $fmend"
sh "$STATE" stamp "$CF" update_check_max_age_days 30 >/dev/null
assert_file_grep "stamp: update_check_max_age_days replaced with 30" "^update_check_max_age_days: 30" "$CF"
[ "$(grep -c '^update_check_max_age_days:' "$CF")" = "1" ] && ok "stamp: update_check_max_age_days no duplicate keys" || bad "stamp: update_check_max_age_days no duplicate keys"
set +e
sh "$STATE" stamp "$CF" update_check_max_age_days 0 >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: update_check_max_age_days zero refused" 2 "$rc"
set +e
sh "$STATE" stamp "$CF" update_check_max_age_days -3 >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: update_check_max_age_days negative refused" 2 "$rc"
set +e
sh "$STATE" stamp "$CF" update_check_max_age_days weekly >/dev/null 2>&1; rc=$?
set -e
assert_exit "stamp: update_check_max_age_days non-numeric refused" 2 "$rc"

exit "$fail"
