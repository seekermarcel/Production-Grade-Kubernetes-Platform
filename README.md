# Production-Grade Kubernetes Platform

A production-ready Kubernetes platform running on Kind, featuring GitOps with ArgoCD, full observability stack, and a demo service.

---

## Local Kind Cluster

### Prerequisites

- [kind](https://kind.sigs.k8s.io) – Kubernetes in Docker
- [kubectl](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/) – Kubernetes CLI
- [helmfile](https://github.com/helmfile/helmfile) – Declarative Helm chart management

### Increase Local Resources

Required due to [known inotify limits](https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files):

```bash
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
```

### Cluster Management

| Action              | Command          |
|---------------------|------------------|
| Bootstrap cluster   | `make kind-up`   |
| Destroy cluster     | `make kind-down` |

---

## Services

### Demo Service

| Property    | Value                                                                                      |
|-------------|--------------------------------------------------------------------------------------------|
| **URL**     | <http://demo.localhost>                                                                    |
| **Purpose** | Simple HTTP service demonstrating deployment, health checks, autoscaling, and observability |

**Endpoints:**

| Endpoint    | Description |
|-------------|-------------|
| `/`         | Main endpoint |
| `/healthz`  | Liveness probe |
| `/readyz`   | Readiness probe |

**Quick Test:**

```bash
curl -H "Host: demo.localhost" http://localhost/
```

---

### ArgoCD

| Property        | Value                   |
|-----------------|-------------------------|
| **URL**         | <http://localhost:8080> |
| **Username**    | `admin`                 |

> **Note:** ArgoCD is intentionally not exposed via ingress locally. Access via port-forward.

**Setup Access:**

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:80
```

**Retrieve Password:**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

**Manages:**

- Platform components
- Demo service
- Observability stack
- CRDs and ordering via sync waves

---

### Grafana

| Property     | Value                       |
|--------------|-----------------------------|
| **URL**      | <http://grafana.localhost>  |
| **Username** | `admin`                     |
| **Password** | `admin`                     |

**Included Dashboards:**

- Demo Service dashboard (SLIs via ingress-nginx)
- Default Kubernetes / node dashboards

---

### Prometheus

| Property    | Value                          |
|-------------|--------------------------------|
| **URL**     | <http://prometheus.localhost>  |

**Purpose:**

- Inspect metrics
- Validate scrape targets
- Debug PromQL queries

---

### Alertmanager

| Property    | Value                            |
|-------------|----------------------------------|
| **URL**     | <http://alertmanager.localhost>  |

**Purpose:**

- View active alerts
- Inspect alert routing (local setup)
