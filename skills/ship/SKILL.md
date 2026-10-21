---
name: ship
description: DevBox phase 8. Prepares a verified branch for release - final checks, CHANGELOG entry, SemVer bump, PR with evidence and rollback plan opened via gh with the user requested as reviewer, release notes and rollout plan - and stops at the human merge and deploy gates. Use when the phase is "verify-ship" after verification passed, or when the user says "ship it", "open a PR", "release", "cut a version".
argument-hint: "[feature number] [--release]"
---

# /devbox:ship

Feature: $ARGUMENTS (default: the active feature). Precondition: `/devbox:verify` wrote "Verified" for the
current commit and `/devbox:review` has no open CRITICAL or MAJOR findings. If not, go there first.

Checklist: `.devbox/templates/release-checklist.md`. Playbook: `.devbox/playbooks/git-and-release.md`.

## 1. Final checks

- `git status` clean; branch is not protected; rebased or merged with the latest `main` and still green
  (`devbox verify` again after updating).
- No secrets, debug output, commented-out code, stray TODOs without an issue in `git diff main...HEAD`.
- Docs updated where behavior changed: README, reference docs, help text, `docs/architecture.md`, ADRs.

## 2. Changelog and version

- Add the change under `## [Unreleased]` in `CHANGELOG.md` (create it from Keep a Changelog if missing),
  grouped as Added, Changed, Deprecated, Removed, Fixed, Security. Written for users, not a commit dump.
  Mark breaking changes with **Breaking:**.
- Releases only (`--release`, or when the project releases per merge): pick the SemVer bump from the changes
  (breaking: MAJOR, feat: MINOR, fix: PATCH; 0.x may break in MINOR), update the manifest version, move
  Unreleased into a dated version section. The tag is created after the human merges, by the human or CI.

## 3. Pull request

Write the PR body with the project template (`.github/pull_request_template.md`). Make it human: lead with
the problem and the outcome in two sentences, then the approach. Include the verification matrix summary and
the `devbox verify` output, the risk and the rollback steps, and links to the spec and tasks. Apply the
`/devbox:humanize` rules (no em-dashes, no filler). Then:

```bash
git push -u origin HEAD
gh pr create --title "<conventional title>" --body-file <file> --reviewer <user>
```

Request the user's review (use the reviewer named in the user's instructions, otherwise ask). Add the PR URL to
progress.md. If there is no GitHub remote, stop and give the user the exact commands instead.

## 4. Rollout plan

In the PR and progress.md: how it is deployed (flag default off, canary, percentage), what to watch (the
golden signals, the spec's success metrics), and the rollback in under five minutes. For data migrations, the
expand, migrate, contract order and what happens if each step fails.

## 5. Human gates (stop here)

The human reviews, merges and deploys. You do not run `gh pr merge`, deploy to production, publish packages
or create release tags without an explicit instruction for that specific action. After the human confirms the
merge, run `devbox approve ship`, log it, and continue with `/devbox:retro`.
