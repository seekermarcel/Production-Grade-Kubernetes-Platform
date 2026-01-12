# Production-Grade-Kubernetes-Platform

## Local Kind Cluster

**Prereqs**
- [kind](https://kind.sigs.k8s.io)
- [kubectl](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/)
- [helmfile](https://github.com/helmfile/helmfile)

**Increase local resources** because: https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files
```bash
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
```

**Bootstrapping Kind**
```bash
make kind-up
```

**Deleting Kind**
```bash
make kind-down
```