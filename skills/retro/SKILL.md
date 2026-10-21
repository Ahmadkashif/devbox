---
name: retro
description: DevBox phase 9 (learn). Runs a short blameless retrospective after a feature ships or an incident - what went well, what hurt, where the process or the agents went wrong - and turns each lesson into a durable change in AGENTS.md, the constitution, a playbook, a hook or a test. Also writes postmortems for incidents. Use after `devbox approve ship`, after an incident, or when the user says "retro", "postmortem", "what did we learn".
argument-hint: "[feature number | incident description]"
---

# /devbox:retro

Lessons that stay in chat are lost. A retro is only done when something on disk changed, or when you have
written down that nothing needs to.

Target: $ARGUMENTS (default: the most recently shipped feature)

## Feature retro

1. Read the feature's `progress.md` from top to bottom, the PR discussion (`gh pr view --comments`), and the
   git log for the branch.
2. Collect facts, not feelings:
   - estimate versus actual (appetite in spec.md versus dates in progress.md);
   - gates that failed and why (THROW AWAY verdicts, red verify runs, QA failures, review findings);
   - rework: tasks reopened, specs changed after approval, design drift;
   - agent failure modes: scope creep, hallucinated APIs, weakened tests, missed context, repeated mistakes.
3. For each problem, ask "what would have prevented this?" and pick the cheapest durable fix, in this order
   of preference: a deterministic check (test, lint rule, hook, CI step) beats a playbook rule, which beats a
   line in `AGENTS.md`, which beats a note.
4. Make the changes (small PRs), and append a `## Retro` entry to progress.md: went well, hurt, changes made
   (with links), and follow-ups filed as issues.
5. If a change should apply to every DevBox project, not just this one, say so and suggest the edit to the
   DevBox repository itself (a playbook or skill), so the harness improves too.

## Incident postmortem

Use `.devbox/templates/postmortem.md`, written to `docs/postmortems/YYYY-MM-DD-<slug>.md`. Blameless: describe
what the system and process allowed, never who to blame. Build the timeline from logs and commits. Every action
item gets an owner and a tracking issue. An incident that burned more than 20% of an error budget needs at least
one P0 action.

## Rules

- Keep it short: a retro longer than the feature's spec is a smell.
- No vague actions ("be more careful"). Every action is a concrete change someone can review.
- Prune: if an `AGENTS.md` rule never changed behavior, delete it while you are there.
