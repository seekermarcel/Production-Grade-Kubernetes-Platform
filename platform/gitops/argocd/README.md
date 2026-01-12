# Argo CD (local GitOps on kind)

## Install
Argo CD is installed as part of `platform/bootstrap/helmfile.yaml`.

## Bootstrap GitOps
1) Edit `platform/gitops/argocd/root-application.yaml` and set `repoURL` to your GitHub repo.
2) Apply it:

```bash
kubectl apply -f platform/gitops/argocd/root-application.yaml
