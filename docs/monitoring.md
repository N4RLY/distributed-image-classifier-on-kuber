
# Monitoring Overview

This document describes the monitoring setup for the distributed image classifier deployed on a Kubernetes cluster. It explains how Prometheus and Grafana are configured, which metrics are exposed, and how to access and interpret dashboards

---

## Components

### Prometheus
- **Purpose**: Collects metrics from the application and Kubernetes environment
- **Deployment**: `monitoring/prometheus/prometheus-deployment.yaml`
- **Service**: LoadBalancer on port `9090`
- **Scrape Interval**: 5 seconds
- **Scraped Targets**:
  - FastAPI app (`/metrics` on port `8001`)
  - Prometheus itself
  - Kubernetes cadvisor node metrics

### Grafana
- **Purpose**: Visualizes metrics from Prometheus in real-time dashboards
- **Deployment**: `monitoring/grafana/grafana-deployment.yaml`
- **Service**: LoadBalancer on port `3000`
- **Credentials**: `admin / admin`
- **Dashboards**: Auto-provisioned via `dashboards.yaml`
- **Datasource**: Prometheus (`http://prometheus:9090`)

---

## Key Metrics Monitored

| Metric Name                              | Description                                |
|-----------------------------------------|--------------------------------------------|
| `api_requests_total`                    | Number of API requests to `/classify`      |
| `api_request_latency_seconds_bucket`    | Histogram of request latency               |
| `model_inference_latency_seconds_bucket`| Histogram of inference latency             |
| `container_cpu_usage_seconds_total`     | CPU usage per container                    |
| `container_memory_usage_bytes`          | Memory usage per container                 |
| `container_network_receive_bytes_total` | Network ingress per container              |
| `container_network_transmit_bytes_total`| Network egress per container               |

---

## Accessing the Monitoring Dashboard

### Kubernetes
To access Prometheus and Grafana dashboards:

```bash
kubectl port-forward svc/prometheus 9090:9090
kubectl port-forward svc/grafana 3000:3000
```

### Web Access (Minikube LoadBalancer)
```bash
minikube service prometheus --url
minikube service grafana --url
```
Open the URL in your browser to access each dashboard.

---

## Viewing Dashboards

The Grafana dashboard includes panels for:

- **API Performance**
  - Request throughput (requests/sec)
  - Latency (p50, p95)

- **Model Inference**
  - Inference latency distribution
  - Inference duration heatmaps

- **Scaling Activity**
  - Number of running pods
  - HPA scaling behavior

- **Resource Utilization**
  - CPU and memory per pod
  - Network traffic by pod

---

## Troubleshooting

| Issue                                 | Solution                                  |
|--------------------------------------|-------------------------------------------|
| Metrics not showing in Grafana       | Check Prometheus targets & pod annotations|
| Grafana dashboard is empty           | Ensure dashboards are correctly mounted   |
| Prometheus shows scrape errors       | Verify `/metrics` endpoint is reachable   |
| CPU/Memory metrics missing           | Ensure metrics-server is enabled in Minikube |

---

## Configuration Details

### Prometheus
- Configured via `prometheus.yml` (mounted from ConfigMap)
- Uses static and Kubernetes service discovery
- Custom relabeling for pod and namespace labels

### Grafana
- Dashboards are auto-loaded from `grafana-dashboards` ConfigMap
- Datasources defined in `datasource.yaml`

---

## Example PromQL Queries

```promql
sum(rate(api_requests_total[1m])) by (endpoint)
histogram_quantile(0.95, rate(api_request_latency_seconds_bucket[5m]))
count(kube_pod_status_phase{phase="Running"})
sum(rate(container_cpu_usage_seconds_total[1m])) by (pod)
```

---

## Notes
- Dashboards refresh every 10 seconds
- All monitoring components run in the `image-classifier` namespace
- This setup is optimized for development via Minikube but can scale to production

