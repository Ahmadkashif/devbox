---
name: slice
description: DevBox phase 4 (plan). Breaks an approved spec and design into tasks.md - thin vertical slices (tracer bullets) through every layer, each sized to one agent session, tagged AFK or HITL, ordered by dependency with P1 first, every acceptance criterion covered, each with a Verify step - and optionally files them as GitHub issues. Use when the phase is "plan", or when the user says "break this down", "make tasks", "slice it", "turn the PRD into issues".
argument-hint: "[feature number] [--issues]"
---

# /devbox:slice

Feature: $ARGUMENTS (default: the active feature). Preconditions: spec approved; design approved or
intentionally absent.

## Process

1. **Read** `spec.md`, `design.md`, the contracts and ADRs. Build a list of every acceptance criterion ID.
2. **Draft vertical slices.** Each task is a narrow but complete path through every layer it touches
   (data, logic, interface, tests), demoable or verifiable on its own. Never slice horizontally ("all the
   models", then "all the endpoints"); that produces untestable halves and big-bang integration.
   - T001 is a **walking skeleton** for new features or projects: the thinnest end-to-end path that runs,
     with its test and CI green. Everything after it widens the path.
   - Size: one focused agent session, one reviewable commit or small PR (roughly under 400 changed lines).
     Split anything bigger. Prefer many thin slices.
   - Tag `[AFK]` when an agent can finish and merge it with no human input; `[HITL]` when it needs a human
     (a product decision, credentials, a visual design review, a manual test on a device). Prefer AFK and
     push human decisions earlier into the spec where possible.
   - Write `after:` dependencies and keep the order topological, P1 stories first.
   - Every task line cites its criteria, e.g. `(US1: AC1.1, AC1.2)`, and has a `Verify:` line with the
     command or observable check that proves it.
   - Add hardening tasks for edge cases and NFRs, and a final HITL ship task (docs, CHANGELOG, rollout).
3. **Write `tasks.md`** in the exact line format at the top of the template (the CLI parses it):
   `- [ ] T001 [AFK] Title (US1: AC1.1) after: none` followed by an indented `Verify:` line.
4. **Coverage check (read-only analysis).** Confirm: every acceptance criterion maps to at least one task;
   no task cites a criterion that does not exist; no task implements something outside the spec; nothing
   contradicts the design or the constitution. Fix gaps before showing the user.
5. **Quiz the user.** Show the numbered list (title, AFK or HITL, after, criteria). Ask: is the granularity
   right, are the dependencies right, should any be merged or split, are the HITL and AFK tags right?
   Iterate until they agree.
6. **Optional: GitHub issues** (when the user asks, or passes `--issues`). Check `gh auth status` and that a
   GitHub remote exists. File in dependency order so "Blocked by" can reference real numbers, using the
   feature issue form fields: What to build (reference the spec, do not paste it), Acceptance criteria,
   Self-verification, Mode (AFK or HITL), Blocked by. Add the issue number to the task line, e.g.
   `T003 [AFK] ... (#42)`. Print a task to URL table at the end.
7. **Hand off.** Log progress, commit (`docs(tasks): NNN-name`), and run `/devbox:critique`. Leave
   `status: draft`; only a GO verdict leads to `devbox approve tasks`.
