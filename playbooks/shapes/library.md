# Library or SDK

> Reusable packages, SDKs and frameworks consumed by other developers' code

## When this applies

- Packages published to a registry (npm, PyPI, crates.io, Maven Central, NuGet, Go modules, SwiftPM).
- Internal shared libraries used by several services or apps.
- Client SDKs for an API: also read `api-service` for the contract, and consider generating the SDK from it.

## Default architecture

- A small public surface with an explicit boundary between public and internal (Rust `pub(crate)`, Go `internal/`, Python leading underscore plus `__all__`, TS package `exports`).
- No global mutable state. Configuration passed explicitly (options objects, builders, functional options).
- Typed, documented errors that callers can match on. Recoverable failures never panic or throw untyped exceptions.
- Types designed to evolve: non-exhaustive or sealed enums and structs, optional fields with defaults, no positional boolean parameters.
- Pluggable I/O: for SDKs, a transport layer the caller can replace (HTTP client, retries, timeouts, logging hooks).
- Minimal dependencies, and never expose a dependency's types in the public API (that couples your semver to theirs).
- Avoid starting with: a 1.0 before real users, a giant "utils" surface, abstract base classes for one implementation, framework lock-in for a general-purpose library.

## Quality attributes

- API stability: semver strictly followed once 1.0 ships; breaking changes only in a major release, after at least one minor release of deprecation.
- Dependency footprint: count and justify every runtime dependency; prefer zero.
- Supported runtimes: a documented minimum (MSRV for Rust, minimum Node, Python, JDK, .NET) that is tested in CI.
- Documentation: every public item documented with an example that compiles or runs.
- Performance: benchmarks for hot paths, tracked over releases.
- Supply-chain integrity: releases only from CI, with provenance and an SBOM.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- Who are the callers, and what is the first program they will write with this? Write that program in the spec.
- What is in scope for 1.0, and what is explicitly never going to be in this library?
- Which runtimes and versions must be supported, and for how long?
- What is the error-handling contract: which failures are recoverable, which are bugs?
- Thread safety, async model and cancellation expectations.
- Licensing and any constraints on dependencies' licenses.

/devbox:design should decide and record:

- The public API sketch (signatures and types) and what each module hides.
- The semver and deprecation policy (write it in the README).
- How the public API surface is tracked and diffed (see verify gates).
- Release process: version bump, CHANGELOG, tag, CI publish with trusted publishing (OIDC) and provenance.

## Testing strategy

- Unit tests through the public API, not internals, so refactors do not break tests.
- Documentation examples compiled and run as tests (Rust doctests, Python doctest or example tests, Go `Example` functions, TS type tests for typings).
- Public-API diff gates on every PR: cargo-semver-checks (Rust), api-extractor (TypeScript), japicmp or revapi (JVM), apidiff (Go), PublicApiAnalyzers (.NET).
- Version matrix: minimum supported runtime and latest; minimum and maximum dependency versions.
- Property-based tests for invariants (round trips, idempotence, ordering) and fuzzing for parsers and decoders.
- Mutation testing on core logic to check the suite actually catches bugs.
- A consumer test: a tiny project that installs the packed artifact and uses it, to catch packaging mistakes.

## Walking skeleton

T001 delivers: the package skeleton with one public function or type that does something real, documented with a tested example, the public API report checked in, a CI matrix covering the minimum and latest runtimes, and a dry-run publish (pack and install into a consumer test project).

## Checklist

- [ ] Semver and deprecation policy written in the README
- [ ] Public API surface report checked into the repo and diffed in CI
- [ ] CHANGELOG maintained (Keep a Changelog) with an Unreleased section
- [ ] Deprecations last at least one minor release before removal, with migration notes
- [ ] Minimum supported runtime version declared and tested in CI
- [ ] Every public item documented with a runnable example
- [ ] No panics or untyped exceptions for recoverable errors
- [ ] No dependency types exposed in the public API
- [ ] Runtime dependencies minimized and each one justified in design.md
- [ ] LICENSE and SECURITY.md present
- [ ] Releases published only from CI using trusted publishing (OIDC) with provenance attestations
- [ ] SBOM generated for each release
- [ ] Packed artifact installs and works in a clean consumer project
- [ ] Docs follow Diataxis: a tutorial, how-to guides, generated reference, and an explanation of design choices

## Pitfalls

- Hyrum's law: every observable behavior becomes a contract for someone. Keep the surface small and behavior documented.
- Staying on 0.x forever so nobody can depend on stability.
- Breaking changes in a patch or minor release.
- Never testing against minimum dependency versions, so the declared range is a lie.
- Leaking internal modules through re-exports or wildcard imports.
- Global configuration singletons that make two callers in one process fight.
- Publishing from a laptop: unreproducible builds and stolen-token risk.

## Verify gates

Use the stack defaults from `.devbox/playbooks/languages.md`, then add the API-surface check:

```
# Rust
DEVBOX_TEST_CMD=cargo nextest run && cargo test --doc
DEVBOX_BUILD_CMD=cargo build --all-features && cargo semver-checks
# TypeScript
DEVBOX_BUILD_CMD=pnpm run build && pnpm exec api-extractor run
```

CI extras: runtime and dependency-version matrix, `npm pack`/`uv build`/`cargo package` plus a consumer install test.

## Sources

- https://rust-lang.github.io/api-guidelines/checklist.html
- https://semver.org/spec/v2.0.0.html
- https://keepachangelog.com/
- https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/
- https://www.swift.org/documentation/api-design-guidelines/
- https://go.dev/blog/module-compatibility
- https://packaging.python.org/
- https://azure.github.io/azure-sdk/
- https://diataxis.fr/
- https://docs.pypi.org/trusted-publishers/
- https://docs.npmjs.com/generating-provenance-statements
