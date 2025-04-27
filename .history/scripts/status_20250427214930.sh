#!/bin/bash

# Stop script if error happens
set -e

# Variables
NAMESPACE="image-classifier"

echo "===== Showing Status of Image Classifier ====="

# Show pods
echo "Pods in namespace:"
kubectl get pods -n "${NAMESPACE}"

# Show HPA (Horizontal Pod Autoscaler) status
echo ""
echo "HPA (Horizontal Pod Autoscaler) status:"
kubectl get hpa -n "${NAMESPACE}"

# Show services
echo ""
echo "Services in namespace:"
kubectl get svc -n "${NAMESPACE}"
