---
name: adr
description: Records an Architecture Decision Record in docs/adr/ (MADR 4 format) - context, drivers, options considered, decision, consequences, confirmation - for any hard-to-reverse or cross-cutting decision, and supersedes old ADRs instead of editing them. Use during design, when a significant technical choice is made or reversed, or when the user says "write an ADR", "record this decision", "why did we choose X".
argument-hint: "<decision title in imperative form, e.g. Use PostgreSQL for event storage>"
---

# /devbox:adr

Decision: $ARGUMENTS

## When an ADR is required

Write one when a decision is hard to reverse (a one-way door), affects more than one module, adds a
dependency, service, language or data store, changes a public contract, or when a reasonable person would
later ask "why is it like this?". Skip it for choices that are local and cheap to change.

## Steps

1. `devbox adr "<title>"` creates `docs/adr/NNNN-title.md` from the template and prints the path.
2. Fill it in, in this order:
   - **Context and problem statement**: the forces and the question, two to five sentences.
   - **Decision drivers**: the criteria that matter (latency, cost, team skills, compliance, time).
   - **Considered options**: at least two real options, including "do nothing" when it is viable.
   - **Decision outcome**: "Chosen option X, because ..." tied to the drivers, then the decision in active
     voice ("We will ...").
   - **Consequences**: good and bad, honestly. The bad ones are the point.
   - **Confirmation**: how compliance is checked (a lint rule, an architecture test, review) and when to revisit.
3. Status `proposed` until the human or team agrees; then `accepted`. Link it from the feature's `design.md`.
4. Commit: `docs(adr): NNNN title`.

## Changing a past decision

Never edit an accepted ADR's decision. Write a new ADR that references the old one, and change the old one's
status to `superseded by ADR-NNNN`. Small dated clarifications at the bottom are fine.
