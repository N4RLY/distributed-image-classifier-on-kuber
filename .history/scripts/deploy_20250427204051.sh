#!/usr/bin/env bash
set -euo pipefail

### ─── CONFIGURE THESE ─────────────────────────────────────────────────────────
# Docker image you want to build & (optionally) push
IMAGE_NAME="image-classifier:latest"
# Kubernetes namespace
NAMESPACE="image-classifier"
# Where your K8s YAML lives
KUBE_DIR="../kubernetes"
PROM_DIR="../monitoring/prometheus"
GRAF_DIR="../monitoring/grafana"
# If you have a private registry, add: docker build -t myregistry/$IMAGE_NAME . && docker push myregistry/$IMAGE_NAME
### ─────────────────────────────────────────────────────────────────────────────

echo "🛠  Building Docker image"
docker build -t ${IMAGE_NAME} .

echo "📦 Ensuring namespace exists: ${NAMESPACE}"
if ! kubectl get ns "${NAMESPACE}" &>/dev/null; then
  kubectl create namespace "${NAMESPACE}"
fi

echo "🚀 Deploying app resources"
kubectl apply -n "${NAMESPACE}" -f "${KUBE_DIR}/configmap.yaml"    # :contentReference[oaicite:0]{index=0}&#8203;:contentReference[oaicite:1]{index=1}
kubectl apply -n "${NAMESPACE}" -f "${KUBE_DIR}/deployment.yaml"   # :contentReference[oaicite:2]{index=2}&#8203;:contentReference[oaicite:3]{index=3}
kubectl apply -n "${NAMESPACE}" -f "${KUBE_DIR}/service.yaml"      # :contentReference[oaicite:4]{index=4}&#8203;:contentReference[oaicite:5]{index=5}
kubectl apply -n "${NAMESPACE}" -f "${KUBE_DIR}/ingress.yaml"      # :contentReference[oaicite:6]{index=6}&#8203;:contentReference[oaicite:7]{index=7}
kubectl apply -n "${NAMESPACE}" -f "${KUBE_DIR}/hpa.yaml"          # :contentReference[oaicite:8]{index=8}&#8203;:contentReference[oaicite:9]{index=9}

echo "📊 Deploying Prometheus"
kubectl apply -n "${NAMESPACE}" -f "${PROM_DIR}/prometheus-rbac.yaml"      # :contentReference[oaicite:10]{index=10}&#8203;:contentReference[oaicite:11]{index=11}
kubectl apply -n "${NAMESPACE}" -f "${PROM_DIR}/prometheus-config.yaml"    # :contentReference[oaicite:12]{index=12}&#8203;:contentReference[oaicite:13]{index=13}
kubectl apply -n "${NAMESPACE}" -f "${PROM_DIR}/prometheus-deployment.yaml" # :contentReference[oaicite:14]{index=14}&#8203;:contentReference[oaicite:15]{index=15}

echo "📈 Deploying Grafana"
# This single file bundles deployment + all ConfigMaps for dashboards & datasources
kubectl apply -n "${NAMESPACE}" -f "${GRAF_DIR}/grafana-deployment.yaml"    # :contentReference[oaicite:16]{index=16}&#8203;:contentReference[oaicite:17]{index=17}

echo "✅ All resources have been applied."
