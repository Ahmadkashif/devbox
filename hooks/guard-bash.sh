#!/usr/bin/env bash
# PreToolUse hook for Bash: blocks catastrophic or irreversible commands that DevBox reserves for humans.
# Exit 2 blocks the call and shows the reason to the agent. Disable for one session with DEVBOX_GUARD=off.
set -u
HOOK_INPUT="$(cat)"  # read by hook_json in lib.sh
export HOOK_INPUT
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=hooks/lib.sh
. "$here/lib.sh"
guard_disabled && exit 0

cmd="$(hook_json '.tool_input.command')"
[ -n "$cmd" ] || exit 0

# Catastrophic patterns are matched against the raw command.
# shellcheck disable=SC2016 # literal $HOME in the pattern is intended
rm_seg="$(printf '%s' "$cmd" | grep -Eo '(^|[;&|[:space:]])rm([[:space:]]+-[[:alnum:]-]+)*[[:space:]]+"?(/|/\*|~|~/|\$HOME|\$\{HOME\}|\.|\.\.|\*)"?([[:space:]]|;|&|$)' | head -n 1 || true)"
if [ -n "$rm_seg" ] && printf '%s' "$rm_seg" | grep -Eq '[[:space:]](-[[:alnum:]]*[rR]|--recursive)'; then
  block "recursive delete of /, ~, \$HOME, . or * . Delete specific paths instead."
fi
if printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])(mkfs(\.[a-z0-9]+)?|dd[[:space:]].*of=/dev/(sd|nvme|disk|hd))|:\(\)[[:space:]]*\{'; then
  block "disk formatting, raw device writes or fork bombs."
fi

# Policy patterns are matched with quoted strings removed, so commit messages and echo text do not trip them.
bare="$(printf '%s' "$cmd" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")"
has() { printf '%s' "$bare" | grep -Eq "$1"; }

if has '(^|[;&|[:space:]])git[[:space:]].*--no-verify' || has '(^|[;&|[:space:]])git[[:space:]]+commit([[:space:]].*)?[[:space:]]-[[:alpha:]]*n[[:alpha:]]*([[:space:]]|$)'; then
  block "--no-verify skips git hooks. Fix what the hook reports instead."
fi
if has '(^|[;&|[:space:]])git[[:space:]]+push([[:space:]].*)?[[:space:]](--force([[:space:]]|$|=)|-[[:alnum:]]*f([[:space:]]|$)|\+[[:alnum:]_/.-]+)'; then
  block "force push. Use --force-with-lease on your own feature branch, and never on a shared or protected branch."
fi
if has '(^|[;&|[:space:]])git[[:space:]]+push[[:space:]].*--force-with-lease.*(main|master|trunk|production|prod|release)([[:space:]]|$)'; then
  block "force push to a protected branch."
fi
if has '(^|[;&|[:space:]])git[[:space:]]+reset[[:space:]].*--hard'; then
  block "git reset --hard discards work. Use git stash, or ask the human to run it."
fi
if has '(^|[;&|[:space:]])git[[:space:]]+clean[[:space:]]+-[[:alnum:]]*(f[[:alnum:]]*x|x[[:alnum:]]*f)'; then
  block "git clean -fx deletes ignored files such as .env and local data. Remove specific paths instead."
fi
if has '(curl|wget)[[:space:]][^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z|k|da)?sh([[:space:]]|$)'; then
  block "piping a download into a shell. Download the script, read it, then run it."
fi
if has 'chmod[[:space:]]+(-[[:alnum:]]+[[:space:]]+)*-R[[:space:]]+0?777|chmod[[:space:]]+0?777[[:space:]]+-R'; then
  block "recursive chmod 777."
fi
if has '(^|[;&|[:space:]])gh[[:space:]]+(pr[[:space:]]+merge|repo[[:space:]]+delete|release[[:space:]]+delete)'; then
  block "merging PRs and deleting repos or releases are human decisions (constitution Article IX). Ask the human."
fi
if has '(^|[;&|[:space:]])(terraform|tofu)[[:space:]]+(destroy|apply[[:space:]].*-auto-approve)'; then
  block "unattended infrastructure apply or destroy. Run plan and hand it to a human."
fi
if has '(^|[;&|[:space:]])((npm|pnpm)[[:space:]]+publish|yarn[[:space:]]+(npm[[:space:]]+)?publish|cargo[[:space:]]+publish|twine[[:space:]]+upload|uv[[:space:]]+publish|gem[[:space:]]+push|poetry[[:space:]]+publish)'; then
  block "publishing a package is irreversible and public. Releases go through CI after human approval."
fi
exit 0
