# AGENTS.md

Instructions for agents and humans working on **DevBox itself** (this repository). For what DevBox does, read
`README.md`; for the operating model it imposes on projects, read `playbooks/lifecycle.md`.

## What lives where

- `bin/devbox`: the CLI. One bash file, compatible with bash 3.2 (macOS) and later: no associative arrays,
  no `mapfile`, no `${var,,}`. Dependencies: git and POSIX coreutils only. Never source project files; read
  config with `cfg_get`.
- `skills/<name>/SKILL.md`: plugin skills, invoked as `/devbox:<name>`. Keep each under about 150 lines; put
  long reference material in sibling files. Refer to playbooks as `.devbox/playbooks/X.md` with the
  `${CLAUDE_PLUGIN_ROOT}/playbooks/X.md` fallback.
- `agents/*.md`: plugin subagents, invoked as `devbox:<name>`. `permissionMode`, `hooks` and `mcpServers`
  are ignored for plugin agents, so do not rely on them.
- `hooks/`: `hooks.json` plus scripts. Hooks must be fast (under a second), must exit 0 when they have nothing
  to say, and must degrade gracefully without jq (python3 fallback in `lib.sh`).
- `playbooks/`: agent-agnostic Markdown. Every file: when to read it, rules as imperatives, checklist,
  anti-patterns, sources. Shape playbooks must keep line 3 as the `> one-line description` (parsed by
  `devbox shapes`).
- `templates/project/`: rendered into projects by `devbox init`. `{{KEY}}` placeholders are replaced; a
  `.tmpl` suffix is stripped (used for files Claude Code or DevBox would otherwise pick up in this repo).
- `templates/spec/`, `templates/docs/`: copied verbatim into `.devbox/templates/` and rendered by
  `devbox feature` and `devbox adr`.
- `templates/ci/<stack>.yml`: one per stack, actions pinned to full SHAs with a version comment.

## Commands

- Test everything: `tests/run.sh` (add `-v` to see output of failing checks). Must pass before every commit.
- Validate the plugin: `claude plugin validate .`
- Lint shell: `shellcheck -x bin/devbox hooks/*.sh tests/*.sh install.sh`
- Try the plugin locally: `claude --plugin-dir .`

## Rules

- Never use the em-dash or en-dash characters anywhere (the test suite fails on them). Use commas, colons,
  parentheses, or "to" for ranges.
- Never write the literal clarification marker (square bracket, NEEDS CLARIFICATION, colon) outside tests; the
  CLI parses it.
- Task lines in templates must not match the task regex (`- [ ] T` followed by digits) or new features would
  start with phantom tasks.
- Any change to the CLI, a hook, or a template gets a test in `tests/run.sh`.
- Versions: bump `DEVBOX_VERSION` in `bin/devbox` and `version` in `.claude-plugin/plugin.json` together (a test
  checks they match), and add a `CHANGELOG.md` entry.
- When updating pinned GitHub Actions, resolve the tag to its commit SHA (`gh api repos/<owner>/<repo>/commits/<tag> --jq .sha`)
  and keep the `# vX.Y.Z` comment.
- Playbook facts carry a source. When a version or standard changes, update the playbook and `docs/sources.md`.
- Commits: Conventional Commits. Work on a branch and open a PR; do not push to `main`.

## Lessons learned

- A literal clarification marker inside a template comment made every new spec look unclarified. Describe the
  marker in words in templates.
