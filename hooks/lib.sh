# shellcheck shell=bash
# Shared helpers for DevBox hooks. Sourced, not executed.

# hook_json EXPR : evaluate a jq expression against the hook's stdin JSON (stored in $HOOK_INPUT).
# Falls back to python3 for the few expressions DevBox uses. Prints nothing when neither exists.
hook_json() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | jq -r "$1 // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | python3 -I -c '
import json, sys
expr = sys.argv[1]
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = data.get("tool_input") or {}
if expr == ".cwd":
    out = data.get("cwd")
elif expr == ".tool_input.command":
    out = ti.get("command")
elif expr == ".tool_input.file_path":
    out = ti.get("file_path")
elif expr == "content":
    parts = [ti.get("content"), ti.get("new_string")] + [e.get("new_string") for e in ti.get("edits") or []]
    out = "\n".join(p for p in parts if isinstance(p, str))
else:
    out = None
if out:
    sys.stdout.write(str(out))
' "$1"
  fi
}

# Escape hatch for a single session: DEVBOX_GUARD=off claude
guard_disabled() { [ "${DEVBOX_GUARD:-on}" = "off" ]; }

block() {
  printf 'DevBox guard blocked this: %s\n' "$1" >&2
  exit 2
}
