# ML system

> Trained-model systems: feature pipelines, training, evaluation, serving and monitoring

## When this applies

- Products that train or fine-tune their own models: ranking, recommendation, classification, forecasting, vision, speech.
- Model serving (batch scoring or online inference) and the pipelines that feed it.
- Apps built on hosted foundation models without training: read `llm-app` instead. Data movement: also read `data-pipeline`.

## Default architecture

- Ship a heuristic or simple baseline first (Rules of ML, rule 1). The ML system must beat it to justify its cost.
- Pipeline stages as separate, versioned, testable components: feature pipeline -> training pipeline -> evaluation -> model registry -> serving (batch or online) -> monitoring.
- One feature definition shared by training and serving (a feature store or a shared library), to avoid training/serving skew. Log the features actually used at serving time and train on those logs.
- Experiment tracking (MLflow or Weights and Biases) and a model registry with stages (staging, production, archived).
- Data versioning (DVC, lakeFS, or Delta/Iceberg time travel) so every model can name the exact data it was trained on.
- Deploy new models as shadow or canary first, with automatic promotion or rollback gates.
- Avoid starting with: deep models before a baseline exists, notebooks as production code, online learning before offline evaluation is trustworthy, a platform before a second model exists.

## Quality attributes

- Model quality on the overall population and on important slices (segments, regions, rare classes), with thresholds written in design.md.
- Offline metrics that are shown to correlate with the online business metric.
- Serving latency and throughput budgets (for example p99 inference under 50 ms for online ranking).
- Reproducibility: code, data snapshot, config, seed and environment versioned together (model lineage).
- Fairness and safety requirements stated per use case; NIST AI RMF as the risk framework.
- Freshness: how stale a model or feature may get before it must be retrained.
- Cost per training run and per thousand predictions.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- What decision does the model drive, and what does a wrong prediction cost (false positive vs false negative)?
- What is the non-ML baseline, and what improvement justifies ML?
- Which online metric defines success, and which offline metric predicts it?
- Where do labels come from, how delayed are they, and how noisy?
- Which slices must not regress? Are there fairness or regulatory constraints?
- Batch or online serving? Latency budget? Fallback when the model is unavailable?

/devbox:design should decide and record:

- Feature definitions and how they are shared between training and serving.
- Train/validation/test split strategy that prevents temporal and target leakage.
- Evaluation protocol: held-out sets, slice metrics, baselines, acceptance thresholds.
- Release protocol: shadow, canary percentage, promotion criteria, rollback trigger.
- Monitoring: drift, skew, data quality, prediction distribution, latency.
- A model card and dataset datasheet per release.

## Testing strategy

Follow the four areas of Google's ML Test Score:

- Data tests: schema validation, feature value ranges and distributions, expectations on nulls and cardinality, no PII where it is not allowed.
- Model tests: beats the baseline; slice metrics meet thresholds; invariance tests (irrelevant input changes do not change output) and directional tests (relevant changes move output the right way); no leakage features.
- Infrastructure tests: training is reproducible from a pinned config; the full pipeline runs end to end on a small sample in CI; the model loads in the serving stack and returns predictions; rollback to the previous model works.
- Monitoring tests: alerts fire on injected skew, drift, staleness and NaN spikes.
- Plain unit tests on feature transformations and pre/post-processing code.
- Mock nothing in the feature logic; use small, fixed fixture datasets.

## Walking skeleton

T001 delivers: the heuristic baseline served behind the same interface the model will use, a training pipeline that runs end to end on a small sample in CI, a registered (even trivial) model with lineage, an offline evaluation report comparing it to the baseline, and serving-time feature logging.

## Checklist

- [ ] A heuristic or simple baseline shipped and measured first
- [ ] Serving-time features logged and used for training data
- [ ] Training/serving skew check in place
- [ ] Code, data version, config and seed recorded for every model (lineage)
- [ ] Model card written for each release
- [ ] Held-out and slice evaluations with thresholds; results stored with the model
- [ ] Offline metrics shown to correlate with the online metric
- [ ] Shadow or canary release with automatic promotion and rollback gates
- [ ] Drift, skew and data-quality alerts with a named owner
- [ ] One-step rollback through the model registry, rehearsed
- [ ] Dependencies, CUDA/runtime versions and hardware pinned for training and serving
- [ ] Personal data and consent governance applied to training data
- [ ] Fallback behavior when the model or feature store is unavailable

## Pitfalls

- Target leakage and temporal leakage (training on information not available at prediction time).
- Contaminated evaluation sets that overlap with training data.
- Copying notebook code into production instead of building tested pipeline components.
- Optimizing a proxy metric that does not move the business metric.
- Feedback loops where the model's own predictions shape its future training data.
- Silent breakage in an upstream feature pipeline that degrades the model without errors.
- No baseline, so nobody knows whether the model helps.

## Verify gates

Use the Python gates from `.devbox/playbooks/languages.md`, then add:

```
DEVBOX_TEST_CMD=uv run pytest && uv run python -m pipelines.smoke --sample 1000
```

CI extras: data validation on a fixed sample, evaluation report diff against the current production model, model load test in the serving container.

## Sources

- https://developers.google.com/machine-learning/guides/rules-of-ml
- https://research.google/pubs/pub46555/ (The ML Test Score)
- https://papers.nips.cc/paper/2015/hash/86df7dcfd896fcaf2674f757a2463eba-Abstract.html (Hidden Technical Debt in ML Systems)
- https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning
- https://arxiv.org/abs/1810.03993 (Model Cards)
- https://arxiv.org/abs/1803.09010 (Datasheets for Datasets)
- https://www.nist.gov/itl/ai-risk-management-framework
- https://mlflow.org/docs/latest/
