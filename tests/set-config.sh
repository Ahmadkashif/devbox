#!/usr/bin/env bash
# set-config.sh FILE KEY VALUE: replace or append KEY=VALUE in a .devbox/config file (test helper).
set -euo pipefail
file="$1" key="$2" val="$3"
tmp="$(mktemp)"
if grep -qE "^${key}=" "$file"; then
  awk -v k="$key" -v v="$val" 'index($0, k"=") == 1 { print k"="v; next } { print }' "$file" >"$tmp"
else
  cat "$file" >"$tmp"
  printf '%s=%s\n' "$key" "$val" >>"$tmp"
fi
cat "$tmp" >"$file"
rm -f "$tmp"
