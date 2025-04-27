#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="image-classifier"

echo "♻️  Rolling update: image-classifier Deployment"
kubectl rollout restart deployment image-classifier -n ${NAMESPACE}
kubectl rollout status deployment image-classifier -n ${NAMESPACE}
echo "✅ Update complete."
