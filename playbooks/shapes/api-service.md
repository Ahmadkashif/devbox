# API service

> Backend services and APIs: REST, gRPC, GraphQL, workers, webhooks and background jobs

## When this applies

- Any server-side process that other software calls: public or internal APIs, BFFs, webhook receivers, job workers, event consumers.
- Fullstack products: combine with the web shape via `devbox init --shape web-app,api-service`.
- Data transformation pipelines read `data-pipeline`; model serving also reads `ml-system`; LLM-backed endpoints also read `llm-app`.

## Default architecture

- Modular monolith first. One deployable, internally split into modules with hexagonal layers: transport (HTTP/gRPC handlers) -> use cases -> domain -> adapters (database, queues, third-party APIs). Dependencies point inward. Split into services only when a module needs independent scaling, ownership or release cadence, and record that in an ADR.
- Contract first: write the OpenAPI 3.x, protobuf or GraphQL schema, lint it, review it, then generate server stubs and clients.
- PostgreSQL by default for state. Use the database for constraints (unique, foreign keys, check) rather than trusting application code.
- Events and side effects through a transactional outbox, never dual writes (database plus queue in two steps).
- Slow or retryable work goes to a queue-backed background job, not the request path.
- Stateless processes configured through environment variables (12-factor); logs to stdout as structured JSON.
- Avoid starting with: microservices, event sourcing, Kubernetes for a single service, a hand-rolled framework, an ORM-heavy "repository for everything" layer that adds no behavior.

## Quality attributes

- Availability and latency SLOs set per endpoint class, measured near the user. Typical starting point: 99.9% of requests successful and p99 under an agreed budget (for example 300 ms for reads) over a 28-day window. Write the SLO in design.md and the runbook.
- Correctness under retries: every non-idempotent operation is safe to retry (idempotency keys) and every handler tolerates duplicate delivery.
- Data integrity: constraints in the schema, transactions around multi-row invariants, UTC timestamps.
- Security: OWASP API Security Top 10 (Broken Object Level Authorization is number one), OWASP Top 10:2025, ASVS 5.0 level 2 for anything handling personal or financial data.
- Backward compatibility: never break existing clients within a version.
- Observability: the four golden signals (latency, traffic, errors, saturation) per endpoint, traces across every hop.
- Cost: know the cost per request or per tenant for anything expensive.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- Who are the clients (browser, mobile, partners, internal services)? Which are trusted?
- Expected traffic now and in a year, read/write ratio, peak shape, payload sizes.
- Which operations must be idempotent? What happens on duplicate submits and client retries?
- Consistency requirements: what must be strongly consistent, what can be eventually consistent?
- Authentication method and authorization model (roles, ownership, tenants). Who may read and write each resource?
- Data retention, deletion, residency and audit requirements.
- What is the deprecation policy for old versions or fields?

/devbox:design should decide and record:

- Resource model and URL or RPC naming (Google AIP-121/122 style), standard vs custom methods.
- Error model: RFC 9457 problem details for HTTP APIs.
- Pagination (cursor or page tokens, default and max page size), filtering and sorting.
- Versioning convention (path `v1`, header, or date-based) and the compatibility rules.
- Migration plan: expand, migrate, contract; how long both shapes coexist.
- Timeouts, retry policy (exponential backoff with jitter), circuit breakers per outbound dependency.
- Threat model (`.devbox/templates/threat-model.md`) for anything public or multi-tenant.

## Testing strategy

- Unit tests on domain logic and use cases, with ports faked at the boundary.
- Integration tests against a real database (Testcontainers or a disposable local instance), not mocks of your own repository layer. Cover constraint violations, transactions and concurrent requests.
- Contract and breaking-change checks: `oasdiff breaking` for OpenAPI, `buf breaking` for protobuf, consumer-driven contracts (Pact) between services, with provider verification in the provider's CI.
- Authorization tests: for every protected resource, an unauthenticated request, a wrong-tenant request and a wrong-role request must fail.
- Migration tests: run migrations forward (and back when supported) against a production-like snapshot.
- Load tests (k6 or similar) against the SLO before launch and for any hot-path change.
- Fuzz parsers and anything that decodes untrusted input.
- Mock only third-party APIs, clocks and randomness.

## Walking skeleton

T001 delivers: one endpoint defined in the contract, implemented through every layer (handler, use case, adapter, real database table with a migration), returning RFC 9457 errors, a health/readiness probe, structured logs with a trace ID, an integration test against a real database, and a CI pipeline that runs migrations and tests and builds the deployable artifact.

## Checklist

- [ ] API contract in the repo; breaking-change check runs in CI
- [ ] Errors use RFC 9457 `application/problem+json`; no stack traces or internals leak
- [ ] `Idempotency-Key` (or request ID) honored on non-idempotent POST/PATCH: key, request fingerprint and response stored with a TTL; same key with a different payload returns 409 or 422
- [ ] Every list endpoint paginated with a default and a hard maximum page size
- [ ] Timeouts on every outbound call; retries with backoff and jitter only on idempotent operations; circuit breakers where a dependency can hang
- [ ] Migrations follow expand/contract, run as a separate deploy step, avoid long locks on hot tables
- [ ] Input validated at the boundary against the schema; output encoded
- [ ] Authentication on every endpoint and object-level authorization on every resource access
- [ ] Rate limits and quotas on public and expensive endpoints; 429 with rate-limit headers
- [ ] OpenTelemetry traces, metrics and JSON logs with trace IDs; no secrets or personal data in logs
- [ ] Liveness and readiness probes separated; graceful shutdown drains in-flight requests on SIGTERM
- [ ] Secrets loaded from a secret manager or environment at runtime, never committed
- [ ] SLOs defined with burn-rate alerts; runbook written (`.devbox/templates/runbook.md`)
- [ ] Deprecation and Sunset headers plus a written deprecation policy for anything public
- [ ] Background jobs are idempotent and re-entrant; poison messages go to a dead-letter queue

## Pitfalls

- Dual writes (save to the database, then publish to the queue) without an outbox: one of them will fail eventually.
- Retrying non-idempotent calls, which double-charges or double-sends.
- N+1 queries, especially in GraphQL resolvers (use dataloaders) and unbounded query depth or complexity.
- SELECT-then-INSERT races where a unique constraint should exist.
- Reusing protobuf field numbers instead of marking them `reserved`.
- Coupling schema migrations to application deploys so a rollback breaks the database.
- Unbounded queries and responses; missing indexes for new WHERE and ORDER BY clauses.
- Personal data and tokens written to logs; error messages that echo internals.

## Verify gates

Typical `.devbox/config` (pick the stack's commands from `.devbox/playbooks/languages.md`), plus extra gates:

```
DEVBOX_LINT_CMD=<stack linter> && npx @redocly/cli lint openapi.yaml   # or buf lint
DEVBOX_TEST_CMD=<stack test runner, including integration tests with a real database>
```

CI extras: `oasdiff breaking <base> <head>` or `buf breaking --against '.git#branch=main'`, migration dry run, container image scan, k6 smoke against a preview environment.

## Sources

- https://google.aip.dev/
- https://github.com/microsoft/api-guidelines (use the azure/ and graph/ guidelines; the root file is deprecated)
- https://opensource.zalando.com/restful-api-guidelines/
- https://www.rfc-editor.org/rfc/rfc9110
- https://www.rfc-editor.org/rfc/rfc9457
- https://datatracker.ietf.org/doc/draft-ietf-httpapi-idempotency-key-header/ (expired draft, still the common pattern)
- https://spec.openapis.org/
- https://protobuf.dev/best-practices/
- https://buf.build/docs/best-practices/style-guide
- https://graphql.org/learn/best-practices/
- https://owasp.org/API-Security/
- https://12factor.net/
- https://opentelemetry.io/docs/specs/semconv/
- https://sre.google/sre-book/service-level-objectives/
- https://docs.pact.io/
