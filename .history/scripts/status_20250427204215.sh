#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="image-classifier"

echo "🔎 Showing resources in ${NAMESPACE}"
kubectl get all -n ${NAMESPACE}

echo "🔎 Current HPA status"
kubectl get hpa -n ${NAMESPACE}
