#!/usr/bin/env sh
# Create a new project under artifact-driven-dev, in one command.
#
#   curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/main/new.sh \
#     | sh -s -- my-project
#
# Usage: new.sh [--no-launch] [--source <path>] <target-dir>
#
# This is an *acquisition* channel, nothing more. It resolves an ARDD source
# checkout, creates the target, and then hands off to that checkout's
# install.sh — the only real install/upgrade entry point (constitution,
# Project Scope & Intent). It never reimplements any part of install.sh, and
# must never grow a /ardd-setup-style bridge: unlike the npx channel, it can
# simply invoke the installer directly.
#
# It never prompts. Under `curl | sh` this script's stdin *is* the pipe
# carrying its own source text, so a `read` would consume script or block
# forever. Everywhere an interactive installer would ask, this one refuses:
# a non-empty target, or a source path that isn't an ARDD checkout, is an
# error — not a question. The one exception is the final handoff, which
# reopens /dev/tty for Claude Code (stdout is still the terminal even when
# stdin is a pipe).
#
# Source ownership: the default checkout at ~/.ardd/source belongs to this
# script — it clones it and keeps it current. A checkout named explicitly via
# --source or $ARDD_SOURCE belongs to the user; it is read and never mutated.

set -e

REPO_URL="https://github.com/moui72/artifact-driven-dev"
DEFAULT_SOURCE="$HOME/.ardd/source"

no_launch=0
source_arg=""
target=""

usage() {
  cat >&2 <<EOF
Usage: new.sh [--no-launch] [--source <path>] <target-dir>

  --no-launch      Install, then print the next step instead of opening Claude Code.
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
    --no-launch) no_launch=1; shift ;;
    --source)    [ $# -ge 2 ] || usage; source_arg="$2"; shift 2 ;;
    --source=*)  source_arg="${1#--source=}"; shift ;;
    -h|--help)   usage ;;
    -*)          echo "Error: unknown option '$1'" >&2; usage ;;
    *)           [ -z "$target" ] || { echo "Error: unexpected argument '$1'" >&2; usage; }
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

echo ""
if [ "$no_launch" -eq 1 ] || ! command -v claude >/dev/null 2>&1 || [ ! -r /dev/tty ]; then
  if [ "$no_launch" -ne 1 ] && ! command -v claude >/dev/null 2>&1; then
    echo "Claude Code isn't on your PATH, so I can't open the first session for you."
  elif [ "$no_launch" -ne 1 ]; then
    echo "No terminal available, so I can't open the first session for you."
  fi
  echo "Start it with:"
  echo ""
  echo "  cd $target"
  echo "  claude \"/ardd-kickoff\""
  echo ""
  # The install genuinely succeeded — exiting nonzero here would misreport it.
  exit 0
fi

echo "Opening Claude Code in $target — /ardd-kickoff will walk you through the design."
echo ""
cd "$TARGET"
# stdin is the curl pipe; stdout is still the terminal. Reopen the tty so
# Claude Code gets a real interactive stdin.
exec claude "/ardd-kickoff" < /dev/tty
