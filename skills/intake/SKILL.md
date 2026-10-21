---
name: intake
description: Phase 0 of DevBox. Installs DevBox into a repository (new or existing), classifies the project shape and stack, configures the verify gates, fills in AGENTS.md, and adopts the project constitution. Use when starting a new project, adopting DevBox in an existing repo, when `devbox status` says the directory is not a DevBox project, or when the user says "set up devbox", "bootstrap", "new project".
argument-hint: "[project description or path]"
---

# /devbox:intake

Goal: a repository where any agent or human can run `devbox verify` and get a truthful green or red,
and where `AGENTS.md` tells them everything they would otherwise get wrong.

Input: $ARGUMENTS

## 1. Understand the project

- Existing code: explore it first (delegate a broad sweep to an Explore subagent). Find the language,
  framework, package manager, test runner, how it is built and run, and what is deployed where.
- New project: ask the user for a one-paragraph brief: who it is for, what problem it solves, constraints
  (platform, budget, deadline, compliance), and what "v1 works" means. Ask follow-ups one at a time,
  each with your recommended answer.

## 2. Classify

- **Shape** (one or more, comma separated): run `devbox shapes` to list them. Examples: a SaaS with a React
  front end and an API is `web-app,api-service`; a Python package is `library`; a scraper with a schedule is
  `data-pipeline`; a chat assistant is `llm-app` plus whatever hosts it.
- **Stack**: `node`, `python`, `go`, `rust`, `jvm`, `dotnet` or `generic`. Auto-detected from manifest files.
- For a new project, propose a stack using `.devbox/playbooks/languages.md` and the shape playbooks
  (`${CLAUDE_PLUGIN_ROOT}/playbooks/` before init). Prefer boring, well-supported defaults. Confirm with the user.

## 3. Install

```bash
devbox init --shape <shape[,shape]> --stack <stack> [--name <name>]
```

It never overwrites existing files (it prints `keep` for those). It vendors playbooks and templates into
`.devbox/`, a pinned copy of the CLI into `.devbox/bin/devbox` (used by CI), adds a CI workflow, PR and
issue templates, Dependabot config, `docs/adr/0001`, and gitignore entries. If `git` is not initialized,
run `git init` first and work on a branch such as `chore/devbox-intake`.

For a brand new project, also create the walking skeleton later as the first feature, not now.

## 4. Make the verify gates real

Open `.devbox/config`. For each of FORMAT, LINT, TYPECHECK, TEST, BUILD set the exact command this project
uses (look at package scripts, Makefiles, CI files). Then run `devbox verify`.

- Green: good. Red on a pre-existing problem: record it in `AGENTS.md` under Lessons learned, and agree with
  the user whether to fix it now (a patch) or temporarily blank that gate with a TODO and an issue.
- A project with no tests at all: keep TEST pointing at the runner anyway; the first feature adds tests.

## 5. Fill in AGENTS.md

Replace every `TODO(devbox)` section with facts you verified: what the project is, the repo map, setup and
run commands, conventions with one real example, where tests live. Keep it under about 150 lines; link to
docs instead of copying them. Remove anything an agent could infer from the code in seconds.
`CLAUDE.md` should stay a thin `@AGENTS.md` import plus Claude-only notes.

## 6. Constitution

Walk the user through `.devbox/constitution.md` article by article in a few lines each. Ask whether any
project-specific article belongs there (for example "all money in integer cents", "offline first",
"public API frozen until v2"). Record amendments in its table. This is a human gate: get an explicit OK.

## 7. Finish

- `devbox doctor` must report healthy (or list only accepted gaps).
- Commit: `chore: adopt DevBox (shape <shape>, stack <stack>)`.
- Tell the user the next step: the first feature (for new projects: the walking skeleton) via `/devbox:deliver`.
