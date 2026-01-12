#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-platform}"
command -v kind >/dev/null || { echo "kind is required"; exit 1; }

echo "==> Deleting kind cluster: ${CLUSTER_NAME}"
kind delete cluster --name "${CLUSTER_NAME}"

echo "✅ Deleted."
