---
name: build
description: DevBox phase 6. Implements approved tasks from tasks.md one at a time - as a controller dispatching a fresh devbox:implementer subagent per task (test first, verify, commit, check off), reviewing each result before the next - or hands AFK tasks to the `devbox run` loop. Use when the phase is "build", or when the user says "build it", "implement the tasks", "start coding", "next task".
argument-hint: "[feature number] [task id] [--afk]"
---

# /devbox:build

Feature: $ARGUMENTS (default: the active feature). Precondition: `tasks.md` has `status: approved`
(the critique returned GO). If not, stop and run `/devbox:critique`.

## Before the first task

1. Make sure you are on a work branch, never a protected one: `git switch -c feat/<feature-slug>` if needed.
2. The tree is clean and `devbox verify` is green on the baseline. If the baseline is red, stop: that is a
   patch to do first, not something to build on.
3. Re-read the last progress entry, especially any "watch during execution" note from Linus.

## Choose the mode

- **AFK** (`--afk`, or when every remaining task is `[AFK]` and the user wants to step away): explain what
  will happen, then run `devbox run --max <n>` (start with `--dry-run` once to show the prompt). The loop
  runs one headless session per task, verifies and checks commits after each, and stops on HITL, blocks,
  failures or usage limits. Report the outcome when it stops.
- **In session** (default): you are the controller. Loop over tasks as below.

## Controller loop (one task at a time)

1. `devbox next` gives the next open task. If it is `[HITL]`, stop and ask the human for what it needs.
2. **Brief.** Write a short brief for the implementer: the task line, the acceptance criteria text it cites
   (copied from spec.md), the relevant design excerpt (interfaces, data model), files likely involved,
   and the verify command. Only what this task needs.
3. **Dispatch** the `devbox:implementer` subagent with the brief. One implementer at a time on this tree.
4. **Check the report, do not trust it.** The implementer returns DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT
   or BLOCKED. Whatever it says:
   - read the diff (`git show --stat HEAD`, then the changes);
   - confirm a test exists for each cited criterion and that it would fail without the change;
   - run `devbox verify` yourself and read the output;
   - confirm the task is `[x]` and progress.md has an entry with evidence.
5. **Review.** For anything beyond trivial, run `/devbox:review` on the task's commits. CRITICAL or MAJOR
   findings go back to a fresh implementer with the findings as the brief (up to three rounds, then stop and
   involve the user). Never fix findings yourself in the controller context.
6. NEEDS_CONTEXT: answer from the spec, design or code, or ask the user, then re-dispatch. BLOCKED: mark
   `[!]`, write the reason in progress.md, and move to the next unblocked task or stop.
7. Repeat. Every few tasks, re-read the spec's P1 stories to make sure the slices still add up to them.

## When all tasks are done

Run `devbox status` (phase should be `verify-ship`) and continue with `/devbox:verify`.

## Rules

- Exactly one task per implementer. No "while I'm here" changes; file a follow-up task instead.
- A task is done only with green verify, a commit, a checked box and evidence.
- If a task reveals the design is wrong, stop building. Update `design.md` (and an ADR), get approval, then
  continue. Do not let code and design drift apart.
