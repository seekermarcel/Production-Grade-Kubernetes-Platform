# Production-Grade Kubernetes Platform — Architecture

This repository builds a **production-grade Kubernetes platform** designed to be:
- easy to reproduce,
- safe to operate,
- secure by default,
- observable end-to-end,
- and boring in the best way.

It supports both **local development with `kind`** and **cloud environments** (`dev`, `staging`, `prod`) using the same platform concepts and (as much as possible) the same Kubernetes manifests.



## Goals

### 1) Secure defaults
- Least-privilege access (RBAC) and clear separation of duties
- No long-lived credentials in CI (prefer OIDC/workload identity where possible)
- Security scanning and policy checks built into CI
- Sensible cluster hardening (namespace isolation, pod security, admission policies)

### 2) Repeatable & auditable
- Fully reproducible environments from source control
- Infrastructure defined as code (Terraform for cloud resources)
- In-cluster components installed declaratively (GitOps)
- Changes are reviewed, versioned, and traceable

### 3) Observable by design
- Metrics, logs, and (optionally) traces are first-class
- Dashboards that answer: “Is the user impacted?”
- Alerts tuned to avoid noise and focus on symptoms over causes
- Clear runbooks for common failures

### 4) Easy upgrades
- Kubernetes version upgrades are planned, tested, and documented
- Cluster add-ons have explicit versions and upgrade paths
- Node rotation and add-on upgrades are designed to be routine operations

### 5) Safe rollbacks
- GitOps-driven releases with quick rollback paths
- Progressive delivery patterns where appropriate (e.g., canary/blue-green for the demo app)
- Clear failure modes and fast recovery steps



## Non-goals

To keep this platform realistic and maintainable, the following are **explicitly out of scope** (for now):

- **Multi-region active-active** architecture (active-passive DR is preferred)
- **A full service mesh** (complexity isn’t free; revisit if needed)
- **Enterprise multi-tenant platform** with strict cross-team chargeback
- **Perfect abstraction across all clouds** (portability matters, but not at the cost of clarity)

These may be added later as optional expansions, but they are not required to consider the platform “production-grade”.



## Environments

The platform is designed around four environments:

### `kind` (local)
- Purpose: fast iteration, developer workflow, and CI smoke tests
- Characteristics:
  - Single-node or small multi-node cluster
  - Local ingress and TLS (local issuer)
  - Minimal external dependencies
- Expected parity:
  - Same app manifests and platform components whenever feasible
  - Some cloud-only integrations (managed LBs, DNS providers, cloud IAM) are naturally mocked or omitted

### `dev` (cloud)
- Purpose: integration testing with real cloud primitives
- Characteristics:
  - Smaller and cheaper sizing
  - May be more permissive for experimentation
  - Still follows the same GitOps and security patterns

### `staging` (cloud)
- Purpose: release candidate validation and “production-like” confidence
- Characteristics:
  - Closest to production configuration
  - Used for upgrade rehearsals and incident simulations
  - Stricter policies than `dev`

### `prod` (cloud)
- Purpose: demonstrate real operational standards
- Characteristics:
  - Strongest guardrails and least privilege
  - Strict change control via GitOps
  - Explicit upgrade and rollback procedures
  - Monitoring + alerting focused on user impact



## Baseline SLO (Demo App)

This platform includes a demo service intended to prove end-to-end operations.

**Service Level Objective (SLO):**
- **Availability:** 99.9% monthly for the demo service

**Notes:**
- This SLO is used to drive alerting, dashboards, and operational decisions.
- Error budget and alert thresholds are designed to reflect user impact, not raw infrastructure utilization.

**Measurement approach (high level):**
- Availability is computed from successful request rate (e.g., non-5xx responses) over total requests.
- SLI sources: ingress metrics and/or service-level metrics exported to Prometheus.



## Design principles

- **Boring is good:** prefer simple, well-understood components.
- **Separation of concerns:** cloud infra vs cluster config vs application delivery.
- **Everything is versioned:** infra modules, add-ons, charts, policies, and apps.
- **Document the “why”:** major tradeoffs are recorded in `docs/decisions.md`.
- **Operate what you build:** runbooks and incident workflows are part of the deliverable.



## High-level component overview

### Provisioning & lifecycle
- Cloud infrastructure provisioned via Terraform (for `dev`/`staging`/`prod`)
- `kind` cluster provisioned via a config file + scripts/Makefile
- Kubernetes add-ons and platform components managed via GitOps

### Platform capabilities
- Ingress + TLS
- DNS automation (cloud)
- Observability (metrics/logs; traces optional)
- Policy and security controls
- Standardized app deployment patterns



## What “done” looks like (acceptance criteria)

A platform build is considered successful when:

- A new environment can be brought up from scratch using documented commands
- The demo service deploys via GitOps and is reachable through ingress
- Dashboards show golden signals (latency, traffic, errors, saturation)
- Alerts fire on meaningful user-impact scenarios and link to runbooks
- Upgrades and rollbacks are documented and demonstrably safe
- CI enforces baseline quality/security checks (linting, scanning, policy validation)
