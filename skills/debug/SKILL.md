---
name: debug
description: Systematic debugging - reproduce, isolate, find the root cause with one hypothesis at a time, prove it with a failing test, then fix - instead of guessing at fixes. Use for any bug, failing test, flaky behavior, crash, performance regression or "it doesn't work", and before any fix in the DevBox patch lane.
argument-hint: "[symptom, error message or failing test]"
---

# /devbox:debug

**No fix without a root cause.** A fix you cannot explain is a guess, and guesses create new bugs.

Symptom: $ARGUMENTS

## Phase 1: Reproduce

- Get the exact symptom: full error text, stack trace, logs, inputs, environment, version or commit.
- Reproduce it reliably with the smallest possible case. Turn the reproduction into a failing automated test
  as early as you can; that test is the finish line.
- Flaky? Run it in a loop, vary timing, seeds and parallelism until you can make it fail on demand.
- Cannot reproduce: say so, list what you tried, and gather more data (add logging at the boundary) instead of
  changing code blindly.

## Phase 2: Isolate

- Read the code path end to end, from the entry point to the failure. Do not stop at the first suspicious line.
- Check what changed: `git log -p` on the involved files, recent dependency bumps, config, data, environment.
  `git bisect` with the failing test when a known-good commit exists.
- Compare with a working case: what is different about the input, state or environment?
- Find the boundary: the last point where data is correct and the first where it is wrong. Log or assert there.

## Phase 3: Hypothesize and test

- Write one hypothesis: "X happens because Y, so if I change Z the test will pass and nothing else will break."
- Test it with the smallest possible change or an experiment (a log line, an assertion, a debugger breakpoint).
- One variable at a time. If the hypothesis is wrong, revert the experiment completely before the next one.
- **Three failed hypotheses means you misunderstand the system.** Stop, write down what you now know in
  `progress.md`, and question the architecture or your assumptions, or ask the user. Do not try a fourth fix
  of the same kind.

## Phase 4: Fix

1. The failing reproduction test exists and fails for the reason you identified.
2. Fix the root cause, not the symptom. A null check that hides bad data upstream is a symptom fix.
3. The test passes; `devbox verify` is green.
4. Look for siblings: the same mistake elsewhere (grep for the pattern), and add tests there too.
5. Commit with a message that explains the cause: `fix(parser): handle CRLF in headers (root cause: ...)`.
6. If the bug revealed a gap in the spec or in AGENTS.md, update them, and add a lesson line.

## Rules

- Never "fix" by deleting or loosening the failing test, adding sleeps, catching and ignoring the error, or
  retrying until it passes.
- Never change several things at once and keep whichever combination worked.
- Report the root cause in plain words first, then the change.
