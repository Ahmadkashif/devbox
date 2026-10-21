# Infrastructure

> Infrastructure as code, platforms, Kubernetes, GitOps, CI/CD and cloud foundations

## When this applies

- Terraform or OpenTofu modules and stacks, Kubernetes manifests and Helm charts, GitOps repositories, platform tooling.
- CI/CD pipelines and deployment automation for other shapes.
- Usually paired with the shape it hosts, for example `devbox init --shape api-service,infrastructure`.

## Default architecture

- Layered stacks with small root modules: org/bootstrap (accounts, identity, state backend) -> network -> platform (clusters, databases, shared services) -> applications. Each layer has its own state and its own blast radius.
- Remote, encrypted, locked state per environment and per stack. Never one giant state file.
- Reusable modules versioned and pinned; provider versions pinned with the lock file committed.
- Pull-based GitOps (Argo CD or Flux) for cluster workloads: Git is the desired state, the cluster converges to it.
- Policy as code at two points: IaC scanning in CI (Checkov or Trivy) and admission control in clusters (OPA Gatekeeper, Conftest, or Kyverno).
- Secrets via External Secrets Operator or SOPS, sourced from a cloud secret manager or Vault.
- CI authenticates to clouds with OIDC workload identity, never long-lived keys.
- Avoid starting with: ClickOps, a self-managed control plane when a managed service fits, one state file for everything, custom operators before standard ones, multi-cloud without a business reason.

## Quality attributes

- Reproducibility: any environment can be rebuilt from code; no manual drift.
- Blast radius: a change in one stack cannot break unrelated stacks.
- Recovery objectives: RPO and RTO stated per data store and proven by restore drills.
- Auditability: every change goes through a reviewed PR with a recorded plan.
- Security baseline: CIS Benchmarks for the platform, Pod Security Standards `restricted` for workloads.
- Cost: every resource labeled with owner and cost center; budgets and alerts per environment.
- Upgrade cadence: Kubernetes supports three minor versions at a time; plan upgrades before your version leaves support (check the current release).

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- Which environments exist (dev, staging, prod, previews) and how alike must they be?
- RPO and RTO for each data store. What is the disaster scenario we must survive?
- Compliance and data residency constraints.
- Who may change production, and with what approval?
- Expected scale and growth; cost ceiling.
- Which managed services are acceptable, and which require self-hosting?

/devbox:design should decide and record:

- Stack layering, state layout and backend, module boundaries (ADR).
- GitOps tool and repository layout (app-of-apps, environment overlays).
- Identity: OIDC trust between CI and cloud, human access (SSO, break-glass), Kubernetes RBAC.
- Network design: segmentation, ingress, egress controls, default-deny policies.
- Backup, restore and disaster recovery plan with drill frequency.
- Rollout and rollback for platform changes (canary node pools, staged cluster upgrades).

## Testing strategy

- Static: `terraform fmt -check` / `tofu fmt -check`, `validate`, `tflint`; `kubeconform` and `kube-linter` for manifests; `helm lint`.
- Policy: Checkov or Trivy config scans in CI; Conftest policies on the rendered plan; admission policies tested with fixtures.
- Plan review: every PR posts a plan; apply happens only from CI after approval.
- Module tests: `terraform test` / `tofu test` with mocks for unit-level checks, Terratest for real ephemeral environments.
- Ephemeral preview environments for significant changes, destroyed automatically.
- Disaster recovery: scheduled restore drills from backups (Velero for clusters, database point-in-time restore).
- Drift detection on a schedule that alerts on differences.

## Walking skeleton

T001 delivers: a remote, locked, encrypted state backend bootstrapped; one small stack (for example a network or a single managed service) applied from CI via OIDC after a reviewed plan; fmt, validate, tflint and a policy scan running on PRs; and the rollback path (revert PR, re-apply) demonstrated.

## Checklist

- [ ] State remote, encrypted, locked, and split per environment and stack
- [ ] Provider and module versions pinned; lock file committed
- [ ] Secrets kept out of state where the tool supports it (ephemeral resources, write-only attributes)
- [ ] Plan on every PR; apply only from CI after approval
- [ ] Scheduled drift detection with alerts
- [ ] Workloads set requests and limits, liveness, readiness and startup probes, a PodDisruptionBudget, >= 2 replicas with topology spread, and autoscaling where load varies
- [ ] Pod Security `restricted`: non-root, read-only root filesystem, dropped capabilities
- [ ] Default-deny NetworkPolicies with explicit allows
- [ ] Least-privilege RBAC; service account tokens not auto-mounted unless needed
- [ ] Container images signed (cosign) and verified at admission; no `:latest` tags
- [ ] Every resource labeled with owner and cost center
- [ ] Backups tested by restore drills on a schedule
- [ ] CI uses OIDC to the cloud; no long-lived cloud keys in CI secrets
- [ ] Kubernetes and provider upgrade cadence on the calendar

## Pitfalls

- One giant state file where every apply risks everything.
- ClickOps changes that drift from code and get reverted by the next apply.
- `:latest` image tags, making rollbacks and audits impossible.
- Plaintext secrets in Git or in Terraform state.
- `count` on lists, which re-indexes and destroys resources when an item is removed (use `for_each`).
- Missing PodDisruptionBudgets, so node drains take services down.
- Backups that have never been restored.

## Verify gates

```
DEVBOX_FORMAT_CMD=terraform fmt -check -recursive        # or tofu fmt -check -recursive
DEVBOX_LINT_CMD=tflint --recursive && checkov -d . --quiet
DEVBOX_TYPECHECK_CMD=terraform validate                   # per root module
DEVBOX_TEST_CMD=terraform test                            # or tofu test
DEVBOX_BUILD_CMD=kubeconform -strict -summary manifests/
```

CI extras: plan posted to the PR, Conftest on the plan JSON, actionlint and zizmor for workflow files.

## Sources

- https://developer.hashicorp.com/terraform/language/style
- https://www.terraform-best-practices.com/
- https://cloud.google.com/docs/terraform/best-practices-for-terraform
- https://opentofu.org/docs/
- https://opengitops.dev/
- https://kubernetes.io/docs/setup/production-environment/
- https://kubernetes.io/docs/concepts/security/security-checklist/
- https://kubernetes.io/docs/concepts/security/pod-security-standards/
- https://learnk8s.io/production-best-practices
- https://www.cisecurity.org/cis-benchmarks
- https://aws.amazon.com/architecture/well-architected/
