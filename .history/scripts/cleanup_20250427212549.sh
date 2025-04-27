#!/bin/bash

set -e

# Configuration
NAMESPACE="image-classifier"

echo "===== 🧹 Cleaning up Image Classifier Deployment ====="

# Delete monitoring stack first
echo "📉 Deleting monitoring stack (Prometheus + Grafana)..."
kubectl delete -n "${NAMESPACE}" -f monitoring/prometheus/prometheus-deployment.yaml || true
kubectl delete -n "${NAMESPACE}" -f monitoring/prometheus/prometheus-rbac.yaml || true
kubectl delete -n "${NAMESPACE}" -f monitoring/prometheus/prometheus-config.yaml || true
kubectl delete -n "${NAMESPACE}" -f monitoring/grafana/grafana-deployment.yaml || true

# Delete application resources
echo "🗑 Deleting application (API deployment, service, ingress, HPA)..."
kubectl delete -n "${NAMESPACE}" -f kubernetes/ingress.yaml || true
kubectl delete -n "${NAMESPACE}" -f kubernetes/hpa.yaml || true
kubectl delete -n "${NAMESPACE}" -f kubernetes/service.yaml || true
kubectl delete -n "${NAMESPACE}" -f kubernetes/deployment.yaml || true
kubectl delete -n "${NAMESPACE}" -f kubernetes/configmap.yaml || true

# Delete namespace
echo "🚪 Deleting namespace ${NAMESPACE}..."
kubectl delete namespace "${NAMESPACE}" || true

echo "===== ✅ Cleanup Completed Successfully ====="
