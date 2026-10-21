---
status: accepted
date: 2026-10-21
---

# 0004. A conservative AFK runner: one fresh session per task, verified between tasks

## Context and problem statement

Autonomous loops (the Ralph technique, GSD executors, superpowers subagent-driven development, the user's earlier
orchestrator) deliver a lot when tasks are well specified, and do damage when they are not. The runner must be useful
unattended without becoming a liability.

## Decision outcome

`devbox run` starts one headless agent session per open task with a fixed worker prompt, and after each session
requires: the task checked off, a new commit, and green verify gates. It refuses protected branches, dirty trees and
unapproved task lists, stops on HITL and blocked tasks, honours a `.devbox/STOP` file and `--max`, and on usage or
rate limits it pauses with exit code 4. It never enables paid overage. The agent command is configurable; the default
is Claude Code in auto permission mode. Fully unattended permission bypass is documented only for disposable
containers or VMs.

### Consequences

- Good, because each task starts with a clean context and ends with verified, committed work a human can review.
- Good, because the loop is agent-agnostic (anything that reads a prompt on stdin).
- Bad, because serial execution is slower than parallel worktrees. Parallelism can come later behind its own ADR.
