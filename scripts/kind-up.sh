#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-platform}"
KIND_CONFIG="${KIND_CONFIG:-clusters/kind/kind.yaml}"

command -v kind >/dev/null || { echo "kind is required"; exit 1; }
command -v kubectl >/dev/null || { echo "kubectl is required"; exit 1; }
command -v helm >/dev/null || { echo "helm is required"; exit 1; }
command -v helmfile >/dev/null || { echo "helmfile is required"; exit 1; }

echo "==> Creating kind cluster: ${CLUSTER_NAME}"
kind create cluster --name "${CLUSTER_NAME}" --config "${KIND_CONFIG}"

echo "==> Applying namespaces"
kubectl apply -f platform/bootstrap/manifests/namespaces.yaml

echo "==> Installing bootstrap components via helmfile"
pushd platform/bootstrap >/dev/null
helmfile apply
popd >/dev/null

echo "==> Waiting for cert-manager to be ready"
kubectl -n cert-manager rollout status deploy/cert-manager --timeout=180s
kubectl -n cert-manager rollout status deploy/cert-manager-webhook --timeout=180s
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector --timeout=180s

echo "==> Creating local CA issuers"
kubectl apply -f platform/bootstrap/manifests/cert-manager-issuers.yaml

echo "==> Waiting for ingress-nginx to be ready"
kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller --timeout=240s

echo "==> Waiting for Argo CD to be ready"
kubectl -n argocd rollout status deploy/argocd-server --timeout=240s
kubectl -n argocd rollout status deploy/argocd-repo-server --timeout=240s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=240s

echo ""
echo "==> Next: configure Argo CD to sync this repo"
echo "1) Edit platform/gitops/argocd/root-application.yaml and set repoURL to your GitHub repo"
echo "2) Apply it:"
echo "   kubectl apply -f platform/gitops/argocd/root-application.yaml"
echo ""
echo "==> Access Argo CD UI (port-forward):"
echo "   kubectl -n argocd port-forward svc/argocd-server 8080:80"
echo "   Then open: http://localhost:8080"
echo ""
echo "==> Get initial admin password:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
echo ""
echo "✅ kind cluster '${CLUSTER_NAME}' is up."
echo "Try: kubectl get pods -A"
echo "GitOps test object will appear after you apply the root application."
