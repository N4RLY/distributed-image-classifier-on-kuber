#!/bin/bash

# Stop script if error happens
set -e

# Variables
NAMESPACE="image-classifier"

echo "===== Cleaning up Image Classifier Deployment ====="

# First delete monitoring stack (Prometheus and Grafana)
echo "Deleting monitoring stack..."
kubectl delete -n "${NAMESPACE}" -f monitoring/prometheus/prometheus-deployment.yaml || true
kubectl delete -n "${NAMESPACE}" -f monitoring/prometheus/prometheus-rbac.yaml || true
kubectl delete -n "${NAMESPACE}" -f monitoring/prometheus/prometheus-config.yaml || true
kubectl delete -n "${NAMESPACE}" -f monitoring/grafana/grafana-deployment.yaml || true

# Now delete application resources
echo "Deleting application (API, service, ingress, HPA)..."
kubectl delete -n "${NAMESPACE}" -f kubernetes/ingress.yaml || true
kubectl delete -n "${NAMESPACE}" -f kubernetes/hpa.yaml || true
kubectl delete -n "${NAMESPACE}" -f kubernetes/service.yaml || true
kubectl delete -n "${NAMESPACE}" -f kubernetes/deployment.yaml || true
kubectl delete -n "${NAMESPACE}" -f kubernetes/configmap.yaml || true

# Finally delete namespace
echo "Deleting namespace: ${NAMESPACE}"
kubectl delete namespace "${NAMESPACE}" || true

echo "===== Cleanup Finished Successfully ====="
