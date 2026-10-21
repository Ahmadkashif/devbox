---
name: spec
description: DevBox phase 1. Turns a request into specs/NNN-name/spec.md - problem, outcome, prioritized user stories with stable IDs, testable acceptance criteria in EARS or Given/When/Then, edge cases, measurable non-functional requirements, scope and non-goals - describing what and why, never how. Use after `devbox feature`, when the phase is "specify", or when the user says "write a spec", "write a PRD", "spec this out".
argument-hint: "[feature number or name]"
---

# /devbox:spec

A spec is the contract between the person who wants something and everyone who builds and tests it.
It says **what** and **why**. File paths, libraries, code and schemas belong in `design.md`.

Feature: $ARGUMENTS (default: the active feature from `devbox status`)

Playbooks: `.devbox/playbooks/requirements.md` and the shape playbook(s) in `.devbox/playbooks/shapes/`.

## Process

1. **Collect the raw request.** If the user has not given a detailed description, ask for one: the
   problem, who has it, what they do today, what success looks like, and any solution ideas. Let them ramble.
2. **Verify against reality.** Explore the codebase (or delegate to an Explore subagent) to check every
   claim the user made about current behavior. Note contradictions; they become questions.
3. **Draft `spec.md`** from the template already in the feature folder:
   - **Problem and outcome** in the user's language, with evidence when there is any.
   - **User stories** `US1`, `US2`, ... each with a priority. P1 stories alone must form a shippable,
     demoable increment (the MVP). Make the list extensive: cover every actor and every path, including
     admin, error, empty and first-run states.
   - **Acceptance criteria** `AC1.1`, `AC1.2`, ... under each story. Each must be testable as written, using
     EARS (`WHEN <trigger> THE SYSTEM SHALL <response>`, `IF <unwanted> THEN ...`, `WHILE <state> ...`,
     `WHERE <feature> ...`) or Given/When/Then. One behavior per criterion. No "fast", "easy", "intuitive"
     without a number.
   - **Edge cases and failure modes**: empty, huge, malformed, duplicate, concurrent input; dependency down;
     no permission. Use the shape playbook's "Spec and design prompts" list.
   - **NFRs** only where they matter, each with a number or a named standard and how it will be checked.
   - **Success metrics**, **scope**, explicit **out of scope**, **assumptions**.
   - Set `appetite:` (how much time this is worth) and `lane:` in the front matter.
4. **Mark every unknown inline** with a clarification marker (square brackets, the words NEEDS
   CLARIFICATION, a colon and the question). Do not guess and do not ask everything now; the grill phase
   resolves them.
5. **Self-check** the spec against the requirements quality checklist in `requirements.md` (complete,
   unambiguous, consistent, testable, no implementation detail). Fix what fails.
6. **Log and hand off.** Append a progress entry, commit (`docs(spec): draft NNN-name`), and continue with
   `/devbox:grill`. Leave `status: draft`; only the human approval after grilling flips it.

## Rules

- Never put implementation in the spec. If you catch yourself naming a table or a library, move it to a
  note for the design phase.
- Every criterion must be something a test or a person can check with a yes or no.
- Prefer many small stories over a few big ones. Split any story with more than five criteria.
- Write for a reader who was not in the conversation.
