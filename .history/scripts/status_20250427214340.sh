#!/bin/bash
set -e
NAMESPACE="image-classifier"

echo "🔍 Current pods:"
kubectl get pods -n "${NAMESPACE}"

echo "🔍 HPA status:"
kubectl get hpa -n "${NAMESPACE}"

echo "🔍 Services:"
kubectl get svc -n "${NAMESPACE}"
