# distributed-image-classifier-on-kuber


## Local Development Setup

### 1. Install Minikube

On Linux:
```sh
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```
On Mac:
```sh
brew install minikube
```
On Windows:
 1. Download and run the installer for the [latest release](https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe). 
2. Add the minikube.exe binary to your PATH. _(Make sure to run PowerShell as Administrator)_
```sh
$oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
if ($oldPath.Split(';') -inotcontains 'C:\minikube'){
  [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine)
}
```

For other architectures use [minikube documentation](https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download) 

### 2. Start a Minikube cluster and enable the ingress addon:
```sh 
minikube start --cpus=4 --memory=4g
minikube addons enable ingress
```
### 3. Run the deployment script 
```sh 
./scripts/deploy.sh 
```

After successful deployment, three services will be available. You can access them using the following commands:

API:      
```sh 
minikube service image-classifier -n image-classifier --url
```

Prometheus: 
```sh 
minikube service prometheus -n image-classifier --url
```

Grafana:    
```sh 
minikube service grafana -n image-classifier --url
```

### Load Testing the API

To simulate high load on the API using the provided script, follow these steps:

1. First, retrieve the API URL and port by running:

```sh 
minikube service image-classifier -n image-classifier --url
```

2. Copy the port from the _first line_ of output. It looks something like:

```sh 
http://192.168.49.2:30717
```

    Here, `192.168.49.2` is host and `30717` is the port to use.

3. Then, run the load testing script by specifying the port:

    ```bash
    ./scripts/load.sh -h <HOST> -p <PORT>
    ```

    **Example:**

    ```bash
    ./scripts/load.sh -h 192.168.49.2 -p 30717
    ```

The script will send multiple POST requests to the `/predict` endpoint, simulating concurrent users and allowing to observe system behavior and scaling in Grafana dashboards.


## Monitoring with Grafana

Grafana is used for visualizing metrics collected from the application via Prometheus.
