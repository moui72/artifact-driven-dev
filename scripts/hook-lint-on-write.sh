#!/usr/bin/env sh
# PostToolUse hook (Write|Edit). If the written/edited file is under
# .project/, run lint-project.sh immediately and surface any findings back
# to Claude as context — instead of only catching them when /ardd-lint is
# run by hand. Never blocks: the write already happened by the time
# PostToolUse fires, so this only adds visibility, not enforcement.
#
# Reads the hook's stdin JSON (tool_input.file_path, cwd) — see
# .claude/settings.json for the matcher this is wired to.

set -e

INPUT="$(cat)"
FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
[ -z "$FILE_PATH" ] && exit 0

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$PROJECT_ROOT" ]; then
  PROJECT_ROOT="$(printf '%s' "$INPUT" | jq -r '.cwd // empty')"
fi
[ -z "$PROJECT_ROOT" ] && exit 0

case "$FILE_PATH" in
  "$PROJECT_ROOT"/.project/*) ;;
  *) exit 0 ;;
esac

LINT="$PROJECT_ROOT/scripts/lint-project.sh"
[ -x "$LINT" ] || exit 0

OUTPUT="$("$LINT" "$PROJECT_ROOT" 2>&1)" && exit 0

jq -n --arg ctx "lint-project.sh found issues in .project/ after this write (run /ardd-lint for the full report, or fix directly):
$OUTPUT" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}'
exit 0
