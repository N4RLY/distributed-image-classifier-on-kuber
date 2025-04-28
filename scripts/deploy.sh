#!/bin/bash

# Stop script if error happens
set -e

# Variables
NAMESPACE="image-classifier"
IMAGE_NAME="image-classifier"
TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"
TIMEOUT="180s"

echo "===== Deploying Image Classifier to Minikube ====="
echo "Namespace: ${NAMESPACE}"
echo "Image: ${FULL_IMAGE_NAME}"

# Connect Docker to Minikube
echo "Connecting to Minikube Docker..."
eval "$(minikube -p minikube docker-env)"

# Build Docker image
echo "Building Docker image..."
docker build -t "${FULL_IMAGE_NAME}" .

# Create namespace if it does not exist
if ! kubectl get namespace "${NAMESPACE}" &> /dev/null; then
    echo "Creating namespace: ${NAMESPACE}"
    kubectl create namespace "${NAMESPACE}"
fi

# Apply Kubernetes files
echo "Applying Kubernetes manifests..."

# Backup deployment.yaml file
cp kubernetes/deployment.yaml kubernetes/deployment.yaml.bak

# Change imagePullPolicy to Never for Minikube
sed -i.bak 's/imagePullPolicy: IfNotPresent/imagePullPolicy: Never/g' kubernetes/deployment.yaml


# Replace placeholder image name in deployment
sed -i.bak "s|\${DOCKER_REGISTRY:-localhost}/image-classifier:latest|$FULL_IMAGE_NAME|g" kubernetes/deployment.yaml


# Apply manifests one by one
kubectl apply -f kubernetes/configmap.yaml -n "${NAMESPACE}"
kubectl apply -f kubernetes/deployment.yaml -n "${NAMESPACE}"
kubectl apply -f kubernetes/service.yaml -n "${NAMESPACE}"
kubectl apply -f kubernetes/hpa.yaml -n "${NAMESPACE}"

# Restore original deployment.yaml
mv kubernetes/deployment.yaml.bak kubernetes/deployment.yaml

# Deploy Prometheus and Grafana
echo "Deploying monitoring stack..."
kubectl apply -f monitoring/prometheus/prometheus-rbac.yaml -n "${NAMESPACE}"
kubectl apply -f monitoring/prometheus/prometheus-config.yaml -n "${NAMESPACE}"
kubectl apply -f monitoring/prometheus/prometheus-deployment.yaml -n "${NAMESPACE}"
kubectl apply -f monitoring/grafana/grafana-deployment.yaml -n "${NAMESPACE}"

# Wait until deployment is ready
echo "Waiting for deployment to be ready..."
if ! kubectl rollout status deployment/image-classifier -n "${NAMESPACE}" --timeout="${TIMEOUT}"; then
    echo "Deployment failed. Checking pods:"
    kubectl get pods -n "${NAMESPACE}"
    exit 1
fi

echo "===== Deployment Finished Successfully ====="

# Show how to access services
echo ""
echo "You can open these services:"
echo "- API:        minikube service image-classifier -n ${NAMESPACE} --url"
echo "- Prometheus: minikube service prometheus -n ${NAMESPACE} --url"
echo "- Grafana:    minikube service grafana -n ${NAMESPACE} --url"

# Show pods
echo ""
echo "Current pods in namespace:"
kubectl get pods -n "${NAMESPACE}"
