#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="image-classifier:latest"

echo "🔨 Building Docker image: ${IMAGE_NAME}"
docker build -t ${IMAGE_NAME} ..
echo "✅ Build complete."

# Optionally:
# docker tag ${IMAGE_NAME} your-dockerhub-username/image-classifier:latest
# docker push your-dockerhub-username/image-classifier:latest
