# distributed-image-classifier-on-kuber


## Monitoring with Grafana

Grafana is used for visualizing metrics collected from the application via Prometheus.

### Deploy Grafana

```sh
kubectl apply -f monitoring/grafana/
```

### Access Grafana

- By default, Grafana is available at port 3000 in the `monitoring` namespace.
- To access locally:
  ```sh
  kubectl port-forward svc/grafana 3000:3000 -n monitoring
  ```

  Then open [http://localhost:3000](http://localhost:3000) in your browser.
- Default login: **admin / admin**

### Dashboards

- The dashboard "Image Classifier Dashboard" is loaded automatically.
- It shows request rates, latency, pod scaling, CPU/memory usage, and error rates.
