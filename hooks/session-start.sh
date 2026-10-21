#!/usr/bin/env bash
# SessionStart hook: inside a DevBox project, add the current feature, phase and next task as context.
set -u
HOOK_INPUT="$(cat)"  # read by hook_json in lib.sh
export HOOK_INPUT
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=hooks/lib.sh
. "$here/lib.sh"

cwd="$(hook_json '.cwd')"
[ -n "$cwd" ] || cwd="$PWD"
root="$cwd"
while [ "$root" != "/" ] && [ ! -f "$root/.devbox/config" ]; do root="$(dirname "$root")"; done
[ -f "$root/.devbox/config" ] || exit 0

devbox="${CLAUDE_PLUGIN_ROOT:-$here/..}/bin/devbox"
status="$(cd "$root" && NO_COLOR=1 "$devbox" status --brief 2>/dev/null)" || exit 0
printf '%s\n' "$status"
printf 'DevBox lifecycle: .devbox/playbooks/lifecycle.md. Entry point: /devbox:deliver. Verify gates: devbox verify.\n'
exit 0
