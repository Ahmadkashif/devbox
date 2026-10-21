#!/usr/bin/env bash
# Stand-in for a headless coding agent, used by tests/run.sh to exercise `devbox run`.
# Reads the prompt on stdin like `claude -p` does, then behaves according to FAKE_MODE.
set -euo pipefail
cat >/dev/null
tasks="$DEVBOX_FEATURE_DIR/tasks.md"
mark() {
  local tmp
  tmp="$(mktemp)"
  sed "s/- \[ \] $DEVBOX_TASK_ID/- [$1] $DEVBOX_TASK_ID/" "$tasks" >"$tmp"
  cat "$tmp" >"$tasks"
  rm -f "$tmp"
}
case "${FAKE_MODE:-ok}" in
  ok)
    printf '%s\n' "work for $DEVBOX_TASK_ID" >>"work.txt"
    mark x
    git add -A && git commit -qm "feat: complete $DEVBOX_TASK_ID"
    echo '{"type":"result","subtype":"success","is_error":false,"result":"done"}' ;;
  nocommit)
    mark x
    echo '{"type":"result","subtype":"success","is_error":false,"result":"done"}' ;;
  block)
    mark '!'
    git add -A && git commit -qm "chore: block $DEVBOX_TASK_ID"
    echo '{"type":"result","subtype":"success","is_error":false,"result":"blocked"}' ;;
  quota)
    echo '{"type":"result","subtype":"success","is_error":true,"result":"You'"'"'ve hit your session limit"}'
    exit 1 ;;
  fail)
    echo "boom" >&2
    exit 1 ;;
esac
