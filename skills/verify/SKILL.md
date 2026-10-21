---
name: verify
description: DevBox phase 7 and the rule before any "done" claim. Runs the verify gates fresh, maps every acceptance criterion in the spec to concrete evidence, dispatches the independent devbox:qa agent to exercise the real system, and writes a verification report to progress.md. Use when the phase is "verify-ship", before saying anything works, before opening a PR, and when the user asks "is it done?", "does it work?", "verify this".
argument-hint: "[feature number]"
---

# /devbox:verify

**No completion claim without fresh evidence.** "Should work", "looks right" and "tests passed earlier"
are not evidence. A subagent saying DONE is not evidence. The command you just ran and its output is.

Feature: $ARGUMENTS (default: the active feature)

## Procedure

1. **Fresh gates.** Run `devbox verify` now, read the whole output and the exit code. Red means not done:
   go back to build or debug. Then make sure CI would see the same: no uncommitted changes, no skipped tests,
   no `.only`, no disabled lint rules added in this branch (`git diff main...HEAD` and grep for skip, only,
   xfail, eslint-disable, noqa, nolint, `#[ignore]`).
2. **Criteria to evidence matrix.** List every acceptance criterion from `spec.md`. For each, find the test
   that proves it (name and file) or the manual check (command and output, screenshot path, URL). Write the
   matrix into a `## Verification` entry in `progress.md`:

   | Criterion | Evidence | Result |
   |-----------|----------|--------|
   | AC1.1 | `test_export_includes_header` (tests/test_export.py) | pass |

   Any criterion without evidence is a gap: add a test or a task, do not hand-wave it.
3. **NFRs.** For each non-functional requirement with a number, run the check named in the spec (load test,
   Lighthouse, axe, bundle size, benchmark) or record why it cannot run yet as an explicit follow-up.
4. **Independent QA.** Dispatch the `devbox:qa` subagent with the feature folder path and how to run the
   system. It did not build the feature and must exercise it like a user (CLI calls, HTTP requests, a browser
   via Playwright, the library's public API). Its PASS or FAIL per criterion goes into the report verbatim.
5. **Regression sweep.** Run the shape playbook's "Verify gates" extras that apply (for example oasdiff for
   API breaking changes, cargo-semver-checks for libraries, terraform plan for infrastructure).
6. **Verdict.** All criteria pass with evidence, QA passes, gates green: write "Verified" with the date and
   commit SHA in progress.md and continue to `/devbox:review` then `/devbox:ship`. Otherwise list the gaps as
   new tasks in `tasks.md` (they reopen the build phase) and say so plainly.

## Rules

- Report failures with their output. Never round a partial pass up to a pass.
- Never weaken a test or a gate to make verification pass.
- If the evidence shows the spec itself was wrong, stop and raise it with the user; do not quietly ship a
  different feature.
