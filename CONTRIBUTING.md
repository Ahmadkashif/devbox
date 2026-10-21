# Contributing to DevBox

DevBox is developed with DevBox. Read [AGENTS.md](AGENTS.md) for the conventions.

1. Open an issue describing the problem first, unless the change is small and obvious.
2. Work on a branch (`feat/...`, `fix/...`, `docs/...`).
3. Add or update a check in `tests/run.sh` for any change to the CLI, hooks or templates.
4. Run `tests/run.sh` and `claude plugin validate .` until both pass.
5. For playbook changes, cite the source and add it to `docs/sources.md` if it is new.
6. Open a pull request using Conventional Commits for the title. Describe the problem, the change and the evidence.
