---
name: critique
description: DevBox phase 5. Hands the plan (spec + design + tasks, or any written plan or diff) to the devbox:linus subagent for an independent, adversarial GO / THROW AWAY verdict backed by domain lenses and a verification pass, records the verdict, and approves the tasks only on GO. Use when the phase is "critique", before any risky change, or when the user says "call Linus", "ask Linus", "critique this plan", "sanity check this".
argument-hint: "[feature number | path to plan | inline plan]"
---

# /devbox:critique

You are the neutral session that wrote the plan. Linus is the expert who did not. The difference between
what you would have done and what Linus says is the whole point, so do not argue him down in advance.

Target: $ARGUMENTS (default: the active feature's spec, design and tasks)

## How to invoke

1. **Resolve the plan.** A feature: collect paths to `spec.md`, `design.md`, `tasks.md` and linked ADRs.
   A file path: use the file. Inline text: use it. Nothing given and no active feature: use the most recent
   plan you proposed in this session; if there is none, ask for one.
2. **Assemble the handoff** (Linus reads files himself, so pass paths, not pasted contents):
   - the plan location(s) and the stated intent (the why, in one or two sentences);
   - the repository root and current branch;
   - the files and systems the plan expects to touch;
   - anything the user said that constrains the plan.
3. **Dispatch** the `devbox:linus` subagent with that handoff. Tell him to follow his protocol in full:
   context detection, triage, serial lenses, self-verification, the mandatory verification-lens pass, and
   the three-line case.
4. **Return the verdict verbatim** to the user. Do not soften it, summarize it away or add your own spin.
   Then add one line of your own: what you will change, or why you disagree (with evidence).

## After the verdict

- **GO**: append the verdict and the three-line case to `progress.md`, run `devbox approve tasks`, commit,
  and continue to build. Note the "watch during execution" line in progress so the build phase sees it.
- **THROW AWAY**: do not approve. Identify which artifact is wrong (spec, design or tasks), go back to that
  phase, fix it, and run the critique again. Two consecutive THROW AWAYs on the same plan: stop and talk
  to the user about the approach itself.

## Rules

- Never execute a plan that got THROW AWAY.
- Never edit files on Linus's behalf while he is reviewing, and never filter his findings.
- Critique is cheap compared with building the wrong thing. When in doubt, run it.
