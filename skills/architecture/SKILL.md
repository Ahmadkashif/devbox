---
name: architecture
description: Explores a codebase to find architectural friction and proposes module-deepening refactors (deep modules with small interfaces, Ousterhout) that make the code more testable and easier for agents to navigate - presenting candidates, designing several radically different interfaces in parallel, and writing a refactor RFC. Use when the user wants to improve architecture, find refactoring opportunities, untangle tightly coupled modules, or make a codebase more AI-navigable.
argument-hint: "[area of the codebase, optional]"
---

# /devbox:architecture

A **deep module** (John Ousterhout, "A Philosophy of Software Design") has a small interface hiding a large
implementation. Deep modules are more testable, more navigable for agents, and let you test at the boundary
instead of inside. Playbook: `.devbox/playbooks/architecture.md`.

Area: $ARGUMENTS

## 1. Explore

Dispatch an Explore subagent (or several, for different areas) to navigate the code naturally and report where
it hit friction. Do not follow a rigid checklist; the friction is the signal:

- Understanding one concept requires bouncing between many small files.
- Modules so shallow that the interface is nearly as complex as the implementation (pass-through layers).
- Pure functions extracted only for testability while the real bugs hide in how they are called.
- Tightly coupled modules that create integration risk in the seams between them.
- Code that is untested or hard to test.
- The deletion test: if deleting a module makes complexity vanish rather than move, it was a pass-through.

## 2. Present candidates

A numbered list. For each: the cluster of modules, why they are coupled (shared types, call patterns, co-owned
concept), the dependency category (see [REFERENCE.md](REFERENCE.md)), and the test impact (which tests become
boundary tests, which become redundant). Do not propose interfaces yet. Ask which candidate to explore.

## 3. Frame the problem

For the chosen candidate, explain the constraints any new interface must satisfy, the dependencies it relies
on, and a rough illustrative sketch (not a proposal). Show it, then move on immediately.

## 4. Design several interfaces in parallel

Dispatch three or more subagents at once, each with the same technical brief (paths, coupling, dependency
category, what is being hidden) and a different constraint:

1. Minimize the interface: one to three entry points.
2. Maximize flexibility: many use cases and extension points.
3. Optimize the most common caller: make the default case trivial.
4. (when relevant) Ports and adapters around cross-boundary dependencies.

Each returns: interface signature, usage example, what it hides, dependency strategy, trade-offs.

## 5. Recommend

Present the designs, compare them in prose, and give an opinionated recommendation (a hybrid is fine). The user
wants a strong read, not a menu.

## 6. Write the RFC

Write it to `docs/rfcs/NNNN-<slug>.md` using the template in [REFERENCE.md](REFERENCE.md), share the path, and
offer to turn it into a DevBox feature (`devbox feature "Deepen <module>"`) so it goes through the normal
spec, slice and critique gates. Refactors ship separately from behavior changes.
