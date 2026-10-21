---
name: deliver
description: The DevBox runner. Takes any software request (new product, feature, bug fix, refactor, "continue") and drives it to shipped through gated phases - intake, specify, clarify, design, plan, critique, build, verify, ship, learn - picking the right lane (patch, feature, product) and resuming from the state on disk. Use whenever the user asks to build, make, fix, ship or deliver software, says "devbox", "deliver", "continue", "what's next", or starts work in a DevBox project.
argument-hint: "[what to build | feature number | continue]"
---

# /devbox:deliver

You are the conductor. You do not hold the plan in your head; the files hold it. Your job is to find
where the work stands, pick the next phase, run it with the right skill, enforce its gate, and stop at
every human gate with a clear question.

Request: $ARGUMENTS

Playbook: `.devbox/playbooks/lifecycle.md` (or `${CLAUDE_PLUGIN_ROOT}/playbooks/lifecycle.md` before the
project is initialized). Read it once per session if you have not.

## 1. Orient (always, before anything else)

1. Run `devbox status` (fallback: `.devbox/bin/devbox status`). If it says "not inside a DevBox project",
   the next phase is **intake**: run `/devbox:intake` and come back.
2. Read `AGENTS.md`, `.devbox/constitution.md`, and for the active feature the last entry of
   `specs/NNN-name/progress.md`.
3. Run `git status` and `git log --oneline -5`. Note the branch and anything uncommitted.

## 2. Decide what this request is

- **"continue" / empty / a feature number**: resume the active (or named) feature at its current phase.
- **A new request**: classify the lane (one line, with the reason):
  - **Patch**: a bug or small change, one sitting, no new interface. Go to section 4.
  - **Feature**: new behavior in an existing system. `devbox feature "<short name>"`, then section 3.
  - **Product**: a new system or anything with one-way-door decisions. `/devbox:intake` (if needed), then
    write a roadmap of features in `docs/architecture.md`, then run the feature lane for the first one.
- If the request is too vague to classify, ask exactly one question with your recommended answer.

## 3. Run the phase the files say you are in

`devbox status` prints one of these phases for the feature. Run the matching skill, then re-run
`devbox status` to confirm the gate moved.

| Phase | Do this | Gate (do not pass without it) |
|-------|---------|-------------------------------|
| specify | `/devbox:spec` | spec complete with IDs, priorities, testable criteria, non-goals |
| clarify | `/devbox:grill` | zero clarification markers, then ask the human to approve; on yes run `devbox approve spec` |
| design | `/devbox:design` | constitution check done; one-way doors approved by the human; `devbox approve design` |
| plan | `/devbox:slice` | every acceptance criterion maps to a task; tasks vertical, AFK or HITL tagged |
| critique | `/devbox:critique` | Linus says GO; then `devbox approve tasks`. THROW AWAY: return to the phase it blames |
| build | `/devbox:build`, or offer AFK (`devbox run`) when the remaining tasks are AFK | each task verified, committed, checked off |
| blocked | read the `[!]` reasons in progress.md, resolve with the human | blocker removed, task reopened as `[ ]` |
| verify-ship | `/devbox:verify`, then `/devbox:review`, then `/devbox:ship` | evidence for every criterion; review clean; PR opened |
| done | `/devbox:retro` if no retro entry exists yet | lesson captured |

Small features may delete `design.md` (the phase then goes straight from approved spec to plan). Only do
that when the design would fit in two sentences, and say so in progress.md.

## 4. Patch lane

1. Reproduce: write the exact steps or a failing test that shows the bug (use `/devbox:debug` when the cause
   is not obvious). No fix before a reproduction.
2. Fix with `/devbox:tdd`: failing test, minimal fix, refactor.
3. `devbox verify`, then `/devbox:review` on the diff, then `/devbox:ship`.
4. If the patch grows (new interface, schema change, more than one sitting), stop and escalate to the
   feature lane: `devbox feature`, carry over what you learned.

## 5. Human gates: how to ask

At a human gate, stop and ask one crisp question with a recommendation, for example:
"Spec for 003-csv-export is ready: 4 stories, 11 criteria, P1 is the MVP. Approve it? (Recommended: yes,
the open question about archived rows was answered as 'exclude'.)" Then wait. Never run `devbox approve`
for spec, design or ship without an explicit yes in this conversation.

## 6. Between phases

- Append a `progress.md` entry for every phase you finish (format at the top of that file).
- Commit artifacts as you go (`docs(spec): ...`, `docs(design): ...`) on a feature branch, never on main.
- If the context is getting long, finish the phase, write progress, and suggest continuing in a fresh
  session with `/devbox:deliver continue`. The next session loses nothing because state is on disk.

## Rules

- Never skip a gate, and never claim a phase is done without the artifact and the evidence.
- Never write production code before the plan phase is approved, except in the patch lane after a reproduction.
- Never merge, deploy to production, publish packages, delete data or spend money. Ask the human.
- When an artifact is wrong, fix the artifact first, then the code. Specs and code must not drift.
