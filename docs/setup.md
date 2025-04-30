# Setup Guide

This guide walks you through setting up and running the Distributed Image Classifier system locally using Minikube, as well as accessing monitoring tools and performing load testing.

---

## Prerequisites

- Docker
- kubectl
- bash
- Internet connection

---

## 1. Install Minikube

### macOS
```bash
brew install minikube
```

### Linux
```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```

### Windows
1. Download the installer: [Minikube Installer](https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe)  
2. Add `C:\minikube` to your PATH. You can do this via PowerShell:
```powershell
$oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
if ($oldPath.Split(';') -inotcontains 'C:\minikube') {
  [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine)
}
```

For other systems or architectures, see [Minikube Docs](https://minikube.sigs.k8s.io/docs/start/)

---

## 2. Start the Cluster

```bash
minikube start --cpus=4 --memory=4g --addons=metrics-server
minikube addons enable ingress
```

---

## 3. Deploy the System

Use the provided deployment script to set up all Kubernetes resources:
```bash
./scripts/deploy.sh
```

After deployment, three services will be available:

- **Image Classifier (API)**: Accepts image uploads and returns predictions
- **Prometheus**: Collects application metrics
- **Grafana**: Displays dashboards based on Prometheus metrics

### Get Service URLs
```bash
minikube service image-classifier -n image-classifier --url
minikube service prometheus -n image-classifier --url
minikube service grafana -n image-classifier --url
```

---

## 4. Load Testing

### Prepare Image
Copy a sample image to the load testing folder (if not present):
```bash
cp <your-image>.jpeg load-testing/test-images/images.jpeg
```

### Run Load Script
Use the IP and port from step 3:
```bash
./scripts/load.sh -h <HOST> -p <PORT>
```
Example:
```bash
./scripts/load.sh -h 192.168.49.2 -p 30717
```

This sends multiple POST requests to `/classify` to simulate load.

---

## 5. Monitoring with Grafana

1. Open Grafana URL from step 3
2. Login:
   - **Username**: `admin`
   - **Password**: `admin`
3. Open the side menu → Dashboards
4. Locate "Image Classifier Dashboard"
5. Visuals include:
   - API request rates
   - Inference latency (p50/p95)
   - CPU/memory usage
   - Scaling activity
   - Error rates

---

## 6. Cleaning Up Resources

To remove all deployed resources:
```bash
./scripts/cleanup.sh
```

To stop and delete the Minikube cluster:
```bash
minikube delete
```

---


