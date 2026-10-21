# Data pipeline

> Batch and streaming pipelines, ELT, dbt projects and analytics engineering

## When this applies

- Moving and transforming data between systems: ingestion, ELT into a warehouse or lakehouse, reverse ETL, event streams.
- Analytics engineering with dbt or SQL models feeding dashboards and metrics.
- Feature pipelines for ML: also read `ml-system`. Services that produce events: also read `api-service`.

## Default architecture

- Layered models: sources -> staging (one model per source table: rename, cast, light cleaning, nothing else) -> intermediate (joins and business logic) -> marts (facts and dimensions, Kimball style) consumed by BI and applications.
- Functional data engineering: every task is a pure function of its inputs and a logical date. Writes overwrite a partition or MERGE on a key, so re-running is safe. Partitions are immutable once published.
- Asset-based orchestration (Dagster, Airflow 3, or Prefect): define the datasets and their dependencies, not just a list of scripts.
- Incremental models with a `unique_key` and a lookback window for late-arriving data.
- Data contracts at producer and consumer boundaries (Open Data Contract Standard or dbt model contracts), versioned like an API.
- Lineage emitted (OpenLineage) so impact analysis is possible.
- Avoid starting with: one giant DAG, business logic in the BI tool, streaming when hourly batch meets the freshness need, `SELECT *` from raw sources.

## Quality attributes

- Correctness: every published table has tests for keys, relationships and accepted values.
- Freshness SLAs per mart (for example "orders mart updated by 06:00 UTC daily, 99% of days"), monitored and alerted.
- Backfillability: any date range can be recomputed with one documented command, with the same result.
- Reproducibility: same inputs and code produce the same output; no hidden dependence on `now()`.
- Cost: partition pruning, clustering and query tags; cost per run tracked for the expensive models.
- Governance: personal data tagged, masked or excluded; retention and deletion requests honored downstream.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- Who consumes this data, through what tool, and what decision does it drive?
- How fresh must it be, and what happens if it is late or wrong?
- What is the grain of each output table (one row per what)?
- Which sources are authoritative for each field? Who owns each source?
- What personal or regulated data flows through, and who may see it?
- How far back must history go, and how will backfills be triggered?

/devbox:design should decide and record:

- Model layers and naming conventions; the grain and primary key of every mart.
- Incremental strategy per model (full refresh, merge, insert-overwrite by partition), lookback window.
- Contracts at boundaries, and the process for breaking changes (new version, deprecation window).
- Orchestration schedule, retries, SLAs and the owner who gets alerted.
- Environments (dev schemas per developer, CI schema, prod) and how CI avoids full rebuilds.

## Testing strategy

- Data tests on every model: `unique` and `not_null` on primary keys, `relationships` for foreign keys, `accepted_values` for enums.
- dbt unit tests (or SQL unit tests) for non-trivial transformation logic with fixed input rows.
- Enforced model contracts on public marts (column names and types).
- Source freshness checks and volume/anomaly monitors (row count deltas, null rates).
- Slim CI: build and test only modified models and their children (`dbt build --select state:modified+ --defer`).
- Idempotency test: run the same partition twice and assert identical results.
- Backfill rehearsal for a small range before running large ones.
- Mock nothing in SQL tests; use small fixture tables.

## Walking skeleton

T001 delivers: one source declared with a freshness check, one staging model, one mart with primary-key tests, an orchestrated daily run parameterized by logical date, a slim CI job that builds and tests changed models, and a documented backfill command proven on two days of data.

## Checklist

- [ ] Re-running any partition produces the same result (tested)
- [ ] Jobs parameterized by logical date; no `now()` or `current_date` inside transformations
- [ ] Backfill command documented in the runbook and rehearsed
- [ ] Every model has a primary key with `unique` and `not_null` tests
- [ ] Contracts at producer/consumer boundaries; breaking changes versioned
- [ ] Only staging models read raw sources
- [ ] Incremental models declare `unique_key` and handle late data with a lookback
- [ ] Personal data tagged and masked or excluded from marts that do not need it
- [ ] Lineage emitted and browsable
- [ ] SQL linted (sqlfluff) in CI with the right dialect and templater
- [ ] Cost guardrails: partition filters required on large tables, query tags set
- [ ] Freshness and failure alerts routed to a named owner
- [ ] Every mart documented: grain, owner, refresh schedule, known caveats

## Pitfalls

- Non-deterministic transforms (current time, random sampling, unordered window functions).
- Append-only incrementals that duplicate rows on every retry.
- `SELECT *` from sources, so an upstream column change silently flows everywhere.
- Business logic duplicated in the BI tool where it cannot be tested.
- One monolithic DAG where any failure blocks everything.
- Backfills that overwrite good data with a buggy version and no way back (keep prior partitions or snapshots).

## Verify gates

```
DEVBOX_FORMAT_CMD=sqlfluff format --check --dialect <dialect> models/
DEVBOX_LINT_CMD=sqlfluff lint --dialect <dialect> models/
DEVBOX_TEST_CMD=dbt build --select state:modified+ --defer --state <prod-artifacts>
DEVBOX_BUILD_CMD=dbt compile
```

For Python pipeline code, add the Python gates from `.devbox/playbooks/languages.md`.

## Sources

- https://docs.getdbt.com/best-practices
- https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview
- https://docs.getdbt.com/docs/build/data-tests
- https://docs.getdbt.com/docs/build/unit-tests
- https://maximebeauchemin.medium.com/functional-data-engineering-a-modern-paradigm-for-batch-data-processing-2327ec32c42a
- https://github.com/bitol-io/open-data-contract-standard
- https://openlineage.io/
- https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/
- https://docs.sqlfluff.com/
