#!/bin/bash

set -e

# Configuration
NAMESPACE="image-classifier"
IMAGE_NAME="image-classifier"
TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"
TIMEOUT="180s"

echo "===== 🚀 Deploying Image Classifier to Minikube ====="
echo "Namespace: ${NAMESPACE}"
echo "Image: ${FULL_IMAGE_NAME}"

# Point shell to Minikube's Docker daemon
echo "🔧 Using Minikube's Docker daemon..."
eval "$(minikube -p minikube docker-env)"

# Build Docker image
echo "🏗 Building Docker image..."
docker build -t "${FULL_IMAGE_NAME}" .

# Create namespace if needed
if ! kubectl get namespace "${NAMESPACE}" &> /dev/null; then
    echo "📦 Creating namespace: ${NAMESPACE}"
    kubectl create namespace "${NAMESPACE}"
fi

# Apply Kubernetes manifests
echo "📜 Applying Kubernetes manifests..."

# Backup deployment.yaml manually first
cp kubernetes/deployment.yaml kubernetes/deployment.yaml.bak
sed -i '' 's/imagePullPolicy: IfNotPresent/imagePullPolicy: Never/g' kubernetes/deployment.yaml
sed -i '' "s|\${DOCKER_REGISTRY:-localhost}/image-classifier:latest|${FULL_IMAGE_NAME}|g" kubernetes/deployment.yaml


# Apply manifests
kubectl apply -f kubernetes/configmap.yaml -n "${NAMESPACE}"
kubectl apply -f kubernetes/deployment.yaml -n "${NAMESPACE}"
kubectl apply -f kubernetes/service.yaml -n "${NAMESPACE}"
kubectl apply -f kubernetes/ingress.yaml -n "${NAMESPACE}"
kubectl apply -f kubernetes/hpa.yaml -n "${NAMESPACE}"

# Restore original deployment.yaml
mv kubernetes/deployment.yaml.bak kubernetes/deployment.yaml

# Deploy monitoring stack
echo "📈 Deploying monitoring stack..."
kubectl apply -f monitoring/prometheus/prometheus-rbac.yaml -n "${NAMESPACE}"
kubectl apply -f monitoring/prometheus/prometheus-config.yaml -n "${NAMESPACE}"
kubectl apply -f monitoring/prometheus/prometheus-deployment.yaml -n "${NAMESPACE}"
kubectl apply -f monitoring/grafana/grafana-deployment.yaml -n "${NAMESPACE}"

# Wait for application deployment to finish
echo "⏳ Waiting for application to be ready (timeout: ${TIMEOUT})..."
if ! kubectl rollout status deployment/image-classifier -n "${NAMESPACE}" --timeout="${TIMEOUT}"; then
    echo "❌ Deployment did not complete in time. Checking pods:"
    kubectl get pods -n "${NAMESPACE}"
    exit 1
fi

echo "===== ✅ Deployment Completed Successfully ====="

echo -e "\n🌐 Access services using:"
echo "- API:        minikube service image-classifier -n ${NAMESPACE} --url"
echo "- Prometheus: minikube service prometheus -n ${NAMESPACE} --url"
echo "- Grafana:    minikube service grafana -n ${NAMESPACE} --url"

if ! pgrep -f "minikube tunnel" > /dev/null; then
    echo -e "\n💡 Tip: To expose LoadBalancer services and Ingress externally, run 'minikube tunnel' in a separate terminal."
fi

# Pods status
echo -e "\n📋 Pods status:"
kubectl get pods -n "${NAMESPACE}"
