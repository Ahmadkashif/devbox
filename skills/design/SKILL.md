---
name: design
description: DevBox phase 3. Turns an approved spec into design.md - context diagram, chosen approach, deep modules and their interfaces, data model and migrations, contracts, key flows, security (STRIDE), observability, failure modes, rollout and rollback, testing strategy, alternatives - plus ADRs for significant decisions and a constitution check. Use when the phase is "design", or when the user says "design this", "architect this", "how should we build it".
argument-hint: "[feature number or name]"
---

# /devbox:design

Feature: $ARGUMENTS (default: the active feature). Precondition: `spec.md` has `status: approved`.

Playbooks: `.devbox/playbooks/architecture.md`, `api-design.md`, `security.md`, `operations.md`,
`testing.md`, and the shape playbook(s). The design is how; it must trace back to the spec's stories.

## Process

1. **Research before designing.** Read the spec, `docs/architecture.md`, existing ADRs, and the code the
   feature touches. Delegate broad exploration to an Explore subagent and keep the conclusions. For unknown
   libraries, APIs or approaches, run a short spike or web research and note findings in the design.
2. **Design it twice.** Sketch at least two genuinely different approaches (different module boundaries or
   data flows, not two names for the same thing). Compare them against the spec's NFRs, the constitution and
   reversibility. Pick one and say why in the "Approach" section.
3. **Find the deep modules.** Identify the modules to build or change. For each, write its public
   interface and what it hides. Small interface, real complexity behind it. Those interfaces are the test
   seams; confirm with the user which modules get tests at which level.
4. **Fill in `design.md`** from the template. Keep each section short and concrete:
   - data model with migrations planned as expand, migrate, contract;
   - contracts (OpenAPI, JSON Schema, protobuf, CLI flags, events) in `specs/NNN-name/contracts/` when they exist;
   - sequence diagrams only for flows that are not obvious;
   - security: STRIDE over each trust boundary; write a full threat model from
     `.devbox/templates/threat-model.md` for anything touching auth, money, personal data or untrusted input;
   - observability, performance budget, failure modes, rollout (flags) and rollback (under five minutes);
   - testing strategy mapping acceptance criteria to test levels.
5. **Record decisions.** Every hard-to-reverse or cross-cutting decision gets an ADR: `devbox adr "<title>"`,
   then fill it in. Link ADRs from the design. Mark one-way doors explicitly.
6. **Constitution check.** Fill the table at the bottom: each article, pass or fail, and for any exception
   the reason and the simpler alternative you rejected. Unjustified complexity is a design bug.
7. **Review and gate.** Ask the user to approve one-way-door decisions individually. For product-lane work
   or anything risky, run `/devbox:critique` on the design itself before slicing. On approval run
   `devbox approve design`, log progress, and commit (`docs(design): NNN-name`).

## Rules

- No new service, dependency, framework, queue or pattern without a line justifying it.
- Prefer the existing patterns of the codebase over new ones unless the design says why.
- Design for deletion: make it easy to remove or replace each piece.
- If designing reveals the spec is wrong or incomplete, stop and go back to `/devbox:grill`.
