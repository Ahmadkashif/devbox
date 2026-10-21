#!/usr/bin/env bash
# DevBox installer: puts the `devbox` CLI on your PATH and, with --plugin, registers the
# Claude Code plugin from this checkout. Safe to re-run.
#
#   ./install.sh                 link bin/devbox into ~/.local/bin
#   ./install.sh --plugin        also add this checkout as a Claude Code marketplace and install the plugin
#   PREFIX=/usr/local ./install.sh
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
prefix="${PREFIX:-$HOME/.local}"
plugin=0
for arg in "$@"; do
  case "$arg" in
    --plugin) plugin=1 ;;
    -h | --help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

mkdir -p "$prefix/bin"
ln -sf "$here/bin/devbox" "$prefix/bin/devbox"
echo "linked $prefix/bin/devbox -> $here/bin/devbox"
case ":$PATH:" in
  *":$prefix/bin:"*) ;;
  *) echo "note: $prefix/bin is not on your PATH. Add it, e.g.: export PATH=\"$prefix/bin:\$PATH\"" ;;
esac

if [ "$plugin" = 1 ]; then
  command -v claude >/dev/null 2>&1 || { echo "claude CLI not found; install Claude Code first" >&2; exit 1; }
  claude plugin marketplace add "$here"
  claude plugin install devbox@devbox
  echo "Claude Code plugin installed. Restart Claude Code, then run /devbox:deliver in a project."
else
  echo "Claude Code plugin: run ./install.sh --plugin, or inside Claude Code:"
  echo "  /plugin marketplace add Ahmadkashif/devbox"
  echo "  /plugin install devbox@devbox"
fi
"$here/bin/devbox" version
