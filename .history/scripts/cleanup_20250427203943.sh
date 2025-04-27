#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="image-classifier"
KUBE_DIR="kubernetes"
PROM_DIR="monitoring/prometheus"
GRAF_DIR="monitoring/grafana"

echo "🗑 Deleting Grafana"
kubectl delete -n "${NAMESPACE}" -f "${GRAF_DIR}/grafana-deployment.yaml"

echo "🗑 Deleting Prometheus"
kubectl delete -n "${NAMESPACE}" -f "${PROM_DIR}/prometheus-deployment.yaml"
kubectl delete -n "${NAMESPACE}" -f "${PROM_DIR}/prometheus-rbac.yaml"
kubectl delete -n "${NAMESPACE}" -f "${PROM_DIR}/prometheus-config.yaml"

echo "🗑 Deleting Image-Classifier App"
kubectl delete -n "${NAMESPACE}" -f "${KUBE_DIR}/ingress.yaml"
kubectl delete -n "${NAMESPACE}" -f "${KUBE_DIR}/hpa.yaml"
kubectl delete -n "${NAMESPACE}" -f "${KUBE_DIR}/service.yaml"
kubectl delete -n "${NAMESPACE}" -f "${KUBE_DIR}/deployment.yaml"
kubectl delete -n "${NAMESPACE}" -f "${KUBE_DIR}/configmap.yaml"

echo "🗑 Deleting namespace ${NAMESPACE}"
kubectl delete namespace "${NAMESPACE}" || true

echo "✅ Cleanup complete."
