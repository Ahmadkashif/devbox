---
status: accepted
date: 2026-10-21
---

# 0002. Ship as a Claude Code plugin, a bash CLI, and agent-agnostic Markdown

## Context and problem statement

DevBox must work on any machine, for any project shape, and survive changes in agent tooling. Workflow logic that
lives only in prompts is unenforceable; logic that lives only in a tool is invisible to agents.

## Decision drivers

- One install step for Claude Code users; usable by other agents (Codex, Cursor, Copilot) through AGENTS.md.
- Deterministic gates that do not depend on the model behaving.
- No runtime dependencies beyond git and a POSIX shell, so CI and fresh machines just work.

## Considered options

1. Claude Code plugin only (skills, agents, hooks).
2. A template repository copied per project.
3. Plugin for behavior, CLI for state and gates, Markdown playbooks vendored into each project.

## Decision outcome

Chosen option 3. The plugin carries behavior (skills, subagents, hooks) and is installed from this repo, which is
its own marketplace. `bin/devbox` owns state transitions and deterministic gates (`approve`, `verify`, `run`) and is
on the PATH automatically while the plugin is enabled. `devbox init` vendors playbooks, templates and a pinned copy
of the CLI into `.devbox/`, so each project is self-describing, CI runs `.devbox/bin/devbox verify`, and any agent
can follow the process by reading files.

### Consequences

- Good, because gates are enforced by code and hooks, not by trust in prompts.
- Good, because projects keep working if the plugin is removed or another agent is used.
- Bad, because vendored copies drift; `devbox sync` and `devbox doctor` (version check) mitigate it.
- Bad, because the CLI is bash, which limits how much logic it should grow. Keep it small.
