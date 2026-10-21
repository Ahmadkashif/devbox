---
name: tdd
description: Test-driven development with the red-green-refactor loop, one behavior at a time through public interfaces (vertical tracer bullets, never all tests first). Use when building any feature or fixing any bug in DevBox, when the user mentions TDD, red-green-refactor, test-first or integration tests, and inside every build task.
argument-hint: "[behavior or task to implement]"
---

# Test-driven development

**Core principle:** tests verify behavior through public interfaces, not implementation details. The code
can change completely; the tests should not.

Target: $ARGUMENTS

Good tests are integration-style: they exercise real code paths through public APIs and read like a
specification ("user can check out with a valid cart"). Bad tests mock internal collaborators, test private
methods, or verify through side channels (querying the database instead of using the interface). The warning
sign: a test breaks when you refactor but behavior did not change. See [tests.md](tests.md) and
[mocking.md](mocking.md).

## Anti-pattern: horizontal slices

Do not write all the tests first and then all the code. Tests written in bulk test imagined behavior, end up
checking the shape of things, and commit you to a structure before you understand the problem.

```
WRONG (horizontal)            RIGHT (vertical)
RED:   test1..test5           RED -> GREEN: test1 -> impl1
GREEN: impl1..impl5           RED -> GREEN: test2 -> impl2
                              RED -> GREEN: test3 -> impl3
```

## Workflow (Kent Beck's canon)

1. **List the scenarios** you need (behaviors, not implementation steps). Prioritize; you cannot test
   everything. Confirm the public interface and the priority list with the user (or with the spec's
   acceptance criteria inside a build task). Look for [deep modules](deep-modules.md) and design the
   interface for [testability](interface-design.md).
2. **Tracer bullet.** Turn exactly one scenario into a concrete, runnable test. Run it and **watch it fail
   for the right reason** (a test that passes immediately proves nothing). Write the minimum code to pass.
3. **Loop.** Next scenario: RED, then GREEN. Only enough code for the current test. Do not anticipate future
   tests. Add newly discovered scenarios to the list instead of to the code.
4. **Refactor** only when GREEN: remove duplication, deepen modules, improve names, see
   [refactoring.md](refactoring.md). Run the tests after each step. Never refactor while RED.
5. **Commit** at each green step that is a coherent unit.

## Bugs

A bug fix starts with a test that reproduces the bug and fails. Then fix. The test stays forever as a
regression guard.

## Checklist per cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses the public interface only
[ ] I watched it fail, and the failure message made sense
[ ] Expected values come from an independent source (spec, hand calculation), not from running the code
[ ] Code is the minimum for this test; no speculative features
[ ] Test would survive an internal refactor
```

Never delete, skip or weaken a test to get green. If a test is wrong, say why in the commit message.
