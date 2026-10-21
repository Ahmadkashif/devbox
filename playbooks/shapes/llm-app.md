# LLM or agent app

> Products built on hosted language models: chat, RAG, extraction, workflows and agents

## When this applies

- Features that call a language model: summarization, extraction, classification, chat, search with retrieval (RAG), code generation.
- Multi-step LLM workflows and autonomous agents with tools, including MCP servers and clients.
- Usually combined with another shape: `devbox init --shape api-service,llm-app` for an LLM-backed backend, or `web-app,api-service,llm-app` for a full product. Training your own models: read `ml-system`.

## Default architecture

Use the simplest pattern that works, and move up only when evals prove you need to (Anthropic, "Building effective agents"):

1. **Augmented LLM**: one model call with retrieval, tools or memory. Most features stop here.
2. **Workflows** (predefined code paths orchestrating LLM calls):
   - Prompt chaining: fixed sequence of steps, with programmatic gates between them.
   - Routing: classify the input, send it to a specialized prompt or model.
   - Parallelization: sectioning (independent subtasks) or voting (same task several times).
   - Orchestrator-workers: a model breaks down a task and delegates to workers when subtasks cannot be predicted in advance.
   - Evaluator-optimizer: one call generates, another critiques against criteria, loop until it passes.
3. **Agents**: the model decides its own steps and tool calls in a loop. Use only when the steps are genuinely unpredictable, and always with iteration, cost and permission limits.

Building blocks:

- Prompts are versioned artifacts in the repo: template, model ID, parameters (temperature, max tokens) and output schema change together, in one reviewed file, released behind a flag.
- Model IDs live in config, never hard-coded in call sites. When building on Anthropic, default to the latest models: Claude Opus 5.5 (`claude-opus-5-5`) for the hardest reasoning, Claude Sonnet 5.5 (`claude-sonnet-5-5`) as the balanced default, Claude Haiku 5.5 (`claude-haiku-5-5`) for high-volume or latency-sensitive steps, Claude Fable 5.1 (`claude-fable-5-1`) where it fits. Pick per step by eval results and cost, not by habit.
- A model gateway or thin client wrapper that centralizes retries, timeouts, fallbacks, cost accounting and tracing.
- Structured output validated against a JSON Schema (or typed model) with bounded retries on validation failure.
- A least-privilege tool layer: each tool does one clear thing, with typed parameters, clear descriptions, and scoped credentials.
- Input and output guardrails around untrusted content.
- OpenTelemetry GenAI tracing for every call and tool invocation.
- An eval harness that runs in CI.
- Avoid starting with: a multi-agent framework, an agent where a workflow would do, prompts embedded as string literals across the codebase, "vibe" prompt tuning without evals.

## Quality attributes

- Task success rate on the eval suite, with a target per capability written in design.md.
- Groundedness: answers supported by retrieved sources, with citations where users need to trust them.
- Latency budgets per interaction (time to first token and total), and streaming where users wait.
- Token and cost budgets per request, per user and per day, enforced (LLM10 Unbounded Consumption).
- Safety and security against the OWASP Top 10 for LLM Applications 2025 and the Agentic Top 10.
- Privacy: no personal data or secrets sent to models or logs unless required and allowed.
- Consistency under non-determinism: measure pass@k (succeeds at least once in k tries) for capability and pass^k (succeeds every time in k tries) for reliability.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- What does a good output look like? Collect 20 to 50 real examples with expected outcomes before building.
- What is the cost of a wrong, harmful or made-up answer? Who reviews outputs, and when?
- Which actions can the system take on its own, and which need human approval? (Irreversible ones always need approval.)
- What untrusted content reaches the model (user input, web pages, documents, emails, tool results)?
- What data may be sent to which model provider? Retention and residency constraints?
- Latency and cost budget per request; expected volume.
- How will we know in production that quality dropped?

/devbox:design should decide and record:

- Which pattern from the ladder above, and why the simpler ones are not enough.
- Model per step (with eval evidence), fallback provider or model, and the upgrade process.
- Prompt and schema files, their versioning, and how they are rolled out.
- Retrieval design: chunking, embedding model, index, access control on documents, citation format.
- Tool inventory with permissions, side effects, and approval requirements.
- Eval suites, graders, thresholds, and when they run.
- Trace and log policy, including redaction.

## Testing strategy

Evals come first; they are the test suite for model behavior.

- Golden sets built from real traces and real user inputs (anonymized), not only invented examples. Grow them with every production failure.
- Graders in order of preference: code-based checks (exact match, schema validity, regex, unit tests on generated code, tool-call assertions), then LLM-as-judge with a clear rubric, then human review. Calibrate every LLM judge against human labels before trusting it.
- Separate suites: capability evals (can it do the new thing, measured with pass@k) and regression evals (does it still do the old things, measured with pass^k).
- Red-team and prompt-injection suites: direct injection, indirect injection through documents and tool results, jailbreaks, data exfiltration attempts.
- Deterministic unit tests for everything around the model: prompt rendering, schema validation, tool implementations, retrieval filters, cost limits. Mock the model only in these unit tests.
- Online evals and A/B tests in production, sampling traces for grading.
- Re-run the full eval suite on every model upgrade, prompt change and retrieval change, and before switching providers.

## Walking skeleton

T001 delivers: one end-to-end request through the model gateway using a versioned prompt file and a model ID from config, structured output validated against a schema, a trace recorded for the call, a cost and token cap enforced, and an eval suite of at least 20 real examples with a code-based grader running in CI with a pass threshold.

## OWASP Top 10 for LLM Applications 2025

| ID | Risk | Defense |
|----|------|---------|
| LLM01 | Prompt Injection | Separate trusted instructions from untrusted content; treat retrieved and tool content as data; constrain tools and require approval for impactful actions |
| LLM02 | Sensitive Information Disclosure | Minimize and redact data sent to the model; enforce access control before retrieval; filter outputs |
| LLM03 | Supply Chain | Vet models, datasets, plugins and MCP servers; pin versions; review provenance and licenses |
| LLM04 | Data and Model Poisoning | Control and validate training, fine-tuning and retrieval sources; track provenance |
| LLM05 | Improper Output Handling | Treat model output as untrusted input: validate, encode and sanitize before rendering, executing or querying |
| LLM06 | Excessive Agency | Least-privilege tools, narrow scopes, human approval for irreversible actions, rate limits |
| LLM07 | System Prompt Leakage | Never put secrets or access rules in prompts; enforce authorization in code |
| LLM08 | Vector and Embedding Weaknesses | Per-tenant and per-user access control in the vector store; validate ingested content |
| LLM09 | Misinformation | Ground answers in sources, cite them, show uncertainty, keep humans in the loop for high-stakes outputs |
| LLM10 | Unbounded Consumption | Caps on tokens, cost, iterations, concurrency and request size; timeouts; quotas per user |

## OWASP Top 10 for Agentic Applications (2026 edition)

Confirm the exact wording on genai.owasp.org before quoting. ASI01 Agent Goal Hijack, ASI02 Tool Misuse, ASI03 Identity and Privilege Abuse, ASI04 Agentic Supply Chain, ASI05 Unexpected Code Execution, ASI06 Memory and Context Poisoning, ASI07 Insecure Inter-Agent Communication, ASI08 Cascading Failures, ASI09 Human-Agent Trust Exploitation, ASI10 Rogue Agents. Mitigations: least agency, validated tool parameters, sandboxed code execution, signed and authenticated agent-to-agent messages, circuit breakers, and human approval for irreversible actions.

## Tool and MCP security

- Give each tool and MCP server the narrowest credentials it needs; separate read tools from write tools.
- Treat third-party MCP tool descriptions and tool results as untrusted (tool poisoning, rug pulls). Pin server versions and review changes.
- Validate every tool argument in code; never let the model pick file paths, URLs or SQL without allowlists.
- Run model-generated code only in a sandbox with no secrets and limited network.
- Log every tool call with its arguments (redacted) and result status.

## Checklist

- [ ] Eval suite exists before prompt tuning starts, with thresholds in design.md
- [ ] Model IDs and prompt versions pinned in config and released behind flags
- [ ] Structured outputs validated against a schema with bounded retries
- [ ] Model output treated as untrusted before rendering, executing or storing (LLM05)
- [ ] Trusted instructions separated from untrusted content; no secrets in system prompts (LLM01, LLM07)
- [ ] Human approval required for irreversible or external actions (LLM06)
- [ ] Scoped credentials per tool; code execution sandboxed
- [ ] Caps on tokens, cost, iterations and concurrency (LLM10)
- [ ] Every model call and tool call traced
- [ ] Retrieval enforces access control; answers cite sources (LLM08, LLM09)
- [ ] Personal data redacted from prompts and logs where not required
- [ ] Provider or model fallback tested
- [ ] Evals re-run and compared on every model upgrade and prompt change
- [ ] Prompt-injection and red-team suites pass
- [ ] Production traces sampled and graded; failures added to the golden set

## Pitfalls

- Building an agent where a two-step workflow would do.
- Tuning prompts by feel, then breaking three other cases without noticing.
- Trusting an LLM judge that was never compared with human labels.
- Context rot: dumping huge tool outputs and documents into context instead of summarizing and filtering.
- Vague, overlapping or bloated tool sets that confuse the model.
- Trusting third-party MCP servers and tool descriptions as if they were your code.
- No cost caps, so a loop or an abusive user burns the budget overnight.

## Verify gates

Use the stack defaults from `.devbox/playbooks/languages.md`, then add the eval suite as its own gate. Keep the fast deterministic subset in DEVBOX_TEST_CMD and run the full suite (which calls real models) in CI on prompt, model or retrieval changes:

```
DEVBOX_TEST_CMD=uv run pytest && uv run python -m evals.run --suite regression --threshold 0.95
```

## Sources

- https://www.anthropic.com/engineering/building-effective-agents
- https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- https://www.anthropic.com/engineering/writing-tools-for-agents
- https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- https://www.anthropic.com/research/demystifying-evals-for-ai-agents
- https://docs.claude.com/en/docs/about-claude/models (check current model IDs)
- https://genai.owasp.org/llm-top-10/
- https://genai.owasp.org/initiatives/agentic-security-initiative/
- https://modelcontextprotocol.io/specification/latest/basic/security_best_practices
- https://www.nist.gov/itl/ai-risk-management-framework (and NIST AI 600-1)
- https://opentelemetry.io/docs/specs/semconv/gen-ai/
- https://github.com/humanlayer/12-factor-agents
