---
status: accepted
date: 2026-10-21
---

# 0003. Keep delivery state on disk, derive phases from files

## Context and problem statement

Agent sessions lose context through compaction, resets and hand-offs. Every methodology we studied (Spec Kit,
superpowers, BMAD, GSD, HumanLayer, Anthropic's long-running harness guidance, the Ralph loop) converges on keeping
state in files and starting each session by reading them.

## Decision outcome

Each feature lives in `specs/NNN-name/` with `spec.md`, `design.md`, `tasks.md` and an append-only `progress.md`.
The phase is derived, never stored: front matter `status:` on the three documents plus the task checkboxes
(`[ ]`, `[x]`, `[!]`) and the presence of clarification markers. `devbox status` computes it; `devbox approve`
moves documents forward only when preconditions hold. Human approval is required for the spec, one-way-door design
decisions, HITL tasks and merging; a GO from the `linus` agent is required before tasks are approved.

### Consequences

- Good, because any session or human can resume from `devbox status` and the last progress entry.
- Good, because the state is reviewable in pull requests like any other change.
- Bad, because the task line format is a contract between templates, agents and the CLI; changing it needs tests.
