#!/usr/bin/env sh
# Create a new project under artifact-driven-dev, in one command.
#
#   curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/main/new.sh \
#     | sh -s -- my-project
#
# Usage: new.sh [--kickoff|--no-kickoff] [--source <path>] <target-dir>
#
# This is an *acquisition* channel, nothing more. It resolves an ARDD source
# checkout, creates the target, and then hands off to that checkout's
# install.sh — the only real install/upgrade entry point (constitution,
# Project Scope & Intent). It never reimplements any part of install.sh, and
# must never grow a /ardd-setup-style bridge: unlike the npx channel, it can
# simply invoke the installer directly.
#
# Two rules bound its interactivity (constitution v1.2.4). It *refuses* rather
# than asks wherever writing into a directory it doesn't own is at stake — a
# non-empty target, or a --source that isn't an ARDD checkout — because those
# aren't decisions worth offering. And it *never blocks on a question it
# cannot ask*: with no readable /dev/tty it takes the safe default instead of
# hanging a pipeline forever.
#
# Between those bounds it may ask, and the Claude Code handoff does. The prompt
# reads from /dev/tty, not stdin — under `curl | sh` stdin carries this script's
# own source text, while stdout and the tty are still the terminal. The exec,
# by contrast, must leave stdin alone and let Claude Code open the tty itself;
# see launch().
#
# Source ownership: the default checkout at ~/.ardd/source belongs to this
# script — it clones it and keeps it current. A checkout named explicitly via
# --source or $ARDD_SOURCE belongs to the user; it is read and never mutated.

set -e

REPO_URL="https://github.com/moui72/artifact-driven-dev"
DEFAULT_SOURCE="$HOME/.ardd/source"

kickoff=""          # "" = ask; 1 = always; 0 = never
source_arg=""
target=""

usage() {
  cat >&2 <<EOF
Usage: new.sh [--kickoff|--no-kickoff] [--source <path>] <target-dir>

  --kickoff        Open Claude Code on /ardd-kickoff without asking.
  --no-kickoff     Install, then print the next step instead of opening Claude Code.
                   With neither flag, you're asked — unless there's no terminal
                   to ask on, in which case this is the default.
  --source <path>  Use an existing ARDD checkout (also settable as \$ARDD_SOURCE).
                   Read, never modified. Without it, ~/.ardd/source is cloned
                   and kept up to date.

Example:
  curl -fsSL $REPO_URL/raw/main/new.sh | sh -s -- my-project
EOF
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    # Contradictory flags are a usage error, not last-flag-wins: silently
    # guessing which of two opposite intents was meant is worse than asking.
    --kickoff)    [ "$kickoff" != "0" ] || { echo "Error: --kickoff and --no-kickoff are mutually exclusive" >&2; usage; }
                  kickoff=1; shift ;;
    --no-kickoff) [ "$kickoff" != "1" ] || { echo "Error: --kickoff and --no-kickoff are mutually exclusive" >&2; usage; }
                  kickoff=0; shift ;;
    --source)     [ $# -ge 2 ] || usage; source_arg="$2"; shift 2 ;;
    --source=*)   source_arg="${1#--source=}"; shift ;;
    -h|--help)    usage ;;
    -*)           echo "Error: unknown option '$1'" >&2; usage ;;
    *)            [ -z "$target" ] || { echo "Error: unexpected argument '$1'" >&2; usage; }
                  target="$1"; shift ;;
  esac
done

[ -n "$target" ] || usage

# --- Validate the target, before touching the network -------------------
# Cheap checks first: a typo'd target must not cost a clone of ~/.ardd/source.
# Non-empty means any entry other than .git — `git init && curl … | sh` is a
# natural order and refusing it would be a papercut, but writing into a
# directory that already holds real content never is.

if [ -e "$target" ]; then
  [ -d "$target" ] || { echo "Error: '$target' exists and is not a directory." >&2; exit 1; }
  leftovers="$(find "$target" -mindepth 1 -maxdepth 1 ! -name .git | head -n 1)"
  if [ -n "$leftovers" ]; then
    echo "Error: '$target' already exists and is not empty." >&2
    echo "" >&2
    echo "This command creates a *new* project. To add ARDD to an existing one," >&2
    echo "run install.sh from an ARDD checkout against it:" >&2
    echo "  /path/to/artifact-driven-dev/install.sh $target" >&2
    exit 1
  fi
fi

# --- Resolve the source checkout ---------------------------------------
# An explicit --source/$ARDD_SOURCE is the user's checkout: verify, use as-is.
# The default path is ours: clone it if absent, keep it current if present.

is_ardd_checkout() { [ -f "$1/install.sh" ] && [ -d "$1/skills" ]; }

if [ -n "$source_arg" ]; then
  SRC="$source_arg"; owned=0
elif [ -n "${ARDD_SOURCE:-}" ]; then
  SRC="$ARDD_SOURCE"; owned=0
else
  SRC="$DEFAULT_SOURCE"; owned=1
fi

if [ -e "$SRC" ]; then
  if ! is_ardd_checkout "$SRC"; then
    echo "Error: '$SRC' exists but is not an artifact-driven-dev checkout" >&2
    echo "       (expected install.sh and skills/ at its top level)." >&2
    echo "" >&2
    echo "Refusing to write into a directory this script doesn't own." >&2
    echo "Point --source (or \$ARDD_SOURCE) at a real checkout, or clear that path." >&2
    exit 1
  fi
  if [ "$owned" -eq 1 ]; then
    echo "Updating ARDD source at $SRC ..."
    git -C "$SRC" pull --ff-only \
      || echo "  ! pull failed — continuing with the checkout as it stands on disk."
  fi
else
  if [ "$owned" -eq 0 ]; then
    echo "Error: source checkout '$SRC' does not exist." >&2
    exit 1
  fi
  echo "Cloning ARDD source into $SRC ..."
  mkdir -p "$(dirname "$SRC")"
  git clone --quiet "$REPO_URL" "$SRC"
fi

SRC="$(cd "$SRC" && pwd)"

# --- Create the target -------------------------------------------------

mkdir -p "$target"
TARGET="$(cd "$target" && pwd)"

# install.sh runs its .gitignore guidance through `git -C "$TARGET"`, so the
# repo must exist before it is called or those suggestions silently never fire.
if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init --quiet "$TARGET"
  echo "Initialized empty git repository in $TARGET"
fi

# --- Converge on install.sh -------------------------------------------
# Its output (migrations, gitignore guidance, warnings) is the user's only
# view of install-time housekeeping. Relay it verbatim; never summarize.

"$SRC/install.sh" "$TARGET"

# --- Hand off to the first session -------------------------------------

next_steps() { # $1 = optional reason line
  [ -n "$1" ] && echo "$1"
  echo "Start the first session with:"
  echo ""
  echo "  cd $target"
  echo "  claude \"/ardd-kickoff\""
  echo ""
}

# Actually open the tty rather than testing its permission bits: `[ -r /dev/tty ]`
# passes on a CI runner with no controlling terminal, where the open then fails
# with ENXIO. Only a real open answers "can I interact with a human here?"
tty_ok() { (exec 3< /dev/tty) 2>/dev/null; }

launch() {
  echo "Opening Claude Code in $target — /ardd-kickoff will walk you through the design."
  echo ""
  cd "$TARGET"
  # Do NOT redirect stdin here, even though under `curl | sh` it's the curl
  # pipe. Claude Code checks `process.stdin.isTTY && process.stdout.isTTY` and
  # only falls back to opening /dev/tty itself — read-write, which is what its
  # TUI needs — when that check fails. Feeding it `< /dev/tty` (read-only)
  # passes the check, so it uses that fd instead and silently accepts no
  # keystrokes; `<> /dev/tty` makes it exit outright. An EOF'd pipe on stdin is
  # the input it handles correctly.
  exec claude "/ardd-kickoff"
}

# Ask on /dev/tty — never stdin, which is the curl pipe. Bare Enter means yes.
# EOF (a readable but closed tty) means no, matching the no-tty default: never
# block, never guess. An unrecognized answer re-asks, but only three times, so
# a wedged terminal can't spin forever.
ask_kickoff() {
  attempt=0
  while [ "$attempt" -lt 3 ]; do
    printf 'Open Claude Code now and run /ardd-kickoff? [Y/n] ' > /dev/tty
    if ! IFS= read -r reply < /dev/tty; then
      echo "" > /dev/tty
      return 1   # EOF
    fi
    case "$reply" in
      ""|[Yy]|[Yy][Ee][Ss]) return 0 ;;
      [Nn]|[Nn][Oo])        return 1 ;;
      *) echo "Please answer y or n." > /dev/tty ;;
    esac
    attempt=$((attempt + 1))
  done
  echo "No clear answer after 3 tries — not launching." > /dev/tty
  return 1
}

echo ""

# The install genuinely succeeded by this point. Every path below exits 0;
# declining to launch is an outcome, not a failure.
if [ "$kickoff" = "0" ]; then
  next_steps ""
  exit 0
fi

if ! command -v claude >/dev/null 2>&1; then
  next_steps "Claude Code isn't on your PATH, so I can't open the first session for you."
  exit 0
fi

if [ "$kickoff" = "1" ]; then
  launch
fi

if ! tty_ok; then
  next_steps "No terminal available, so I can't open the first session for you."
  exit 0
fi

if ! ask_kickoff; then
  next_steps ""
  exit 0
fi

launch
