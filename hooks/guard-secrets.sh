#!/usr/bin/env bash
# PreToolUse hook for Write/Edit/MultiEdit: blocks writing content that contains live-looking credentials.
# High-precision patterns only, to keep false positives rare. Disable for one session with DEVBOX_GUARD=off.
set -u
HOOK_INPUT="$(cat)"  # read by hook_json in lib.sh
export HOOK_INPUT
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=hooks/lib.sh
. "$here/lib.sh"
guard_disabled && exit 0

if command -v jq >/dev/null 2>&1; then
  content="$(printf '%s' "$HOOK_INPUT" | jq -r '.tool_input | [.content, .new_string, ((.edits // [])[] | .new_string)] | map(select(type == "string")) | join("\n")' 2>/dev/null)"
else
  content="$(hook_json content)"
fi
[ -n "$content" ] || exit 0

patterns='-----BEGIN ((RSA|EC|DSA|OPENSSH|ENCRYPTED|PGP) )?PRIVATE KEY( BLOCK)?-----|(AKIA|ASIA)[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{60,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-proj-[A-Za-z0-9_-]{32,}|xox[abposr]-[A-Za-z0-9-]{10,}|(sk|rk)_live_[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{35}|npm_[A-Za-z0-9]{36}|glpat-[A-Za-z0-9_-]{20,}'
hit="$(printf '%s\n' "$content" | grep -Eo -- "$patterns" | grep -viE 'EXAMPLE|XXXX|your[-_]?key|dummy|fake' | head -n 1 || true)"
if [ -n "$hit" ]; then
  masked="$(printf '%s' "$hit" | cut -c1-8)..."
  file="$(hook_json '.tool_input.file_path')"
  block "content for ${file:-the file} contains what looks like a live credential ($masked). Load secrets from the environment or a secret manager, and use an obviously fake placeholder in code and tests."
fi
exit 0
