---
name: grill
description: DevBox phase 2 (clarify). Interviews the user relentlessly, one question at a time with a recommended answer, walking every branch of the design tree until the spec has zero clarification markers and a shared understanding exists; folds answers back into spec.md and asks for approval. Use when the phase is "clarify", or when the user says "grill me", "interview me", "poke holes in this", "clarify the spec".
argument-hint: "[feature number | path to a PRD or plan]"
---

# /devbox:grill

Interview the user about every aspect of this spec until you both understand it the same way. Walk down
each branch of the design tree and resolve dependencies between decisions in order. For every question,
give your recommended answer and why.

Target: $ARGUMENTS (default: the active feature's `spec.md`; any PRD or plan file path also works)

## Procedure

1. **Read the whole spec**, plus `design.md` if it exists. Do not skim. List every decision that is stated,
   implied but unstated, or missing.
2. **Answer what the code can answer.** If a question is about current behavior, explore the codebase
   instead of asking. Only ask the human what only the human knows.
3. **Build the question list** covering: every clarification marker; ambiguous wording; unstated
   assumptions; branch points (where one choice forks into sub-decisions); edge cases with no defined
   behavior; NFRs with no number; scope boundaries; who the actors are and what they may do; data
   ownership, retention and privacy; failure behavior; how success is measured.
4. **Order by dependency.** Ask the questions whose answers change other questions first.
5. **Ask one at a time.** Each question has: the question, two to four concrete options when that helps,
   your recommended answer with a one-line reason, and what it unblocks. Use the AskUserQuestion tool when
   it is available. Never batch questions.
6. **Fold each answer in immediately.** Update the story or criterion, remove the marker, and add one line to
   the decisions log: `Q: ... -> A: ... (why)`. If the answer creates new questions, insert them in order.
7. **Stop when** there are no markers left, every criterion is testable, and the user has nothing to add.
   If the user says "stop" earlier, mark the remaining items as explicit assumptions in the spec.
8. **Approval gate.** Summarize in three lines: stories and priorities, the decisions that changed the
   spec, any accepted assumptions. Ask: "Approve the spec?" On an explicit yes run `devbox approve spec`,
   append a progress entry, and commit (`docs(spec): approve NNN-name`).

## Rules

- One question per message. A question with no recommendation is lazy; always recommend.
- Challenge the premise when it deserves it: "Do we need this at all?" is a valid question.
- Do not drift into implementation design unless the user's answer depends on it.
- Never approve on the user's behalf, and never treat silence as a yes.
