#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="image-classifier"

echo "📜 Streaming logs for all pods in ${NAMESPACE}"
kubectl logs -n ${NAMESPACE} -l app=image-classifier --follow
