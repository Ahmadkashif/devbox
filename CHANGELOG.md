# Changelog

All notable changes to DevBox are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/2.0.0/) and DevBox uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-10-21

### Added

- Claude Code plugin with a same-repo marketplace: 17 skills (`deliver` plus one per lifecycle phase and helpers
  for TDD, debugging, review, ADRs, architecture and writing voice), 9 subagents (Linus, five domain lenses, the
  verification lens, an implementer and an independent QA), and guardrail hooks (session status, Bash guard,
  secret guard).
- `devbox` CLI: `init`, `feature`, `status`, `next`, `approve`, `use`, `adr`, `verify`, `run` (AFK loop), `sync`,
  `doctor`, `shapes`.
- Playbooks: lifecycle, 13 core playbooks and 14 project-shape playbooks, with a bibliography in `docs/sources.md`.
- Templates: project scaffold (AGENTS.md, CLAUDE.md, constitution, config, architecture overview, ADR 0001, PR and
  issue templates, Dependabot, SECURITY.md), spec, design, tasks, progress, worker prompt, ADR, threat model,
  runbook, postmortem, release checklist, and SHA-pinned CI workflows for node, python, go, rust, jvm, dotnet and
  generic stacks.
- Test suite covering the CLI, the AFK runner, the hooks and repository hygiene.
