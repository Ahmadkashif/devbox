---
name: review
description: Reviews a diff (branch, commit range, PR or task commits) like a staff engineer - necessity, fragility, modularity and cross-file synthesis - by dispatching the right DevBox domain lenses (frontend, backend, infra, ai, security) and the verification lens, then reports verified findings by severity and helps resolve them. Use before shipping, after each non-trivial build task, or when the user says "review this", "review my PR", "code review".
argument-hint: "[base..head | PR number | branch] (default: current branch vs main)"
---

# /devbox:review

Target: $ARGUMENTS (default: `main...HEAD`)

Method: `.devbox/playbooks/code-review.md` (or `${CLAUDE_PLUGIN_ROOT}/playbooks/code-review.md`).

## 1. Scope the diff

- Resolve the range. A PR number: `gh pr view <n> --json baseRefName,headRefName,title,body` and
  `gh pr diff <n>`. A branch: `git diff --stat main...HEAD`.
- Read the intent: the PR description, or the feature's spec and tasks. A review without the intent is a
  style check.
- Size check: more than about 400 changed lines of hand-written code, or several unrelated concerns, is
  itself a finding. Suggest how to split it.

## 2. Triage lenses

Decide which lenses apply and say why in one line each:

| Lens agent | Call when the diff touches |
|------------|----------------------------|
| `devbox:frontend-lens` | UI components, client state, styles, browser code, accessibility, SSR |
| `devbox:backend-lens` | APIs, services, database queries and migrations, jobs, auth logic |
| `devbox:infra-lens` | CI/CD, Docker, IaC, Kubernetes, deploy scripts, env and config schemas |
| `devbox:ai-lens` | prompts, LLM calls, tool definitions, agents, evals, model config |
| `devbox:security-lens` | auth, sessions, crypto, secrets, input parsing, file upload, permissions, dependencies |

Dispatch the chosen lenses one at a time, most likely to find a blocker first, each with the diff range,
the intent and its subset of files. Small diffs (a few lines, one concern) can be reviewed directly by you
with the three lenses from the playbook instead.

## 3. Verify, always

After the lenses return, dispatch `devbox:verification-lens` with the intent, the consolidated findings and
the list of changed files. Keep only CONFIRMED and UPGRADED findings, add MISSED ones, and weigh OBJECTIONs.
Drop anything nobody could prove from the source.

## 4. Report

Group by file, most severe first:

```
## path/to/file.ts
**[CRITICAL]** (L42) what breaks, the concrete trigger, what the user sees, and the fix (with code).
**[MAJOR]** (L88) ...
```

Start with one line of cross-file synthesis. Skip files with no findings. No praise padding, no restating
what the code does, no em-dashes. If there is nothing to report, say "No blocking findings" and the one thing
worth watching.

## 5. Resolve

- When reviewing your own work: fix CRITICAL and MAJOR findings now (test first), re-run `devbox verify`,
  re-review the changed lines. MINOR findings become follow-up notes, not scope creep.
- When receiving review from others: evaluate each item technically against the code. Push back with evidence
  when a finding is wrong; never agree just to be agreeable. Fix in order: blocking, simple, complex.
- With `--comment` on a PR and the user's OK, post findings as review comments via `gh`.
