# Sources

Everything DevBox recommends traces back to a published methodology, guideline or standard. This is the
bibliography. The research behind it was done on 2026-10-21; versions, tool releases and URLs move, so
re-check anything version-specific before relying on it, and prefer reading versions from lockfiles and
Dependabot over hard-coding them.

## Agentic and spec-driven development

- [GitHub Spec Kit](https://github.com/github/spec-kit): the `specs/NNN-feature/` layout, constitution articles, clarification markers, task IDs, the constitution check gate, and the read-only cross-artifact analysis before implementing.
- [obra/superpowers](https://github.com/obra/superpowers): brainstorm, plan, subagent-driven development with a fresh implementer per task, TDD as a hard rule, systematic debugging, verification before completion, and how to receive review without performing agreement.
- [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD): role personas that each own one artifact, scale-adaptive planning tracks, a fresh context per story, and retros that feed back into the process.
- [AGENTS.md](https://agents.md/): one canonical, agent-agnostic instruction file per repo, with a thin CLAUDE.md importing it.
- [Claude Code best practices](https://code.claude.com/docs/en/best-practices): explore, plan, implement, commit; give the agent a check it can run; keep CLAUDE.md short; hooks for anything that must always happen.
- [Claude Code plugins, skills, subagents and hooks](https://code.claude.com/docs/en/plugins/manifest-reference.md): the plugin layout DevBox ships as (also [skills](https://code.claude.com/docs/en/skills.md), [sub-agents](https://code.claude.com/docs/en/sub-agents.md), [hooks](https://code.claude.com/docs/en/hooks.md), [headless mode](https://code.claude.com/docs/en/headless.md), [memory and AGENTS.md](https://code.claude.com/docs/en/memory.md)).
- [Anthropic: Building effective agents](https://www.anthropic.com/engineering/building-effective-agents): the pattern ladder (augmented LLM, workflows, agents) and "simplest thing first".
- [Anthropic: Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents): context as a scarce budget; just-in-time retrieval; compaction.
- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents): initializer plus coding sessions, one feature per session, a progress file, never edit tests to pass.
- [Anthropic: Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps): planner, generator and evaluator roles; agree on "done" before building; remove scaffolding as models improve.
- [Anthropic: Writing effective tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents): clear, narrow, mistake-proof tools.
- [Anthropic: Demystifying evals for AI agents](https://www.anthropic.com/research/demystifying-evals-for-ai-agents): code graders first, calibrated judges, capability vs regression suites, pass@k and pass^k.
- [mattpocock/skills](https://github.com/mattpocock/skills): grill-me interviews, PRD and ticket skills, tracer-bullet vertical slices, HITL vs AFK tasks, deep modules, and TDD one seam at a time.
- [HumanLayer: 12-factor agents](https://github.com/humanlayer/12-factor-agents): own your prompts, context and control flow; small focused agents; contact humans through tools.
- [HumanLayer: Advanced context engineering for coding agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents): research, plan, implement with frequent intentional compaction; humans review plans, not giant diffs.
- [Geoffrey Huntley: Ralph](https://ghuntley.com/ralph/) and [how-to-ralph-wiggum](https://github.com/ghuntley/how-to-ralph-wiggum): the fresh-context loop with deterministic backpressure that `devbox run` is built on, plus the guardrails (sandbox, one task per loop, never placeholder implementations).
- [Kiro specs](https://kiro.dev/docs/specs/): requirements, design and tasks documents, EARS acceptance criteria, bugfix specs that record unchanged behavior.
- [EARS (Easy Approach to Requirements Syntax)](https://alistairmavin.com/ears/): the ubiquitous, event, state, unwanted, optional and complex requirement patterns.
- [GSD Core](https://github.com/open-gsd/gsd-core): discuss, plan, execute, verify, ship per phase; reversibility ratings that force human checkpoints.
- [Agent Skills specification](https://agentskills.io/specification): SKILL.md format and progressive disclosure.
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code): survey of community workflows and orchestration patterns.

## Engineering practice

- [Google Engineering Practices](https://google.github.io/eng-practices/): the code review order (design, functionality, complexity, tests, naming, comments, style, docs), small changes, good change descriptions, and "approve when it improves code health".
- [The Twelve-Factor App](https://12factor.net/) and its [open-source refresh](https://github.com/twelve-factor/twelve-factor): config in the environment, disposable stateless processes, logs as event streams, dev/prod parity.
- [Conventional Commits 1.0](https://www.conventionalcommits.org/en/v1.0.0/): the commit message format DevBox uses.
- [Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html): version numbers derived from the kind of change.
- [Keep a Changelog](https://keepachangelog.com/): human-written changelogs with an Unreleased section and fixed change types.
- [Michael Nygard: Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions): the original ADR format.
- [MADR 4](https://adr.github.io/madr/) and [adr.github.io](https://adr.github.io/): the ADR template DevBox ships.
- [joelparkerhenderson/architecture-decision-record](https://github.com/joelparkerhenderson/architecture-decision-record): ADR examples and naming guidance.
- [C4 model](https://c4model.com/): context and container diagrams for every system, components only where needed.
- [arc42](https://arc42.org/overview): the section structure behind `docs/architecture.md`.
- [Trunk-based development](https://trunkbaseddevelopment.com/): short-lived branches, integrate at least daily, feature flags.
- [DORA metrics](https://dora.dev/guides/dora-metrics/) and [capabilities](https://dora.dev/capabilities/): the five delivery metrics and the capabilities that move them; the [2025 report](https://dora.dev/research/2025/dora-report/) on AI as an amplifier.
- [Google SRE book](https://sre.google/sre-book/table-of-contents/) and [workbook](https://sre.google/workbook/table-of-contents/): SLIs, SLOs, error budgets, the four golden signals, toil, and blameless postmortems.
- [OpenTelemetry](https://opentelemetry.io/docs/concepts/signals/) and [semantic conventions](https://opentelemetry.io/docs/specs/semconv/): vendor-neutral traces, metrics and logs.

## Security

- [OWASP Top 10:2025](https://owasp.org/Top10/2025/): the baseline risk list, including software supply chain failures and mishandling of exceptional conditions.
- [OWASP ASVS 5.0](https://owasp.org/www-project-application-security-verification-standard/): verification levels L1 to L3 for application security requirements.
- [OWASP API Security Top 10](https://owasp.org/API-Security/): object-level authorization first.
- [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/llm-top-10/): the LLM risks covered in `llm-app`.
- [OWASP Agentic Security Initiative](https://genai.owasp.org/initiatives/agentic-security-initiative/): the Top 10 for Agentic Applications (2026 edition).
- [OWASP MAS (MASVS, MASTG, MASWE)](https://mas.owasp.org/): mobile security verification.
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/): implementation details, including [secrets management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html).
- [NIST SSDF SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final): the secure development practice groups (prepare, protect, produce, respond).
- [SLSA v1.2](https://slsa.dev/spec/v1.2/): build provenance levels and the source track.
- [OpenSSF Scorecard checks](https://github.com/ossf/scorecard/blob/main/docs/checks.md): repository hygiene checks (token permissions, pinned dependencies, branch protection).
- [Threat Modeling Manifesto](https://www.threatmodelingmanifesto.org/) and [STRIDE](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats): the four questions and the threat categories in the threat model template.
- [EU Cyber Resilience Act](https://digital-strategy.ec.europa.eu/en/policies/cyber-resilience-act): reporting and security obligations for products with digital elements.

## Testing

- [Kent Beck: Canon TDD](https://newsletter.kentbeck.com/p/canon-tdd): test list, one test at a time, make it pass, refactor.
- [Martin Fowler: The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html) and [Kent C. Dodds: The Testing Trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications): invest by confidence per cost; mostly integration tests.
- [Test Desiderata](https://testdesiderata.com/): the properties of good tests.
- [Hypothesis](https://hypothesis.readthedocs.io/) and [fast-check](https://fast-check.dev/): property-based testing.
- [Pact](https://docs.pact.io/): consumer-driven contract testing.
- [Stryker](https://stryker-mutator.io/) and [PIT](https://pitest.org/): mutation testing to measure suite quality.
- [Google: The ML Test Score](https://research.google/pubs/pub46555/): test areas for ML systems.

## Documentation

- [Diataxis](https://diataxis.fr/): tutorials, how-to guides, reference and explanation, never mixed.
- [Write the Docs: docs as code](https://www.writethedocs.org/guide/docs-as-code/): docs in the repo, reviewed with the code.
- [Standard Readme](https://github.com/RichardLitt/standard-readme) and [GitHub: About READMEs](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes): README structure.

## Design

- [John Ousterhout: A Philosophy of Software Design](https://web.stanford.edu/~ouster/cgi-bin/book.php): deep modules, information hiding, strategic programming.
- [Eric Evans: DDD Reference](https://www.domainlanguage.com/ddd/reference/) and [Martin Fowler: Bounded Context](https://martinfowler.com/bliki/BoundedContext.html): ubiquitous language, bounded contexts, aggregates.
- [Alistair Cockburn: Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/) and [Robert C. Martin: The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html): dependencies point inward, adapters at the edge.
- [Martin Fowler: YAGNI](https://martinfowler.com/bliki/Yagni.html) and [Sandi Metz: The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction): build only what is needed; prefer duplication to the wrong abstraction.

## API design

- [Google AIP](https://google.aip.dev/): resource-oriented design, standard methods, pagination, compatibility.
- [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines): the Azure and Graph guidelines (the root document is deprecated).
- [Zalando RESTful API Guidelines](https://opensource.zalando.com/restful-api-guidelines/): API-first, compatibility rules, naming.
- [RFC 9110 HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110) and [RFC 9457 Problem Details](https://www.rfc-editor.org/rfc/rfc9457): status codes and the error format.
- [IETF Idempotency-Key header draft](https://datatracker.ietf.org/doc/draft-ietf-httpapi-idempotency-key-header/): the de facto idempotency pattern (the draft itself has expired).
- [OpenAPI Specification](https://spec.openapis.org/), [protobuf best practices](https://protobuf.dev/best-practices/), [Buf style guide](https://buf.build/docs/best-practices/style-guide), [GraphQL best practices](https://graphql.org/learn/best-practices/): contract-first API definitions.

## Process

- [Shape Up](https://basecamp.com/shapeup): appetite instead of estimates, shaping before betting, circuit breakers, hill charts.
- [Extreme Programming](http://www.extremeprogramming.org/): TDD, continuous integration, small releases, simple design.
- [The Scrum Guide 2020](https://scrumguides.org/scrum-guide.html): goals, increments and the Definition of Done.
- [Kanban Guide](https://kanbanguides.org/): visualize work, limit WIP, manage flow.
- [Design Council: Double Diamond](https://www.designcouncil.org.uk/our-resources/the-double-diamond/): find the right problem before the right solution.
- [Jobs to be Done](https://jtbd.info/): job stories ("When ..., I want to ..., so I can ...").
- [INVEST in good stories](https://xp123.com/articles/invest-in-good-stories-and-smart-tasks/): independent, negotiable, valuable, estimable, small, testable.
- [Martin Fowler: Given When Then](https://martinfowler.com/bliki/GivenWhenThen.html) and [Gherkin reference](https://cucumber.io/docs/gherkin/reference/): acceptance criteria format.

## Project shapes

- Web: [Core Web Vitals](https://web.dev/articles/vitals), [WCAG 2.2](https://www.w3.org/TR/WCAG22/), [WAI-ARIA APG](https://www.w3.org/WAI/ARIA/apg/), [MDN progressive enhancement](https://developer.mozilla.org/en-US/docs/Glossary/Progressive_Enhancement).
- CLI: [Command Line Interface Guidelines](https://clig.dev/), [no-color.org](https://no-color.org/), [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/latest/).
- Libraries: [Rust API Guidelines checklist](https://rust-lang.github.io/api-guidelines/checklist.html), [.NET design guidelines](https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/), [Swift API design guidelines](https://www.swift.org/documentation/api-design-guidelines/), [Go module compatibility](https://go.dev/blog/module-compatibility), [Azure SDK guidelines](https://azure.github.io/azure-sdk/).
- Mobile: [Apple HIG](https://developer.apple.com/design/human-interface-guidelines), [Material Design 3](https://m3.material.io/), [Android architecture](https://developer.android.com/topic/architecture), [Play target SDK requirements](https://developer.android.com/google/play/requirements/target-sdk).
- Desktop: [Electron security](https://www.electronjs.org/docs/latest/tutorial/security), [Electron fuses](https://www.electronjs.org/docs/latest/tutorial/fuses), [Tauri v2 security](https://v2.tauri.app/security/), [The Update Framework](https://theupdateframework.io/).
- Data: [dbt best practices](https://docs.getdbt.com/best-practices), [Functional data engineering](https://maximebeauchemin.medium.com/functional-data-engineering-a-modern-paradigm-for-batch-data-processing-2327ec32c42a), [Open Data Contract Standard](https://github.com/bitol-io/open-data-contract-standard), [OpenLineage](https://openlineage.io/).
- ML: [Rules of Machine Learning](https://developers.google.com/machine-learning/guides/rules-of-ml), [MLOps on Google Cloud](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning), [Model Cards](https://arxiv.org/abs/1810.03993), [NIST AI RMF](https://www.nist.gov/itl/ai-risk-management-framework).
- LLM apps: [MCP security best practices](https://modelcontextprotocol.io/specification/latest/basic/security_best_practices), [OpenTelemetry GenAI conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/).
- Infrastructure: [Terraform style guide](https://developer.hashicorp.com/terraform/language/style), [terraform-best-practices.com](https://www.terraform-best-practices.com/), [OpenTofu](https://opentofu.org/docs/), [OpenGitOps](https://opengitops.dev/), [Kubernetes production environment](https://kubernetes.io/docs/setup/production-environment/), [Kubernetes security checklist](https://kubernetes.io/docs/concepts/security/security-checklist/), [learnk8s production best practices](https://learnk8s.io/production-best-practices).
- Embedded: [MISRA](https://misra.org.uk/), [BARR-C:2018](https://barrgroup.com/embedded-systems/books/embedded-c-coding-standard), [SEI CERT C](https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard), [MCUboot](https://docs.mcuboot.com/), [ETSI EN 303 645](https://www.etsi.org/technologies/consumer-iot-security).
- Games: [Game Programming Patterns](https://gameprogrammingpatterns.com/), [Fix Your Timestep](https://gafferongames.com/post/fix_your_timestep/), [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/), [Xbox Accessibility Guidelines](https://learn.microsoft.com/en-us/gaming/accessibility/guidelines).
- Browser extensions: [Chrome extensions docs](https://developer.chrome.com/docs/extensions), [MDN WebExtensions](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions), [WXT](https://wxt.dev/).
- Smart contracts: [OWASP Smart Contract Top 10](https://scs.owasp.org/sctop10/), [EEA EthTrust Security Levels](https://entethalliance.org/specs/ethtrust-sl/), [Solidity security considerations](https://docs.soliditylang.org/en/latest/security-considerations.html), [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/), [Building Secure Contracts](https://secure-contracts.com/).

## Languages and toolchains

- [Google style guides](https://google.github.io/styleguide/): C++, Java, Python, Shell, TypeScript, Go and more.
- TypeScript and JavaScript: [Biome](https://biomejs.dev/), [ESLint](https://eslint.org/), [TypeScript](https://www.typescriptlang.org/), [Vitest](https://vitest.dev/), [Playwright](https://playwright.dev/), [pnpm](https://pnpm.io/).
- Python: [PEP 8](https://peps.python.org/pep-0008/), [uv](https://docs.astral.sh/uv/), [Ruff](https://docs.astral.sh/ruff/), [Pyright](https://github.com/microsoft/pyright), [pytest](https://docs.pytest.org/).
- Go: [Effective Go](https://go.dev/doc/effective_go), [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments), [golangci-lint](https://golangci-lint.run/).
- Rust: [Rust style guide](https://doc.rust-lang.org/style-guide/), [Clippy](https://doc.rust-lang.org/clippy/), [cargo-nextest](https://nexte.st/), [cargo-semver-checks](https://github.com/obi1kenobi/cargo-semver-checks).
- JVM: [Google Java Style](https://google.github.io/styleguide/javaguide.html), [Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html), [detekt](https://detekt.dev/), [JUnit](https://junit.org/).
- .NET: [C# coding conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions), [dotnet format](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format).
- Swift: [Swift API design guidelines](https://www.swift.org/documentation/api-design-guidelines/), [SwiftLint](https://github.com/realm/SwiftLint), [Swift Testing](https://developer.apple.com/xcode/swift-testing/).
- C and C++: [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/), [clang-tidy](https://clang.llvm.org/extra/clang-tidy/), [CMake presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html).
- Ruby: [Ruby Style Guide](https://rubystyle.guide/), [RuboCop](https://rubocop.org/). PHP: [PER Coding Style](https://www.php-fig.org/per/coding-style/), [PHPStan](https://phpstan.org/).
- Shell: [ShellCheck](https://www.shellcheck.net/), [shfmt](https://github.com/mvdan/sh), [bats-core](https://github.com/bats-core/bats-core). SQL: [SQLFluff](https://docs.sqlfluff.com/), [SQL Style Guide](https://www.sqlstyle.guide/).

## CI/CD and repository hygiene

- [GitHub Actions security hardening](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions): pin actions to commit SHAs, least-privilege `permissions:`, no untrusted input interpolated into `run:`.
- [GitHub changelog: SHA pinning and action blocking policy](https://github.blog/changelog/2025-08-15-github-actions-policy-now-supports-blocking-and-sha-pinning-actions/): org-level enforcement of pinned actions.
- [actionlint](https://github.com/rhysd/actionlint) and [zizmor](https://github.com/zizmorcore/zizmor): workflow linting and security auditing.
- [Dependabot](https://docs.github.com/en/code-security/dependabot) and [Renovate](https://docs.renovatebot.com/): grouped dependency updates with a cooldown.
- [CodeQL](https://github.com/github/codeql-action) and [dependency review](https://github.com/actions/dependency-review-action): static analysis and vulnerable-dependency gates on PRs.
- [CycloneDX](https://cyclonedx.org/) and [SPDX](https://spdx.dev/): SBOM formats.
- [GitHub community health files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file), [CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners), [Contributor Covenant](https://www.contributor-covenant.org/): the repository files `devbox init` scaffolds or recommends.
